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

extends HBoxContainer

var CONFIG_DATA = {}

var CONFIG_ENTRY = ""

var CONFIG_SECTION = ""

var CONFIG_MOD = ""
var pointers = ModLoader._savedObjects[0]

onready var label_button = $Label/LABELBUTTON
onready var key_diag = $Label/LABELBUTTON/CanvasLayer/CaptureKeyDialog
onready var reset_button = $reset
onready var name_label = $Label


func _ready():
	var value = pointers.ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
	if value == null:
		Tool.remove(self)
	value = Array(value)
	$Label.text = CONFIG_DATA.get("name","INPUT_MISSING_NAME")
	label_button.hint_tooltip = CONFIG_DATA.get("description","")
	var ab = Array(CONFIG_DATA.get("always_binds",[]))
	if ab:
		label_button.always_binds = ab
	add_to_group("hevlib_settings_tab",true)

func recheck_availability():
	
	var default = Array(CONFIG_DATA.get("default",[]))
	var values = Array(pointers.ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY))
	var reset = false
	if default.size() != values.size():
		reset = true
	else:
		for g in range(values.size()):
			var i = values[g]
			if typeof(i) == TYPE_STRING:
				i = [i]
			var a = default[g]
			if typeof(a) == TYPE_STRING:
				a = [a]
			if hash(i) != hash(a):
				reset = true
	if reset:
		reset_button.visible = true
		label_button.focus_neighbour_right = label_button.get_path_to(reset_button)
	else:
		reset_button.visible = false
		label_button.focus_neighbour_right = "."
	var requirements = PoolStringArray(CONFIG_DATA.get("requires_bools",[]))
	if requirements.size() >= 1:
		var show = true
		var valid_options = 0
		var true_valids = 0
		var flip = CONFIG_DATA.get("invert_bool_requirement",false)
		for option in requirements:
			
			var split = option.split("/")
			if split.size() == 3:
				var value = pointers.ConfigDriver.__get_value(split[0],split[1],split[2])
				if typeof(value) == TYPE_BOOL:
					valid_options += 1
					if value == true:
						true_valids += 1
		if valid_options >= 1:
			if flip:
				if true_valids >= 1:
					reset_button.modulate = Color(0.6,0.6,0.6,1)
					reset_button.disabled = true
					label_button.modulate = Color(0.6,0.6,0.6,1)
					label_button.disabled = true
				else:
					reset_button.modulate = Color(1,1,1,1)
					reset_button.disabled = false
					label_button.modulate = Color(1,1,1,1)
					label_button.disabled = false
			else:
				if true_valids >= 1:
					reset_button.modulate = Color(1,1,1,1)
					reset_button.disabled = false
					label_button.modulate = Color(1,1,1,1)
					label_button.disabled = false
				else:
					reset_button.modulate = Color(0.6,0.6,0.6,1)
					reset_button.disabled = true
					label_button.modulate = Color(0.6,0.6,0.6,1)
					label_button.disabled = true
	else:
		reset_button.modulate = Color(1,1,1,1)
		reset_button.disabled = false
		label_button.modulate = Color(1,1,1,1)
		label_button.disabled = false

func _reset_pressed():
	pointers.ConfigDriver.__store_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY,Array(CONFIG_DATA.get("default",[])))
	label_button.grab_focus()
	key_diag.applySettings()
	get_tree().call_group("hevlib_settings_tab","recheck_availability")

func _draw():
	
	refocus()

func refocus():
	label_button.rect_size = name_label.rect_size
#	get_tree().call_group("hevlib_settings_tab","recheck_availability")
	
	if is_visible_in_tree():
		yield(get_tree(),"idle_frame")
		pointers.ConfigDriver.set_button_focus(self,label_button)
	

func _visibility_changed():
	if get_position_in_parent() == 0:
		label_button.grab_focus()
	refocus()

func get_focusable(direction = 0):
	return label_button

func get_label(direction = 0):
	return label_button

func get_reset(direction = 0):
	return reset_button
