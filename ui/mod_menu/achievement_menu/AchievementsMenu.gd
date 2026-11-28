# [license]
# SPDX-License-Identifier: LicenseRef-Proprietary
# Copyright © 2026 __hev (Benjamin Buckhurst). All Rights Reserved.
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that all following conditions are met:
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

extends Popup
export (NodePath) var modmenu
onready var mod_menu = get_node_or_null(modmenu)

onready var container : VBoxContainer = $base/VBoxContainer

export (NodePath) var achievement_list_path = NodePath()
onready var achievement_list : VBoxContainer = get_node_or_null(achievement_list_path)
export (NodePath) var achievement_count_path = NodePath()
onready var achievement_count : Label = get_node_or_null(achievement_count_path)
export (NodePath) var stats_list_path = NodePath()
onready var stats_list : VBoxContainer = get_node_or_null(stats_list_path)

onready var pointers : HevLibPointers = ModLoader._savedObjects[0]

onready var achievement_names : PoolStringArray = PoolStringArray(Achivements.achievementRarity.keys())

onready var achievement_box : PackedScene = load("res://HevLib/ui/mod_menu/achievement_menu/boxes/AchievementBox.tscn")
onready var stat_box : PackedScene = load("res://HevLib/ui/mod_menu/achievement_menu/boxes/StatBox.tscn")

var offset : Vector2 = Vector2(12,12)

var achievement_boxes : Array = Array()
var stat_boxes : Array = Array()

onready var achievement_count_label : Label = $base/AchievementCount
onready var achievement_count_label_animator : AnimationPlayer = $base/AchievementCount/AnimationPlayer

var completed_achievement_count : int = 0
func redisplay_boxes():
	if is_visible_in_tree():
		set_process(true)
		var num_achievements : int = achievement_names.size()
		completed_achievement_count = 0
		for i in achievement_boxes:
			i.update_data()
			achievement_count_label.text = "%d / %d" % [completed_achievement_count,num_achievements]
			yield(self,"tick")
		set_process(false)
		if completed_achievement_count == num_achievements:
			achievement_count_label_animator.play("Blink")
		else:
			var locked : int = num_achievements - completed_achievement_count
			var cc : Array = Array()
			for ir in locked:
				var i : HBoxContainer = achievement_list.get_child(completed_achievement_count + ir)
				var icon : TextureProgress = i.icon
				if icon.value > 0 and icon.value < icon.max_value:
					cc.append(i)
			for ir in range(cc.size(),0,-1):
				achievement_list.move_child(cc[ir - 1],completed_achievement_count)
			achievement_count_label_animator.play("RESET")
	else:
		for i in achievement_boxes:
			i.visible = false

func _ready():
	get_tree().get_root().connect("size_changed", self, "_on_resize")
	for i in achievement_names:
		var box : HBoxContainer = achievement_box.instance()
		box.name = i
		box.achievement_id = i
		box.menu_container = self
		box.mod_menu = mod_menu
		achievement_boxes.append(box)
		achievement_list.add_child(box)
	for i in Achivements.achivements.keys():
		if i.begins_with("stat:"):
			var box : HBoxContainer = stat_box.instance()
			box.name = i
			box.stat_id = i
			stat_boxes.append(box)
			stats_list.add_child(box)
	connect("visibility_changed",self,"redisplay_boxes")
	connect("visibility_changed",self,"redisplay_stats")

func redisplay_stats():
	for i in stat_boxes:
		i.update_data()
		yield(self,"tick")

func _about_to_show():
	lastFocus = get_focus_owner()
	_on_resize()

func _visibility_changed():
	_on_resize()

func show_menu():
	popup()

func cancel():
	$AnimateAppear.play("hider")

func hider():
	hide()
	refocus()

var lastFocus = null
func refocus():
	if lastFocus and lastFocus.has_method("grab_focus"):
		lastFocus.grab_focus()
	else:
		Debug.l("I have no focus to fall back to!")

func _on_resize():
	if is_visible_in_tree():
		var size : Vector2 = Settings.getViewportSize()
		rect_size = size
		$ColorRect.rect_size = size
		$base.rect_size = size - offset
		$base.rect_position = offset/2
		container.rect_size = size - offset

signal tick

func _process(delta: float) -> void:
	emit_signal("tick")
