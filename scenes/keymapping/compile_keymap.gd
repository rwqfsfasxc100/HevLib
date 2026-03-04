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
var script_header = "extends Reference\n\nvar pointers\n\nfunc _init(p):\n\tpointers = p\n\nfunc handle_input(bits, event):\n\tpass"

var checker_entry = "\n\tif event.is_action_pressed(\"%s\"):"
var is_other_button_pressed = "\n\t\tif not %s:\n\t\t\tCurrentGame.get_tree().set_input_as_handled()\n\t\telse:\n\t\t\tpass"
var in_bits = "(%s in bits)"


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
	
	
	for action in p:
		var data = p[action]
		var keys = data["controls"]
		for key in keys:
			if key.size() > 1:
				var handler = checker_entry % action
				var expression = ""
				for i in range(0,key.size() - 1):
					var kv = key[i]
					var sc = pointers.Keymapping.__string_to_scancode(kv)
					if not expression:
						var v = "(" + in_bits % sc
						expression += v
					else:
						var v = " and " + in_bits % sc
						expression += v
				expression += ")"
				handler += is_other_button_pressed % expression
				scripting += handler
	return scripting
	
	
	
