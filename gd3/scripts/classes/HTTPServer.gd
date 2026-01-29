extends Node
class_name HTTPServer
# ANTIMONY 'HTTPServer' by Banderi --- v1.0

onready var TCP_SERVER : TCP_Server = TCP_Server.new()
var SERVER_PORT = null
export var USE_HTTPS : bool = false
export var VERBOSE : bool = true
var SERVER_KEY : CryptoKey = null
var SERVER_CERT : X509Certificate = null

var LOG = []
func host_address(data_peer):
	if data_peer is StreamPeerTCP:
		return data_peer.get_connected_host()
	elif data_peer is StreamPeerSSL:
		for tcp_stream in TCP_STREAMS:
			if TCP_STREAMS[tcp_stream] == data_peer:
				return tcp_stream.get_connected_host()
	return "???"
func is_peer_connected(data_peer):
	if data_peer is StreamPeerTCP:
		return data_peer.is_connected_to_host()
	elif data_peer is StreamPeerSSL:
		for tcp_stream in TCP_STREAMS:
			if TCP_STREAMS[tcp_stream] == data_peer:
				return tcp_stream.is_connected_to_host()
	return false

func start(port : int, ssl_key : CryptoKey = null, ssl_cert : X509Certificate = null):
	# load key/cert pair for HTTPS
	if USE_HTTPS:
		SERVER_KEY = ssl_key
		SERVER_CERT = ssl_cert
		
		# validate TLS data
		if SERVER_KEY == null || SERVER_CERT == null:
			Log.error(self, GlobalScope.Error.ERR_INVALID_PARAMETER, "both a valid key and a certificate are required for HTTPS.")
			return false
		if SERVER_KEY.is_public_only():
			Log.error(self, GlobalScope.Error.ERR_INVALID_DATA, "supplied TLS data contains no private key.")
			return false
		Log.generic(self, "Loaded SSL key and certificate.");
	
	# init server
	SERVER_PORT = port
	TCP_SERVER = TCP_Server.new()
	var r = TCP_SERVER.listen(SERVER_PORT)
	if r != OK:
		Log.error(self, r, "could not start HTTP server!")
		return false
	Log.generic(self, "Listening on port " + str(SERVER_PORT));
	return true
func stop():
	TCP_SERVER.stop()

var TCP_STREAMS = {}
func destroy_stream(stream_peer):
	if stream_peer is StreamPeerSSL:
		for tcp_stream in TCP_STREAMS:
			if TCP_STREAMS[tcp_stream] == stream_peer:
				return destroy_stream(tcp_stream)
	elif stream_peer in TCP_STREAMS:
		var ssl_peer = TCP_STREAMS[stream_peer]
		if ssl_peer != null:
			ssl_peer.disconnect_from_stream()
		else:
			stream_peer.disconnect_from_host()
		TCP_STREAMS.erase(stream_peer)
		return true
	return false
func accept_tcp_stream(tcp_stream : StreamPeerTCP):
	if tcp_stream in TCP_STREAMS:
		return false
	
	if USE_HTTPS:
		var ssl_peer = StreamPeerSSL.new()
		ssl_peer.blocking_handshake = false # ???
		var r = ssl_peer.accept_stream(tcp_stream, SERVER_KEY, SERVER_CERT) # -30976 (-0x7900) = ?????									(not an HTTPS request)
		if r != OK:															# -30592 (-0x7780) = MBEDTLS_ERR_SSL_FATAL_ALERT_MESSAGE	(cert chain invalid)
			Log.error(self, r, "attempted TLS connection but failed.")		# -27648 (-0x6C00) = MBEDTLS_ERR_SSL_INTERNAL_ERROR			(attempted to invoke twice)
			ssl_peer.disconnect_from_stream()
			TCP_STREAMS[tcp_stream] = null
			return false
		else:
			Log.generic(self, "TLS stream accepted.")
			TCP_STREAMS[tcp_stream] = ssl_peer
			return true
	else:
		if tcp_stream.get_status() != StreamPeerTCP.STATUS_CONNECTED:
			Log.error(self, GlobalScope.Error.ERR_CONNECTION_ERROR, "attempted TLS connection but failed.")
			return false
		TCP_STREAMS[tcp_stream] = null
		return true

func get_incoming_tcp_data(data_peer, printerrors = true): # this DOES NOT SUPPORT TLS.
	var data = PoolByteArray([])
	while true:
		# check if connected
		if !is_peer_connected(data_peer):
			if printerrors:
				Log.error(self, GlobalScope.Error.ERR_CONNECTION_ERROR, str(host_address(data_peer)," suddenly dropped during exchange."))
			return null
		
		# get incoming bytes
		var bytes_incoming = data_peer.get_available_bytes()
		if bytes_incoming == 0:
			break # end of data stream
		else:
			var _data = data_peer.get_data(bytes_incoming)
			if _data[0] != OK:
				if printerrors:
					Log.error(self, GlobalScope.Error.ERR_CONNECTION_ERROR, "failure receiving incoming data! (%s)" % [_data[0]])
				return null
			data.append_array(_data[1])
	if data.empty():
		return null
	else:
		return data
func parse_http_data(data : PoolByteArray, printerrors = true):
	var content_string = data.get_string_from_utf8()
	var content_parts = content_string.split("\r\n")
	if content_parts.empty():
		if printerrors:
			Log.error(self, GlobalScope.Error.ERR_PARSE_ERROR, "no valid CRLF-terminated lines found.")
		return null

	# read HTTP request-line
	var request_line = content_parts[0]
	var request_line_parts = request_line.split(" ")
	if request_line_parts.size() != 3:
		if printerrors:
			Log.error(self, GlobalScope.Error.ERR_PARSE_ERROR, "request-line is malformed / missing required fields.")
		return null
	var method = request_line_parts[0]
	var full_url = request_line_parts[1]
	var protocol_version = request_line_parts[2]

	# read HTTP headers
	var headers_endl = content_parts.find("") # the headers block is split from the HTTP body with a double CRLF
	if headers_endl == -1:
		if printerrors:
			Log.error(self, GlobalScope.Error.ERR_PARSE_ERROR, "end of headers block not found.")
		return null
	var headers = {}
	for i in range(1, headers_endl):
		var header_parts = content_parts[i].split(":", true, 1)
		var header = header_parts[0].strip_edges().to_lower()
		var value = header_parts[1].strip_edges()
		headers[header] = value

	# read HTTP body
	var body = ""
	if headers_endl != content_parts.size() - 1:
		var body_parts = Array(content_parts).slice(headers_endl + 1, content_parts.size())
		body = PoolStringArray(body_parts).join("\r\n")
	
	# parse endpoint from url
	var url = full_url.lstrip("\/")
	var url_string = url.split("?")
	var endpoint = url_string[0]
	
	# parse query parameters from url
	var query_params = {}
	if url_string.size() > 1:
		var query_string = url_string[1].split("&")
		for param in query_string:
			var pair = Array(param.split("="))
			if pair.size() > 1:
				match pair[1].to_lower():
					"false": query_params[pair[0]] = false
					"true": query_params[pair[0]] = true
					_: query_params[pair[0]] = pair[1]
			else:
				query_params[pair[0]] = true
	return {
		"method": method,
		"url": full_url,
		"endpoint": endpoint,
		"query_params": query_params,
		"protocol": protocol_version,
		"headers": headers,
		"body": body
	}
func _process(_delta):
	if TCP_SERVER.is_listening():
		for tcp_stream in TCP_STREAMS:
			var ssl_peer = TCP_STREAMS[tcp_stream]
			if ssl_peer != null:
				match ssl_peer.get_status():
					StreamPeerSSL.STATUS_ERROR:
						Log.error(self, GlobalScope.Error.ERR_CONNECTION_ERROR, "the connection failed!")
						destroy_stream(tcp_stream)
					StreamPeerSSL.STATUS_ERROR_HOSTNAME_MISMATCH:
						Log.error(self, GlobalScope.Error.ERR_CONNECTION_ERROR, "the host did not match.")
						destroy_stream(tcp_stream)
					StreamPeerSSL.STATUS_DISCONNECTED:
						Log.generic(self, str(host_address(ssl_peer),": the client disconnected."))
						destroy_stream(tcp_stream)
					StreamPeerSSL.STATUS_HANDSHAKING:
						Log.generic(self, "TLS Handshaking...")
						ssl_peer.poll()
					StreamPeerSSL.STATUS_CONNECTED:
						ssl_peer.poll()
						
						var tcp_data = get_incoming_tcp_data(ssl_peer, VERBOSE)
						if tcp_data != null:
							
							# attempt to parse HTTPS
							var http_data = parse_http_data(tcp_data, VERBOSE)
							if http_data != null: # valid HTTP request
								Log.generic(self, str(host_address(ssl_peer),": HTTPS <%s> request" % [http_data.method]))
								http_data["data_peer"] = ssl_peer
								emit_signal("http_request", http_data)
							else: # raw TCP stream
								Log.generic(self, str(host_address(ssl_peer),": TCP (SSL) data <%d bytes>" % [tcp_data.size()]))
								emit_signal("unhandled_tcp_request", {
									"data": tcp_data,
									"data_peer": ssl_peer
								})
			else:
				match tcp_stream.get_status():
					StreamPeerTCP.STATUS_ERROR:
						Log.error(self, GlobalScope.Error.ERR_CONNECTION_ERROR, "the connection failed!")
						destroy_stream(tcp_stream)
					StreamPeerTCP.STATUS_NONE:
						Log.generic(self, str(host_address(tcp_stream),": the client disconnected."))
						destroy_stream(tcp_stream)
					StreamPeerTCP.STATUS_CONNECTING:
						Log.generic(self, "Connecting...")
					StreamPeerTCP.STATUS_CONNECTED:
						
						var tcp_data = get_incoming_tcp_data(tcp_stream, VERBOSE)
						if tcp_data != null:
					
							# attempt to parse HTTP
							var http_data = parse_http_data(tcp_data, VERBOSE)
							if http_data != null: # valid HTTP request
								Log.generic(self, str(host_address(tcp_stream),": HTTP <%s> request" % [http_data.method]))
								http_data["data_peer"] = tcp_stream
								emit_signal("http_request", http_data)
							else: # raw TCP stream
								Log.generic(self, str(host_address(tcp_stream),": TCP data <%d bytes>" % [tcp_data.size()]))
								emit_signal("unhandled_tcp_request", {
									"data": tcp_data,
									"data_peer": tcp_stream
								})
		
		if TCP_SERVER.is_connection_available():
			var tcp_stream = TCP_SERVER.take_connection() as StreamPeerTCP
			if tcp_stream != null:
				if !accept_tcp_stream(tcp_stream):
					pass # error!!

signal http_request(request)
signal unhandled_tcp_request(request)

func respond_http(data_peer, response_body, response_code : int = 200, err_message : String = "", content_type : String = "text/plain"):
	if VERBOSE:
		Log.generic(self,"Responding to %s with: %s" % [host_address(data_peer),response_body])
	var status_line = "HTTP/1.1 %d %s\r\n" % [response_code, err_message]
	var header = "Content-Type: " + content_type + "\r\n"
	var body = response_body
	var http_response_string = PoolStringArray([status_line,header,"\r\n",body]).join("")
	data_peer.put_data(http_response_string.to_utf8())
	destroy_stream(data_peer)
func respond_tcp(data_peer, response_data):
	if VERBOSE:
		Log.generic(self,"Responding to %s with: %s" % [host_address(data_peer),response_data])
	data_peer.put_utf8_string(response_data)
	destroy_stream(data_peer)
