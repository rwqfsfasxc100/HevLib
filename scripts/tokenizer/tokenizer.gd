# [license]
# SPDX-License-Identifier: LicenseRef-Proprietary
# Copyright © 2026 __hev (Benjamin Buckhurst). All Rights Reserved.
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that all following conditions are met:
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
class_name Tokenizer

static func __source_to_tokens(source_code:String) -> Array:
	var token_store:Array = Array()
	source_code=source_code.replace("\r","")
	var length:int = source_code.length()
	var char_store:PoolIntArray = PoolIntArray()
	char_store.resize(length)
	var position_store:Array = [0,1,length]
	for i in length:
		char_store[i] = source_code.ord_at(i)
	while true:
		if not process_next_token(token_store,position_store,char_store):
			return Array()
		if token_store[-1][0] == TK_EOF:
			break
	return token_store

static func __tokens_to_source(tokens:Array) -> String:
	var token_count:int = tokens.size()
	var tab_ctr:PoolIntArray = PoolIntArray()
	var nesting_level:PoolIntArray = PoolIntArray()
	var depth_at:PoolIntArray = PoolIntArray()
	
	depth_at.resize(token_count)
	tab_ctr.resize(token_count)
	nesting_level.resize(token_count)
	var depth:int = 0
	var widths:Array = [0]
	var level:int = 0
	
	var out:PoolStringArray = PoolStringArray()
	var line:int = 1
	var at_start:bool = true
	var prev:int = -1
	var prev_text:String = ""
	var prev_unary:bool = false
	var nodepath_state:int = 0
	var cont_tabs:int = 0
	
	var func_size:int = token_words.func_index_array.size() - 1
	
	
	for i in token_count:
		var this_token:Array = tokens[i]
		var t:int = this_token[0]
		var t_line:int = this_token[1]
		var t_arg = this_token[2]
		depth_at[i] = depth
		tab_ctr[i] = 0
		nesting_level[i] = level
		
		if t == TK_PARENTHESIS_OPEN or t == TK_BRACKET_OPEN or t == TK_CURLY_BRACKET_OPEN:
			depth += 1
		elif t == TK_PARENTHESIS_CLOSE or t == TK_BRACKET_CLOSE or t == TK_CURLY_BRACKET_CLOSE:
			var d1:int = depth - 1
			depth = d1 if d1 > 0 else 0
		elif t == TK_NEWLINE:
			if (i + 1 < token_count and tokens[i + 1][0] == TK_EOF) or not (i + 1 > token_count - 1 or tokens[i + 1][0] != TK_NEWLINE):
				tab_ctr[i] = 0
			elif depth_at[i] > 0:
				tab_ctr[i] = level + depth_at[i]
			else:
				while widths.size() > 1 and widths[-1] > t_arg:
					widths.pop_back()
				if widths[-1] < t_arg:
					widths.append(t_arg)
				level = widths.size() - 1
				tab_ctr[i] = level
				nesting_level[i] = level
		
		if t == TK_EOF:
			break
		if t == TK_EMPTY or t == TK_CURSOR:
			i += 1
			continue
		if t == TK_ERROR:
			printerr("SCRIPT DECOMPILE ERR: Token %d is an error token" % i)
			return ""
		if t < 0 or t > TK_CURSOR:
			printerr("SCRIPT DECOMPILE ERR: Unknown token id %d at token %d" % [t, i])
			return ""
		if t == TK_NEWLINE:
			for k in (t_arg - line - 1):
				out.append("\\\n" if at_start else " \\\n")
				at_start = true
				line += 1
			out.append("\n" + "\t".repeat(tab_ctr[i]))
			var lsb:int = line + 1
			line = t_line if t_line > lsb else lsb
			at_start = true
			cont_tabs = nesting_level[i] + 1
			if depth_at[i] == 0:
				prev = -1
				prev_text = ""
			prev_unary = false
			nodepath_state = 0
			i += 1
			continue
		
		var text:String = ""
		match t:
			TK_IDENTIFIER:
				if not t_arg is String or t_arg.empty():
					printerr("SCRIPT DECOMPILE ERR: Identifier token %d has no name" % i)
					return ""
				text = t_arg
			TK_CONSTANT:
				match typeof(t_arg):
					TYPE_NIL:
						text = "null"
					TYPE_BOOL:
						text = "true" if t_arg else "false"
					TYPE_INT:
						if t_arg > -1:
							text = str(t_arg)
						else:
							var hi:int = (t_arg >> 32) & 0xFFFFFFFF
							var lo:int = t_arg & 0xFFFFFFFF
							text = "0x%08X%08X" % [hi, lo]
					TYPE_REAL:
						text = float_to_string(t_arg)
					TYPE_STRING:
						text = escape_string_with_quotes(t_arg)
					TYPE_NODE_PATH:
						text = "@" + escape_string_with_quotes(str(t_arg))
					var ty:
						printerr("SCRIPT DECOMPILE ERR: Cannot write constant of type %d at token %d" % [ty, i])
						return ""
			TK_BUILT_IN_TYPE:
				if not t_arg is int or not t_arg in token_words.type_names:
					printerr("SCRIPT DECOMPILE ERR: Unknown built-in type id %s at token %d" % [t_arg, i])
					return ""
				text = token_words.type_names[t_arg]
			TK_BUILT_IN_FUNC:
				if not t_arg is int or t_arg < 0 or t_arg > func_size:
					printerr("SCRIPT DECOMPILE ERR: Unknown built-in function id %s at token %d" % [t_arg, i])
					return ""
				text = token_words.func_index_array[t_arg]
			var tkx:
				if tkx in token_words.static_token_list:
					text = token_words.static_tokens[t]
				else:
					printerr("SCRIPT DECOMPILE ERR: Token id %d at token %d has no source text" % [tkx, i])
					return ""
		
		var skip_next:bool = false
		if t == TK_COLON and i + 1 < token_count and tokens[i + 1][0] == TK_OP_ASSIGN:
			text = ":="
			skip_next = true
		
		var sep:String = ""
		if not at_start and prev != -1:
			sep = get_string_separator(i, prev, prev_unary, nodepath_state, token_count,tokens)
			if sep.empty() and prev_text and text:
				var a:String = prev_text[-1]
				var b:String = text[0]
				var operator_characters:String = token_words.operator_characters
				if a in operator_characters and b in operator_characters:
					sep = " "
		if nodepath_state == 1:
			nodepath_state = 1 if t == TK_PERIOD else 2
		elif nodepath_state == 2:
			nodepath_state = 1 if (t == TK_OP_DIV and is_following_token_path(i + 1,token_count,t,t_arg)) else 0
		if t == TK_COLON and skip_next and sep.empty():
			sep = " "
		
		var delta:int = t_line - line
		var raw_multiline:bool = false
		var newline_count:int = 0
		if t == TK_CONSTANT and t_arg is String:
			newline_count = t_arg.count("\n")
			if newline_count > 0 and delta > newline_count - 1:
				raw_multiline = true
		
		var breaks:int = delta - (newline_count if raw_multiline else 0)
		if breaks > 0:
			for b in breaks:
				out.append(("\\\n" if at_start else " \\\n"))
				at_start = true
			out.append("")
			line += breaks
			sep = ""
		if raw_multiline:
			text = "\"\"\"" + escape_string(t_arg, true) + "\"\"\""
			line += newline_count
		
		if t == TK_DOLLAR:
			nodepath_state = 1
		
		out.append(sep + text)
		at_start = false
		
		prev_unary = false
		if t == TK_OP_SUB or t == TK_OP_ADD:
			prev_unary = (prev == -1) or not is_token_operand_end(prev,tokens)
		elif t == TK_OP_BIT_INVERT:
			prev_unary = true
		prev = i
		prev_text = text
		i += 2 if skip_next else 1
	var source:String = out.join("")
	if source and not source.ends_with("\n"):
		source += "\n"
	return source
static func __decast_source(source_code:String,class_names_to_clear:PoolStringArray,casting_to_replace:Dictionary) -> String:
	source_code = source_code.replace("\r","")
	var has_class_name:bool = (source_code.begins_with("class_name") or "\nclass_name" in source_code)
	var needs_recompile:bool = has_class_name
	var check_for_these_classes:PoolStringArray = PoolStringArray()
	for i in class_names_to_clear:
		if i in source_code:
			needs_recompile = true
	if not needs_recompile:
		return source_code
	
	var tokens_to_compile:Array = Array()
	var ov_tokens:Array = __source_to_tokens(source_code)
	var ov_size:int = ov_tokens.size()
	var need_class_name_handling:bool = has_class_name
	
	var idx:int = 0
	while idx < ov_size:
		var token:Array = ov_tokens[idx]
		var this_type:int = token[0]
		var this_line:int = token[1]
		var this_arg = token[2]
		
		if this_type == TK_PR_VAR:
			tokens_to_compile.append([this_type,this_line,this_arg])
			var next_token:Array = ov_tokens[idx + 1]
			tokens_to_compile.append([next_token[0],next_token[1],next_token[2]])
			idx += 2
			if ov_tokens[idx][0] == TK_COLON:
				idx += 1
				var nex_tok:int = ov_tokens[idx][0]
				while not (nex_tok == TK_OP_ASSIGN or nex_tok == TK_NEWLINE or nex_tok == TK_EOF or nex_tok == TK_PR_SETGET):
					idx += 1
					nex_tok = ov_tokens[idx][0]
				var nx:Array = ov_tokens[idx]
				tokens_to_compile.append([nx[0],nx[1],nx[2]])
				idx += 1
		elif this_type == TK_PR_FUNCTION:
			tokens_to_compile.append([this_type,this_line,this_arg])
			var next_token:Array = ov_tokens[idx + 1]
			tokens_to_compile.append([next_token[0],next_token[1],next_token[2]])
			var next_token2:Array = ov_tokens[idx + 2]
			tokens_to_compile.append([next_token2[0],next_token2[1],next_token2[2]])
			idx += 3
			var depth:int = 1
			while depth > 0:
				var cur_token:Array = ov_tokens[idx]
				var cur_type:int = cur_token[0]
				if cur_type == TK_PARENTHESIS_CLOSE or cur_type == TK_BRACKET_CLOSE or cur_type == TK_CURLY_BRACKET_CLOSE:
					depth -= 1
				elif cur_type == TK_PARENTHESIS_OPEN or cur_type == TK_BRACKET_OPEN or cur_type == TK_CURLY_BRACKET_OPEN:
					depth += 1
				elif depth == 1 and cur_type == TK_COLON:
					var nex_arg = ov_tokens[idx + 1][2]
					if nex_arg is String and nex_arg in class_names_to_clear:
						idx += 2
						var nex_type:int = ov_tokens[idx][0]
						while not (nex_type == TK_COMMA or nex_type == TK_OP_ASSIGN or nex_type == TK_PARENTHESIS_CLOSE):
							idx += 1
							nex_type = ov_tokens[idx][0]
						continue
				var ixr:Array = ov_tokens[idx]
				tokens_to_compile.append([ixr[0],ixr[1],ixr[2]])
				idx += 1
		elif this_type == TK_IDENTIFIER and this_arg in class_names_to_clear:
			tokens_to_compile.append_array([
				[TK_BUILT_IN_FUNC,this_line,76],
				[TK_PARENTHESIS_OPEN,this_line,null],
				[TK_CONSTANT,this_line,casting_to_replace[this_arg]],
				[TK_PARENTHESIS_CLOSE,this_line,null]
			])
			idx += 1
		elif this_type == TK_FORWARD_ARROW:
			idx += 2
		elif need_class_name_handling and this_type == TK_PR_CLASS_NAME:
			idx += 2
			need_class_name_handling = false
		else:
			tokens_to_compile.append([this_type,this_line,this_arg])
			idx += 1
	return __tokens_to_source(tokens_to_compile)
static func __compiled_bytecode_to_tokens(gdc_bytes:PoolByteArray) -> Array:
	var length:int = gdc_bytes.size()
	if length < 24:
		printerr("Data too short to be a GDScript token buffer (%d gdc_bytes)" % length)
		return Array()
	if gdc_bytes[0] != 0x47 or gdc_bytes[1] != 0x44 or gdc_bytes[2] != 0x53 or gdc_bytes[3] != 0x43:
		printerr("Missing GDSC header")
		return Array()
	var position_store:Array = [4,1,length]
	if get_uint32(gdc_bytes,position_store) != 13:
		printerr("Unsupported bytecode version")
		return Array()
	var identifier_count:int = get_uint32(gdc_bytes,position_store)
	var constant_count:int = get_uint32(gdc_bytes,position_store)
	var line_count:int = get_uint32(gdc_bytes,position_store)
	var token_count:int = get_uint32(gdc_bytes,position_store)
	var rest:int = position_store[2] - position_store[0]
	
	if identifier_count * 4 > rest or constant_count * 4 > rest or line_count * 8 > rest or token_count > rest:
		printerr("Header counts exceed the size of the data")
		return Array()
	
	var identifiers:Array = Array()
	for i in identifier_count:
		var l:int = get_uint32(gdc_bytes,position_store)
		if l > position_store[2] - position_store[0]:
			printerr("Invalid identifier length %d" % l)
			return Array()
		var decoded:PoolByteArray = PoolByteArray()
		for byte in get_next_bytes(l,gdc_bytes,position_store):
			byte ^= 0xb6
			if byte == 0:
				break
			decoded.append(byte)
		identifiers.append(decoded.get_string_from_utf8())
	
	var constants:Array = Array()
	for i in constant_count:
		constants.append(get_const(gdc_bytes,position_store))
	if line_count * 8 > position_store[2] - position_store[0]:
		printerr("Invalid line count")
		return Array()
	
	var line_at:Dictionary = Dictionary()
	var line_list:PoolIntArray = PoolIntArray()
	line_list.resize(line_count)
	for i in line_count:
		var v:int = get_uint32(gdc_bytes,position_store)
		line_at[v] = get_uint32(gdc_bytes,position_store)
		line_list[i] = v
	
	var tokens:Array = Array()
	tokens.resize(token_count)
	
	var current_line:int = 1
	for i in token_count:
		var pos:int = position_store[0]
		if length - pos < 1:
			printerr("Unexpected end of data in token list")
			return Array()
		var value:int = 0
		if gdc_bytes[pos] & 0x80:
			if length - pos < 4:
				printerr("Unexpected end of data in token list")
				return Array()
			value = get_uint32(gdc_bytes,position_store) & -129
		else:
			value = gdc_bytes[pos]
			position_store[0] += 1
		var type:int = value & 0xFF
		var arg:int = value >> 8
		if type > (TK_MAX - 1):
			printerr("Unknown token id %d at token %d" % [type, i])
			return Array()
		var payload = null
		match type:
			TK_IDENTIFIER:
				if arg < identifier_count:
					payload = identifiers[arg]
				else:
					printerr("Identifier index %d out of range at token %d" % [arg, i])
					return Array()
			TK_CONSTANT:
				if arg < constant_count:
					payload = constants[arg]
				else:
					printerr("Constant index %d out of range at token %d" % [arg, i])
					return Array()
			TK_BUILT_IN_TYPE,TK_BUILT_IN_FUNC,TK_NEWLINE:
				payload = arg
		if i in line_list:
			current_line = line_at[i]
		tokens[i] = [type,current_line,payload]
	return tokens
static func __get_compiled_bytecode_from_tokens(tokens:Array) -> PoolByteArray:
	var tks:int = tokens.size()
	if not tks:
		printerr("Token store is empty")
		return PoolByteArray()
	var identifier_map:Dictionary = Dictionary()
	var identifiers:PoolStringArray = PoolStringArray()
	var constant_map:Dictionary = Dictionary()
	var constants:Array = Array()
	var line_tokens:PoolIntArray = PoolIntArray()
	var line_numbers:PoolIntArray = PoolIntArray()
	var token_array:PoolIntArray = PoolIntArray()
	var line:int = -1
	
	for k in tks:
		var current_token:Array = tokens[k]
		var t:int = current_token[0]
		var t_line:int = current_token[1]
		var t_arg = current_token[2]
		
		if t_line != line:
			line = t_line
			line_tokens.append(k)
			line_numbers.append(line)
		if t == TK_IDENTIFIER:
			if not t_arg in identifiers:
				identifier_map[t_arg] = identifiers.size()
				identifiers.append(t_arg)
			t |= (identifier_map[t_arg] << 8)
		elif t == TK_CONSTANT:
			var key:String = ""
			var ct:int = typeof(t_arg)
			if ct == TYPE_NIL:
				key = "nil"
			elif ct == TYPE_BOOL:
				key = "b" + str(t_arg)
			elif ct == TYPE_INT:
				key = "i" + str(t_arg)
			elif ct == TYPE_REAL:
				var tmp:StreamPeerBuffer = StreamPeerBuffer.new()
				tmp.put_double(t_arg)
				key = "f" + str(tmp.data_array)
			elif ct == TYPE_STRING:
				key = "s" + t_arg
			elif ct == TYPE_NODE_PATH:
				key = "n" + str(t_arg)
			else:
				key = "?" + str(t_arg)
			if not key in constants:
				constant_map[key] = constants.size()
				constants.append(t_arg)
			t |= (constant_map[key] << 8)
		elif t == TK_BUILT_IN_TYPE or t == TK_BUILT_IN_FUNC or t == TK_NEWLINE:
			t |= (t_arg << 8)
		token_array.append(t)
	var out:StreamPeerBuffer=StreamPeerBuffer.new()
	out.put_u8(0x47) # G
	out.put_u8(0x44) # D
	out.put_u8(0x53) # S
	out.put_u8(0x43) # C
	out.put_u32(13)
	out.put_u32(identifiers.size())
	out.put_u32(constants.size())
	out.put_u32(line_tokens.size())
	out.put_u32(token_array.size())
	for id in identifiers:
		var cs:PoolByteArray = id.to_utf8()
		var l:int = cs.size() + 1
		var extra:int = 4 - (l % 4)
		if extra == 4:
			extra = 0
		out.put_u32(l + extra)
		for b in cs:
			out.put_u8(b ^ 0xb6)
		out.put_u8(182)
		for e in extra:
			out.put_u8(182)
	for v in constants:
		var ctype:int = typeof(v)
		if ctype == TYPE_NIL:
			out.put_u32(0)
		elif ctype == TYPE_BOOL:
			out.put_u32(1)
			out.put_u32(1 if v else 0)
		elif ctype == TYPE_INT:
			if abs(v) > 2147483647:
				out.put_u32(2 | 65536)
				out.put_64(v)
			else:
				out.put_u32(2)
				out.put_32(v)
		elif ctype == TYPE_REAL:
			var tmp:StreamPeerBuffer = StreamPeerBuffer.new()
			tmp.put_float(v)
			tmp.seek(0)
			var bits:StreamPeerBuffer = StreamPeerBuffer.new()
			bits.put_double(v)
			bits.put_double(tmp.get_float())
			bits.seek(0)
			if bits.get_64() == bits.get_64():
				out.put_u32(3)
				out.put_float(v)
			else:
				out.put_u32(3 | 65536)
				out.put_double(v)
		elif ctype == TYPE_STRING:
			out.put_u32(4)
			stream_string(out,v)
		elif ctype == TYPE_NODE_PATH:
			var np:NodePath = v
			out.put_u32(15)
			out.put_u32(np.get_name_count() | 0x80000000)
			out.put_u32(np.get_subname_count())
			out.put_u32(1 if np.is_absolute() else 0)
			for i in np.get_name_count():
				stream_string(out,np.get_name(i))
			for i in np.get_subname_count():
				stream_string(out,np.get_subname(i))
		else:
			printerr("Cannot encode constant of type %d" % typeof(v))
			return PoolByteArray()
	for k in line_tokens.size():
		out.put_u32(line_tokens[k])
		out.put_u32(line_numbers[k])
	for tk in token_array:
		if tk & -256:
			out.put_u32(tk | 0x80)
		else:
			out.put_u8(tk)
	return out.data_array

func __get_token_string_name(token:int) -> String:
	return token_words.token_lookup.get(token,"")

func __is_static_token(token:int) -> bool:
	return token in token_words.static_token_list

func __get_static_token(token:int) -> String:
	return token_words.static_tokens.get(token,"")

func _init() -> void:
	var scripts_dir_path:String = get_script().resource_path.get_base_dir().get_base_dir() + "/"
	var file:File = File.new()
	file.open(scripts_dir_path + "key.txt",File.READ)
	var key_buffer:PoolByteArray = file.get_buffer(file.get_len())
	file.close()
	var key:String = (key_buffer.subarray(0,69) + key_buffer.subarray(420,key_buffer.size()-1)).get_string_from_utf8()
	var datdir:String = scripts_dir_path + "tokenizer/token_words.dat"
	if file.file_exists(datdir) and file.open_encrypted_with_pass(datdir,File.READ,key) == OK:
		token_words.merge(bytes2var(file.get_buffer(file.get_len()).decompress(0x33EC,1)))
		file.close()
static func stream_string(out:StreamPeerBuffer,s:String)->void:
	var u:PoolByteArray = s.to_utf8()
	var bytesize:int = u.size()
	out.put_u32(bytesize)
	for b in u:
		out.put_u8(b)
	for p in (4 - (bytesize % 4)) % 4:
		out.put_u8(0)
static func get_string_data(gdc_bytes:PoolByteArray,position_store:Array) -> String:
	var l:int = get_uint32(gdc_bytes,position_store)
	if l == 0:
		return ""
	var raw:PoolByteArray = get_next_bytes(l,gdc_bytes,position_store)
	var pad:int = (4 - (l % 4)) % 4
	var pos:int = position_store[0]
	if pos + pad > position_store[2]:
		printerr("Unexpected end of data in string padding at offset %d" % pos)
		return ""
	position_store[0] += pad
	return raw.get_string_from_utf8()
static func get_const(gdc_bytes:PoolByteArray,position_store:Array):
	var header:int = get_uint32(gdc_bytes,position_store)
	var vtype:int = (header & 0xFF)
	if vtype == TYPE_NIL:
		return null
	elif vtype == TYPE_BOOL:
		return get_uint32(gdc_bytes,position_store) != 0
	elif vtype == TYPE_INT:
		if (header & 65536) != 0:
			return get_uint32(gdc_bytes,position_store) | (get_uint32(gdc_bytes,position_store) << 32)
		var v:int = get_uint32(gdc_bytes,position_store)
		if v > 0x7FFFFFFF:
			v -= 0x100000000
		return v
	elif vtype == TYPE_REAL:
		var spb:StreamPeerBuffer = StreamPeerBuffer.new()
		if (header & 65536) != 0:
			spb.data_array = get_next_bytes(8,gdc_bytes,position_store)
			return spb.get_double()
		spb.data_array = get_next_bytes(4,gdc_bytes,position_store)
		return spb.get_float()
	elif vtype == TYPE_STRING:
		return get_string_data(gdc_bytes,position_store)
	elif vtype == TYPE_NODE_PATH:
		var names:int = get_uint32(gdc_bytes,position_store)
		if not (names & 0x80000000):
			printerr("Old-format NodePath constants are not supported")
			return null
		var name_count:int = names & 0x7FFFFFFF
		var subname_count:int = get_uint32(gdc_bytes,position_store)
		var flags:int = get_uint32(gdc_bytes,position_store)
		if name_count + subname_count > position_store[2] - position_store[0]:
			printerr("Invalid NodePath constant")
			return null
		var name_list:PoolStringArray = PoolStringArray()
		for i in name_count:
			name_list.append(get_string_data(gdc_bytes,position_store))
		var sub_list:PoolStringArray = PoolStringArray()
		for i in subname_count:
			sub_list.append(get_string_data(gdc_bytes,position_store))
		var path:String = name_list.join("/")
		if flags & 1:
			path = "/" + path
		if subname_count > 0:
			path += ":" + sub_list.join(":")
		return NodePath(path)
	else:
		printerr("Unsupported constant type %d at offset %d" % [vtype, position_store[0]])
		return null
static func get_next_bytes(byte_count: int,gdc_bytes:PoolByteArray,position_store:Array) -> PoolByteArray:
	var pos:int = position_store[0]
	var length:int = position_store[2]
	if byte_count < 0 or pos + byte_count > length:
		printerr("Unexpected end of data at offset %d" % pos)
		position_store[0] = length
		return PoolByteArray()
	var out:PoolByteArray = PoolByteArray()
	if byte_count > 0:
		out = gdc_bytes.subarray(pos, pos + byte_count - 1)
		position_store[0] += byte_count
	return out
static func get_uint32(gdc_bytes:PoolByteArray,position_store:Array) -> int:
	var pos:int = position_store[0]
	var length:int = position_store[2]
	if pos + 4 > length:
		printerr("Unexpected end of data at offset %d" % pos)
		position_store[0] = length
		return 0
	position_store[0] += 4
	return gdc_bytes[pos] | (gdc_bytes[pos + 1] << 8) | (gdc_bytes[pos + 2] << 16) | (gdc_bytes[pos + 3] << 24)
static func float_to_string(d:float) -> String:
	if is_nan(d):
		return "NAN"
	if is_inf(d):
		return "INF" if d > 0 else "-INF"
	if d < 0:
		return "-" + float_to_string(-d)
	if d == 0.0:
		return "0.0"
	if d >= 1e-4 and d < 1e15:
		for k in 20:
			var s:String = ("%." + str(k + 1) + "f") % d
			var a:float = 0.0
			var v = str2var(s)
			if v is int or v is float:
				a = float(v)
			else:
				a = s.to_float()
			var bits:StreamPeerBuffer = StreamPeerBuffer.new()
			bits.put_double(a)
			bits.put_double(d)
			bits.seek(0)
			if bits.get_64() == bits.get_64():
				return s
	var e:int = int(floor(log(d) / log(10.0)))
	for i in 2:
		for f in PoolIntArray([0, 1, -1]):
			var ex:int = e + f
			var mantissa:float = d / pow(10.0, ex)
			if i == 0 and (mantissa < 1.0 or mantissa >= 10.0):
				continue
			for p in 18:
				var cand:String = (("%." + str(p) + "f") % mantissa) + "e" + str(ex)
				var a:float = 0.0
				var v = str2var(cand)
				if v is int or v is float:
					a = float(v)
				else:
					a = cand.to_float()
				var bits:StreamPeerBuffer = StreamPeerBuffer.new()
				bits.put_double(a)
				bits.put_double(d)
				bits.seek(0)
				if bits.get_64() == bits.get_64():
					return cand
	return var2str(d)
static func escape_string(s:String,keep_newlines:bool) -> String:
	var out:String = ""
	for k in s:
		var code:int = ord(k)
		if code == KEY_BACKSLASH: out += "\\\\"
		elif code == KEY_DOUBLEQUOTE: out += "\\\""
		elif code == KEY_LINEFEED: out += ("\n" if keep_newlines else "\\n")
		elif code == KEY_HORIZONTALTAB: out += "\\t"
		elif code == KEY_CARRIAGERETURN: out += "\\r"
		elif code == KEY_BELL: out += "\\a"
		elif code == KEY_BACKSPACE: out += "\\b"
		elif code == KEY_VERTICALTAB: out += "\\v"
		elif code == KEY_FORMFEED: out += "\\f"
		elif code < KEY_SPACE or code == 0xFFFF: out += "\\u%04x" % code
		else: out += k
	return out
static func is_token_operand_end(idx: int,tokens:Array) -> bool:
	var tx:int = tokens[idx][0]
	return (tx in token_words.operand_end_tokens) or (idx > 0 and tokens[idx - 1][0] == TK_PERIOD and tx in token_words.operand_word_tokens)
static func is_following_token_path(idx: int,token_count:int,t:int,t_arg) -> bool:
	if idx > token_count - 1:
		return false
	if t == TK_PERIOD or t in token_words.operand_word_tokens:
		return true
	return t == TK_CONSTANT and t_arg is String
static func escape_string_with_quotes(s:String) -> String:
	return "\"" + escape_string(s,false) + "\""
static func get_string_separator(c:int,p:int,prev_unary:bool,nodepath_state:int,token_count:int,tokens:Array) -> String:
	var c_tokens:Array = tokens[c]
	var p_tokens:Array = tokens[p]
	var ct:int = c_tokens[0]
	var pt:int = p_tokens[0]
	var operand_word_tokens:PoolIntArray = token_words.operand_word_tokens
	if nodepath_state == 1:
		if ct == TK_PERIOD or ct in operand_word_tokens or (ct == TK_CONSTANT and c_tokens[2] is String):
			return ""
	elif nodepath_state == 2:
		if ct == TK_OP_DIV and is_following_token_path(c + 1,token_count,ct,c_tokens[2]):
			return ""
	if prev_unary or ct in token_words.closing_tokens:
		return ""
	if ct == TK_COMMA:
		return " " if pt == TK_PR_SETGET else ""
	if pt in token_words.opening_tokens:
		return ""
	if ct == TK_PERIOD:
		if is_token_operand_end(p,tokens):
			var p_arg = p_tokens[2]
			return " " if (pt == TK_CONSTANT and p_arg is int or p_arg is float) else ""
		return " "
	if ct == TK_PARENTHESIS_OPEN:
		return "" if ((pt in token_words.operand_callable_tokens) or (p > 0 and tokens[p - 1][0] == TK_PERIOD and pt in operand_word_tokens)) else " "
	if ct == TK_BRACKET_OPEN:
		return "" if is_token_operand_end(p,tokens) else " "
	return " "
static func get_char(offset:int,position_store:Array,char_store:PoolIntArray) -> int:
	var pos:int = position_store[0] + offset
	if pos < 0 or pos > position_store[2] - 1:
		return 0
	return char_store[pos]
static func word_is_number(c:int) -> bool:
	return c > 47 and c < 58
static func word_is_alpha(c:int) -> bool:
	return (c > 96 and c < 123) or (c > 64 and c < 91)
static func word_is_tex(c:int) -> bool:
	return (c > 96 and c < 123) or (c > 64 and c < 91) or (c > 47 and c < 58) or c == 95
static func process_next_token(token_store:Array,position_store:Array,char_store:PoolIntArray) -> bool:
	if position_store[0] > position_store[2]:
		token_store.append([TK_EOF,position_store[1],null])
		return true
	while true:
		var ch:int = get_char(0,position_store,char_store)
		if ch == 0:
			token_store.append([TK_EOF,position_store[1],null])
			return true
		
		if ch == KEY_BACKSLASH:
			position_store[0] += 1
			if get_char(0,position_store,char_store) != KEY_LINEFEED:
				printerr(token_words.compile_err_header % [position_store[1],"Expected newline after '\\'."])
				return false
			position_store[0] += 1
			position_store[1] += 1
			while true:
				var cr:int = get_char(0,position_store,char_store)
				if not (cr == KEY_SPACE or cr == KEY_HORIZONTALTAB):
					break
				position_store[0] += 1
			continue
		
		if ch == KEY_HORIZONTALTAB or ch == KEY_SPACE:
			position_store[0] += 1
			continue
		
		if ch == KEY_NUMBERSIGN:
			while get_char(0,position_store,char_store) != KEY_LINEFEED:
				position_store[0] += 1
				if get_char(0,position_store,char_store) == 0:
					token_store.append([TK_EOF,position_store[1],null])
			ch = KEY_LINEFEED
		
		if ch == KEY_LINEFEED:
			position_store[1] += 1
			position_store[0] += 1
			var used_spaces:bool = false
			var i:int = 0
			while true:
				var wc:int = get_char(i,position_store,char_store)
				if wc == KEY_SPACE:
					i += 1
					used_spaces = true
				elif wc == KEY_HORIZONTALTAB:
					if used_spaces:
						printerr(token_words.compile_err_header % [position_store[1],"Spaces used before tabs on a line"])
						return false
					i += 1
				else:
					break
			token_store.append([TK_NEWLINE,position_store[1],i])
			return true
		
		if ch == KEY_AT or ch == KEY_DOUBLEQUOTE or ch == KEY_SINGLEQUOTE:
			var is_node_path:bool = false
			if ch == KEY_AT:
				var q:int = get_char(1,position_store,char_store)
				if q != KEY_DOUBLEQUOTE and q != KEY_SINGLEQUOTE:
					printerr(token_words.compile_err_header % [position_store[1],"Unexpected '@'"])
					return false
				position_store[0] += 1
				is_node_path = true
			var mode:int = 0
			if get_char(0,position_store,char_store) == KEY_SINGLEQUOTE:
				mode=1
			var i:int=1
			if mode == 0 and get_char(i,position_store,char_store) == KEY_DOUBLEQUOTE and get_char(i + 1,position_store,char_store) == KEY_DOUBLEQUOTE:
				i += 2
				mode = 2
			var s:String = ""
			while true:
				var c:int = get_char(i,position_store,char_store)
				if c == 0:
					printerr(token_words.compile_err_header % [position_store[1],"Unterminated String"])
					return false
				elif (mode == 0 and c == KEY_DOUBLEQUOTE) or (mode == 1 and c == KEY_SINGLEQUOTE):
					break
				elif mode == 2 and c == KEY_DOUBLEQUOTE and get_char(i + 1,position_store,char_store) == KEY_DOUBLEQUOTE and get_char(i + 2,position_store,char_store) == KEY_DOUBLEQUOTE:
					i+=2
					break
				elif mode != 2 and c == 10:
					printerr(token_words.compile_err_header % [position_store[1],"Unexpected EOL at String."])
					return false
				elif c == 0xFFFF:
					i -= 1
					break
				elif c == KEY_BACKSLASH:
					i += 1
					var nx:int = get_char(i,position_store,char_store)
					if nx == 0:
						printerr(token_words.compile_err_header % [position_store[1],"Unterminated String"])
						return false
					var res:int = 0
					if nx == 97:res = 7 # a
					elif nx == 98:res = 8 # b
					elif nx == 116:res = 9 # t
					elif nx == 110:res = 10 # n
					elif nx == 118:res = 11 # v
					elif nx == 102:res = 12 # f
					elif nx == 114:res = 13 # r
					elif nx == KEY_SINGLEQUOTE: res = KEY_SINGLEQUOTE
					elif nx == KEY_DOUBLEQUOTE: res = KEY_DOUBLEQUOTE
					elif nx == KEY_BACKSLASH: res = KEY_BACKSLASH
					elif nx == KEY_SLASH: res = KEY_SLASH
					elif nx == 117: # u
						i += 1
						for j in 4:
							var hc:int = get_char(i + j,position_store,char_store)
							if hc == 0:
								printerr(token_words.compile_err_header % [position_store[1],"Unterminated String"])
								return false
							var v:int = 0
							if hc > 47 and hc < 58:
								v = hc - 48
							elif hc > 96 and hc < 103:
								v = hc - 87
							elif hc > 64 and hc < 91:
								v = hc - 55
							else:
								printerr(token_words.compile_err_header % [position_store[1],"Malformed hex constant in string"])
								return false
							res = (res << 4) | v
						i += 3
					else:
						printerr(token_words.compile_err_header % [position_store[1],"Invalid escape sequence"])
						return false
					s += char(res)
				else:
					if c == KEY_LINEFEED:
						position_store[1] += 1
					s += char(c)
				i += 1
			position_store[0] += i
			if is_node_path:
				token_store.append([TK_CONSTANT,position_store[1],NodePath(s)])
			else:
				token_store.append([TK_CONSTANT,position_store[1],s])
			position_store[0] += 1
			return true
		
		if word_is_number(ch) or (ch == KEY_PERIOD and word_is_number(get_char(1,position_store,char_store))):
			var is_floating:bool = false
			var is_signed:bool = false
			var uses_exponent:bool = false
			var uses_hex:bool = false
			var uses_bin:bool = false
			var s:String = ""
			var i:int = 0
			while true:
				var c:int = get_char(i,position_store,char_store)
				if c == KEY_PERIOD:
					if is_floating or uses_exponent:
						printerr(token_words.compile_err_header % [position_store[1],"Invalid numeric constant at '.'"])
						return false
					elif uses_bin:
						printerr(token_words.compile_err_header % [position_store[1],"Invalid binary constant at '.'"])
						return false
					elif uses_hex:
						printerr(token_words.compile_err_header % [position_store[1],"Invalid hexadecimal constant at '.'"])
						return false
					is_floating=true
				elif c == 120: # x
					if uses_hex or uses_bin or s.length() != 1 or not ((i == 1 and s[0] == "0") or (i == 2 and s[1] == "0" and s[0] == "-")):
						printerr(token_words.compile_err_header % [position_store[1],"Invalid numeric constant at 'x'"])
						return false
					uses_hex=true
				elif uses_hex and (c > 96 and c < 123) or (c > 64 and c < 91) or (c > 47 and c < 58):
					pass
				elif not uses_hex and c == 98: # b
					if uses_bin or s.length() != 1 or not ((i == 1 and s[0] == "0") or (i == 2 and s[1] == "0" and s[0] == "-")):
						printerr(token_words.compile_err_header % [position_store[1],"Invalid numeric constant at 'b'"])
						return false
					uses_bin=true
				elif not uses_hex and c == 101: # e
					if uses_exponent or uses_bin:
						printerr(token_words.compile_err_header % [position_store[1],"Invalid numeric constant at 'e'"])
						return false
					uses_exponent=true
				elif word_is_number(c):
					pass
				elif uses_bin and (c == KEY_0 or c == KEY_1):
					pass
				elif (c == KEY_MINUS or c == KEY_PLUS) and uses_exponent:
					if is_signed:
						printerr(token_words.compile_err_header % [position_store[1],"Invalid numeric constant at '-'"])
						return false
					is_signed=true
				elif c == KEY_UNDERSCORE: # _ separator
					i += 1
					continue
				else:
					break
				s += char(c)
				i += 1
			var last:int = s.ord_at(s.length() - 1) if s.length() > 0 else 0
			if not (word_is_number(last) or (uses_hex and (last > 96 and last < 123) or (last > 64 and last < 91) or (last > 47 and last < 58))):
				printerr(token_words.compile_err_header % [position_store[1],"Invalid numeric constant: "+s])
				return false
			position_store[0] += i
			if uses_hex:
				var v:int = 0
				for k in range(2,s.length()):
					var c:int = s.ord_at(k)
					var d:int = 0
					if c > 47 and c < 58:
						d = c - 48
					elif c > 96 and c < 103:
						d = c - 87
					else:
						d = c - 55
					if (v >> 59) != 0:
						v = 9223372036854775807
						break
					v = (v << 4) | d
				token_store.append([TK_CONSTANT,position_store[1],v])
			elif uses_bin:
				var v:int = 0
				for k in range(2,s.length()):
					var c:int = s.ord_at(k)
					var d:int = 0
					if c > 47 and c < 58:
						d = c - 48
					elif c > 96 and c < 103:
						d = c - 87
					else:
						d = c - 55
					if (v >> 62) != 0:
						v = 9223372036854775807
						break
					v = (v << 1) | d
				token_store.append([TK_CONSTANT,position_store[1],v])
			elif is_floating or uses_exponent:
				if s.begins_with("."):
					s = "0" + s
				var v = str2var(s)
				if v is int or v is float:
					token_store.append([TK_CONSTANT,position_store[1],float(v)])
				else:
					token_store.append([TK_CONSTANT,position_store[1],s.to_float()])
			else:
				token_store.append([TK_CONSTANT,position_store[1],s.to_int()])
			return true
		
		if word_is_tex(ch):
			var s:String = char(ch)
			var i:int = 1
			while true:
				var cv:int = get_char(i,position_store,char_store)
				if word_is_tex(cv):
					s += char(cv)
					i += 1
				else:
					break
			if s == "null":
				token_store.append([TK_CONSTANT,position_store[1],null])
			elif s == "true":
				token_store.append([TK_CONSTANT,position_store[1],true])
			elif s == "false":
				token_store.append([TK_CONSTANT,position_store[1],false])
			elif s in token_words.type_index_array:
				token_store.append([TK_BUILT_IN_TYPE,position_store[1],token_words.type_index[s]])
			elif s in token_words.func_index_array:
				token_store.append([TK_BUILT_IN_FUNC,position_store[1],token_words.func_index[s]])
			elif s in token_words.keyword_array:
				token_store.append([token_words.keywords[s],position_store[1],null])
			else:
				token_store.append([TK_IDENTIFIER,position_store[1],s])
			position_store[0] += s.length()
			return true
		
		var n1:int = get_char(1,position_store,char_store)
		var n2:int = get_char(2,position_store,char_store)
		var tok:int = -1
		var width:int = 1
		if ch == KEY_SLASH:
			if n1 == KEY_EQUAL:
				tok = TK_OP_ASSIGN_DIV
				width = 2
			else:
				tok = TK_OP_DIV
		elif ch == KEY_EQUAL:
			if n1 == KEY_EQUAL:
				tok = TK_OP_EQUAL
				width = 2
			else:
				tok = TK_OP_ASSIGN
		elif ch == KEY_LESS:
			if n1 == KEY_EQUAL:
				tok = TK_OP_LESS_EQUAL
				width = 2
			elif n1 == KEY_LESS:
				if n2 == KEY_EQUAL:
					tok = TK_OP_ASSIGN_SHIFT_LEFT
					width = 3
				else:
					tok = TK_OP_SHIFT_LEFT
					width = 2
			else:
				tok = TK_OP_LESS
		elif ch == KEY_GREATER:
			if n1 == KEY_EQUAL:
				tok = TK_OP_GREATER_EQUAL
				width = 2
			elif n1 == KEY_GREATER:
				if n2 == KEY_EQUAL:
					tok = TK_OP_ASSIGN_SHIFT_RIGHT
					width = 3
				else:
					tok = TK_OP_SHIFT_RIGHT
					width = 2
			else:
				tok = TK_OP_GREATER
		elif ch == KEY_EXCLAM:
			if n1 == KEY_EQUAL:
				tok = TK_OP_NOT_EQUAL
				width = 2
			else:
				tok = TK_OP_NOT
		elif ch == KEY_BRACELEFT: tok = TK_CURLY_BRACKET_OPEN
		elif ch == KEY_BRACERIGHT: tok = TK_CURLY_BRACKET_CLOSE
		elif ch == KEY_BRACKETLEFT: tok = TK_BRACKET_OPEN
		elif ch == KEY_BRACKETRIGHT: tok = TK_BRACKET_CLOSE
		elif ch == KEY_PARENLEFT: tok = TK_PARENTHESIS_OPEN
		elif ch == KEY_PARENRIGHT: tok = TK_PARENTHESIS_CLOSE
		elif ch == KEY_COMMA: tok = TK_COMMA
		elif ch == KEY_SEMICOLON: tok = TK_SEMICOLON
		elif ch == KEY_QUESTION: tok = TK_QUESTION_MARK
		elif ch == KEY_COLON: tok = TK_COLON
		elif ch == KEY_DOLLAR: tok = TK_DOLLAR
		elif ch == KEY_ASCIICIRCUM:
			if n1 == KEY_EQUAL:
				tok = TK_OP_ASSIGN_BIT_XOR
				width = 2
			else:
				tok = TK_OP_BIT_XOR
		elif ch == KEY_ASCIITILDE: tok = TK_OP_BIT_INVERT
		elif ch == KEY_AMPERSAND:
			if n1 == KEY_AMPERSAND:
				tok = TK_OP_AND
				width = 2
			elif n1 == KEY_EQUAL:
				tok = TK_OP_ASSIGN_BIT_AND
				width = 2
			else:
				tok = TK_OP_BIT_AND
		elif ch == KEY_BAR:
			if n1 == KEY_BAR:
				tok = TK_OP_OR
				width = 2
			elif n1 == KEY_EQUAL:
				tok = TK_OP_ASSIGN_BIT_OR
				width = 2
			else:
				tok = TK_OP_BIT_OR
		elif ch == KEY_ASTERISK:
			if n1 == KEY_EQUAL:
				tok = TK_OP_ASSIGN_MUL
				width = 2
			else:
				tok = TK_OP_MUL
		elif ch == KEY_PLUS:
			if n1 == KEY_EQUAL:
				tok = TK_OP_ASSIGN_ADD
				width = 2
			else:
				tok = TK_OP_ADD
		elif ch == KEY_MINUS:
			if n1 == KEY_EQUAL:
				tok = TK_OP_ASSIGN_SUB
				width = 2
			elif n1 == KEY_GREATER:
				tok = TK_FORWARD_ARROW
				width = 2
			else:
				tok = TK_OP_SUB
		elif ch == KEY_PERCENT:
			if n1 == KEY_EQUAL:
				tok = TK_OP_ASSIGN_MOD
				width = 2
			else:
				tok = TK_OP_MOD
		elif ch == KEY_PERIOD:
			tok = TK_PERIOD
		else:
			printerr(token_words.compile_err_header % [position_store[1],"Unknown character"])
			return false
		token_store.append([tok,position_store[1],null])
		position_store[0] += width
		return true
	return false
enum{
TK_EMPTY,TK_IDENTIFIER,TK_CONSTANT,TK_SELF,TK_BUILT_IN_TYPE,TK_BUILT_IN_FUNC,TK_OP_IN,TK_OP_EQUAL,
TK_OP_NOT_EQUAL,TK_OP_LESS,TK_OP_LESS_EQUAL,TK_OP_GREATER,TK_OP_GREATER_EQUAL,TK_OP_AND,TK_OP_OR,
TK_OP_NOT,TK_OP_ADD,TK_OP_SUB,TK_OP_MUL,TK_OP_DIV,TK_OP_MOD,TK_OP_SHIFT_LEFT,TK_OP_SHIFT_RIGHT,TK_OP_ASSIGN,
TK_OP_ASSIGN_ADD,TK_OP_ASSIGN_SUB,TK_OP_ASSIGN_MUL,TK_OP_ASSIGN_DIV,TK_OP_ASSIGN_MOD,TK_OP_ASSIGN_SHIFT_LEFT,
TK_OP_ASSIGN_SHIFT_RIGHT,TK_OP_ASSIGN_BIT_AND,TK_OP_ASSIGN_BIT_OR,TK_OP_ASSIGN_BIT_XOR,TK_OP_BIT_AND,
TK_OP_BIT_OR,TK_OP_BIT_XOR,TK_OP_BIT_INVERT,TK_CF_IF,TK_CF_ELIF,TK_CF_ELSE,TK_CF_FOR,TK_CF_WHILE,TK_CF_BREAK,
TK_CF_CONTINUE,TK_CF_PASS,TK_CF_RETURN,TK_CF_MATCH,TK_PR_FUNCTION,TK_PR_CLASS,TK_PR_CLASS_NAME,TK_PR_EXTENDS,
TK_PR_IS,TK_PR_ONREADY,TK_PR_TOOL,TK_PR_STATIC,TK_PR_EXPORT,TK_PR_SETGET,TK_PR_CONST,TK_PR_VAR,TK_PR_AS,
TK_PR_VOID,TK_PR_ENUM,TK_PR_PRELOAD,TK_PR_ASSERT,TK_PR_YIELD,TK_PR_SIGNAL,TK_PR_BREAKPOINT,TK_PR_REMOTE,
TK_PR_SYNC,TK_PR_MASTER,TK_PR_SLAVE,TK_PR_PUPPET,TK_PR_REMOTESYNC,TK_PR_MASTERSYNC,TK_PR_PUPPETSYNC,
TK_BRACKET_OPEN,TK_BRACKET_CLOSE,TK_CURLY_BRACKET_OPEN,TK_CURLY_BRACKET_CLOSE,TK_PARENTHESIS_OPEN,
TK_PARENTHESIS_CLOSE,TK_COMMA,TK_SEMICOLON,TK_PERIOD,TK_QUESTION_MARK,TK_COLON,TK_DOLLAR,TK_FORWARD_ARROW,
TK_NEWLINE,TK_CONST_PI,TK_CONST_TAU,TK_WILDCARD,TK_CONST_INF,TK_CONST_NAN,TK_ERROR,TK_EOF,TK_CURSOR,TK_MAX}
enum{KEY_HORIZONTALTAB=9,KEY_LINEFEED=10,KEY_CARRIAGERETURN=13,KEY_SINGLEQUOTE=39,
KEY_DOUBLEQUOTE=34,KEY_BELL=7,KEY_BACKSPACE=8,KEY_VERTICALTAB=11,KEY_FORMFEED=12}
const token_words = Dictionary()
