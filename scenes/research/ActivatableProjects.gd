extends MarginContainer

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

const research_item = preload("res://HevLib/scenes/research/research_item_box/ResearchItem.tscn")
var research_state = {}

var current_mod_ids = []

onready var inactive_list = $Scroll/Items
onready var active_list = get_node("../../../../HEVLIB_RESEARCH_CURRENT/CurrentResearchManagement/VBoxContainer/ScrollContainer/Projects")

func _initialize():
	research_state = CurrentGame.state.hevlib_research
	for project in research_state:
		var obj = research_state[project]
		
		if obj.state.active == false and obj.source in current_mod_ids:
			var p = research_item.instance()
			p.this_research_project = obj
			p.name = obj.source + "|" + obj.name
			match obj.mode:
				"story_only":
					if getStory(obj.story_flag) < obj.progress_complete:
						obj.state.active = true
						active_list.add_child(p)
					else:
						obj.state.completed = true
						active_list.add_child(p)
				_:
					
					inactive_list.add_child(p)
	
	
	
	pass



func getStory(story):
	return int(CurrentGame.state.story.get(story, -1))
