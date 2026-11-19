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

extends "res://CurrentGame.gd"

signal hlr_storychanged(story,from,to)

onready var hl_research_enabled:bool = false setget setResearchEnabled , getResearchEnabled
onready var researchSysPointers:HevLibPointers = ModLoader._savedObjects[0]

onready var research_store:Dictionary = researchSysPointers.Equipment.research_store

var research_state:Dictionary = Dictionary()
var research_project_ids:PoolStringArray = PoolStringArray()
onready var active_mods:PoolStringArray = researchSysPointers.ManifestV2.__get_mod_ids()

var hl_researchoverhead_uinit : bool = false
func _ready():
	if hl_researchoverhead_uinit:
		researchSysPointers.main_modmain.log_double_load_error(get_script().resource_path)
	hl_researchoverhead_uinit = true
	connect("newGame",self,"init_research_on_save_load")

func setStory(story, to, onlyRise = true):
	if hl_research_enabled:
		emit_signal("hlr_storychanged",story,getStory(story),to)
	.setStory(story,to,onlyRise)

func setResearchEnabled(how:bool):
	hl_research_enabled = how
	researchSysPointers.l("Setting research system to be enabled? [%s]" % how,"Research")

func getResearchEnabled() -> bool:
	return research_store and researchSysPointers.is_editor

func advanceTimeBySeconds(seconds):
	.advanceTimeBySeconds(seconds)
	

var active_projects:Array = Array()
var inactive_projects:Array = Array()
var complete_projects:Array = Array()

func init_research_on_save_load():
	research_state = state.get_or_add("hevlib_research",Dictionary())
	research_project_ids = PoolStringArray(research_state.keys())
	active_projects.clear()
	inactive_projects.clear()
	complete_projects.clear()
	for mod in research_store:
		var mod_store:Dictionary = research_store[mod]
		for entry in mod_store:
			var research_entry:Dictionary = mod_store[entry].duplicate(true)
			var id:String = research_entry["uid"]
			if id in research_project_ids:
				research_entry = research_state[id]
				var mode:String = research_entry.mode
				var rs:Dictionary = research_entry.state
				if rs.completed:
					complete_projects.append(research_entry)
				elif rs.active:
					active_projects.append(research_entry)
				elif mode == "story_only":
					var story:int = getStory(research_entry.story_flag)
					if story > -1 and story < research_entry.progress_complete:
						inactive_projects.append(research_entry)
					else:
						active_projects.append(research_entry)
				else:
					inactive_projects.append(research_entry)
				researchSysPointers.l("Research project %s already in state" % id,"HevLib.Research")
			else:
				research_entry["state"] = {
					"active":false,
					"time_while_active":-1,
					"completed":false,
				}
				research_state[id] = research_entry
				var mode:String = research_entry.mode
				if research_entry.mode == "story_only":
					var story:int = getStory(research_entry.story_flag)
					if story > -1 and story < research_entry.progress_complete:
						inactive_projects.append(research_entry)
					else:
						active_projects.append(research_entry)
				else:
					inactive_projects.append(research_entry)
				researchSysPointers.l("Adding research project %s to state" % id,"HevLib.Research")
			

func get_active_research_projects() -> Array:
	return active_projects

func get_inactive_research_projects() -> Array:
	return inactive_projects

func get_completed_research_projects() -> Array:
	return complete_projects



