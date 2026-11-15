# [license]
# 3-Clause BSD NON-AI License
# 
# Copyright 2026 __hev (Benjamin Buckhurst)
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.
# 
# 4. The source code and the binary form, and any modifications made to them may not be used for the purpose of input data, reference code snippets and/or files, OR used in the training of, or improvement of machine learning algorithms,
# including but not limited to artificial intelligence, natural language processing, or data mining. This condition applies to any derivatives,
# modifications, or updates based on the Software code. Any usage of the source code or the binary form may not be present in any form as data fed, inputted, or provided to an AI, or present in any AI-training dataset is considered a breach of this License.
# 
# 5. Any projects deriving work from this project MUST include a copy of this license and all other license and/or copyright agreements posed within other source material,
# all of which must be followed to its entirety. Failure to follow these licenses prohibit all modification and redistribution of the material until all licensing has been reinstated.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# [/license]

extends Reference

enum {
	ERR_SSL_HANDSHAKE_ERROR = 49,
	ERR_NO_RESPONSE,
	ERR_REDIRECT_LIMIT_REACHED,
	ERR_CHUNKED_BODY_SIZE_MISMATCH
	ERR_BODY_SIZE_LIMIT_EXCEEDED
}

class NetHandlerClient:
	signal connected()
	signal disconnected()
	signal request_completed(response)
	signal response_stream(response, chunk)
	
	var net_connection:HTTPConnection = null
	
	var http:HTTPClient = HTTPClient.new()
	var https:String = ""
	var requesting: bool = false
	
	var idle_timeout:int = 10000 setget set_idle_timeout, get_idle_timeout
	var max_redirects:int = 8 setget set_max_redirects, get_max_redirects
	var body_size_limit:int = -1 setget set_body_size_limit, get_body_size_limit
	var stream:bool = false setget enable_stream, is_stream_enabled
	var keep_alive:bool = false
	
	var pointers:HevLibPointers
	
	func _init(p:HevLibPointers) -> void:
		pointers = p
		http.blocking_mode_enabled = true
		net_connection = HTTPConnection.new(http,p)
		net_connection.connect("connected",self,"_on_connected")
		net_connection.connect("disconnected",self,"_on_disconnected")
		net_connection.connect("response_stream",self,"_on_response_stream")
	
	func has_connection() -> bool:
		return net_connection.has_connection()
	
	func request_async(url:String,headers:Dictionary = {},validate_ssl:bool = true,method:int = HTTPClient.METHOD_GET,body:PoolByteArray = []) -> HTTPResponse:
		if not requesting:
			net_connection.url = pointers.Networking.__parse_url(url)
			net_connection.set_request({
				method = method,
				headers = _dict_headers2array(headers),
				body = body,
			})
			net_connection.verify_host = validate_ssl
		else:
			printerr("Already performing an HTTP request")
			return null
		requesting = true
		reference()
		if not has_connection():
			net_connection.start()
		var response:HTTPResponse = yield(net_connection,"request_completed")
		unreference()
		requesting = false
		
		if not keep_alive:
			net_connection.close()
		
		emit_signal("request_completed", response)
		
		return response
	
	func set_idle_timeout(value:int) -> void:
		if requesting:
			printerr("Cannot set [idle_timeout] while requesting")
		else:
			net_connection.idle_timeout = value
	
	func set_max_redirects(value:int) -> void:
		if requesting:
			printerr("Cannot set [max_redirects] while requesting")
		else:
			net_connection.max_redirects = value
	
	func set_body_size_limit(value:int) -> void:
		if requesting:
			printerr("Cannot set [body_size_limit] while requesting")
		else:
			net_connection.body_size_limit = value
	
	func enable_stream(value:bool) -> void:
		if requesting:
			printerr("Cannot set [stream] while requesting")
		else:
			net_connection.stream = value
	
	func get_idle_timeout() -> int:
		return net_connection.idle_timeout
	
	func get_max_redirects() -> int:
		return net_connection.max_redirects
	
	func get_body_size_limit() -> int:
		return net_connection.body_size_limit
	
	func is_stream_enabled() -> bool:
		return net_connection.stream
	
	func close() -> void:
		net_connection.close()
	
	func _on_connected() -> void:
		emit_signal("connected")
	
	func _on_disconnected() -> void:
		emit_signal("disconnected")
	
	func _on_response_stream(response:HTTPResponse,chunk:PoolByteArray) -> void:
		call_deferred("emit_signal","response_stream",response,chunk)
	
	func _notification(what:int) -> void:
		match what:
			NOTIFICATION_PREDELETE:
				net_connection.close()
				net_connection.call_deferred("free")

	static func _dict_headers2array(headers:Dictionary) -> PoolStringArray:
		var array:PoolStringArray = PoolStringArray()
		for header in headers:
			array.append(header + ": " + headers[header])
		return array

class HTTPConnection extends Object:
	signal connected()
	signal disconnected()
	signal request_completed(response)
	signal response_stream(response, chunk)
	
	var thread:Thread = Thread.new()
	var mutex:Mutex = Mutex.new()
	var request_data:Dictionary = {} setget set_request
	var request_sent:bool = false
	var response_obtained:bool = false
	var do_reset_response:bool = false
	var skip_body:bool = false
	var has_responded:bool = false
	var response_len:int = 0
	var current_redirections:int = 0
	var next_timeout:int = 0
	
	var http:HTTPClient = null
	var url:Dictionary = {} setget set_url
	var connected:bool = false
	
	var verify_host:bool = false
	var idle_timeout:int = 0
	var max_redirects:int = 0
	var body_size_limit:int = 0
	var stream:bool = false
	
	var pointers:HevLibPointers
	
	func _init(client:HTTPClient,p:HevLibPointers) -> void:
		pointers = p
		http = client
	
	func has_connection() -> bool:
		return http.get_status() != HTTPClient.STATUS_DISCONNECTED
	
	func get_request() -> Dictionary:
		mutex.lock()
		var request:Dictionary = request_data
		mutex.unlock()
		return request
	
	func get_url() -> Dictionary:
		mutex.lock()
		var new_url:Dictionary = url
		mutex.unlock()
		return new_url
	
	func set_request(data:Dictionary) -> void:
		mutex.lock()
		request_data = data
		mutex.unlock()
	
	static func must_reconnect(old:Dictionary,new:Dictionary) -> bool:
		return (old.empty() or new.empty()) or not old.host.empty() and (old.host != new.host or old.use_ssl != new.use_ssl) or old.port != new.port
	
	func set_url(new_url:Dictionary) -> void:
		mutex.lock()
		var reconnect:bool = must_reconnect(url, new_url)
		url = new_url
		mutex.unlock()
		
		if connected and reconnect:
			_connect(url)
	
	func start() -> void:
		thread.start(self, "_execute")
	
	func close() -> void:
		url.clear()
		http.close()
		if thread.is_active():
			thread.wait_to_finish()
			thread = Thread.new()
		if connected:
			connected = false
			call_deferred("emit_signal", "disconnected")
	
	func _return_response(response:HTTPResponse) -> void:
		has_responded = true
		do_reset_response = true
		request_sent = false
		response_obtained = false
		response_len = 0
		current_redirections = 0
		
		mutex.lock()
		request_data.clear()
		mutex.unlock()
		
		if response.body:
			var compressed:PoolByteArray = response.body
			var mode:int = -1
			var buffer_size:int = 0
			var encoding:String = ""
			for header in response.headers:
				if header.to_lower() == "content-encoding":
					encoding = response.headers[header]
					break
			match encoding:
				"gzip", "x-gzip":
					mode = File.COMPRESSION_GZIP
					buffer_size = (compressed[-1] << 24 | compressed[-2] << 16 | compressed[-3] << 8 | compressed[-4])
			if mode > 0:
				response.body = compressed.decompress(buffer_size, mode)
		
		call_deferred("emit_signal", "request_completed", response)
	
	func _stream_chunk(response:HTTPResponse,chunk:PoolByteArray) -> void:
		call_deferred("emit_signal","response_stream",response,chunk)
	
	func _execute(_data = null) -> void:
		var response:HTTPResponse = HTTPResponse.new()
		var error:int = _connect(url)
		if error != OK:
			response.error = error
			_return_response(response)
			return
		_connection_loop(response)
		
		if has_connection():
			call_deferred("close")
	
	func _connect(url:Dictionary) -> int:
		return http.connect_to_host(url.host,url.port,url.use_ssl,verify_host)
	
	func _connection_loop(response:HTTPResponse) -> void:
		while _handle_status(http.get_status(), response):
			if do_reset_response:
				response = HTTPResponse.new()
				do_reset_response = false
			OS.delay_msec(1)
	
	func _handle_status(status:int,response:HTTPResponse) -> bool:
		var resume:bool = true
		match status:
			HTTPClient.STATUS_DISCONNECTED,HTTPClient.STATUS_CANT_CONNECT:
				response.error = ERR_CANT_CONNECT
				resume = false
			HTTPClient.STATUS_CANT_RESOLVE:
				response.error = ERR_CANT_RESOLVE
				resume = false
			HTTPClient.STATUS_CONNECTION_ERROR:
				response.error = ERR_CONNECTION_ERROR
				resume = false
			HTTPClient.STATUS_SSL_HANDSHAKE_ERROR:
				response.error = ERR_SSL_HANDSHAKE_ERROR
				resume = false
			HTTPClient.STATUS_CONNECTING,HTTPClient.STATUS_RESOLVING,HTTPClient.STATUS_CONNECTED,HTTPClient.STATUS_REQUESTING,HTTPClient.STATUS_BODY:
				http.poll()
				continue
			HTTPClient.STATUS_CONNECTED:
				if not connected:
					set_deferred("connected", true)
					call_deferred("emit_signal", "connected")
				skip_body = false
				
				if not next_timeout:
					next_timeout = OS.get_ticks_msec() + idle_timeout
				
				if request_sent:
					next_timeout = 0
					if not response_obtained:
						response.error = _handle_response(response)
					
					if http.get_response_body_length() < 0:
						_return_response(response)
					else:
						response.error = ERR_CHUNKED_BODY_SIZE_MISMATCH
						_return_response(response)
					
				elif request_data:
					next_timeout = 0
					http.request_raw(request_data.method,url.path,request_data.headers,request_data.body)
					request_sent = true
					has_responded = false
				
				resume = not (idle_timeout * next_timeout > 0 and next_timeout <= OS.get_ticks_msec())
			HTTPClient.STATUS_BODY:
				if not response_obtained:
					response.error = _handle_response(response)
				response.error = _handle_body(response)
		
		if not (resume or has_responded):
			_return_response(response)
		
		return resume
	
	func _handle_response(response:HTTPResponse) -> int:
		if not http.has_response():
			skip_body = true
			_return_response(response)
			return ERR_NO_RESPONSE
		
		response_obtained = true
		response.code = http.get_response_code()
		response.headers = http.get_response_headers_as_dictionary()
		
		match response.code:
			HTTPClient.RESPONSE_MOVED_PERMANENTLY, HTTPClient.RESPONSE_FOUND:
				return _handle_redirect(response)
		
		return response.error
	
	func _handle_body(response:HTTPResponse) -> int:
		if http.get_status() != HTTPClient.STATUS_BODY:
			return response.error
		
		var body_length:int = http.get_response_body_length()
		var chunk:PoolByteArray = http.read_response_body_chunk()
		
		if skip_body:
			return response.error
		
		var chunk_size:int = chunk.size()
		if chunk_size > 0:
			response_len += chunk_size
			if stream:
				_stream_chunk(response, chunk)
			else:
				response._append_chunk(chunk)
		
		if not http.is_response_chunked() and body_length == 0:
			_return_response(response)
		if body_size_limit > -1 and body_length > body_size_limit:
			_return_response(response)
			return ERR_BODY_SIZE_LIMIT_EXCEEDED
		
		if body_size_limit > -1 and response_len > body_size_limit:
			_return_response(response)
			return ERR_BODY_SIZE_LIMIT_EXCEEDED
		
		if body_length > -1 and response_len == body_length:
			_return_response(response)
		return response.error
	
	func _handle_redirect(response:HTTPResponse) -> int:
		if max_redirects > -1 and current_redirections >= max_redirects:
			skip_body = true
			_return_response(response)
			return ERR_REDIRECT_LIMIT_REACHED
		
		var redirect_url:String = response.get_header("Location")
		if redirect_url.empty():
			return OK
		
		url = pointers.Networking.__parse_url(redirect_url)
		request_data.path = url.path
		
		
		skip_body = true
		request_sent = false
		current_redirections += 1
		return OK

class HTTPResponse:
	const RESPONSE_SUCCESS_MAX:int = 299
	
	var error:int = 0
	var code:int = 0
	var headers:Dictionary = {}
	var body:PoolByteArray = PoolByteArray()
	
	func _init(err:int = 0,cde:int = 0,header_data: Dictionary = {},body_array:PoolByteArray = PoolByteArray()) -> void:
		error = err
		code = cde
		headers = header_data
		body = body_array
	
	func successful() -> bool:
		return error == OK and code >= HTTPClient.RESPONSE_OK and code <= RESPONSE_SUCCESS_MAX
	
	func has_header(name:String) -> bool:
		return name in headers
	
	func get_header(name:String) -> String:
		return headers.get(name,"")
	
	func _append_chunk(chunk:PoolByteArray) -> void:
		body.append_array(chunk)

class HTTPConnectionPool:
	signal request_completed(response, client)
	
	const DEFAULT_MIN:int = 1
	const DEFAULT_MAX:int = IP.RESOLVER_MAX_QUERIES
	
	var clients:Array = []
	
	var active:int = 0
	
	var max_clients:int = DEFAULT_MIN
	var min_clients:int = DEFAULT_MAX
	
	var idle_timeout:int = 10000 setget set_idle_timeout
	
	var pointers:HevLibPointers
	
	func _init(minClients:int = DEFAULT_MIN,maxClients:int = DEFAULT_MAX,idleTimeout:int = 10000,p:HevLibPointers = null) -> void:
		pointers = p
		min_clients = minClients
		max_clients = maxClients
		idle_timeout = idleTimeout
		for i in min_clients:
			create_client()
	
	func request_async(url:String,headers:Dictionary = {},validate_ssl:bool = true,method:int = HTTPClient.METHOD_GET,body:PoolByteArray = PoolByteArray()) -> HTTPResponse:
		var client:NetHandlerClient
		var state = _find_client()
		if state is GDScriptFunctionState:
			client = yield(state, "completed")
		else:
			client = state
		active += 1
		reference()
		state = client.request_async(url, headers, validate_ssl, method, body)
		var response:HTTPResponse = yield(state, "completed")
		emit_signal("request_completed",response,client)
		unreference()
		active -= 1
		return response
	
	func set_idle_timeout(value:int) -> void:
		idle_timeout = int(max(0,value))
		var total_clients:int = clients.size()
		if total_clients < min_clients:
			return
		
		for i in range(min_clients, total_clients):
			var client:NetHandlerClient = clients[i]
			client.idle_timeout = idle_timeout
	
	func _find_client() -> NetHandlerClient:
		var client:NetHandlerClient = null
		var total_clients:int = clients.size()
		
		if active == max_clients:
			while not client or client.requesting:
				client = yield(self, "request_completed")[1]
		
		if not client and active == total_clients and total_clients < max_clients:
			create_client()
			client = clients[-1]
		
		if not client:
			for subclient in clients:
				if not subclient.requesting:
					client = subclient
		return client
	
	func create_client() -> void:
		var client:NetHandlerClient = NetHandlerClient.new(pointers)
		client.keep_alive = true
		if clients.size() >= min_clients:
			client.idle_timeout = idle_timeout
			client.connect("disconnected",self,"_on_client_disonnected",[client])
		clients.append(client)
	
	func _on_request_completed(response:HTTPResponse,client:NetHandlerClient) -> void:
		emit_signal("request_completed",response,client)
	
	func _on_client_disonnected(client:NetHandlerClient) -> void:
		clients.erase(client)
	
	func _notification(what: int) -> void:
		match what:
			NOTIFICATION_PREDELETE:
				for client in clients:
					client.close()




