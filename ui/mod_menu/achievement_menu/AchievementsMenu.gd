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

var offset : Vector2 = Vector2(12,12)

func rebuild_achievement_list():
	for i in achievement_list.get_children():
		achievement_list.remove_child(i)
		Tool.remove(i)
	
	
	
	breakpoint

func rebuild_stat_list():
	for i in stats_list.get_children():
		stats_list.remove_child(i)
		Tool.remove(i)
	
	
	
	breakpoint

func _ready():
	get_tree().get_root().connect("size_changed", self, "_on_resize")
	Achivements.connect("achivedOffline",self,"rebuild_achievement_list")
	Achivements.connect("stat",self,"rebuild_stat_list")
	rebuild_achievement_list()

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
	
