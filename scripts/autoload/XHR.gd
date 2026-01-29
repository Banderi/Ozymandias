extends Node
# ANTIMONY 'XHR' by Banderi --- v1.1

func throw(err):
	Log.error(self, err, "XHR request fail.")
	return null
func construct_url_from_bag(url_bag): # this ASSUMES the bag is VALID!
	if url_bag.size() == 0:
		return ""
	var url = url_bag[0]
	
	# construct and append query string
	var query_string = ""
	var query_article = "?"
	for q in range(1,url_bag.size()):
		var query_bag = url_bag[q]
		
		# single string
		if query_bag is String && query_bag != "":
			query_string += str(query_article,query_bag.http_escape())
			query_article = "&"
		
		# dictionary of items
		elif query_bag is Dictionary && query_bag.size() != 0:
			for param in query_bag:
				query_string += str(query_article,param,"=",str(query_bag[param]).http_escape())
				query_article = "&"
		
	return url + query_string

# for NOW we create a new HTTPRequest object for every single request
# TODO: reuse previous ones instead
func REQUEST(uri : String, custom_headers : PoolStringArray, ssl : bool, method, payload, download_path):
	var xhr = XHRHandler.new()
	add_child(xhr)
	xhr.uri = uri
	xhr.use_threads = true
	xhr.set_download_file(download_path)
	var err = xhr.request(uri, custom_headers, ssl, method, payload)
	if err != OK:
		xhr.queue_free()
		return throw(err)
	return xhr

func GET(url_bag, ssl = true, custom_headers = []):
	return REQUEST(construct_url_from_bag(url_bag), custom_headers, ssl, HTTPClient.METHOD_GET, "", "")
func POST(url_bag, payload = "", ssl = true, custom_headers = []):
	return REQUEST(construct_url_from_bag(url_bag), custom_headers, ssl, HTTPClient.METHOD_POST, payload, "")
func DOWNLOAD(url_bag, download_path, ssl = true, custom_headers = []):
	return REQUEST(construct_url_from_bag(url_bag), custom_headers, ssl, HTTPClient.METHOD_GET, "", download_path)

func ENET(ip : String, port : int, data):
	get_tree().network_peer = null
	var enet_peer = NetworkedMultiplayerENet.new()
	var err = enet_peer.create_client(ip, port)
	if err != OK:
		return throw(err)
	get_tree().network_peer = enet_peer # this is needed to actually make the peer run by the Godot system!
	yield(get_tree(),"idle_frame")
	return enet_peer

func TCP(ip : String, port : int, data):
	var tcp = TCPHandler.new()
	add_child(tcp)
	tcp.push_data(data)
	var err = tcp.peer.connect_to_host(ip, port)
	if err != OK:
		tcp.queue_free()
		return throw(err)
	return tcp
