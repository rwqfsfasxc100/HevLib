extends HBoxContainer

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

var CONFIG_DATA = {}

var CONFIG_ENTRY = ""

var CONFIG_SECTION = ""

var CONFIG_MOD = ""
var pointers = ModLoader._savedObjects[0]
export (String,"slider","spinbox") var style = "slider"

export (String,"int","float") var val_type = "int"

onready var slider = $slider
onready var label = $Label
onready var spinbox = $spinbox
onready var SliderLabel = $SliderLabel

var volatile = false

func _ready():
	var value = pointers.ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
	if value == null:
		Tool.remove(self)
	label.text = CONFIG_DATA.get("name","INTFLOAT_MISSING_NAME")
	
	style = CONFIG_DATA.get("style","slider")
	var minimum = float(CONFIG_DATA.get("min",0.0))
	var maximum = float(CONFIG_DATA.get("max",10.0))
	var step = float(CONFIG_DATA.get("step",1.0))
	slider.min_value = minimum
	slider.max_value = maximum
	slider.step = step
	spinbox.min_value = minimum
	spinbox.max_value = maximum
	spinbox.step = step
	match val_type:
		"int":
			slider.rounded = true
			spinbox.rounded = true
			value = round(value)
		"float":
			slider.rounded = false
			spinbox.rounded = false
	
	if style == "slider":
		spinbox.visible = false
		slider.visible = true
		SliderLabel.visible = true
		$Label/LABELBUTTON.focus_neighbour_right = get_path_to($slider)
	elif style == "spinbox":
		spinbox.visible = true
		slider.visible = false
		SliderLabel.visible = false
		$Label/LABELBUTTON.focus_neighbour_right = get_path_to($spinbox)
	slider.value = value
	spinbox.value = value
	volatile = CONFIG_DATA.get("require_restart",false)
	SliderLabel.text = str(value)
	var desc = str(CONFIG_DATA.get("description",""))
	if volatile:
		if desc != "":
			desc = TranslationServer.translate(desc) + "\n\n" + TranslationServer.translate("HEVLIB_SETTING_REQUIRES_RESTART")
		else:
			desc = "HEVLIB_SETTING_REQUIRES_RESTART"
	$Label/LABELBUTTON.hint_tooltip = desc
	add_to_group("hevlib_settings_tab",true)

func _reset_pressed():
	var val = CONFIG_DATA.get("default",10.0)
	if volatile:
		var old_val = pointers.ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
		if old_val != val:
			triggerVolatile()
	slider.value = val
	spinbox.value = val
	SliderLabel.text = str(val)
	pointers.ConfigDriver.__store_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY,val)
	match style:
		"slider":
			slider.grab_focus()
		"spinbox":
			spinbox.grab_focus()
func _draw():
	
	refocus()

func refocus():
	$Label/LABELBUTTON.rect_size = $Label.rect_size
	if style == "slider":
		spinbox.visible = false
		slider.visible = true
		SliderLabel.visible = true
	elif style == "spinbox":
		spinbox.visible = true
		slider.visible = false
		SliderLabel.visible = false
	pointers.ConfigDriver.set_button_focus(self,get_node(style))

func _value_changed(value):
	if volatile:
		var old_val = pointers.ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
		if old_val != value:
			triggerVolatile()
	pointers.ConfigDriver.__store_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY,value)
	SliderLabel.text = str(value)
	get_tree().call_group("hevlib_settings_tab","recheck_availability")
	refocus()


func _visibility_changed():
	refocus()
	if get_position_in_parent() == 0:
		$Label/LABELBUTTON.grab_focus()



func recheck_availability():
	var v = pointers.ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
	slider.set("value" , float(v))
	SliderLabel.text = str(v)
	spinbox.set("value" , float(v))
	if v != CONFIG_DATA.get("default",10.0):
		$reset.visible = true
		$Label/LABELBUTTON.focus_neighbour_right = $Label/LABELBUTTON.get_path_to($reset)
	else:
		$reset.visible = false
		match style:
			"slider":
				$Label/LABELBUTTON.focus_neighbour_right = $Label/LABELBUTTON.get_path_to($slider)
			"spinbox":
				$Label/LABELBUTTON.focus_neighbour_right = $Label/LABELBUTTON.get_path_to($spinbox)
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
					slider.modulate = Color(0.6,0.6,0.6,1)
					SliderLabel.modulate = Color(0.6,0.6,0.6,1)
					slider.editable = false
					spinbox.modulate = Color(0.6,0.6,0.6,1)
					spinbox.editable = false
				else:
					$reset.modulate = Color(1,1,1,1)
					$reset.disabled = false
					slider.modulate = Color(1,1,1,1)
					SliderLabel.modulate = Color(1,1,1,1)
					slider.editable = true
					spinbox.modulate = Color(1,1,1,1)
					spinbox.editable = true
			else:
				if true_valids >= 1:
					$reset.modulate = Color(1,1,1,1)
					$reset.disabled = false
					slider.modulate = Color(1,1,1,1)
					SliderLabel.modulate = Color(1,1,1,1)
					slider.editable = true
					spinbox.modulate = Color(1,1,1,1)
					spinbox.editable = true
				else:
					$reset.modulate = Color(0.6,0.6,0.6,1)
					$reset.disabled = true
					slider.modulate = Color(0.6,0.6,0.6,1)
					SliderLabel.modulate = Color(0.6,0.6,0.6,1)
					slider.editable = false
					spinbox.modulate = Color(0.6,0.6,0.6,1)
					spinbox.editable = false
	else:
		$reset.modulate = Color(1,1,1,1)
		$reset.disabled = false
		slider.modulate = Color(1,1,1,1)
		SliderLabel.modulate = Color(1,1,1,1)
		slider.editable = true
		spinbox.modulate = Color(1,1,1,1)
		spinbox.editable = true

func _input(event):
	if slider.has_focus():
		var action_passed = false
		var val = 0
		var step = 0
		match val_type:
			"int":
				val = round(slider.value)
				step = round(slider.step)
			"float":
				val = float(slider.value)
				step = float(slider.step)
		if event.is_action_pressed("ui_left"):
			if not slider.allow_lesser:
				if val > slider.min_value:
					slider.value = val - step
					action_passed = true
			else:
				slider.value = val - step
				action_passed = true
		if event.is_action_pressed("ui_right"):
			if not slider.allow_greater:
				if val < slider.max_value:
					slider.value = val + step
					action_passed = true
			else:
				slider.value = val + step
				action_passed = true
		if action_passed:
			get_viewport().set_input_as_handled()
			get_tree().call_group("hevlib_settings_tab","recheck_availability")
			$Timer.start()


func _timeout():
	slider.grab_focus()

var updateCacheDir = "user://cache/.Mod_Menu_2_Cache/updates/has_updated.txt"
func triggerVolatile():
	var file = File.new()
	file.open(updateCacheDir,File.WRITE)
	file.store_string("1")
	file.close()
