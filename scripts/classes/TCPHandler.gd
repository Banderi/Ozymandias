extends Node
class_name TCPHandler

onready var peer = StreamPeerTCP.new()
func get_host_uri():
	return str(peer.get_connected_host(),":",peer.get_connected_port())

signal finished
signal received(data)
func _finished():
	Log.generic(XHR,"<%s> The TCP stream from %s was closed." % [name,get_host_uri()])
	emit_signal("finished")
	queue_free()
func _received(data : PoolByteArray):
	Log.generic(XHR,"<%s> %s responded with %d bytes" % [name,get_host_uri(),data.size()])
	if !data.empty():
		var data_str = data.get_string_from_utf8().split("\n",false)
		var json_data = parse_json(data_str[data_str.size()-1])
		if json_data != null:
			if json_data.get("method","") == "Log":
				print("		JSON-RPC LOG: \"",json_data.params.message,"\"")
			else:
				emit_signal("received_jsonrpc", json_data)
	emit_signal("received", data)

var data_to_send = []
func put_utf8_data(data):
	var string_formatted = ""
	if data is String:
		string_formatted = data + "\n"
	else:
		string_formatted = JSON.print(data) + "\n"
	Log.generic(XHR,"<%s> Sending %d bytes to %s" % [name,string_formatted.length(),get_host_uri()])
	peer.put_data(string_formatted.to_utf8())
func push_data(data):
	if data != null:
		data_to_send.push_back(data)
	return self
func get_incoming_data():
	var bytes_incoming = peer.get_available_bytes()
	if bytes_incoming > 0:
		print("Incoming TCP: %d bytes..." % [bytes_incoming])
		var r = peer.get_data(bytes_incoming)
		if r[0] != OK: # <-- r_code
			Log.generic(XHR,"<%s> %s attempted to respond, but the stream failed." % [name,get_host_uri()])
		else:
			return r[1] # <-- PoolByteArray

signal received_jsonrpc
onready var rpc_handler = JSONRPC.new()
func get_jsonrpc_id():
	return 1251365
func push_jsonrpc(request, params):
	var request_str = rpc_handler.make_request(request, params, get_jsonrpc_id())
	return push_data(request_str)

var t = 0
func _process(delta):
	t += delta
	var status = peer.get_status()
	match status:
		peer.STATUS_CONNECTING:
			pass
		peer.STATUS_NONE:
			_finished()
		peer.STATUS_ERROR:
			_finished()
		peer.STATUS_CONNECTED:
			if !data_to_send.empty():
				var data = data_to_send[0]
				if data != null:
					put_utf8_data(data)
				data_to_send.pop_front()
			var incoming = get_incoming_data()
			if incoming != null:
				_received(incoming)
