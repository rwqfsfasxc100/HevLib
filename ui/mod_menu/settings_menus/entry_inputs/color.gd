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

var volatile = false

onready var label_button = $Label/LABELBUTTON
onready var name_label = $Label
onready var color_button = $CheckButton
onready var reset_button = $reset

func _ready():
	var value = pointers.ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
	if value == null:
		Tool.remove(self)
	volatile = CONFIG_DATA.get("require_restart",false)
	var edit_alpha = CONFIG_DATA.get("edit_alpha",true)
	if not edit_alpha:
		value.a = 1
	name_label.text = CONFIG_DATA.get("name","COLOR_MISSING_NAME")
	color_button.color = value
	color_button.edit_alpha = edit_alpha
	var desc = str(CONFIG_DATA.get("description",""))
	if volatile:
		if desc != "":
			desc = TranslationServer.translate(desc) + "\n\n" + TranslationServer.translate("HEVLIB_SETTING_REQUIRES_RESTART")
		else:
			desc = "HEVLIB_SETTING_REQUIRES_RESTART"
	label_button.hint_tooltip = desc
	add_to_group("hevlib_settings_tab",true)

func _toggled(color):
	if volatile:
		var old_val = pointers.ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
		if old_val != color:
			triggerVolatile()
	pointers.ConfigDriver.__store_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY,color)
	get_tree().call_group("hevlib_settings_tab","recheck_availability")

func recheck_availability():
	var col = pointers.ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
	if not CONFIG_DATA.get("edit_alpha",true):
		col.a = 1
	color_button.color = col
	if color_button.color != CONFIG_DATA.get("default",Color(1,1,1,1)):
		reset_button.visible = true
		label_button.focus_neighbour_right = label_button.get_path_to(reset_button)
		color_button.focus_neighbour_left = label_button.get_path_to(reset_button)
	else:
		reset_button.visible = false
		label_button.focus_neighbour_right = label_button.get_path_to(color_button)
		color_button.focus_neighbour_left = label_button.get_path_to(label_button)
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
					color_button.modulate = Color(0.6,0.6,0.6,1)
					color_button.disabled = true
				else:
					reset_button.modulate = Color(1,1,1,1)
					reset_button.disabled = false
					color_button.modulate = Color(1,1,1,1)
					color_button.disabled = false
			else:
				if true_valids >= 1:
					reset_button.modulate = Color(1,1,1,1)
					reset_button.disabled = false
					color_button.modulate = Color(1,1,1,1)
					color_button.disabled = false
				else:
					reset_button.modulate = Color(0.6,0.6,0.6,1)
					reset_button.disabled = true
					color_button.modulate = Color(0.6,0.6,0.6,1)
					color_button.disabled = true
	else:
		reset_button.modulate = Color(1,1,1,1)
		reset_button.disabled = false
		color_button.modulate = Color(1,1,1,1)
		color_button.disabled = false

func _reset_pressed():
	var defaultVal = CONFIG_DATA.get("default",Color(1,1,1,1))
	if not CONFIG_DATA.get("edit_alpha",true):
		defaultVal.a = 1
	if volatile:
		var old_val = pointers.ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
		if old_val != defaultVal:
			triggerVolatile()
	color_button.color = defaultVal
	pointers.ConfigDriver.__store_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY,defaultVal)
	color_button.grab_focus()
	get_tree().call_group("hevlib_settings_tab","recheck_availability")

func _draw():
	
	refocus()

func refocus():
	label_button.rect_size = name_label.rect_size
	if is_visible_in_tree():
		yield(get_tree(),"idle_frame")
		pointers.ConfigDriver.set_button_focus(self,color_button)
	

func _visibility_changed():
	if get_position_in_parent() == 0:
		label_button.grab_focus()
	refocus()

var updateCacheDir = "user://cache/.Mod_Menu_2_Cache/updates/has_updated.txt"
func triggerVolatile():
	var file = File.new()
	file.open(updateCacheDir,File.WRITE)
	file.store_string("1")
	file.close()

# Color picker node. _picker_created must have been ran for this to be filled.
var picker:ColorPicker

# Color picker components. _picker_created must have been ran for these to be filled.
var rslider:HSlider
var rspinbox:SpinBox
var gslider:HSlider
var gspinbox:SpinBox
var bslider:HSlider
var bspinbox:SpinBox
var aslider:HSlider
var aspinbox:SpinBox
var hsvtoggle
var rawtoggle
var hexlabel
var hexlineedit
func _picker_created():
	picker = color_button.get_picker()
	picker.presets_enabled = false
	picker.presets_visible = false
	picker.rect_min_size = picker.rect_size
	
	rslider = picker.get_child(4).get_child(0).get_child(1)  # Red/Hue slider
	rspinbox = picker.get_child(4).get_child(0).get_child(2)  # Red/Hue spinbox
	gslider = picker.get_child(4).get_child(1).get_child(1)  # Green/Saturation slider
	gspinbox = picker.get_child(4).get_child(1).get_child(2)  # Green/Saturation spinbox
	bslider = picker.get_child(4).get_child(2).get_child(1)  # Blue/Value slider
	bspinbox = picker.get_child(4).get_child(2).get_child(2)  # Blue/Value spinbox
	aslider = picker.get_child(4).get_child(3).get_child(1)  # Alpha slider
	aspinbox = picker.get_child(4).get_child(3).get_child(2)  # Alpha slider
	hsvtoggle = picker.get_child(4).get_child(4).get_child(0)  # HSV toggle
	rawtoggle = picker.get_child(4).get_child(4).get_child(1)  # "Raw" toggle
	hexlabel = picker.get_child(4).get_child(4).get_child(2)  # Hex '#' label (why focus_mode == 2??)
	hexlineedit = picker.get_child(4).get_child(4).get_child(3)  # Hex LineEdit
	
	rslider.focus_mode = 2
	rspinbox.focus_mode = 2
	gslider.focus_mode = 2
	gspinbox.focus_mode = 2
	bslider.focus_mode = 2
	bspinbox.focus_mode = 2
	aslider.focus_mode = 2
	aspinbox.focus_mode = 2
	hsvtoggle.focus_mode = 2
	rawtoggle.focus_mode = 2
	hexlineedit.focus_mode = 2
	
	rslider.focus_neighbour_right = rslider.get_path_to(rspinbox)
	rslider.focus_neighbour_bottom = rslider.get_path_to(gslider)
	gslider.focus_neighbour_top = gslider.get_path_to(rslider)
	gslider.focus_neighbour_right = gslider.get_path_to(gspinbox)
	gslider.focus_neighbour_bottom = gslider.get_path_to(bslider)
	bslider.focus_neighbour_top = bslider.get_path_to(gslider)
	bslider.focus_neighbour_right = bslider.get_path_to(bspinbox)
	bslider.focus_neighbour_bottom = bslider.get_path_to(aslider)
	aslider.focus_neighbour_top = aslider.get_path_to(bslider)
	aslider.focus_neighbour_right = aslider.get_path_to(aspinbox)
	aslider.focus_neighbour_bottom = aslider.get_path_to(hsvtoggle)
	
	picker.connect("visibility_changed",self,"picker_showing",[picker])

func picker_showing(pc:ColorPicker):
	if pc and pc.is_visible_in_tree():
		yield(get_tree(),"idle_frame")
		pc.get_child(4).get_child(0).get_child(1).grab_focus()
	else:
		color_button.grab_focus()

func _input(event):
	if picker and picker.is_visible_in_tree() and event is InputEventJoypadMotion:
		if (event.axis == JOY_AXIS_0 or event.axis == JOY_AXIS_2):
			if abs(event.axis_value) > 0.5:
				var av = event.axis_value
				scale = int(round(clamp((abs(av) * 2.0) - 0.5,0,1) * 3)) * sign(av)
			else:
				scale = 0.0
var scale = 0.0
func _physics_process(delta):
	var cfocus = get_focus_owner()
	if cfocus == rslider:
		var current = rslider.value
		if picker.raw_mode:
			rslider.value = clamp(current + (scale / 255.0),0.0,100.0)
		else:
			rslider.value = clamp(current + scale,0,255)
	elif cfocus == gslider:
		var current = gslider.value
		if picker.raw_mode:
			gslider.value = clamp(current + (scale / 255.0),0.0,100.0)
		else:
			gslider.value = clamp(current + scale,0,255)
	elif cfocus == bslider:
		var current = bslider.value
		if picker.raw_mode:
			bslider.value = clamp(current + (scale / 255.0),0.0,100.0)
		else:
			bslider.value = clamp(current + scale,0,255)
	elif cfocus == aslider:
		var current = aslider.value
		if picker.raw_mode:
			aslider.value = clamp(current + (scale / 255.0),0.0,1.0)
		else:
			aslider.value = clamp(current + scale,0,255)

func get_focusable(direction = 0):
	return color_button

func get_label(direction = 0):
	return label_button

func get_reset(direction = 0):
	return reset_button
