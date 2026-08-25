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
export (String,"slider","spinbox") var style = "slider"

export (String,"int","float") var val_type = "int"

onready var slider = $MarginContainer/slider
onready var label = $Label
onready var spinbox = $MarginContainer/spinbox
onready var SliderLabel = $SliderLabel
onready var focus_button = $MarginContainer/Focus
onready var label_button = $Label/LABELBUTTON
onready var reset_button = $reset
onready var spinbox_focus = $MarginContainer/spinbox_focus

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
		label_button.focus_neighbour_right = get_path_to(focus_button)
	elif style == "spinbox":
		spinbox.visible = true
		slider.visible = false
		SliderLabel.visible = false
		label_button.focus_neighbour_right = get_path_to(focus_button)
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
	label_button.hint_tooltip = desc
	add_to_group("hevlib_settings_tab",true)

func _reset_pressed():
	var val = CONFIG_DATA.get("default",10.0)
	if volatile:
		var old_val = pointers.ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
		if not is_equal_approx(val,old_val):
			triggerVolatile()
	slider.value = val
	spinbox.value = val
	SliderLabel.text = str(val)
	pointers.ConfigDriver.__store_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY,val)
	focus_button.grab_focus()

func _draw():
	
	refocus()

func refocus():
	label_button.rect_size = label.rect_size
	if style == "slider":
		spinbox.visible = false
		slider.visible = true
		SliderLabel.visible = true
	elif style == "spinbox":
		spinbox.visible = true
		slider.visible = false
		SliderLabel.visible = false
	if is_visible_in_tree():
		yield(get_tree(),"idle_frame")
		pointers.ConfigDriver.set_button_focus(self,focus_button)

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
		label_button.grab_focus()



func recheck_availability():
	var v = pointers.ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
	slider.set("value" , float(v))
	SliderLabel.text = str(v)
	spinbox.set("value" , float(v))
	if not is_equal_approx(v,CONFIG_DATA.get("default",10.0)):
		reset_button.visible = true
		label_button.focus_neighbour_right = label_button.get_path_to(reset_button)
		reset_button.focus_neighbour_left = reset_button.get_path_to(label_button)
		reset_button.focus_neighbour_right = reset_button.get_path_to(focus_button)
		focus_button.focus_neighbour_left = focus_button.get_path_to(reset_button)
	else:
		reset_button.visible = false
		label_button.focus_neighbour_right = label_button.get_path_to(focus_button)
		focus_button.focus_neighbour_left = focus_button.get_path_to(label_button)
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
					slider.modulate = Color(0.6,0.6,0.6,1)
					SliderLabel.modulate = Color(0.6,0.6,0.6,1)
					slider.editable = false
					spinbox.modulate = Color(0.6,0.6,0.6,1)
					spinbox.editable = false
				else:
					reset_button.modulate = Color(1,1,1,1)
					reset_button.disabled = false
					slider.modulate = Color(1,1,1,1)
					SliderLabel.modulate = Color(1,1,1,1)
					slider.editable = true
					spinbox.modulate = Color(1,1,1,1)
					spinbox.editable = true
			else:
				if true_valids >= 1:
					reset_button.modulate = Color(1,1,1,1)
					reset_button.disabled = false
					slider.modulate = Color(1,1,1,1)
					SliderLabel.modulate = Color(1,1,1,1)
					slider.editable = true
					spinbox.modulate = Color(1,1,1,1)
					spinbox.editable = true
				else:
					reset_button.modulate = Color(0.6,0.6,0.6,1)
					reset_button.disabled = true
					slider.modulate = Color(0.6,0.6,0.6,1)
					SliderLabel.modulate = Color(0.6,0.6,0.6,1)
					slider.editable = false
					spinbox.modulate = Color(0.6,0.6,0.6,1)
					spinbox.editable = false
	else:
		reset_button.modulate = Color(1,1,1,1)
		reset_button.disabled = false
		slider.modulate = Color(1,1,1,1)
		SliderLabel.modulate = Color(1,1,1,1)
		slider.editable = true
		spinbox.modulate = Color(1,1,1,1)
		spinbox.editable = true

func _input(event):
	var box = get_specific_rangebox()
	var boxfocus = false
	if box:
		boxfocus = box.has_focus()
	var ffocus = focus_button.has_focus()
	if ffocus:
		if Input.is_action_just_pressed("ui_accept"):
			_timeout()
			get_viewport().set_input_as_handled()
	elif boxfocus:
		var action_passed = false
		if Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("ui_accept"):
			box.focus_mode = Control.FOCUS_NONE
			focus_button.grab_focus()
			get_viewport().set_input_as_handled()
		else:
			var val = 0.0
			var step = 0.0
			match val_type:
				"int":
					val = round(box.value)
					step = round(box.step)
				"float":
					val = float(box.value)
					step = float(box.step)
			if event.is_action_pressed("ui_left"):
				if not box.allow_lesser:
					if val > box.min_value:
						box.value -= step
						action_passed = true
				else:
					box.value -= step
					action_passed = true
			if event.is_action_pressed("ui_right"):
				if not box.allow_greater:
					if val < box.max_value:
						box.value += step
						action_passed = true
				else:
					box.value += step
					action_passed = true
			if action_passed:
				get_viewport().set_input_as_handled()
				get_tree().call_group("hevlib_settings_tab","recheck_availability")
				$Timer.start()

var echo = 0.5
var echo_ctr = 0.0
var press_ctr = 0.0
func _process(delta):
	var box = get_specific_rangebox()
	if box and box.has_focus():
		spinbox_focus.visible = style == "spinbox"
		var l = Input.is_action_pressed("ui_left")
		var r = Input.is_action_pressed("ui_right")
		if l or r:
			echo_ctr += delta
			if echo_ctr > echo:
				press_ctr += delta
				if press_ctr > 0.0625:
					press_ctr = 0.0
					var val = 0.0
					var step = 0.0
					match val_type:
						"int":
							val = round(box.value)
							step = round(box.step)
						"float":
							val = float(box.value)
							step = float(box.step)
					if l:
						if not box.allow_lesser:
							if val > box.min_value:
								box.value -= step
						else:
							box.value -= step
					if r:
						if not box.allow_greater:
							if val < box.max_value:
								box.value += step
						else:
							box.value += step
		else:
			echo_ctr = 0.0
			press_ctr = 0.0
	else:
		spinbox_focus.visible = false


func _timeout():
	var box = get_specific_rangebox()
	if box:
		box.focus_mode = Control.FOCUS_ALL
		box.grab_focus()
		
var updateCacheDir = "user://cache/.Mod_Menu_2_Cache/updates/has_updated.txt"
func triggerVolatile():
	var file = File.new()
	file.open(updateCacheDir,File.WRITE)
	file.store_string("1")
	file.close()

func get_focusable(direction = 0):
	return focus_button

func get_specific_rangebox():
	match style:
		"slider":
			return slider
		"spinbox":
			return spinbox
	return
	

func get_label(direction = 0):
	return label_button

func get_reset(direction = 0):
	return reset_button
