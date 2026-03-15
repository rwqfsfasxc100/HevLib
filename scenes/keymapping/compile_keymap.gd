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

var bit_size_check = "(bits.size() == %s) and"


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
	
	var exclusiveKeys = []
#	var exclusiveActs = {}
	var exclusiveSize = {}
	
	var exclusiveExtraKeys = {}
	
	var exclusivesTree = {}
	
	var exclSize = exclusives.size()
	if exclSize > 0:
		var factorial = pointers.DataFormat.__factorial(exclSize)
		var list = pointers.DataFormat.__get_unique_pairs(factorial)
		var ekeys = exclusives.keys()
		if factorial > 1:
			for pair in list:
				var act1 = ekeys[pair[0]]
				var act2 = ekeys[pair[1]]
				var a = exclusives[act1]["controls"]
				var b = exclusives[act2]["controls"]
				for c1 in a:
					for c2 in b:
						var num1 = c1[0]
						if num1 == c2[0]:
							var s1 = c1.size()
							var s2 = c2.size()
							var depth = (s1 if s1 > s2 else s2)
							var dp = depth
							# Create a key trace with exclusivesTree so the code can reverse recursively 
							# travel through the branches to have each exclusive combination effectively
							# served on a plate. 
							#
							# Have each level contain an "actions" and a "branch" entry to separate that 
							# level's inputs with those lower down the branch. It also makes it easier
							# to not need to deal with orderless binds, as they can be clumped together
							# with the same keys as ordered binds, just w/o the need for order checks
							
							breakpoint
							if not num1 in exclusiveKeys:
								exclusiveKeys.append(num1)
							if not num1 in exclusiveSize:
								exclusiveSize[num1] = {"max":0}
#							if not num1 in exclusiveActs:
#								exclusiveActs[num1] = []
#							if not act1 in exclusiveActs[num1]:
#								exclusiveActs[num1].append(act1)
#							if not act2 in exclusiveActs[num1]:
#								exclusiveActs[num1].append(act2)
							if s1 > 0:
								if not s1 in exclusiveSize[num1]:
									exclusiveSize[num1][s1] = []
								if not act1 in exclusiveSize[num1][s1]:
									exclusiveSize[num1][s1].append(act1)
								if s1 > 1:
									if not num1 in exclusiveExtraKeys:
										exclusiveExtraKeys[num1] = {}
									if not act1 in exclusiveExtraKeys[num1]:
										exclusiveExtraKeys[num1][act1] = []
									if not c1 in exclusiveExtraKeys[num1][act1]:
										exclusiveExtraKeys[num1][act1].append(c1)
							
							if s2 > 0:
								if not s2 in exclusiveSize[num1]:
									exclusiveSize[num1][s2] = []
								if not act1 in exclusiveSize[num1][s2]:
									exclusiveSize[num1][s2].append(act2)
								if s2 > 1:
									if not num1 in exclusiveExtraKeys:
										exclusiveExtraKeys[num1] = {}
									if not act2 in exclusiveExtraKeys[num1]:
										exclusiveExtraKeys[num1][act2] = []
									if not c2 in exclusiveExtraKeys[num1][act2]:
										exclusiveExtraKeys[num1][act2].append(c2)
							
							if depth > exclusiveSize[num1]["max"]:
								exclusiveSize[num1]["max"] = depth
		else:
			
			
			breakpoint
		
		# Make sure to always check the common key is pressed to consider cancelling
		
		for key in exclusiveKeys:
			var size = exclusiveSize[key]["max"]
			var check_statement = ""
			var keyExtras = exclusiveExtraKeys[key]
			while size > 0:
				
				var actions = exclusiveSize[key][size]
				for action in actions:
					var operate = exclusives[action]
					if check_statement:
						check_statement += "and %s" % exclusives_check_for_input % action
					else:
						check_statement = "\n\tif " + exclusives_check_for_input % action
				
				breakpoint
				size -= 1
			check_statement += ":"
	
	
	
	return scripting
	
	
	
