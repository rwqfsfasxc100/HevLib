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

extends Popup

export var offset = Vector2(12,12)
export var tablist = NodePath("")
onready var tabs = get_node_or_null(tablist)

export var mod_tab = preload("res://HevLib/ui/mod_menu/changelogs/ModChangelogTab.tscn")

func open(mods):
	if tabs:
		for i in tabs.get_children():
			tabs.remove_child(i)
		for mod in mods:
			var data = mods[mod]
			if data["changelog"] != "":
				var tab = mod_tab.instance()
				tab.name = data.get("name",mod)
				tab.mod_data = data.duplicate(true)
				tabs.add_child(tab)

func _ready():
	connect("about_to_show",self,"_about_to_show")
	connect("visibility_changed",self,"_on_resize")

func _about_to_show():
	lastFocus = get_focus_owner()
	$base/PanelContainer/VBoxContainer/FooterButtons/Close.grab_focus()

func show_menu():
	popup()

func cancel():
	hide()
	refocus()

var lastFocus = null
func refocus():
	if lastFocus and lastFocus.has_method("grab_focus"):
		lastFocus.grab_focus()
	else:
		Debug.l("I have no focus to fall back to!")

func _unhandled_input(event):
	if visible and Input.is_action_just_pressed("ui_cancel"):
		cancel()
		get_tree().set_input_as_handled()

func _on_resize():
	if is_visible_in_tree():
		var size = Settings.getViewportSize()
		var offsetSize = size - offset
		var vbsize = offsetSize - Vector2(10,10)
		rect_size = size
#		$ColorRect.rect_min_size = size
		$ColorRect.rect_size = size
#		$base.rect_min_size = offsetSize
		$base.rect_size = offsetSize
		$base.rect_position = offset/2
		$base/PanelContainer.rect_size = offsetSize
		$base/PanelContainer/VBoxContainer.rect_position = Vector2(5,5)
		$base/PanelContainer/VBoxContainer.rect_size = vbsize
