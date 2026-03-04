extends Node

var file = File.new()
var keybind_folder = "user://cache/.HevLib_Cache/Keybinds/"
var keybinds = keybind_folder + "defined_control_configs.json"
var vanilla = keybind_folder + "vanilla_binds.json"
var pointers

func _init(p):
	pointers = p

var script_header = "extends Reference\n\nvar pointers\n\nfunc _init(p):\n\tpointers = p\n\nfunc handle_input(bits):"
var bit_check = "%s in bits"
var action_start = "\n\t\tpointers.Keymapping.__simulate_input_press(\"%s\")"
var action_release = "\n\t\tpointers.Keymapping.__simulate_input_depress(\"%s\")"

var action_start_old = "\n\t\tif not Input.is_action_pressed(\"%s\"):\n\t\t\tpointers.Keymapping.__simulate_input_press(\"%s\",%s)"
var action_release_old = "\n\t\tif Input.is_action_pressed(\"%s\"):\n\t\t\tpointers.Keymapping.__simulate_input_depress(\"%s\",%s)"

var direct = "false"

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
			g["opts"] = {"allow_extra_keys":true,"order_sensitive":false,"exclusive":false}
	
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
	var ui = pointers.Keymapping.__get_built_in_action_list()
	var ignore_builtin = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","input_virtualization_ignore_builtin")
	for action in p:
		if ignore_builtin and action in ui:
			continue
		var data = p[action]
		var opts = data["opts"]
		var check_statement = "" 
		if data["controls"].size() > 0:
			for key in data["controls"]:
				var ob = ""
				for k in key:
					var g = pointers.Keymapping.__string_to_scancode(k)
					if not ob:
						ob = "(" + bit_check % g
					else:
						ob += " and " + bit_check % g
				if ob:
					ob += ")"
				if not check_statement:
					check_statement = "\n\tif (" + ob
				else:
					check_statement += " or " + ob

			check_statement += "):"
			check_statement += action_start_old % [action,action,direct]
			check_statement += "\n\telse:"
			check_statement += action_release_old % [action,action,direct]
			scripting += check_statement
#	for action in p:
#		scripting += "\n\tif Input.is_action_pressed(\"%s\"):\n\t\tprint(\"Action \",\"%s\",\" pressed\")" % [action,action]
	return scripting
