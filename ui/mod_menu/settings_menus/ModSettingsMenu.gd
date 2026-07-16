extends Popup

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

var SELECTED_MOD = ""
var SELECTED_MOD_ID = ""

export (NodePath) var modmenu
onready var mod_menu = get_node_or_null(modmenu)

onready var container = $base/TabContainer

var offset = Vector2(12,12)

const mod_tab = preload("res://HevLib/ui/mod_menu/settings_menus/generic_mod_tab.tscn")

func _about_to_show():
	for child in container.get_children():
		Tool.remove(child)
	
	if SELECTED_MOD != "":
		var tab = mod_tab.instance()
		tab.mod = SELECTED_MOD
		tab.mod_id = SELECTED_MOD_ID
		container.add_child(tab)
	
	lastFocus = get_focus_owner()
	
	get_node("base/TabContainer").get_child(0).get_node("MarginContainer/TabContainer").get_child(0).get_node("MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer").get_child(0).get_node("Label/LABELBUTTON").call_deferred("grab_focus")
	
	_on_resize()

func _ready():
	get_tree().get_root().connect("size_changed", self, "_on_resize")
func _visibility_changed():
	_on_resize()

func show_menu():
	popup()

func cancel():
	$AnimateAppear.play("hider")

func hider():
	hide()
	refocus()
	mod_menu.show_restart_menu()

var lastFocus = null
func refocus():
	if lastFocus and lastFocus.has_method("grab_focus"):
		lastFocus.grab_focus()
	else:
		Debug.l("I have no focus to fall back to!")

func _on_resize():
	if is_visible_in_tree():
		var size = Settings.getViewportSize()
		rect_size = size
		$ColorRect.rect_size = size
		$base.rect_size = size - offset
		$base.rect_position = offset/2
		$base/TabContainer.rect_size = size - offset
	
