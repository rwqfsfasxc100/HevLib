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

var pos:int = 0
var line:int = 1
var length:int = 0

func __source_to_tokens(source_code:String) -> bool:
	source_code=source_code.replace("\r","")
	var source_length:int = source_code.length()
	pos = 0
	line = 1
	length = source_length
	type_store.clear()
	args_store.clear()
	line_store.clear()
	char_store.clear()
	char_store.resize(source_length)
	for i in source_length:
		char_store[i] = source_code.ord_at(i)
	while true:
		if not next_token():
			return false
		if type_store[-1] == TK_EOF:
			break
	return true

func __get_compiled_bytecode_from_tokens() -> PoolByteArray:
	if not type_store.size():
		printerr("Token store is empty")
		return PoolByteArray()
	var identifier_map:Dictionary = {}
	var identifiers:PoolStringArray = PoolStringArray()
	var constant_map:Dictionary = {}
	var constants:Array = Array()
	var line_tokens:PoolIntArray = PoolIntArray()
	var line_numbers:PoolIntArray = PoolIntArray()
	var token_array:PoolIntArray = PoolIntArray()
	var line:int = -1
	for k in type_store.size():
		if line_store[k] != line:
			line = line_store[k]
			line_tokens.append(k)
			line_numbers.append(line)
		var t:int = type_store[k]
		var local_token:int = t
		if t == TK_IDENTIFIER:
			var id:String = args_store[k]
			if!id in identifiers:
				identifier_map[id] = identifiers.size()
				identifiers.append(id)
			local_token |= (identifier_map[id] << 8)
		elif t == TK_CONSTANT:
			var constant_val = args_store[k]
			var key:String = ""
			match typeof(constant_val):
				TYPE_NIL:
					key = "nil"
				TYPE_BOOL:
					key = "b" + str(constant_val)
				TYPE_INT:
					key = "i" + str(constant_val)
				TYPE_REAL:
					var tmp:StreamPeerBuffer = StreamPeerBuffer.new()
					tmp.put_double(constant_val)
					key = "f" + str(tmp.data_array)
				TYPE_STRING:
					key = "s" + constant_val
				TYPE_NODE_PATH:
					key = "n" + str(constant_val)
				_:
					key = "?" + str(constant_val)
			if not key in constants:
				constant_map[key] = constants.size()
				constants.append(constant_val)
			local_token |= (constant_map[key] << 8)
		elif t == TK_BUILT_IN_TYPE or t == TK_BUILT_IN_FUNC or t == TK_NEWLINE:
			local_token |= (args_store[k] << 8)
		token_array.append(local_token)
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
		out.put_u8(0 ^ 0xb6)
		for e in extra:
			out.put_u8(0 ^ 0xb6)
	for v in constants:
		match typeof(v):
			TYPE_NIL:
				out.put_u32(0)
			TYPE_BOOL:
				out.put_u32(1)
				out.put_u32(1 if v else 0)
			TYPE_INT:
				if v > 2147483647 or v < -2147483648:
					out.put_u32(2 | (1 << 16))
					out.put_64(v)
				else:
					out.put_u32(2)
					out.put_32(v)
			TYPE_REAL:
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
					out.put_u32(3 | (1 << 16))
					out.put_double(v)
			TYPE_STRING:
				out.put_u32(4)
				stream_string(out,v)
			TYPE_NODE_PATH:
				var np:NodePath = v
				out.put_u32(15)
				out.put_u32(np.get_name_count() | 0x80000000)
				out.put_u32(np.get_subname_count())
				out.put_u32(1 if np.is_absolute() else 0)
				for i in np.get_name_count():
					stream_string(out,np.get_name(i))
				for i in np.get_subname_count():
					stream_string(out,np.get_subname(i))
			_:
				printerr("Cannot encode constant of type %d" % typeof(v))
				return PoolByteArray()
	for k in line_tokens.size():
		out.put_u32(line_tokens[k])
		out.put_u32(line_numbers[k])
	for tk in token_array:
		if tk & ~0xFF:
			out.put_u32(tk | 0x80)
		else:
			out.put_u8(tk)
	return out.data_array

func __get_token_string_name(token:int) -> String:
	if token in token_list:
		return token_lookup[token]
	return ""

func __is_static_token(token:int) -> bool:
	return token in static_token_list

func __get_static_token(token:int) -> String:
	return static_tokens[token]

func __compiled_bytecode_to_tokens(bytes:PoolByteArray) -> bool:
	gdc_bytes.clear()
	gdc_bytes.append_array(bytes)
	length = bytes.size()
	line = 1
	pos = 0
	
	if length < 24:
		printerr("Data too short to be a GDScript token buffer (%d gdc_bytes)" % length)
		return false
	if gdc_bytes[0] != 0x47 or gdc_bytes[1] != 0x44 or gdc_bytes[2] != 0x53 or gdc_bytes[3] != 0x43:
		printerr("Missing GDSC header")
		return false
	pos = 4
	if get_uint32() != 13:
		printerr("Unsupported bytecode version")
		return false
	
	var identifier_count:int = get_uint32()
	var constant_count:int = get_uint32()
	var line_count:int = get_uint32()
	var token_count:int = get_uint32()
	var rest:int = length - pos
	
	if identifier_count * 4 > rest or constant_count * 4 > rest or line_count * 8 > rest or token_count > rest:
		printerr("Header counts exceed the size of the data")
		return false
	var identifiers:Array = []
	for i in identifier_count:
		var l:int = get_uint32()
		if l > length - pos:
			printerr("Invalid identifier length %d" % l)
			return false
		var decoded:PoolByteArray = PoolByteArray()
		for byte in get_next_bytes(l):
			byte ^= 0xb6
			if byte == 0:
				break
			decoded.append(byte)
		identifiers.append(decoded.get_string_from_utf8())
	var constants:Array = []
	for i in constant_count:
		constants.append(get_const())
	if line_count * 8 > length - pos:
		printerr("Invalid line count")
		return false
	var line_at:Dictionary = {}
	var line_list:PoolIntArray = PoolIntArray()
	line_list.resize(line_count)
	for i in line_count:
		var v:int = get_uint32()
		line_at[v] = get_uint32()
		line_list[i] = v
	type_store.resize(token_count)
	args_store.resize(token_count)
	line_store.resize(token_count)
	
	var current_line:int = 1
	for i in token_count:
		if length - pos < 1:
			printerr("Unexpected end of data in token list")
			return false
		var value:int = 0
		if gdc_bytes[pos] & 0x80:
			if length - pos < 4:
				printerr("Unexpected end of data in token list")
				return false
			value = get_uint32() & ~0x80
		else:
			value = gdc_bytes[pos]
			pos += 1
		var type:int = value & 0xFF
		var arg:int = value >> 8
		if type >= TK_MAX:
			printerr("Unknown token id %d at token %d" % [type, i])
			return false
		var payload = null
		match type:
			TK_IDENTIFIER:
				if arg >= identifiers.size():
					printerr("Identifier index %d out of range at token %d" % [arg, i])
					return false
				payload = identifiers[arg]
			TK_CONSTANT:
				if arg >= constants.size():
					printerr("Constant index %d out of range at token %d" % [arg, i])
					return false
				payload = constants[arg]
			TK_BUILT_IN_TYPE,TK_BUILT_IN_FUNC,TK_NEWLINE:
				payload = arg
		if i in line_list:
			current_line = line_at[i]
		type_store[i] = type
		args_store[i] = payload
		line_store[i] = current_line
	return true

func __tokens_to_source() -> String:
	var token_count:int = type_store.size()
	if token_count and args_store.size() != token_count or line_store.size() != token_count:
		printerr("SCRIPT DECOMPILE ERR: type, args, and line stores must be the same size")
		return ""
	
	var tab_ctr:PoolIntArray = PoolIntArray()
	var nesting_level:PoolIntArray = PoolIntArray()
	var depth_at:PoolIntArray = PoolIntArray()
	
	depth_at.resize(token_count)
	tab_ctr.resize(token_count)
	nesting_level.resize(token_count)
	
	var depth:int = 0
	var widths:Array = [0]
	var level:int = 0
	for i in token_count:
		var t:int = type_store[i]
		depth_at[i] = depth
		tab_ctr[i] = 0
		nesting_level[i] = level
		if t == TK_PARENTHESIS_OPEN or t == TK_BRACKET_OPEN or t == TK_CURLY_BRACKET_OPEN:
			depth += 1
		elif t == TK_PARENTHESIS_CLOSE or t == TK_BRACKET_CLOSE or TK_CURLY_BRACKET_CLOSE:
			var d1:int = depth - 1
			depth = d1 if d1 > 0 else 0
		elif t == TK_NEWLINE:
			if (i + 1 < token_count and type_store[i + 1] == TK_EOF) or not (i + 1 >= token_count or type_store[i + 1] != TK_NEWLINE):
				tab_ctr[i] = 0
			elif depth_at[i] > 0:
				tab_ctr[i] = level + depth_at[i]
			else:
				var w:int = args_store[i]
				while widths.size() > 1 and widths[-1] > w:
					widths.pop_back()
				if widths[-1] < w:
					widths.append(w)
				level = widths.size() - 1
				tab_ctr[i] = level
				nesting_level[i] = level
	
	var out:PoolStringArray = PoolStringArray()
	var line:int = 1
	var at_start:bool = true
	var prev:int = -1
	var prev_text:String = ""
	var prev_unary:bool = false
	var nodepath_state:int = 0
	var cont_tabs:int = 0
	
	var i:int = 0
	while i < token_count:
		var t:int = type_store[i]
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
			for k in (line_store[i] - line - 1):
				out.append("\\\n" if at_start else " \\\n")
				at_start = true
				line += 1
			out.append("\n" + "\t".repeat(tab_ctr[i]))
			var lsa:int = line_store[i]
			var lsb:int = line + 1
			line = lsa if lsa > lsb else lsb
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
		match type_store[i]:
			TK_IDENTIFIER:
				var identifier = args_store[i]
				if not identifier is String or identifier.empty():
					printerr("SCRIPT DECOMPILE ERR: Identifier token %d has no name" % i)
					return ""
				text = identifier
			TK_CONSTANT:
				var v = args_store[i]
				match typeof(v):
					TYPE_NIL:
						text = "null"
					TYPE_BOOL:
						text = "true" if v else "false"
					TYPE_INT:
						if v >= 0:
							text = str(v)
						else:
							var hi:int = (v >> 32) & 0xFFFFFFFF
							var lo:int = v & 0xFFFFFFFF
							text = "0x%08X%08X" % [hi, lo]
					TYPE_REAL:
						text = float_to_string(v)
					TYPE_STRING:
						text = escape_string_with_quotes(v)
					TYPE_NODE_PATH:
						text = "@" + escape_string_with_quotes(str(v))
					var ty:
						printerr("SCRIPT DECOMPILE ERR: Cannot write constant of type %d at token %d" % [ty, i])
						return ""
			TK_BUILT_IN_TYPE:
				var tid = args_store[i]
				if not tid is int or not type_names.has(tid):
					printerr("SCRIPT DECOMPILE ERR: Unknown built-in type id %s at token %d" % [tid, i])
					return ""
				text = type_names[tid]
			TK_BUILT_IN_FUNC:
				var fid = args_store[i]
				if not fid is int or fid < 0 or fid >= func_index_array.size():
					printerr("SCRIPT DECOMPILE ERR: Unknown built-in function id %s at token %d" % [fid, i])
					return ""
				text = func_index_array[fid]
			var tkx:
				if tkx in static_tokens:
					text = static_tokens[t]
				else:
					printerr("SCRIPT DECOMPILE ERR: Token id %d at token %d has no source text" % [tkx, i])
					return ""
		
		var skip_next:bool = false
		if t == TK_COLON and i + 1 < token_count and type_store[i + 1] == TK_OP_ASSIGN:
			text = ":="
			skip_next = true
		
		var sep:String = ""
		if not at_start and prev != -1:
			sep = get_string_separator(i, prev, prev_unary, nodepath_state, token_count)
			if sep.empty() and prev_text and text:
				var a:String = prev_text[-1]
				var b:String = text[0]
				if a in operator_characters and b in operator_characters:
					sep = " "
		if nodepath_state == 1:
			nodepath_state = 1 if t == TK_PERIOD else 2
		elif nodepath_state == 2:
			nodepath_state = 1 if (t == TK_OP_DIV and is_following_token_path(i + 1,token_count)) else 0
		if t == TK_COLON and skip_next and sep.empty():
			sep = " "
		
		var delta:int = line_store[i] - line
		var raw_multiline:bool = false
		var newline_count:int = 0
		if t == TK_CONSTANT and args_store[i] is String:
			newline_count = args_store[i].count("\n")
			if newline_count > 0 and delta >= newline_count:
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
			text = "\"\"\"" + escape_string(args_store[i], true) + "\"\"\""
			line += newline_count
		
		if t == TK_DOLLAR:
			nodepath_state = 1
		
		out.append(sep + text)
		at_start = false
		
		prev_unary = false
		if t == TK_OP_SUB or t == TK_OP_ADD:
			prev_unary = (prev == -1) or not is_token_operand_end(prev)
		elif t == TK_OP_BIT_INVERT:
			prev_unary = true
		prev = i
		prev_text = text
		i += 2 if skip_next else 1
	
	var source:String = out.join("")
	if source and not source.ends_with("\n"):
		source += "\n"
	
	return source

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
const token_list = PoolIntArray([TK_EMPTY,TK_IDENTIFIER,TK_CONSTANT,TK_SELF,TK_BUILT_IN_TYPE,TK_BUILT_IN_FUNC,TK_OP_IN,TK_OP_EQUAL,
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
	TK_NEWLINE,TK_CONST_PI,TK_CONST_TAU,TK_WILDCARD,TK_CONST_INF,TK_CONST_NAN,TK_ERROR,TK_EOF,TK_CURSOR,TK_MAX])
const static_token_list = PoolIntArray([TK_SELF,TK_OP_IN,TK_OP_EQUAL,
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
	TK_NEWLINE,TK_CONST_PI,TK_CONST_TAU,TK_WILDCARD,TK_CONST_INF,TK_CONST_NAN])
const token_lookup = {
	TK_EMPTY:"TK_EMPTY",
	TK_IDENTIFIER:"TK_IDENTIFIER",
	TK_CONSTANT:"TK_CONSTANT",
	TK_SELF:"TK_SELF",
	TK_BUILT_IN_TYPE:"TK_BUILT_IN_TYPE",
	TK_BUILT_IN_FUNC:"TK_BUILT_IN_FUNC",
	TK_OP_IN:"TK_OP_IN",
	TK_OP_EQUAL:"TK_OP_EQUAL",
	TK_OP_NOT_EQUAL:"TK_OP_NOT_EQUAL",
	TK_OP_LESS:"TK_OP_LESS",
	TK_OP_LESS_EQUAL:"TK_OP_LESS_EQUAL",
	TK_OP_GREATER:"TK_OP_GREATER",
	TK_OP_GREATER_EQUAL:"TK_OP_GREATER_EQUAL",
	TK_OP_AND:"TK_OP_AND",
	TK_OP_OR:"TK_OP_OR",
	TK_OP_NOT:"TK_OP_NOT",
	TK_OP_ADD:"TK_OP_ADD",
	TK_OP_SUB:"TK_OP_SUB",
	TK_OP_MUL:"TK_OP_MUL",
	TK_OP_DIV:"TK_OP_DIV",
	TK_OP_MOD:"TK_OP_MOD",
	TK_OP_SHIFT_LEFT:"TK_OP_SHIFT_LEFT",
	TK_OP_SHIFT_RIGHT:"TK_OP_SHIFT_RIGHT",
	TK_OP_ASSIGN:"TK_OP_ASSIGN",
	TK_OP_ASSIGN_ADD:"TK_OP_ASSIGN_ADD",
	TK_OP_ASSIGN_SUB:"TK_OP_ASSIGN_SUB",
	TK_OP_ASSIGN_MUL:"TK_OP_ASSIGN_MUL",
	TK_OP_ASSIGN_DIV:"TK_OP_ASSIGN_DIV",
	TK_OP_ASSIGN_MOD:"TK_OP_ASSIGN_MOD",
	TK_OP_ASSIGN_SHIFT_LEFT:"TK_OP_ASSIGN_SHIFT_LEFT",
	TK_OP_ASSIGN_SHIFT_RIGHT:"TK_OP_ASSIGN_SHIFT_RIGHT",
	TK_OP_ASSIGN_BIT_AND:"TK_OP_ASSIGN_BIT_AND",
	TK_OP_ASSIGN_BIT_OR:"TK_OP_ASSIGN_BIT_OR",
	TK_OP_ASSIGN_BIT_XOR:"TK_OP_ASSIGN_BIT_XOR",
	TK_OP_BIT_AND:"TK_OP_BIT_AND",
	TK_OP_BIT_OR:"TK_OP_BIT_OR",
	TK_OP_BIT_XOR:"TK_OP_BIT_XOR",
	TK_OP_BIT_INVERT:"TK_OP_BIT_INVERT",
	TK_CF_IF:"TK_CF_IF",
	TK_CF_ELIF:"TK_CF_ELIF",
	TK_CF_ELSE:"TK_CF_ELSE",
	TK_CF_FOR:"TK_CF_FOR",
	TK_CF_WHILE:"TK_CF_WHILE",
	TK_CF_BREAK:"TK_CF_BREAK",
	TK_CF_CONTINUE:"TK_CF_CONTINUE",
	TK_CF_PASS:"TK_CF_PASS",
	TK_CF_RETURN:"TK_CF_RETURN",
	TK_CF_MATCH:"TK_CF_MATCH",
	TK_PR_FUNCTION:"TK_PR_FUNCTION",
	TK_PR_CLASS:"TK_PR_CLASS",
	TK_PR_CLASS_NAME:"TK_PR_CLASS_NAME",
	TK_PR_EXTENDS:"TK_PR_EXTENDS",
	TK_PR_IS:"TK_PR_IS",
	TK_PR_ONREADY:"TK_PR_ONREADY",
	TK_PR_TOOL:"TK_PR_TOOL",
	TK_PR_STATIC:"TK_PR_STATIC",
	TK_PR_EXPORT:"TK_PR_EXPORT",
	TK_PR_SETGET:"TK_PR_SETGET",
	TK_PR_CONST:"TK_PR_CONST",
	TK_PR_VAR:"TK_PR_VAR",
	TK_PR_AS:"TK_PR_AS",
	TK_PR_VOID:"TK_PR_VOID",
	TK_PR_ENUM:"TK_PR_ENUM",
	TK_PR_PRELOAD:"TK_PR_PRELOAD",
	TK_PR_ASSERT:"TK_PR_ASSERT",
	TK_PR_YIELD:"TK_PR_YIELD",
	TK_PR_SIGNAL:"TK_PR_SIGNAL",
	TK_PR_BREAKPOINT:"TK_PR_BREAKPOINT",
	TK_PR_REMOTE:"TK_PR_REMOTE",
	TK_PR_SYNC:"TK_PR_SYNC",
	TK_PR_MASTER:"TK_PR_MASTER",
	TK_PR_SLAVE:"TK_PR_SLAVE",
	TK_PR_PUPPET:"TK_PR_PUPPET",
	TK_PR_REMOTESYNC:"TK_PR_REMOTESYNC",
	TK_PR_MASTERSYNC:"TK_PR_MASTERSYNC",
	TK_PR_PUPPETSYNC:"TK_PR_PUPPETSYNC",
	TK_BRACKET_OPEN:"TK_BRACKET_OPEN",
	TK_BRACKET_CLOSE:"TK_BRACKET_CLOSE",
	TK_CURLY_BRACKET_OPEN:"TK_CURLY_BRACKET_OPEN",
	TK_CURLY_BRACKET_CLOSE:"TK_CURLY_BRACKET_CLOSE",
	TK_PARENTHESIS_OPEN:"TK_PARENTHESIS_OPEN",
	TK_PARENTHESIS_CLOSE:"TK_PARENTHESIS_CLOSE",
	TK_COMMA:"TK_COMMA",
	TK_SEMICOLON:"TK_SEMICOLON",
	TK_PERIOD:"TK_PERIOD",
	TK_QUESTION_MARK:"TK_QUESTION_MARK",
	TK_COLON:"TK_COLON",
	TK_DOLLAR:"TK_DOLLAR",
	TK_FORWARD_ARROW:"TK_FORWARD_ARROW",
	TK_NEWLINE:"TK_NEWLINE",
	TK_CONST_PI:"TK_CONST_PI",
	TK_CONST_TAU:"TK_CONST_TAU",
	TK_WILDCARD:"TK_WILDCARD",
	TK_CONST_INF:"TK_CONST_INF",
	TK_CONST_NAN:"TK_CONST_NAN",
	TK_ERROR:"TK_ERROR",
	TK_EOF:"TK_EOF",
	TK_CURSOR:"TK_CURSOR",
}
const static_tokens = {
	TK_SELF:"self",
	TK_OP_IN:"in",
	TK_OP_EQUAL:"==",
	TK_OP_NOT_EQUAL:"!=",
	TK_OP_LESS:"<",
	TK_OP_LESS_EQUAL:"<=",
	TK_OP_GREATER:">",
	TK_OP_GREATER_EQUAL:">=",
	TK_OP_AND:"and",
	TK_OP_OR:"or",
	TK_OP_NOT:"not",
	TK_OP_ADD:"+",
	TK_OP_SUB:"-",
	TK_OP_MUL:"*",
	TK_OP_DIV:"/",
	TK_OP_MOD:"%",
	TK_OP_SHIFT_LEFT:"<<",
	TK_OP_SHIFT_RIGHT:">>",
	TK_OP_ASSIGN:"=",
	TK_OP_ASSIGN_ADD:"+=",
	TK_OP_ASSIGN_SUB:"-=",
	TK_OP_ASSIGN_MUL:"*=",
	TK_OP_ASSIGN_DIV:"/=",
	TK_OP_ASSIGN_MOD:"%=",
	TK_OP_ASSIGN_SHIFT_LEFT:"<<=",
	TK_OP_ASSIGN_SHIFT_RIGHT:">>=",
	TK_OP_ASSIGN_BIT_AND:"&=",
	TK_OP_ASSIGN_BIT_OR:"|=",
	TK_OP_ASSIGN_BIT_XOR:"^=",
	TK_OP_BIT_AND:"&",
	TK_OP_BIT_OR:"|",
	TK_OP_BIT_XOR:"^",
	TK_OP_BIT_INVERT:"~",
	TK_CF_IF:"if",
	TK_CF_ELIF:"elif",
	TK_CF_ELSE:"else",
	TK_CF_FOR:"for",
	TK_CF_WHILE:"while",
	TK_CF_BREAK:"break",
	TK_CF_CONTINUE:"continue",
	TK_CF_PASS:"pass",
	TK_CF_RETURN:"return",
	TK_CF_MATCH:"match",
	TK_PR_FUNCTION:"func",
	TK_PR_CLASS:"class",
	TK_PR_CLASS_NAME:"class_name",
	TK_PR_EXTENDS:"extends",
	TK_PR_IS:"is",
	TK_PR_ONREADY:"onready",
	TK_PR_TOOL:"tool",
	TK_PR_STATIC:"static",
	TK_PR_EXPORT:"export",
	TK_PR_SETGET:"setget",
	TK_PR_CONST:"const",
	TK_PR_VAR:"var",
	TK_PR_AS:"as",
	TK_PR_VOID:"void",
	TK_PR_ENUM:"enum",
	TK_PR_PRELOAD:"preload",
	TK_PR_ASSERT:"assert",
	TK_PR_YIELD:"yield",
	TK_PR_SIGNAL:"signal",
	TK_PR_BREAKPOINT:"breakpoint",
	TK_PR_REMOTE:"remote",
	TK_PR_SYNC:"sync",
	TK_PR_MASTER:"master",
	TK_PR_SLAVE:"slave",
	TK_PR_PUPPET:"puppet",
	TK_PR_REMOTESYNC:"remotesync",
	TK_PR_MASTERSYNC:"mastersync",
	TK_PR_PUPPETSYNC:"puppetsync",
	TK_BRACKET_OPEN:"[",
	TK_BRACKET_CLOSE:"]",
	TK_CURLY_BRACKET_OPEN:"{",
	TK_CURLY_BRACKET_CLOSE:"}",
	TK_PARENTHESIS_OPEN:"(",
	TK_PARENTHESIS_CLOSE:")",
	TK_COMMA:",",
	TK_SEMICOLON:";",
	TK_PERIOD:".",
	TK_QUESTION_MARK:"?",
	TK_COLON:":",
	TK_DOLLAR:"$",
	TK_FORWARD_ARROW:"->",
	TK_NEWLINE:"\n",
	TK_CONST_PI:"PI",
	TK_CONST_TAU:"TAU",
	TK_WILDCARD:"_",
	TK_CONST_INF:"INF",
	TK_CONST_NAN:"NAN",
}

const func_index={
	"sin":0,"cos":1,"tan":2,"sinh":3,"cosh":4,"tanh":5,"asin":6,"acos":7,"atan":8,"atan2":9,
	"sqrt":10,"fmod":11,"fposmod":12,"posmod":13,"floor":14,"ceil":15,"round":16,"abs":17,"sign":18,"pow":19,
	"log":20,"exp":21,"is_nan":22,"is_inf":23,"is_equal_approx":24,"is_zero_approx":25,"ease":26,"decimals":27,
	"step_decimals":28,"stepify":29,"lerp":30,"lerp_angle":31,"inverse_lerp":32,"range_lerp":33,
	"smoothstep":34,"move_toward":35,"dectime":36,"randomize":37,"randi":38,"randf":39,"rand_range":40,"seed":41,
	"rand_seed":42,"deg2rad":43,"rad2deg":44,"linear2db":45,"db2linear":46,"polar2cartesian":47,
	"cartesian2polar":48,"wrapi":49,"wrapf":50,"max":51,"min":52,"clamp":53,"nearest_po2":54,
	"weakref":55,"funcref":56,"convert":57,"typeof":58,"type_exists":59,"char":60,"ord":61,"str":62,
	"print":63,"printt":64,"prints":65,"printerr":66,"printraw":67,"print_debug":68,"push_error":69,
	"push_warning":70,"var2str":71,"str2var":72,"var2bytes":73,"bytes2var":74,"range":75,"load":76,
	"inst2dict":77,"dict2inst":78,"validate_json":79,"parse_json":80,"to_json":81,"hash":82,"Color8":83,"ColorN":84,
	"print_stack":85,"get_stack":86,"instance_from_id":87,"len":88,"is_instance_valid":89,"deep_equal":90,
}
const func_index_array = PoolStringArray([
	"sin","cos","tan","sinh","cosh","tanh","asin",
	"acos","atan","atan2","sqrt","fmod","fposmod","posmod","floor","ceil",
	"round","abs","sign","pow","log","exp","is_nan","is_inf","is_equal_approx",
	"is_zero_approx","ease","decimals","step_decimals","stepify","lerp",
	"lerp_angle","inverse_lerp","range_lerp","smoothstep","move_toward","dectime",
	"randomize","randi","randf","rand_range","seed","rand_seed","deg2rad",
	"rad2deg","linear2db","db2linear","polar2cartesian","cartesian2polar",
	"wrapi","wrapf","max","min","clamp","nearest_po2","weakref","funcref",
	"convert","typeof","type_exists","char","ord","str","print","printt","prints",
	"printerr","printraw","print_debug","push_error","push_warning","var2str",
	"str2var","var2bytes","bytes2var","range","load","inst2dict","dict2inst",
	"validate_json","parse_json","to_json","hash","Color8","ColorN","print_stack",
	"get_stack","instance_from_id","len","is_instance_valid","deep_equal",
])
const type_index={
	"bool":TYPE_BOOL,"int":TYPE_INT,"float":TYPE_REAL,"String":TYPE_STRING,
	"Vector2":TYPE_VECTOR2,"Rect2":TYPE_RECT2,"Vector3":TYPE_VECTOR3,"Transform2D":TYPE_TRANSFORM2D,
	"Plane":TYPE_PLANE,"Quat":TYPE_QUAT,"AABB":TYPE_AABB,"Basis":TYPE_BASIS,
	"Transform":TYPE_TRANSFORM,"Color":TYPE_COLOR,"NodePath":TYPE_NODE_PATH,"RID":TYPE_RID,
	"Object":TYPE_OBJECT,"Dictionary":TYPE_DICTIONARY,"Array":TYPE_ARRAY,
	"PoolByteArray":TYPE_RAW_ARRAY,"PoolIntArray":TYPE_INT_ARRAY,"PoolRealArray":TYPE_REAL_ARRAY,
	"PoolStringArray":TYPE_STRING_ARRAY,"PoolVector2Array":TYPE_VECTOR2_ARRAY,
	"PoolVector3Array":TYPE_VECTOR3_ARRAY,"PoolColorArray":TYPE_COLOR_ARRAY,
}
const type_index_array = PoolStringArray([
	"bool","int","float","String","Vector2","Rect2","Vector3","Transform2D",
	"Plane","Quat","AABB","Basis","Transform","Color","NodePath","RID",
	"Object","Dictionary","Array","PoolByteArray","PoolIntArray","PoolRealArray",
	"PoolStringArray","PoolVector2Array","PoolVector3Array","PoolColorArray",
])
const type_names = {
	1:"bool",2:"int",3:"float",4:"String",5:"Vector2",6:"Rect2",7: "Vector3",
	8:"Transform2D",9:"Plane",10:"Quat",11:"AABB",12:"Basis",13:"Transform",
	14:"Color",15:"NodePath",16:"RID",17:"Object",18:"Dictionary",19:"Array",
	20:"PoolByteArray",21:"PoolIntArray",22:"PoolRealArray",23:"PoolStringArray",
	24: "PoolVector2Array", 25: "PoolVector3Array", 26: "PoolColorArray",
}
const keywords={
	"in":TK_OP_IN,"not":TK_OP_NOT,"or":TK_OP_OR,"and":TK_OP_AND,
	"func":TK_PR_FUNCTION,"class":TK_PR_CLASS,"class_name":TK_PR_CLASS_NAME,
	"extends":TK_PR_EXTENDS,"is":TK_PR_IS,"onready":TK_PR_ONREADY,
	"tool":TK_PR_TOOL,"static":TK_PR_STATIC,"export":TK_PR_EXPORT,
	"setget":TK_PR_SETGET,"var":TK_PR_VAR,"as":TK_PR_AS,"void":TK_PR_VOID,
	"preload":TK_PR_PRELOAD,"assert":TK_PR_ASSERT,"yield":TK_PR_YIELD,
	"signal":TK_PR_SIGNAL,"breakpoint":TK_PR_BREAKPOINT,
	"remote":TK_PR_REMOTE,"master":TK_PR_MASTER,"slave":TK_PR_SLAVE,
	"puppet":TK_PR_PUPPET,"sync":TK_PR_SYNC,"remotesync":TK_PR_REMOTESYNC,
	"mastersync":TK_PR_MASTERSYNC,"puppetsync":TK_PR_PUPPETSYNC,
	"const":TK_PR_CONST,"enum":TK_PR_ENUM,
	"if":TK_CF_IF,"elif":TK_CF_ELIF,"else":TK_CF_ELSE,"for":TK_CF_FOR,
	"while":TK_CF_WHILE,"break":TK_CF_BREAK,"continue":TK_CF_CONTINUE,
	"return":TK_CF_RETURN,"match":TK_CF_MATCH,"pass":TK_CF_PASS,
	"self":TK_SELF,"PI":TK_CONST_PI,"TAU":TK_CONST_TAU,"_":TK_WILDCARD,
	"INF":TK_CONST_INF,"NAN":TK_CONST_NAN,
}
const keyword_array = PoolStringArray([
	"in","not","or","and","func","class","class_name","extends","is","onready",
	"tool","static","export","setget","var","as","void","preload","assert","yield",
	"signal","breakpoint","remote","master","slave","puppet","sync","remotesync",
	"mastersync","puppetsync","const","enum","if","elif","else","for","while",
	"break","continue","return","match","pass","self","PI","TAU","_","INF","NAN",
])
const compile_err_header="SCRIPT COMPILE ERR - line %d: %s"
const decompile_err_header="SCRIPT DECOMPILE ERR - line %d: %s"
enum{
	KEY_HORIZONTALTAB=9,KEY_LINEFEED=10,KEY_CARRIAGERETURN=13,KEY_SINGLEQUOTE=39,
	KEY_DOUBLEQUOTE=34,KEY_BELL=7,KEY_BACKSPACE=8,KEY_VERTICALTAB=11,KEY_FORMFEED=12,
}

const operator_characters = "+-*/%=<>!&|^~"

var type_store:PoolIntArray = PoolIntArray()
var args_store:Array = Array()
var line_store:PoolIntArray = PoolIntArray()
var char_store:PoolIntArray = PoolIntArray()

var builtin_classes = ClassDB.get_class_list() + type_index_array

static func stream_string(out:StreamPeerBuffer,s:String)->void:
	var u:PoolByteArray = s.to_utf8()
	out.put_u32(u.size())
	for b in u:
		out.put_u8(b)
	for p in (4 - (u.size() % 4)) % 4:
		out.put_u8(0)

func next_token() -> bool:
	if pos > length:
		push_token(TK_EOF)
		return true
	while true:
		var ch:int = get_char(0)
		if ch == 0:
			push_token(TK_EOF)
			return true
		
		if ch == KEY_BACKSLASH:
			pos += 1
			if get_char(0) != KEY_LINEFEED:
				printerr(compile_err_header % [line,"Expected newline after '\\'."])
				return false
			pos += 1
			line += 1
			while true:
				var cr:int = get_char(0)
				if not (cr == KEY_SPACE or cr == KEY_HORIZONTALTAB):
					break
				pos += 1
			continue
		
		if ch == KEY_HORIZONTALTAB or ch == KEY_SPACE:
			pos += 1
			continue
		
		if ch == KEY_NUMBERSIGN:
			while get_char(0) != KEY_LINEFEED:
				pos += 1
				if get_char(0) == 0:
					push_token(TK_EOF)
					return true
			ch = KEY_LINEFEED
		
		if ch == KEY_LINEFEED:
			line += 1
			pos += 1
			var used_spaces:bool = get_char(0) == KEY_SPACE
			var i:int = 0
			while true:
				var wc:int = get_char(i)
				if wc == KEY_SPACE:
					if not used_spaces:
						printerr(compile_err_header % [line,"Mixed tabs and spaces in indentation"])
						return false
					i += 1
				elif wc == KEY_HORIZONTALTAB:
					if used_spaces:
						printerr(compile_err_header % [line,"Spaces used before tabs on a line"])
						return false
					i += 1
				else:
					break
			push_token(TK_NEWLINE,i)
			return true
		
		if ch == KEY_AT or ch == KEY_DOUBLEQUOTE or ch == KEY_SINGLEQUOTE:
			return read_string_token(ch)
		
		if word_is_number(ch) or (ch == KEY_PERIOD and word_is_number(get_char(1))):
			return read_number_token()
		
		if word_is_tex(ch):
			return read_word_token(ch)
		
		var n1:int = get_char(1)
		var n2:int = get_char(2)
		var tok:int = -1
		var width:int = 1
		match ch:
			KEY_SLASH:
				if n1 == KEY_EQUAL:
					tok = TK_OP_ASSIGN_DIV
					width = 2
				else:
					tok = TK_OP_DIV
			KEY_EQUAL:
				if n1 == KEY_EQUAL:
					tok = TK_OP_EQUAL
					width = 2
				else:
					tok = TK_OP_ASSIGN
			KEY_LESS:
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
			KEY_GREATER:
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
			KEY_EXCLAM:
				if n1 == KEY_EQUAL:
					tok = TK_OP_NOT_EQUAL
					width = 2
				else:
					tok = TK_OP_NOT
			KEY_BRACELEFT: tok = TK_CURLY_BRACKET_OPEN
			KEY_BRACERIGHT: tok = TK_CURLY_BRACKET_CLOSE
			KEY_BRACKETLEFT: tok = TK_BRACKET_OPEN
			KEY_BRACKETRIGHT: tok = TK_BRACKET_CLOSE
			KEY_PARENLEFT: tok = TK_PARENTHESIS_OPEN
			KEY_PARENRIGHT: tok = TK_PARENTHESIS_CLOSE
			KEY_COMMA: tok = TK_COMMA
			KEY_SEMICOLON: tok = TK_SEMICOLON
			KEY_QUESTION: tok = TK_QUESTION_MARK
			KEY_COLON: tok = TK_COLON
			KEY_DOLLAR: tok = TK_DOLLAR
			KEY_ASCIICIRCUM:
				if n1 == KEY_EQUAL:
					tok = TK_OP_ASSIGN_BIT_XOR
					width = 2
				else:
					tok = TK_OP_BIT_XOR
			KEY_ASCIITILDE: tok = TK_OP_BIT_INVERT
			KEY_AMPERSAND:
				if n1 == KEY_AMPERSAND:
					tok = TK_OP_AND
					width = 2
				elif n1 == KEY_EQUAL:
					tok = TK_OP_ASSIGN_BIT_AND
					width = 2
				else:
					tok = TK_OP_BIT_AND
			KEY_BAR:
				if n1 == KEY_BAR:
					tok = TK_OP_OR
					width = 2
				elif n1 == KEY_EQUAL:
					tok = TK_OP_ASSIGN_BIT_OR
					width = 2
				else:
					tok = TK_OP_BIT_OR
			KEY_ASTERISK:
				if n1 == KEY_EQUAL:
					tok = TK_OP_ASSIGN_MUL
					width = 2
				else:
					tok = TK_OP_MUL
			KEY_PLUS:
				if n1 == KEY_EQUAL:
					tok = TK_OP_ASSIGN_ADD
					width = 2
				else:
					tok = TK_OP_ADD
			KEY_MINUS:
				if n1 == KEY_EQUAL:
					tok = TK_OP_ASSIGN_SUB
					width = 2
				elif n1 == KEY_GREATER:
					tok = TK_FORWARD_ARROW
					width = 2
				else:
					tok = TK_OP_SUB
			KEY_PERCENT:
				if n1 == KEY_EQUAL:
					tok = TK_OP_ASSIGN_MOD
					width = 2
				else:
					tok = TK_OP_MOD
			KEY_PERIOD:
				tok = TK_PERIOD
		if tok == -1:
			printerr(compile_err_header % [line,"Unknown character"])
			return false
		push_token(tok)
		pos += width
		return true
	return false

func read_word_token(ch:int)->bool:
	var s:String = char(ch)
	var i:int = 1
	while true:
		var cv:int = get_char(i)
		if word_is_tex(cv):
			s += char(cv)
			i += 1
		else:
			break
	if s == "null":
		push_token(TK_CONSTANT,null)
	elif s == "true":
		push_token(TK_CONSTANT,true)
	elif s == "false":
		push_token(TK_CONSTANT,false)
	elif s in type_index_array:
		push_token(TK_BUILT_IN_TYPE,type_index[s])
	elif s in func_index_array:
		push_token(TK_BUILT_IN_FUNC,func_index[s])
	elif s in keyword_array:
		push_token(keywords[s])
	else:
		push_token(TK_IDENTIFIER,s)
	pos += s.length()
	return true

func read_number_token()->bool:
	var is_floating:bool = false
	var is_signed:bool = false
	var uses_exponent:bool = false
	var uses_hex:bool = false
	var uses_bin:bool = false
	var s:String = ""
	var i:int = 0
	while true:
		var c:int = get_char(i)
		if c == KEY_PERIOD:
			if is_floating or uses_exponent:
				printerr(compile_err_header % [line,"Invalid numeric constant at '.'"])
				return false
			if uses_bin:
				printerr(compile_err_header % [line,"Invalid binary constant at '.'"])
				return false
			elif uses_hex:
				printerr(compile_err_header % [line,"Invalid hexadecimal constant at '.'"])
				return false
			is_floating=true
		elif c == 120: # x
			if uses_hex or uses_bin or s.length() != 1 or not ((i == 1 and s[0] == "0") or (i == 2 and s[1] == "0" and s[0] == "-")):
				printerr(compile_err_header % [line,"Invalid numeric constant at 'x'"])
				return false
			uses_hex=true
		elif uses_hex and (c >= KEY_0 and c <= KEY_9) or (c >= 97 and c <= 102) or (c >= KEY_A and c <= KEY_Z):
			pass
		elif not uses_hex and c==98: # b
			if uses_bin or s.length() != 1 or not ((i == 1 and s[0] == "0") or (i == 2 and s[1] == "0" and s[0] == "-")):
				printerr(compile_err_header % [line,"Invalid numeric constant at 'b'"])
				return false
			uses_bin=true
		elif not uses_hex and c == 101: # e
			if uses_exponent or uses_bin:
				printerr(compile_err_header % [line,"Invalid numeric constant at 'e'"])
				return false
			uses_exponent=true
		elif word_is_number(c):
			pass
		elif uses_bin and (c == KEY_0 or c == KEY_1):
			pass
		elif (c == KEY_MINUS or c == KEY_PLUS) and uses_exponent:
			if is_signed:
				printerr(compile_err_header % [line,"Invalid numeric constant at '-'"])
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
	if not (word_is_number(last) or (uses_hex and (last >= KEY_0 and last <= KEY_9) or (last >= 97 and last <= 102) or (last >= KEY_A and last <= KEY_Z))):
		printerr(compile_err_header % [line,"Invalid numeric constant: "+s])
		return false
	pos += i
	if uses_hex:
		push_token(TK_CONSTANT,radixify(s,2,4))
	elif uses_bin:
		push_token(TK_CONSTANT,radixify(s,2,1))
	elif is_floating or uses_exponent:
		if s.begins_with("."):
			s = "0" + s
		var v = str2var(s)
		if v is int or v is float:
			push_token(TK_CONSTANT,float(v))
		else:
			push_token(TK_CONSTANT,s.to_float())
	else:
		push_token(TK_CONSTANT,s.to_int())
	return true

func read_string_token(ch:int)->bool:
	var is_node_path:bool = false
	if ch == KEY_AT:
		var q:int = get_char(1)
		if q != KEY_DOUBLEQUOTE and q != KEY_SINGLEQUOTE:
			printerr(compile_err_header % [line,"Unexpected '@'"])
			return false
		pos += 1
		is_node_path = true
	var mode:int = 0
	if get_char(0) == KEY_SINGLEQUOTE:
		mode=1
	var i:int=1
	if mode == 0 and get_char(i) == KEY_DOUBLEQUOTE and get_char(i + 1) == KEY_DOUBLEQUOTE:
		i += 2
		mode = 2
	var s:String = ""
	while true:
		var c:int = get_char(i)
		if c == 0:
			printerr(compile_err_header % [line,"Unterminated String"])
			return false
		elif mode == 0 and c == KEY_DOUBLEQUOTE:
			break
		elif mode == 1 and c == KEY_SINGLEQUOTE:
			break
		elif mode == 2 and c == KEY_DOUBLEQUOTE and get_char(i + 1) == KEY_DOUBLEQUOTE and get_char(i + 2) == KEY_DOUBLEQUOTE:
			i+=2
			break
		elif mode != 2 and c == 10:
			printerr(compile_err_header % [line,"Unexpected EOL at String."])
			return false
		elif c == 0xFFFF:
			i -= 1
			break
		elif c == KEY_BACKSLASH:
			i += 1
			var nx:int = get_char(i)
			if nx == 0:
				printerr(compile_err_header % [line,"Unterminated String"])
				return false
			var res:int = 0
			match nx:
				97:res = 7 # a
				98:res = 8 # b
				116:res = 9 # t
				110:res = 10 # n
				118:res = 11 # v
				102:res = 12 # f
				114:res = 13 # r
				KEY_SINGLEQUOTE: res = KEY_SINGLEQUOTE
				KEY_DOUBLEQUOTE: res = KEY_DOUBLEQUOTE
				KEY_BACKSLASH: res = KEY_BACKSLASH
				KEY_SLASH: res = KEY_SLASH
				117: # u
					i += 1
					for j in 4:
						var hc:int = get_char(i + j)
						if hc == 0:
							printerr(compile_err_header % [line,"Unterminated String"])
							return false
						var v:int = 0
						if hc >= KEY_0 and hc <= KEY_9:
							v = hc - 48
						elif hc >= 97 and hc <= 102:
							v = hc - 97 + 10
						elif hc >= KEY_A and hc <= KEY_Z:
							v = hc - 65 + 10
						else:
							printerr(compile_err_header % [line,"Malformed hex constant in string"])
							return false
						res = (res << 4) | v
					i += 3
				_:
					printerr(compile_err_header % [line,"Invalid escape sequence"])
					return false
			s += char(res)
		else:
			if c == KEY_LINEFEED:
				line += 1
			s += char(c)
		i += 1
	pos += i
	if is_node_path:
		push_token(TK_CONSTANT,NodePath(s))
	else:
		push_token(TK_CONSTANT,s)
	pos += 1
	return true

static func radixify(s:String,start:int,radix:int) -> int:
	var v:int = 0
	for k in range(start,s.length()):
		var c:int = s.ord_at(k)
		var d:int = 0
		if c >= KEY_0 and c <= KEY_9:
			d = c - 48
		elif c >= 97 and c <= 102:
			d = c - 97 + 10
		else:
			d = c - 65 + 10
		if (v >> (63 - radix)) != 0:
			return 9223372036854775807
		v = (v << radix) | d
	return v

func push_token(type:int,arg = null) -> void:
	type_store.append(type)
	args_store.append(arg)
	line_store.append(line)

func get_char(offset:int) -> int:
	var p:int = pos + offset
	if p < 0 or p >= length:
		return 0
	return char_store[p]

static func word_is_number(c:int) -> bool:
	return c >= KEY_0 and c <= KEY_9

static func word_is_alpha(c:int) -> bool:
	return (c >= 97 and c <= 122) or (c >= KEY_A and c <= KEY_Z)

static func word_is_tex(c:int) -> bool:
	return (c >= 97 and c <= 122) or (c >= KEY_A and c<= KEY_Z) or (c >= KEY_0 and c <= KEY_9) or c == 95

const gdc_bytes = PoolByteArray()
func get_uint32() -> int:
	if pos + 4 > length:
		printerr("Unexpected end of data at offset %d" % pos)
		pos = length
		return 0
	var v:int = gdc_bytes[pos] | (gdc_bytes[pos + 1] << 8) | (gdc_bytes[pos + 2] << 16) | (gdc_bytes[pos + 3] << 24)
	pos += 4
	return v

func get_next_bytes(byte_count: int) -> PoolByteArray:
	if byte_count < 0 or pos + byte_count > length:
		printerr("Unexpected end of data at offset %d" % pos)
		pos = length
		return PoolByteArray()
	var out:PoolByteArray = PoolByteArray()
	if byte_count > 0:
		out = gdc_bytes.subarray(pos, pos + byte_count - 1)
	pos += byte_count
	return out

func get_string_data() -> String:
	var l:int = get_uint32()
	if l == 0:
		return ""
	var raw:PoolByteArray = get_next_bytes(l)
	var pad:int = (4 - (l % 4)) % 4
	if pos + pad > length:
		printerr("Unexpected end of data in string padding at offset %d" % pos)
		return ""
	pos += pad
	return raw.get_string_from_utf8()

func get_const():
	var header:int = get_uint32()
	match (header & 0xFF):
		TYPE_NIL:
			return null
		TYPE_BOOL:
			return get_uint32() != 0
		TYPE_INT:
			if (header & (1 << 16)) != 0:
				return get_uint32() | (get_uint32() << 32)
			var v:int = get_uint32()
			if v >= 0x80000000:
				v -= 0x100000000
			return v
		TYPE_REAL:
			var spb:StreamPeerBuffer = StreamPeerBuffer.new()
			if (header & (1 << 16)) != 0:
				spb.data_array = get_next_bytes(8)
				return spb.get_double()
			spb.data_array = get_next_bytes(4)
			return spb.get_float()
		TYPE_STRING:
			return get_string_data()
		TYPE_NODE_PATH:
			var names:int = get_uint32()
			if not (names & 0x80000000):
				printerr("Old-format NodePath constants are not supported")
				return null
			var name_count:int = names & 0x7FFFFFFF
			var subname_count:int = get_uint32()
			var flags:int = get_uint32()
			if name_count + subname_count > length - pos:
				printerr("Invalid NodePath constant")
				return null
			var name_list:PoolStringArray = PoolStringArray()
			for i in name_count:
				name_list.append(get_string_data())
			var sub_list:PoolStringArray = PoolStringArray()
			for i in subname_count:
				sub_list.append(get_string_data())
			var path:String = name_list.join("/")
			if flags & 1:
				path = "/" + path
			if subname_count > 0:
				path += ":" + sub_list.join(":")
			return NodePath(path)
		var vtype:
			printerr("Unsupported constant type %d at offset %d" % [vtype, pos])
			return null

const operand_word_tokens = PoolIntArray([TK_IDENTIFIER,TK_SELF,TK_BUILT_IN_TYPE,TK_BUILT_IN_FUNC,TK_OP_IN,TK_OP_NOT,TK_OP_AND,TK_OP_OR,TK_CF_IF,TK_PR_PUPPETSYNC,TK_CONST_PI,TK_CONST_TAU,TK_WILDCARD,TK_CONST_INF,TK_CONST_NAN])
const operand_end_tokens = PoolIntArray([TK_IDENTIFIER,TK_CONSTANT,TK_SELF,TK_BUILT_IN_TYPE,TK_BUILT_IN_FUNC,TK_PARENTHESIS_CLOSE,TK_BRACKET_CLOSE,TK_CURLY_BRACKET_CLOSE,TK_CONST_PI,TK_CONST_TAU,TK_WILDCARD,TK_CONST_INF,TK_CONST_NAN])
const operand_callable_tokens = PoolIntArray([TK_IDENTIFIER,TK_BUILT_IN_FUNC,TK_BUILT_IN_TYPE,TK_PARENTHESIS_CLOSE,TK_BRACKET_CLOSE,TK_PR_PRELOAD,TK_PR_YIELD,TK_PR_ASSERT,TK_PR_EXPORT])

func float_to_string(d:float) -> String:
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

func escape_string(s:String,keep_newlines:bool) -> String:
	var out:String = ""
	for k in s:
		match ord(k):
			KEY_BACKSLASH:
				out += "\\\\"
			KEY_DOUBLEQUOTE:
				out += "\\\""
			KEY_LINEFEED:
				out += ("\n" if keep_newlines else "\\n")
			KEY_HORIZONTALTAB:
				out += "\\t"
			KEY_CARRIAGERETURN:
				out += "\\r"
			KEY_BELL:
				out += "\\a"
			KEY_BACKSPACE:
				out += "\\b"
			KEY_VERTICALTAB:
				out += "\\v"
			KEY_FORMFEED:
				out += "\\f"
			var code:
				if code < KEY_SPACE or code == 0xFFFF:
					out += "\\u%04x" % code
				else:
					out += k
	return out

func escape_string_with_quotes(s:String) -> String:
	return "\"" + escape_string(s,false) + "\""

const closing_tokens = PoolIntArray([TK_PARENTHESIS_CLOSE,TK_BRACKET_CLOSE,TK_CURLY_BRACKET_CLOSE,TK_SEMICOLON,TK_COLON])
const opening_tokens = PoolIntArray([TK_DOLLAR,TK_PERIOD,TK_PARENTHESIS_OPEN,TK_BRACKET_OPEN,TK_CURLY_BRACKET_OPEN])

func get_string_separator(c:int,p:int,prev_unary:bool,nodepath_state:int,token_count:int) -> String:
	var ct:int = type_store[c]
	var pt:int = type_store[p]
	
	if nodepath_state == 1:
		if ct == TK_PERIOD or ct in operand_word_tokens or (ct == TK_CONSTANT and args_store[c] is String):
			return ""
	elif nodepath_state == 2:
		if ct == TK_OP_DIV and is_following_token_path(c + 1,token_count):
			return ""
	if prev_unary or ct in closing_tokens:
		return ""
	if ct == TK_COMMA:
		return " " if pt == TK_PR_SETGET else ""
	if pt in opening_tokens:
		return ""
	if ct == TK_PERIOD:
		if is_token_operand_end(p):
			return " " if (type_store[p] == TK_CONSTANT and args_store[p] is int or args_store[p] is float) else ""
		return " "
	if ct == TK_PARENTHESIS_OPEN:
		return "" if ((type_store[p] in operand_callable_tokens) or (p > 0 and type_store[p - 1] == TK_PERIOD and type_store[p] in operand_word_tokens)) else " "
	if ct == TK_BRACKET_OPEN:
		return "" if is_token_operand_end(p) else " "
	return " "

func is_token_operand_end(idx: int) -> bool:
	return (type_store[idx] in operand_end_tokens) or (idx > 0 and type_store[idx - 1] == TK_PERIOD and type_store[idx] in operand_word_tokens)

func is_following_token_path(idx: int,token_count:int) -> bool:
	if idx >= token_count:
		return false
	var t:int = type_store[idx]
	if t == TK_PERIOD or t in operand_word_tokens:
		return true
	return t == TK_CONSTANT and args_store[idx] is String
