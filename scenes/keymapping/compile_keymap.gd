extends Node

var pointers

func _init(p):
	pointers = p


var control_vars = {}
# General variables
var file = File.new()
var keybind_folder = "user://cache/.HevLib_Cache/Keybinds/"
var keybinds = keybind_folder + "defined_control_configs.json"
var vanilla = keybind_folder + "vanilla_binds.json"

# Code prefabs
var script_header = "extends Reference\n\nfunc handle_input(bits, event):\n\tpass"

var bit_size_check = "(bits.size() == %s) and "


# Order specific checkers
var orderspecific_checker_entry = "\n\tif event.is_action_pressed(\"%s\", true):"
var orderspecific_checker_end = "\n\telif %s:\n\t\tInput.action_release(\"%s\")"
var orderspecific_checker_expression = "not (%s)"
var orderspecific_checker_expression_part = "(%s in bits)"

var orderspecific_other_buttons_pressed = "\n\t\tif not %s:\n\t\t\tCurrentGame.get_tree().set_input_as_handled()\n\t\t\tInput.action_release(\"%s\")\n\t\telse:\n\t\t\tpass"

var orderspecific_part_def = "\n\t\tvar p%d = bits.find(%s)"
var orderspecific_expr_part = "(%d if p%d > -1 else %d)"

# Order nonspecific checkers
var ordernonspecific_part_def = "\n\t\tvar p%d = %s in bits"
var ordernonspecific_expr_part = "p%d"

# Exclusive handlers

var exclusives_check_for_input = "event.is_action_pressed(\"%s\", true)"
var exclusives_variable_statement = "\n\tvar charset_%s = true"
var exclusives_variable_obj = "charset_%s"
var exclusives_variable_falsify = "\n\t\t\t\tcharset_%s = false"
var exclusives_expression_check = "if not %s:\n\t\t\t\t"
var exclusives_exit_this_expression = "if not %s:\n\t\t\t\t\tCurrentGame.get_tree().set_input_as_handled()\n\t\t\t\t\tInput.action_release(\"%s\")\n\t\t\telse:%s"
var exclusives_exit_this_expression_noexbr = "CurrentGame.get_tree().set_input_as_handled()\n\t\t\t\tInput.action_release(\"%s\")\n\t\t\telse:%s"
var exclusives_exit_from_no_keys = "\n\t\telse:\n\t\t\tCurrentGame.get_tree().set_input_as_handled()\n\t\t\tInput.action_release(\"%s\")"
var exclusives_checker_expression_part = "%s in bits"

func compile_keymap():
	var p = {}
	file.open(vanilla,File.READ)
	var h = JSON.parse(file.get_as_text()).result
	file.close()
	control_vars.clear()
	for action in h:
		var d = h[action]
		if not action in p:
			p[action] = {}
		var g = p[action]
		if not "controls" in g:
			g["controls"] = []
		var c = g["controls"]
		for j in d["inputs"]:
			if not j in c:
				c.append(j)
		if not "opts" in g:
			g["opts"] = d.get("opts",{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false})
		
	file.open(keybinds,File.READ)
	var apg = JSON.parse(file.get_as_text()).result
	file.close()
	for action in apg:
		var d = apg[action]
		if action in p:
			for ac in d["controls"]:
				var add = true
				for vb in p[action]["controls"]:
					if hash(vb) == hash(ac):
						add = false
				if add:
					p[action]["controls"].append(ac)
		else:
			p[action] = {}
			p[action]["controls"] = d["controls"]
			p[action]["opts"] = d["opts"]
	var scripting = script_header
	
	var exclusives = {}
	
	for action in p:
		var data = p[action]
		if data["opts"]["exclusive"]:
			exclusives[action] = data
		else:
			scripting += handle_regular_controls(data,action)
	
	if exclusives:
		var exclSize = exclusives.size()
		if exclSize > 1:
			var ordered = {}
			var disordered = {}
			var cKeys = {}
			for e in exclusives:
				var x = exclusives[e]
				var o = x["opts"]
				var k = x["controls"]
				for f in k:
					for f1 in f:
						if not f1 in cKeys:
							cKeys[f1] = []
						if not e in cKeys[f1]:
							cKeys[f1].append(e)
				if o["order_sensitive"]:
					ordered[e] = x
				else:
					disordered[e] = x
			
			for k in cKeys:
				var d = cKeys[k].size()
				if d < 2:
					cKeys.erase(k)
			var checker_vars = PoolStringArray()
			for i in ordered:
				var data = ordered[i]
				var controls = data["controls"]
				var opts = data["opts"]
				for stack in controls:
					
					var single = true
					for a in stack:
						if a in cKeys:
							single = false
					if not single:
						var this_checker = ""
						var checkArr = []
						for a in stack:
							if this_checker:
								this_checker += "_" + a
							else:
								this_checker = a
							if not this_checker in checkArr:
								checkArr.append(this_checker)
						for r in checkArr:
							if not r in checker_vars:
								checker_vars.append(r)
						control_vars[i] = checkArr
					else:
						pass
			for i in disordered:
				var data = disordered[i]
				var controls = data["controls"]
				var opts = data["opts"]
				for stack in controls:
					var single = true
					for a in stack:
						if a in cKeys:
							single = false
					if not single:
						var checkArr = []
						for a in stack:
							if not a in checkArr:
								checkArr.append(a)
						for r in checkArr:
							if not r in checker_vars:
								checker_vars.append(r)
						control_vars[i] = checkArr
					else:
						pass
			var var_statement_list = ""
			for control in checker_vars:
				var_statement_list += exclusives_variable_statement % control
			scripting += var_statement_list
			var ordered_control_list = control_vars.keys()
			ordered_control_list.sort_custom(self,"sort_this_dict")
			
			for ct in ordered_control_list:
				var opts = exclusives[ct]["opts"]
				var extxpr = ""
				var krxpr = exclusives[ct]["controls"]
				for key in krxpr:
					var keysXpr = ""
					for kv in key:
						var sc = pointers.Keymapping.__string_to_scancode(kv)
						if keysXpr:
							keysXpr += " and " + exclusives_checker_expression_part % str(sc)
						else:
							keysXpr = "(" + exclusives_checker_expression_part % str(sc)
					keysXpr += ")"
					if extxpr:
						extxpr += " or " + keysXpr
					else:
						extxpr = "(" + keysXpr
				extxpr = orderspecific_checker_expression % [extxpr + ")"]
				var statement_list = control_vars[ct]
				var handler = "\n\tif " + exclusives_check_for_input % (ct) + ":"
				var expression = ""
				var key = statement_list[-1].split("_")
				if key.size() > 1:
					if opts["order_sensitive"]:
						var map = {}
						var mx = 214748364
						var cb = 1
						for kv in key:
							var sc = pointers.Keymapping.__string_to_scancode(kv)
							map[cb] = sc
							handler += orderspecific_part_def % [cb,sc]
							
							if not expression:
								var v = "(" + orderspecific_expr_part % [cb,cb,mx-cb]
								expression += v
							else:
								var v = " < " + orderspecific_expr_part % [cb,cb,mx-cb]
								expression += v
							cb += 1
						expression += ")"
					else:
						var map = {}
						var mx = 214748364
						var cb = 1
						for kv in key:
							var sc = pointers.Keymapping.__string_to_scancode(kv)
							map[cb] = sc
							handler += ordernonspecific_part_def % [cb,sc]
							
							if not expression:
								var v = "(" + ordernonspecific_expr_part % cb
								expression += v
							else:
								var v = " and " + ordernonspecific_expr_part % cb
								expression += v
							cb += 1
						expression += ")"
				else:
					var sc = pointers.Keymapping.__string_to_scancode(key[0])
					expression = orderspecific_checker_expression_part % sc
				if not opts["allow_extra_keys"]:
					expression = bit_size_check % key.size() + expression
				var state = handler
				var state_checker = ""
				for i in statement_list:
					if state_checker:
						state_checker += " or " + exclusives_variable_obj % i
					else:
						state_checker = "if " + exclusives_variable_obj % i
				
				
				state += "\n\t\t" + state_checker + ":\n\t\t\t"
				var falsifiers = ""
				for k in statement_list:
					falsifiers += exclusives_variable_falsify % k
				var other_bind_check_expression = ""
				var unexited_keys = []
				var used_keys = []
				for c in checker_vars:
					for a in c.split("_"):
						if not a in used_keys:
							used_keys.append(a)
				for bindgroup in krxpr:
					for kcheck in bindgroup:
						if not kcheck in used_keys:
							unexited_keys.append(kcheck)
				
				# Use the unexited_keys array to prevent scancodes inside it from triggering any
				# bind cancelling
				
				var exbr = ""
				
				if unexited_keys:
					for kv in unexited_keys:
						var sc = pointers.Keymapping.__string_to_scancode(kv)
						if other_bind_check_expression:
							other_bind_check_expression += " or " + exclusives_checker_expression_part % str(sc)
						else:
							other_bind_check_expression = exclusives_checker_expression_part % str(sc)
				
				
				if other_bind_check_expression:
					exbr = exclusives_exit_this_expression % [other_bind_check_expression,ct,falsifiers]
				else:
					exbr = exclusives_exit_this_expression_noexbr % [ct,falsifiers]
#					exbr = exclusives_exit_this_expression % ["false",ct,falsifiers]
				state += exclusives_expression_check % expression + exbr + exclusives_exit_from_no_keys % ct + orderspecific_checker_end % [extxpr,ct]
				scripting += state
				
		else:
			var action = exclusives.keys()[0]
			scripting += handle_regular_controls(exclusives[action],action)
			breakpoint
		
	
	return scripting

func handle_regular_controls(data:Dictionary,action: String):
	var scripting = ""
	var keys = data["controls"]
	var opts = data["opts"]
	var extxpr = ""
	for key in keys:
		var keysXpr = ""
		for kv in key:
			var sc = pointers.Keymapping.__string_to_scancode(kv)
			if keysXpr:
				keysXpr += " and " + exclusives_checker_expression_part % str(sc)
			else:
				keysXpr = "(" + exclusives_checker_expression_part % str(sc)
		keysXpr += ")"
		if extxpr:
			extxpr += " or " + keysXpr
		else:
			extxpr = "(" + keysXpr
	extxpr = orderspecific_checker_expression % [extxpr + ")"]
	
	for key in keys:
		if key.size() > 1:
			if opts["order_sensitive"]:
				var handler = orderspecific_checker_entry % action
				var expression = ""
				var map = {}
				var mx = 214748364
				var cb = 1
				for kv in key:
					var sc = pointers.Keymapping.__string_to_scancode(kv)
					map[cb] = sc
					handler += orderspecific_part_def % [cb,sc]
					
					if not expression:
						var v = "(" + orderspecific_expr_part % [cb,cb,mx-cb]
						expression += v
					else:
						var v = " < " + orderspecific_expr_part % [cb,cb,mx-cb]
						expression += v
					cb += 1
				expression += ")"
				
				if not opts["allow_extra_keys"]:
					expression = bit_size_check % key.size() + expression
				
				handler += orderspecific_other_buttons_pressed % [expression,action]
				handler += orderspecific_checker_end % [extxpr,action]
				scripting += handler
			else:
				var handler = orderspecific_checker_entry % action
				var expression = ""
				var map = {}
				var mx = 214748364
				var cb = 1
				for kv in key:
					var sc = pointers.Keymapping.__string_to_scancode(kv)
					map[cb] = sc
					handler += ordernonspecific_part_def % [cb,sc]
					
					if not expression:
						var v = "(" + ordernonspecific_expr_part % cb
						expression += v
					else:
						var v = " and " + ordernonspecific_expr_part % cb
						expression += v
					cb += 1
				expression += ")"
				
				if not opts["allow_extra_keys"]:
					expression = bit_size_check % key.size() + expression
				
				handler += orderspecific_other_buttons_pressed % [expression,action]
				handler += orderspecific_checker_end % [extxpr,action]
				scripting += handler
	return scripting

func sort_this_dict(a,b) -> bool:
	var aData = control_vars[a]
	var bData = control_vars[b]
	if bData.size() > aData.size():
		return false
	return true
