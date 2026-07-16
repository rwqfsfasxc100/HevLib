extends Node

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
# 4. The source code and the binary form, and any modifications made to them may not be used for the purpose of input data, the training of, or improvment of machine learning algorithms,
# including but not limited to artificial intelligence, natural language processing, or data mining. This condition applies to any derivatives,
# modifications, or updates based on the Software code. Any usage of the source code or the binary form in an AI-training dataset is considered a breach of this License.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# [/license]

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
