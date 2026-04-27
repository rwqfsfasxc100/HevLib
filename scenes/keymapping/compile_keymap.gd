extends Node

var pointers

func _init(p):
	pointers = p


# General variables
var file = File.new()
var keybind_folder = "user://cache/.HevLib_Cache/Keybinds/"
var keybinds = keybind_folder + "defined_control_configs.json"
var vanilla = keybind_folder + "vanilla_binds.json"

# Code prefabs
var script_header = "extends Reference\n\nvar pointers\n\nfunc _init(p):\n\tpointers = p\n\nfunc handle_input(bits: PoolIntArray, event):\n\tpass"

var bit_size_check = "(bits.size() == %s) and "


# Order specific checkers
var orderspecific_checker_entry = "\n\tif event.is_action_pressed(\"%s\", true):"
var orderspecific_checker_end = "\n\telse:\n\t\tInput.action_release(\"%s\")"
var orderspecific_other_buttons_pressed = "\n\t\tif not %s:\n\t\t\tCurrentGame.get_tree().set_input_as_handled()\n\t\t\tInput.action_release(\"%s\")\n\t\telse:\n\t\t\tpass"

var orderspecific_part_def = "\n\t\tvar p%d = bits.find(%s)"
var orderspecific_expr_part = "(%d if p%d > -1 else %d)"

# Order nonspecific checkers
var ordernonspecific_part_def = "\n\t\tvar p%d = %s in bits"
var ordernonspecific_expr_part = "p%d"

# Exclusive handlers

var exclusives_check_for_input = "event.is_action_pressed(\"%s\", true)"


func compile_keymap():
	var p = {}
	file.open(vanilla,File.READ)
	var h = JSON.parse(file.get_as_text()).result
	file.close()
	
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
			pass
	var scripting = script_header
	
	var exclusives = {}
	
	for action in p:
		var data = p[action]
		var opts = data["opts"]
		if opts["exclusive"]:
			exclusives[action] = data
		else:
			var keys = data["controls"]
			for key in keys:
				if key.size() > 1:
					if opts["order_sensitive"]:
						var handler = orderspecific_checker_entry % action
						var expression = ""
						var map = {}
						var mx = 214748364
						var cb = 0
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
						handler += orderspecific_checker_end % action
						scripting += handler
					else:
						var handler = orderspecific_checker_entry % action
						var expression = ""
						var map = {}
						var mx = 214748364
						var cb = 0
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
						handler += orderspecific_checker_end % action
						scripting += handler
	
	var sorted_exclusives = {}
	
	# Exclusives check for true bools (i.e. E+CTRL+F: E & F is false but E+CTRL is true)
	# Non-ordered check purely for base chars (i.e. E+CTRL+F: E & F is false, but CTRL is true)
	
	
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
				if d <= 1:
					cKeys.erase(k)
			
			
			for i in ordered:
				var data = ordered[i]
				var controls = data["controls"]
				var opts = data["opts"]
				for stack in controls:
					
					var single = true
					for a in stack:
						if a in cKeys:
							single = false
					if single:
						breakpoint
					else:
						var stack_size = stack.size()
						
						breakpoint

			breakpoint
			
			pass
			
		else:
			
			
			breakpoint
		
	
	return scripting
