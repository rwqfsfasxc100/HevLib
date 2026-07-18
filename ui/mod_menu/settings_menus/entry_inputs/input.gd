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

extends HBoxContainer

var CONFIG_DATA = {}

var CONFIG_ENTRY = ""

var CONFIG_SECTION = ""

var CONFIG_MOD = ""
var pointers = ModLoader._savedObjects[0]

func _ready():
	var value = pointers.ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
	if value == null:
		Tool.remove(self)
	$Label.text = CONFIG_DATA.get("name","INPUT_MISSING_NAME")
	$Label/LABELBUTTON.hint_tooltip = CONFIG_DATA.get("description","")
	var ab = CONFIG_DATA.get("always_binds",[])
	if ab.size() > 0:
		$Label/LABELBUTTON.always_binds = ab
	add_to_group("hevlib_settings_tab",true)

func recheck_availability():
	
	var default = CONFIG_DATA.get("default",[])
	var values = pointers.ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
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
		$reset.visible = true
		$Label/LABELBUTTON.focus_neighbour_right = $Label/LABELBUTTON.get_path_to($reset)
	else:
		$reset.visible = false
		$Label/LABELBUTTON.focus_neighbour_right = "."
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
					$reset.modulate = Color(0.6,0.6,0.6,1)
					$reset.disabled = true
					$Label/LABELBUTTON.modulate = Color(0.6,0.6,0.6,1)
					$Label/LABELBUTTON.disabled = true
				else:
					$reset.modulate = Color(1,1,1,1)
					$reset.disabled = false
					$Label/LABELBUTTON.modulate = Color(1,1,1,1)
					$Label/LABELBUTTON.disabled = false
			else:
				if true_valids >= 1:
					$reset.modulate = Color(1,1,1,1)
					$reset.disabled = false
					$Label/LABELBUTTON.modulate = Color(1,1,1,1)
					$Label/LABELBUTTON.disabled = false
				else:
					$reset.modulate = Color(0.6,0.6,0.6,1)
					$reset.disabled = true
					$Label/LABELBUTTON.modulate = Color(0.6,0.6,0.6,1)
					$Label/LABELBUTTON.disabled = true
	else:
		$reset.modulate = Color(1,1,1,1)
		$reset.disabled = false
		$Label/LABELBUTTON.modulate = Color(1,1,1,1)
		$Label/LABELBUTTON.disabled = false

func _reset_pressed():
	pointers.ConfigDriver.__store_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY,CONFIG_DATA.get("default",[]))
	$Label/LABELBUTTON.grab_focus()
	$Label/LABELBUTTON/CanvasLayer/CaptureKeyDialog.applySettings()
	get_tree().call_group("hevlib_settings_tab","recheck_availability")

func _draw():
	
	refocus()

func refocus():
	$Label/LABELBUTTON.rect_size = $Label.rect_size
#	get_tree().call_group("hevlib_settings_tab","recheck_availability")
	
	pointers.ConfigDriver.set_button_focus(self,get_node("Label/LABELBUTTON"))
	

func _visibility_changed():
	if get_position_in_parent() == 0:
		$Label/LABELBUTTON.grab_focus()
	refocus()
	
