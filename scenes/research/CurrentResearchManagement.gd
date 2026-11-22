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

onready var research_item:PackedScene = load("res://HevLib/scenes/research/research_item_box/active/ResearchItem.tscn")
onready var completed_research_item:PackedScene = load("res://HevLib/scenes/research/research_item_box/completed/ResearchItem.tscn")

onready var pointers:HevLibPointers = ModLoader._savedObjects[0]
onready var current_mod_ids:PoolStringArray = pointers.ManifestV2.__get_mod_ids()

onready var active_list:VBoxContainer = $VBoxContainer/ActiveProjectsList/Projects
onready var completed_list:VBoxContainer = $VBoxContainer/CompletedProjects/Projects

onready var active_projects_count_label:Label = $VBoxContainer/MarginContainer/GridContainer/Active/ActiveValue 
onready var completed_projects_count_label:Label = $VBoxContainer/MarginContainer/GridContainer/Completed/CompletedValue 

onready var show_completed_button:CheckButton = $VBoxContainer/MarginContainer2/HBoxContainer/CheckButton

onready var completed_projects_header:Label = $VBoxContainer/FinishedProjects
onready var completed_projects_container:VBoxContainer = $VBoxContainer/CompletedProjects

var project_mutex:Mutex = Mutex.new()
var adding_flag:bool = false

func _ready():
	show_completed_button.connect("toggled",self,"toggle_completed_visibility")
	connect("visibility_changed",self,"vis_changed")
	add_projects()
	CurrentGame.connect("research_project_reassignment",self,"add_projects")

func add_projects():
	Tool.deferCallInPhysics(self,"do_add_projects")

func do_add_projects():
	project_mutex.lock()
	if adding_flag:
		pointers.l("Already loading current projects","HevLib Research")
		project_mutex.unlock()
		return
	adding_flag = true
	for i in active_list.get_children() + completed_list.get_children():
		Tool.remove(i)
	for obj in CurrentGame.get_active_research_projects():
		var p:HBoxContainer = research_item.instance()
		p.this_research_project = obj
		p.name = obj.source + "|" + obj.name
		active_list.add_child(p)
		if not is_visible_in_tree() and is_inside_tree():
			yield(pointers,"physics_process_tick")
	for obj in CurrentGame.get_completed_research_projects():
		var p:HBoxContainer = completed_research_item.instance()
		p.this_research_project = obj
		p.name = obj.source + "|" + obj.name
		completed_list.add_child(p)
		if not is_visible_in_tree() and is_inside_tree():
			yield(pointers,"physics_process_tick")
	
	
	
	

func vis_changed():
	if is_visible_in_tree():
		var completed_count:int = completed_list.get_child_count()
		if completed_count:
			show_completed_button.disabled = false
			show_completed_button.hint_tooltip = "HEVLIB_RESEARCH_TOGGLE_COMPLETED_VISIBILITY"
			toggle_completed_visibility(show_completed_button.pressed)
		else:
			show_completed_button.disabled = true
			show_completed_button.hint_tooltip = "HEVLIB_RESEARCH_TOGGLE_COMPLETED_VISIBILITY_DISABLED"
			toggle_completed_visibility(false)
		active_projects_count_label.text = str(active_list.get_child_count())
		completed_projects_count_label.text = str(completed_count)

func toggle_completed_visibility(how:bool):
	completed_projects_header.visible = how
	completed_projects_container.visible = how
