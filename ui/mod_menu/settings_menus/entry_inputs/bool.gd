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

var volatile = false

onready var reset_button = $reset
onready var bool_button = $CheckButton
onready var name_label = $Label
onready var label_button = $Label/LABELBUTTON

func _ready():
	var value = pointers.ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
	if value == null:
		Tool.remove(self)
	volatile = CONFIG_DATA.get("require_restart",false)
	name_label.text = CONFIG_DATA.get("name","BOOL_MISSING_NAME")
	bool_button.pressed = value
	var desc = str(CONFIG_DATA.get("description",""))
	if volatile:
		if desc != "":
			desc = TranslationServer.translate(desc) + "\n\n" + TranslationServer.translate("HEVLIB_SETTING_REQUIRES_RESTART")
		else:
			desc = "HEVLIB_SETTING_REQUIRES_RESTART"
	label_button.hint_tooltip = desc
	add_to_group("hevlib_settings_tab",true)

func _toggled(button_pressed):
	if volatile:
		var old_val = pointers.ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
		if old_val != button_pressed:
			triggerVolatile()
	pointers.ConfigDriver.__store_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY,button_pressed)
	var tex = StreamTexture.new()
	if button_pressed:
		tex.load_path = "res://HevLib/ui/themes/icons/on_25.stex"
	else:
		tex.load_path = "res://HevLib/ui/themes/icons/off_25.stex"
	get_tree().call_group("hevlib_settings_tab","recheck_availability")
	
	bool_button.icon = tex

func recheck_availability():
	bool_button.pressed = pointers.ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
	if bool_button.pressed != CONFIG_DATA.get("default",false):
		reset_button.visible = true
		label_button.focus_neighbour_right = label_button.get_path_to(reset_button)
		bool_button.focus_neighbour_left = bool_button.get_path_to(reset_button)
	else:
		reset_button.visible = false
		label_button.focus_neighbour_right = label_button.get_path_to(bool_button)
		bool_button.focus_neighbour_left = bool_button.get_path_to(label_button)
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
					bool_button.modulate = Color(0.6,0.6,0.6,1)
					bool_button.disabled = true
				else:
					reset_button.modulate = Color(1,1,1,1)
					reset_button.disabled = false
					bool_button.modulate = Color(1,1,1,1)
					bool_button.disabled = false
			else:
				if true_valids >= 1:
					reset_button.modulate = Color(1,1,1,1)
					reset_button.disabled = false
					bool_button.modulate = Color(1,1,1,1)
					bool_button.disabled = false
				else:
					reset_button.modulate = Color(0.6,0.6,0.6,1)
					reset_button.disabled = true
					bool_button.modulate = Color(0.6,0.6,0.6,1)
					bool_button.disabled = true
	else:
		reset_button.modulate = Color(1,1,1,1)
		reset_button.disabled = false
		bool_button.modulate = Color(1,1,1,1)
		bool_button.disabled = false

func _reset_pressed():
	var defaultVal = CONFIG_DATA.get("default",false)
	if volatile:
		var old_val = pointers.ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
		if old_val != defaultVal:
			triggerVolatile()
	bool_button.pressed = defaultVal
	pointers.ConfigDriver.__store_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY,defaultVal)
	bool_button.grab_focus()
	get_tree().call_group("hevlib_settings_tab","recheck_availability")

func _draw():
	
	refocus()

func refocus():
	label_button.rect_size = name_label.rect_size
	if is_visible_in_tree():
		yield(get_tree(),"idle_frame")
		pointers.ConfigDriver.set_button_focus(self,bool_button)
	

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

func get_focusable(direction = 0):
	return bool_button

func get_label(direction = 0):
	return label_button

func get_reset(direction = 0):
	return reset_button
