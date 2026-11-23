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

extends MarginContainer

var lastFocus

var research_button

onready var current_project_management = $TabHintContainer/Tabs/HEVLIB_RESEARCH_CURRENT/CurrentResearchManagement
onready var dormant_project_management = $TabHintContainer/Tabs/HEVLIB_RESEARCH_AVAILABLE/MarginContainer/HBoxContainer/ActivatableProjects

onready var show_completed_projects_btn = $TabHintContainer/Tabs/HEVLIB_RESEARCH_CURRENT/CurrentResearchManagement/VBoxContainer/MarginContainer2/HBoxContainer/CheckButton

onready var rpc:HevLibPointers._RPC= ModLoader._savedObjects[0].RPC

func show():
	if visible or $Shower.is_playing():
		return
	lastFocus = get_focus_owner()
	$Shower.play("show")
	show_completed_projects_btn.grab_focus()
	show_completed_projects_btn.pressed = false
	rpc.call_deferred("loader_changed","enceladus_prime",1,"research")


#	var notif = {
#		"title":{"text":"Title Test"},
#		"body":{"text":"Body Test"},
#		"description":{"text":"Desc Test"},
#		"particles":{"show":true},
#		"transition":{"label":"Label Test","old":"Old Value","new":"New Value"},
#		"scene":{"path":"res://ships/RA-TRTL.tscn","position":Vector2(-25,0),"scale":Vector2(0.5,0.5),"rotation":90,"rotation_speed":1800}
#	}
#
#
#	CurrentGame.send_notification(notif)


func hide():
	if not visible or $Shower.current_animation == "hide":
		return
	$Shower.play("hide")
	if lastFocus:
		lastFocus.grab_focus()
	rpc.loader_changed("enceladus_prime",0,"")

func _ready():
	visible = false
	get_parent().connect("hidefoka", self, "hide")


func _input(event):
	if visible and (Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("pause")):
		get_tree().set_input_as_handled()
		hide()

func unfocus():
	if lastFocus and get_focus_owner() == null:
		lastFocus.grab_focus()
		lastFocus = null

func _on_Research_pressed():
	show()
