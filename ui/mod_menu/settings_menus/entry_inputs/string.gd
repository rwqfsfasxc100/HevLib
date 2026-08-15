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
# 4. The source code and the binary form, and any modifications made to them may not be used for the purpose of input data, the training of, or improvement of machine learning algorithms,
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

onready var name_label = $Label
onready var label_button = $Label/LABELBUTTON
onready var line_edit = $LineEdit
onready var reset_button = $reset
func _ready():
	var value = pointers.ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
	if value == null:
		Tool.remove(self)
	name_label.text = CONFIG_DATA.get("name","STRING_MISSING_NAME")
	line_edit.text = value
	volatile = CONFIG_DATA.get("require_restart",false)
	line_edit.max_length = CONFIG_DATA.get("max_length",0)
	line_edit.secret = CONFIG_DATA.get("secret",false)
	line_edit.clear_button_enabled = CONFIG_DATA.get("clear_button",false)
	line_edit.placeholder_text = CONFIG_DATA.get("placeholder","HEVLIB_CONFIG_LINEEDIT_PLACEHOLDER")
	var desc = str(CONFIG_DATA.get("description",""))
	if volatile:
		if desc != "":
			desc = TranslationServer.translate(desc) + "\n\n" + TranslationServer.translate("HEVLIB_SETTING_REQUIRES_RESTART")
		else:
			desc = "HEVLIB_SETTING_REQUIRES_RESTART"
	label_button.hint_tooltip = desc
	add_to_group("hevlib_settings_tab",true)


func recheck_availability():
	line_edit.text = pointers.ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
	if line_edit.text != CONFIG_DATA.get("default",""):
		reset_button.visible = true
		label_button.focus_neighbour_right = label_button.get_path_to(reset_button)
		line_edit.focus_neighbour_left = line_edit.get_path_to(reset_button)
	else:
		reset_button.visible = false
		label_button.focus_neighbour_right = label_button.get_path_to(line_edit)
		line_edit.focus_neighbour_left = line_edit.get_path_to(label_button)
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
					line_edit.modulate = Color(0.6,0.6,0.6,1)
					line_edit.editable = false
				else:
					reset_button.modulate = Color(1,1,1,1)
					reset_button.disabled = false
					line_edit.modulate = Color(1,1,1,1)
					line_edit.editable = true
			else:
				if true_valids >= 1:
					reset_button.modulate = Color(1,1,1,1)
					reset_button.disabled = false
					line_edit.modulate = Color(1,1,1,1)
					line_edit.editable = true
				else:
					reset_button.modulate = Color(0.6,0.6,0.6,1)
					reset_button.disabled = true
					line_edit.modulate = Color(0.6,0.6,0.6,1)
					line_edit.editable = false
	else:
		reset_button.modulate = Color(1,1,1,1)
		reset_button.disabled = false
		line_edit.modulate = Color(1,1,1,1)
		line_edit.editable = true


func _reset_pressed():
	var defaultVal = CONFIG_DATA.get("default","")
	line_edit.text = defaultVal
	if volatile:
		var old_val = pointers.ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
		if old_val != defaultVal:
			triggerVolatile()
	pointers.ConfigDriver.__store_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY,defaultVal)
	line_edit.grab_focus()
	reset_button.visible = false
func _draw():
	refocus()

func refocus():
	label_button.rect_size = name_label.rect_size
	pointers.ConfigDriver.set_button_focus(self,line_edit)
	

func _visibility_changed():
	refocus()
	if get_position_in_parent() == 0:
		label_button.grab_focus()
var caret_pos = 0

func _on_LineEdit_text_entered(new_text):
	caret_pos = line_edit.caret_position
	line_edit.text = new_text
	if volatile:
		var old_val = pointers.ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
		if old_val != new_text:
			triggerVolatile()
	pointers.ConfigDriver.__store_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY,new_text)
	get_tree().call_group("hevlib_settings_tab","recheck_availability")

func _process(delta):
	caret_pos = line_edit.text.length()
	line_edit.caret_position = caret_pos

func _timeout():
	line_edit.grab_focus()

var updateCacheDir = "user://cache/.Mod_Menu_2_Cache/updates/has_updated.txt"
func triggerVolatile():
	var file = File.new()
	file.open(updateCacheDir,File.WRITE)
	file.store_string("1")
	file.close()

func get_focusable(direction = 0):
	return line_edit

func get_label(direction = 0):
	return label_button

func get_reset(direction = 0):
	return reset_button
