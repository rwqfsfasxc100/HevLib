extends Node

# This is a script used to create shadow (man in the middle) scripts, or in other words,
#  a means of changing the inputs and/or outputs of the communication between two
#  scripts.
# 
# e.g. modify the communication between the ship and a _ready() method of an equipment
#  item. Given that virtual methods cannot be overriden normally, this brings some 
#  control back with what it receives being able to be modified
# 
# This script SHOULD NOT be used during runtime due to it being a very heavy operation
# 
# PARAMETERS:
# 
# script_path -> String used for the script that will be shadowed
# 
# desired_methods -> Array used to define all methods that will be shadowed, if they
#  exist within the script. If blank, adds all methods defined within the script.
#  To not shadow anything, add a singular invalid entry (e.g. [null])
# 
# desired_variables -> Array used to define all variables that will be shadowed, if they
#  exist within the script. If blank, adds all variables defined within the script.
#  To not shadow anything, add a singular invalid entry (e.g. [null])
# 
# desired_signals -> Array used to define all signals that will be shadowed, if they
#  exist within the script. If blank, adds all signals stated within the script.
#  To not shadow anything, add a singular invalid entry (e.g. [null])
# 
# use_class_variables -> Bool used to determine if the object type's variables should 
#  be shadowed as well. Only works when variables are defined with desired_variables
# 
# use_class_signals -> Bool used to determine if the object type's variables should be
#  shadowed as well. Only works when variables are defined with desired_methods, and
#  methods not defined by the script WILL NOT have any method default properties due
#  to scope limitations
# 
# use_class_signals -> Bool used to determine if the object type's signals should 
#  be shadowed as well. Only works when signals are defined with desired_signals
# 
# 
# 
# 
# 
# 
# 
# 

func __make_shadow_of_script(script_path: String,desired_methods:Array,desired_variables:Array,desired_signals:Array,use_class_variables:bool = true,use_class_methods:bool = true,use_class_signals:bool = true) -> String:
	var out = ""
	var pointers = preload("res://HevLib/pointers.gd").new()
	var data = pointers.DataFormat.__trim_scripts(script_path,true,true)
	var var_names = data[1]
	var const_names = data[2]
	var signal_names = data[3]
	var method_names = data[4]
	var signal_operands = data[5]
	var method_operands = data[6]
	var method_type = data[7]
	var regex = RegEx.new()
	regex.compile("[A-Z]")
	
	var shadow_var_names = []
	
	var script_type = ""
	var script_lines = data[0].split("\n")
	if script_lines[0].begins_with("extends "):
		script_type = script_lines[0].split("extends ")[1].strip_edges()
		var pv
		if script_type.begins_with("\"") and script_type.ends_with("\""):
			pv = load(script_type).new()
		else:
			pv = pointers.DataFormat.__convert_var_from_string(script_type + ".new()",false)
		if use_class_variables and desired_variables:
			var pvt = pv.get_property_list()
			for a in pvt:
				var n = a.name
				if n in desired_variables:
					if n != "script":
						var vt = regex.search(n)
						if not vt and n.split(" ").size() == 1:
							var_names.append(n)
		if use_class_methods and desired_methods:
			var pvr = pv.get_method_list()
			for a in pvr:
				var methodName = a.name
				if methodName in desired_methods:
					if methodName in PoolStringArray(["_init","set_script","get_script","emit_signal"]):
						continue
					var oArgs = []
					var args = a.args
					var argsSize = args.size()
					for i in range(argsSize):
						var arg = args[i]
						var aout = arg.name
						var ov = "_" + aout + "_"
						var arc = arg["class_name"]
						if arc:
							ov += ": " + arc
						oArgs.append(ov)
					var rx = method_names.find(methodName)
					if rx > -1:
						method_operands[rx] = oArgs
					else:
						method_names.append(methodName)
						method_type.append("")
						method_operands.append(oArgs)
		if use_class_signals and desired_signals:
			var pva = pv.get_signal_list()
			for a in pva:
				var sig_name = a.name
				if sig_name in desired_signals:
					var oArgs = []
					var args = a.args
					var argsSize = args.size()
					for i in range(argsSize):
						var arg = args[i]
						var aout = arg.name
						oArgs.append("_" + aout + "_")
					var rx = signal_names.find(sig_name)
					if rx > -1:
						signal_operands[rx] = oArgs
					else:
						signal_names.append(sig_name)
						signal_operands.append(oArgs)
		Tool.remove(pv)
	
	
	var obj_ref = "var __shadowed_object_ref__ = null\nfunc _init(oref):\n\t__shadowed_object_ref__ = oref\n\t%s\n\n%s%s\n\n"
	
	var setGet_template = "var %s setget __set__%s_ , __get__%s_\nfunc __set__%s_(how):\n\t%s = how;__shadowed_object_ref__.%s = how;\nfunc __get__%s_():\n\tvar __thisObjVar__ = __shadowed_object_ref__.%s;%s = __thisObjVar__;return __thisObjVar__;\n\n"
	
	var variable_handles = ""
	
	
	
	for i in var_names:
		var canadd = true
		if desired_variables:
			if not i in desired_variables:
				canadd = false
		if canadd:
			variable_handles += setGet_template % [i,i,i,i,i,i,i,i,i]
	
	var function_template = "func %s(%s)%s:\n\tvar out = __shadowed_object_ref__.%s(%s)\n\t\n\treturn out\n\n"
	
	var function_handles = ""
	
	for i in range(method_names.size()):
		var method = method_names[i]
		var canadd = true
		if desired_methods:
			if not method in desired_methods:
				canadd = false
		if canadd:
			var operands = method_operands[i]
			var type = method_type[i]
			var o1 = ""
			var o2 = ""
			var o3 = ""
			
			if type:
				o3 = "-> " + type
			for o in operands:
				var selfsplit = o.split("self")
				var sspl = selfsplit.size()
				if sspl > 1:
					var rejoin = ""
					for r in range(sspl - 1):
						var part1 = selfsplit[r]
						var part2 = selfsplit[r + 1]
						var echar = part1.substr(part1.length())
						var bchar = part2.substr(0,1)
						var do = false
						if echar != ":" and echar != " " and echar != "=":
							do = true
						if bchar != "," and bchar != " " and bchar != ")":
							do = true
						if do:
							if r == sspl - 2:
								rejoin += part1 + "__shadowed_object_ref__" + part2
							else:
								rejoin += part1 + "__shadowed_object_ref__"
							
						else:
							if r == sspl - 2:
								rejoin += part1 + "self" + part2
							else:
								rejoin += part1 + "self"
					
					o = rejoin
				
				if o1:
					o1 += (", " + o)
				else:
					o1 = o
				
				var ovrt = o.split(":")[0].split("=")[0].strip_edges()
				if o2:
					o2 += (", " + ovrt)
				else:
					o2 = ovrt
			var ovr = function_template % [method,o1,o3,method,o2]
			function_handles += ovr
	var constant_handle = ""
	for i in script_lines:
		if i.begins_with("const "):
			constant_handle += (i + "\n")
	
	
	
	
	
	
	var signal_template = "signal %s(%s)\n"
	var signal_handles = ""
	
	var signal_emit_template = "\nfunc emit_this_%s(%s):\n\temit_signal(%s)"
	var signal_connect_template = "\n\tconnect(\"%s\",self,\"emit_this_%s\")"
	
	var signal_connectors = ""
	var signal_emitters = ""
	
	for i in range(signal_names.size()):
		var sig = signal_names[i]
		var canadd = true
		if desired_signals:
			if not sig in desired_signals:
				canadd = false
		if canadd:
			var operands : Array = signal_operands[i]
			var oprs = ", ".join(operands)
			signal_handles += signal_template % [sig,oprs]
			signal_connectors += signal_connect_template % [sig,sig]
			var cv = "\"%s\"" % sig
			if oprs:
				cv += ("," + oprs)
			signal_emitters += signal_emit_template % [sig,oprs,cv]
		
	signal_handles += "\n"
	
	
	var scriptTemplate = "func set_script(script):\n\t__shadowed_object_ref__.set_script(script);\nfunc get_script():\n\treturn __shadowed_object_ref__.get_script();\n\n"
	out = obj_ref % [signal_connectors,signal_handles,signal_emitters] + function_handles + variable_handles + constant_handle + scriptTemplate
	return out
