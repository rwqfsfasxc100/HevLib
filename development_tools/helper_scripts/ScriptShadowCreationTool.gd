extends Reference
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
	TK_NEWLINE,TK_CONST_PI,TK_CONST_TAU,TK_WILDCARD,TK_CONST_INF,TK_CONST_NAN,TK_ERROR,TK_EOF,TK_CURSOR,}

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

const type_store:PoolIntArray = PoolIntArray()
const args_store:Array = Array()
const line_store:PoolIntArray = PoolIntArray()

var pointers:HevLibPointers._Tokenizer
var builtin_classes:PoolStringArray = PoolStringArray()
var file:File = File.new()
func __make_shadow_of_script(script_path:String,p:HevLibPointers):
	pointers = p.Tokenizer
	if not builtin_classes:
		builtin_classes = ClassDB.get_class_list() + PoolStringArray(pointers.type_index.keys())
		for i in builtin_classes.size():
			var cn:String = builtin_classes[i]
			if cn.begins_with("_"):
				builtin_classes[i] = cn.trim_prefix("_")

	var is_tool:bool = false

	var extension_type:int = 0
	var extension_class:String = ""
	var functions:Dictionary = {}
	var variables:Dictionary = {}
	var enumerations:PoolStringArray = PoolStringArray()
	var signals:Dictionary = {}
	var constants:PoolStringArray = PoolStringArray()
	var classes:Array = []

	var has_extended:bool = false

	while extension_type != 1:
		has_extended = false
		if not (file.file_exists(script_path) or ResourceLoader.exists(script_path)):
			return ""
		file.open(script_path,File.READ)
		var source_code:String = file.get_as_text()
		file.close()
		pointers.__source_to_tokens(source_code)
		type_store.clear()
		args_store.clear()
		line_store.clear()
		type_store.append_array(pointers.type_store)
		args_store.append_array(pointers.args_store)
		line_store.append_array(pointers.line_store)
		extension_type = 1
		extension_class = "Object"
		var current_indent:int = 0
		var idx:int = 0
		var token_count:int = type_store.size()
		while idx < token_count:
			var token:int = type_store[idx]
			if token == TK_NEWLINE:
				current_indent = args_store[idx]
			if current_indent > 0:
				idx += 1
				continue
			var arg = args_store[idx]
			match token:
				TK_PR_EXTENDS:
					idx += 1
					if not has_extended:
						extension_type = type_store[idx]
						extension_class = args_store[idx]
						if extension_type == TK_CONSTANT:
							script_path = extension_class
						has_extended = true
				TK_PR_CLASS_NAME:
					idx += 1
				TK_PR_FUNCTION:
					idx += 1
					var v:Array = get_function_data(idx)
					idx = v[1]
					var func_data:Dictionary = v[0]
					functions[func_data.name] = func_data
				TK_PR_VAR:
					var v:Array = get_var_data(idx)
					idx = v[1]
					var data:Dictionary = v[0]
					variables[data["name"]] = data["type_cast"]
				TK_PR_CONST:
					idx += 1
					var const_str:String = "const " + args_store[idx]
					idx += 1
					if type_store[idx] == TK_COLON:
						idx += 1
						var c:Array = get_property_type_cast(idx)
						const_str += ":" + c[0]
						idx = c[1]
					var r:Array = get_expression(idx)
					idx = r[1]
					const_str += r[0]
					constants.append(const_str)
				TK_PR_SIGNAL:
					idx += 1
					var sig_string:String = args_store[idx]
					var signal_args:PoolStringArray = PoolStringArray()
					idx += 1
					var has_parenthesis:bool = false
					while true:
						match type_store[idx]:
							TK_PARENTHESIS_CLOSE:
								break
							TK_IDENTIFIER:
								signal_args.append(args_store[idx])
								idx += 1
							TK_COMMA:
								idx += 1
							TK_PARENTHESIS_OPEN:
								has_parenthesis = true
								idx += 1
							TK_NEWLINE,TK_SEMICOLON:
								if has_parenthesis:
									idx += 1
								else:
									break
							TK_SEMICOLON:
								pass
							var tok:
								var tx = token_lookup[tok]
								breakpoint
					signals[sig_string] = signal_args
				TK_PR_ENUM:
					idx += 1
					var enum_str:String = "enum "
					if type_store[idx] == TK_IDENTIFIER:
						enum_str += args_store[idx]
						idx += 1
					var r:Array = get_expression(idx)
					idx = r[1]
					enum_str += r[0]
					enumerations.append(enum_str)
				TK_PR_CLASS:
					idx += 1
					classes.append(args_store[idx])
			idx += 1
	var compile:String = ""
	if is_tool:
		compile = "tool\n"
	compile += "extends %s\n\n" % extension_class
#	compile += "extends Object\n\n"

	var passthrough_object_name:String = "__objref_%d__" % randi()

	compile += "var %s\n" % passthrough_object_name
	compile += ("""
func _init(obj_to_ref):
	%s = obj_to_ref

""") % [passthrough_object_name]
	var setGet_template:String = ("""
var {var_name}{class_cast} setget __set__{var_name}__,__get__{var_name}__
func __set__{var_name}__(how):
	%s.{var_name} = how
func __get__{var_name}__():
	return %s.{var_name}

""") % [passthrough_object_name,passthrough_object_name]
	var class_template:String = ("""
var {var_name}=null setget,__get__{var_name}__
func __get__{var_name}__():
	return %s.{var_name}

""") % passthrough_object_name

#	for i in ClassDB.class_get_enum_list(extension_class):
#		enumerations.append("enum %s{%s}" % [i,ClassDB.class_get_enum_constants(extension_class,i).join(",")])

#	var fKeys:PoolStringArray = PoolStringArray(functions.keys())
#	if not "_init" in fKeys:
#		fKeys.append("_init")
#	for i in ClassDB.class_get_method_list(extension_class):
#		var item_name:String = i.name
#		if not item_name in fKeys:
#			var args:Array = []
#			for a in i.args:
#				args.append([a.name,a["class_name"],""])
#			var argOffset:int = args.size() - i.default_args.size()
#			for idx in i.default_args.size():
#				args[idx + argOffset][2] = var2str(i.default_args[idx])
#			functions[item_name] = {"args":args,"type":i["return"]["class_name"]}

#	var vkeys:PoolStringArray = PoolStringArray(variables.keys())
#	for i in ClassDB.class_get_property_list(extension_class):
#		var item_name:String = i.name
#		if not (" " in item_name or item_name in vkeys):
#			variables[item_name] = pointers.type_index.keys()[pointers.type_index.values().find(i.type)]

#	var object_builtin_notifs:PoolStringArray = PoolStringArray([
#		"NOTIFICATION_POSTINITIALIZE",
#		"NOTIFICATION_PREDELETE",
#		"CONNECT_DEFERRED",
#		"CONNECT_PERSIST",
#		"CONNECT_ONESHOT",
#		"CONNECT_REFERENCE_COUNTED",
#	])

#	for i in ClassDB.class_get_integer_constant_list(extension_class):
#		if not i in object_builtin_notifs:
#			constants.append("const " + i + "=" + var2str(ClassDB.class_get_integer_constant(extension_class,i)))

#	var skeys:PoolStringArray = PoolStringArray(signals.keys())
#	for i in ClassDB.class_get_signal_list(extension_class):
#		var item_name:String = i.name
#		if not (item_name == "script_changed" or item_name in skeys):
#			var args:PoolStringArray = PoolStringArray()
#			for r in i.args:
#				args.append(r.name)
#			signals[item_name] = args

	var signal_emitters:String = ""

	for i in signals.keys():
		var data:PoolStringArray = signals[i]
		compile += "\t%s.connect(\"%s\",self,\"%s\")\n" % [passthrough_object_name,i,"__emit_%s_signal__"%i]
		var combined:String = ",".join(data)
		var cr:String = ""
		if combined:
			cr = "," + combined
		signal_emitters += "\nsignal %s(%s)\nfunc __emit_%s_signal__(%s):\n\temit_signal(\"%s\"%s)\n" % [i,combined,i,combined,i,cr]

	compile += signal_emitters
	for i in constants:
		compile += i + "\n"

	var builtin_identifiers:PoolStringArray = PoolStringArray(pointers.static_tokens.values())

	for i in enumerations:
		compile += i + "\n"
	functions.erase("_init")
	for i in functions.keys():
		var content:Dictionary = functions[i]
		var args_default:String = ""
		var cast:String = ""
		var fCast:String = content["type"]
		if fCast:
			if fCast.split(".").size() < 2 and fCast in builtin_classes:
				cast = " -> " + fCast
		var args:String = ""
		for r in content["args"]:
			var aName:String = r[0]
			if aName in builtin_identifiers:
				aName += "_id_name"
			var aCast:String = r[1]
			if aCast:
				if aCast.split(".").size() < 2:
					aCast = ":" + aCast
				else:
					aCast = ""
			var aDefault:String = r[2]
			if aDefault:
				aDefault = "=" + aDefault
			if args_default:
				args_default += "," + aName + aCast + aDefault
				args += "," + aName
			else:
				args_default = aName + aCast + aDefault
				args = aName

		compile += ("""
func %s(%s)%s:

	return %s.%s(%s)
""") % [i,args_default,cast,passthrough_object_name,i,args]


	for i in variables.keys():
		var cast:String = variables[i]
		if cast:
			cast = ":" + cast
		compile += setGet_template.format({"var_name":i,"class_cast":cast})

	for i in classes:
		compile += class_template.format({"var_name":i})

	return compile

const casting_escapes = PoolIntArray([TK_OP_ASSIGN,TK_NEWLINE,TK_SEMICOLON,TK_COMMA,TK_PARENTHESIS_CLOSE])
const expression_ends = PoolIntArray([TK_NEWLINE,TK_SEMICOLON,TK_COMMA])




func get_function_data(idx:int):
	var func_data:Dictionary = {"name":args_store[idx],"args":[],"type":""}
	idx += 2
	var op:Array = ["","",""]
	while true:
		match type_store[idx]:
			TK_IDENTIFIER:
				op[0] = args_store[idx]
				idx += 1
			TK_CONSTANT:
				var cs = args_store[idx]
				if cs is String:
					op[2] = var2str(cs).replace("\a","\\a").replace("\b","\\b").replace("\f","\\f").replace("\n","\\n").replace("\r","\\r").replace("\t","\\t").replace("\v","\\v")
				else:
					op[2] = var2str(cs)
				idx += 1
			TK_COLON:
				idx += 1
				var c:Array = get_property_type_cast(idx)
				idx = c[1]
				op[1] = c[0]
			TK_PARENTHESIS_CLOSE:
				idx += 1
				func_data["args"].append(op)
				op = ["","",""]
				break
			TK_COMMA:
				idx += 1
				func_data["args"].append(op)
				op = ["","",""]
			TK_OP_ASSIGN:
				idx += 1
				var v:Array = get_expression(idx)
				idx = v[1]
				op[2] = v[0]
			TK_NEWLINE:
				idx += 1
			var tok:
				var tx:String = token_lookup[tok]
				breakpoint
	
	return [func_data,idx]

func get_var_data(idx:int):
	idx += 1
	var operands:Dictionary = {"name":args_store[idx],"type_cast":"","expression":""}
	idx += 1
	if type_store[idx] == TK_COLON:
		idx += 1
		var r:Array = get_property_type_cast(idx)
		operands["type_cast"] = r[0]
		idx = r[1]
		if type_store[idx] == TK_OP_ASSIGN:
			var expr:Array = get_expression(idx + 1)
			idx = expr[1]
			operands["expression"] = expr[0]
	elif type_store[idx] == TK_OP_ASSIGN:
		var expr:Array = get_expression(idx + 1)
		idx = expr[1]
		operands["expression"] = expr[0]
	return [operands,idx]

const depth_increase = PoolIntArray([TK_CURLY_BRACKET_OPEN,TK_BRACKET_OPEN,TK_PARENTHESIS_OPEN])
const depth_decrease = PoolIntArray([TK_CURLY_BRACKET_CLOSE,TK_BRACKET_CLOSE,TK_PARENTHESIS_CLOSE])

func get_expression(idx) -> Array:
	var out:String = ""
	var depth:int = 0
	while depth > 0 or (depth == 0 and not type_store[idx] in expression_ends):
		var tok:int = type_store[idx]
		var tok_str:String = token_lookup[tok]
		if tok in depth_increase:
			depth += 1
		elif tok in depth_decrease:
			depth -= 1
		if depth < 0:
			idx -= 1
			break
		if pointers.__is_static_token(tok):
			if out and pointers.word_is_tex(ord(out[-1])):
				out += " "
			var nex:String = pointers.__get_static_token(tok)
			out += nex
			if pointers.word_is_tex(ord(nex[-1])):
				out += " "
		else:
			match tok:
				TK_IDENTIFIER:
					out += args_store[idx]
				TK_CONSTANT:
					var cs = args_store[idx]
					if cs is String:
						out += var2str(cs).replace("\a","\\a").replace("\b","\\b").replace("\f","\\f").replace("\n","\\n").replace("\r","\\r").replace("\t","\\t").replace("\v","\\v")
					else:
						out += var2str(cs)
				TK_BUILT_IN_TYPE:
					out += pointers.type_index.keys()[pointers.type_index.values().find(args_store[idx])]
				TK_BUILT_IN_FUNC:
					out += pointers.func_index.keys()[pointers.func_index.values().find(args_store[idx])]
				_:
					breakpoint
		if tok == TK_NEWLINE:
			out += "\t".repeat(args_store[idx])
		idx += 1


	return [out,idx]

func get_property_type_cast(idx:int) -> Array:
	var cast:String = ""
	while not type_store[idx] in casting_escapes:
		match type_store[idx]:
			TK_IDENTIFIER:
				var id:String = args_store[idx]
				if cast.empty():
					if id and not id.split(".")[0] in builtin_classes:
						id = "Object"
				cast += id
			TK_BUILT_IN_TYPE:
				cast += pointers.type_index.keys()[pointers.type_index.values().find(args_store[idx])]
			_:
				var tx:String = token_lookup[type_store[idx]]
				breakpoint
		idx += 1
	return [cast,idx]

