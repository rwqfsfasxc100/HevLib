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

extends HBoxContainer

export var this_research_project = {}

onready var name_button = $Progress/Name

onready var sub_progress_container = $Progress/SubBarProgress/HBoxContainer/BarContainer
onready var total_progress_container = $Progress/FullProgress

onready var start_button = $Progress/StartContainer/StartButton
onready var start_container = $Progress/StartContainer

const progress_bar = preload("res://HevLib/scenes/research/research_item_box/ResearchProgressBar.tscn")

var mark_for_completion = false

var progress_bars = {}

var pointers = ModLoader._savedObjects[0]

onready var sprite_container = $Icon/PanelContainer/TextureRect
onready var scene_container = $Icon/PanelContainer/ViewportContainer
onready var scene_offset = $Icon/PanelContainer/ViewportContainer/Viewport/Container/Rotation_offset

func _ready():
	connect("visibility_changed",self,"recheck_vis")
	initialize()
	
	start_button.connect("pressed",self,"start_pressed")
	
	
	

signal completed
signal started


func initialize():
	var project_state = this_research_project.get("state",{})
	var project_mode = this_research_project.get("mode","story_only")
	
	var project_name = this_research_project.get("name","RESEARCH_TEMPLATE")
	var project_description = this_research_project.get("description","RESEARCH_DESC_TEMPLATE")
	
	match project_mode:
		"story_only":
			var story_flag = this_research_project.get("story_flag","")
			var story_val = getStory(story_flag)
			var story_min = max(this_research_project.get("story_min",0),0)
			var story_max = max(this_research_project.get("story_max",1000),0)
			var progress_min = this_research_project.get("progress_zero",0)
			var progress_max = this_research_project.get("progress_complete",1000)
			var source = this_research_project.get("source","missing.mod.id")
			
			
			if (story_min > -1 and story_val < story_min) or (story_max > -1 and story_val > story_max):
				exit()
			
			var bar = progress_bar.instance()
			bar.source = source
			bar.mode = project_mode
			bar.story_flag = story_flag
			bar.story_min = progress_min
			bar.story_max = progress_max
			bar.parent = self
			bar.is_total = true
			bar.connect("storyFlag",self,"handle_story")
			total_progress_container.add_child(bar)
			
#			breakpoint
		"story_progress":
			var story_flag = this_research_project.get("story_flag")
			var story_val = getStory(story_flag)
			var story_min = this_research_project.get("story_min",0)
			var story_max = this_research_project.get("story_max",1000)
			var progress_min = this_research_project.get("progress_zero",0)
			var progress_max = this_research_project.get("progress_complete",1000)
			
			var tooltip_text = this_research_project.get("tooltip_text","")
			
			var unlock_story = this_research_project.get("unlock_story","")
			var unlock_set = this_research_project.get("unlock_set",1000)
			
			var source = this_research_project.get("source","missing.mod.id")
			
			if (story_min > -1 and story_val < story_min) or (story_max > -1 and story_val > story_max):
				exit()
			
			
			
#			breakpoint
		"isolated":
			
			var show_when = this_research_project.get("show_when")
			var tasks = this_research_project.get("tasks",[])
			var initiation_price = this_research_project.get("initiation_price",100000)
			
			var unlock_story = this_research_project.get("unlock_story","")
			var unlock_set = this_research_project.get("unlock_set",1000)
			
			var source = this_research_project.get("source","missing.mod.id")
			
			if this_research_project.state.active:
				for task in tasks:
					var tooltip_text = task.get("tooltip_text","")
					var reset_on_halt = task.get("reset_on_halt",false)
					var mode = task.get("mode","story")
					var story_flag = task.get("story_flag","")
					match mode:
						"story":
							var bar = progress_bar.instance()
							
							bar.mode = mode
							bar.source = source
							bar.tooltip_text = tooltip_text
							bar.reset_on_halt = reset_on_halt
							bar.story_flag = story_flag
							bar.story_min = task.get("story_min",0)
							bar.story_max = task.get("story_max",1000)
							bar.connect("storyFlag",self,"handle_story")
							sub_progress_container.add_child(bar)
						"payment":
							var bar = progress_bar.instance()
							
							bar.mode = mode
							bar.source = source
							bar.story_flag = story_flag
							bar.tooltip_text = tooltip_text
							bar.reset_on_halt = reset_on_halt
							bar.amount = task.get("amount",100000)
							
							sub_progress_container.add_child(bar)
						"time":
							var bar = progress_bar.instance()
							
							bar.mode = mode
							bar.source = source
							bar.story_flag = story_flag
							bar.tooltip_text = tooltip_text
							bar.reset_on_halt = reset_on_halt
							bar.minutes = task.get("minutes",0)
							bar.hours = task.get("hours",0)
							bar.days = task.get("days",0)
							bar.months = task.get("months",0)
							bar.years = task.get("years",0)
							
							sub_progress_container.add_child(bar)
							
						
				
			
#			breakpoint
	name_button.text = project_name
	name_button.hint_tooltip = project_description
	
	var display_mode = this_research_project.get("display_mode","sprite")
	var display_path:String = this_research_project.get("display_path","")
	var sprite_fallback = false
	if pointers.FileAccess.__file_exists(display_path):
		match display_mode:
			"sprite":
				match display_path.get_extension():
					"png":
						sprite_container.texture = pointers.FileAccess.__load_png(display_path)
						sprite_container.visible = true
						scene_container.visible = false
					"stex":
						var tex = StreamTexture.new()
						tex.load_path = display_path
						sprite_container.texture = tex
						sprite_container.visible = true
						scene_container.visible = false
					_:
						sprite_fallback = true
			"scene":
				var scene = load(display_path)
				if scene is PackedScene:
					var inst = scene.instance()
					var display_positioning = this_research_project.get("display_positioning",{})
					var scale = display_positioning.get("scale",Vector2.ONE)
					scene_offset.position = display_positioning.get("position",Vector2.ZERO) * scale
					scene_offset.rotation = deg2rad(display_positioning.get("rotation",0.0))
					scene_offset.scale = scale
					pointers.NodeAccess.__remove_scripts(inst)
					scene_offset.add_child(inst)
					sprite_container.visible = false
					scene_container.visible = true
				else:
					sprite_fallback = true
			_:
				sprite_fallback = true
	if sprite_fallback:
		sprite_container.visible = true
		scene_container.visible = false
	
	

func handle_story(flag,value):
	
	pass

func exit():
	Tool.remove(self)

func getStory(story):
	return int(CurrentGame.state.story.get(story, -1))

var default_vp_positioning = {"position":Vector2(0,0),"rotation":90,"scale":Vector2(1,1)}

func update_progress():
	pass

func is_finished() -> bool:
	match this_research_project.get("mode","story_only"):
		"story_only","story_progress":
			if getStory(this_research_project.get("story_flag","")) >= this_research_project.get("progress_complete",1000):
				return true
		"isolated":
			var failed = false
			for task in this_research_project.get("tasks",[]):
				match task.get("mode",""):
					"story":
						if getStory(task.get("story_flag","")) != task.get("story_max",1000):
							return false
					"payment":
						if getStory(task.get("story_flag","")) != task.get("amount",100000):
							return false
					"time":
						var time_total = Time.get_unix_time_from_datetime_dict({
							"year":task.get("years",0),
							"month":task.get("months",0),
							"day":task.get("days",0),
							"hour":task.get("hours",0),
							"minute":task.get("minutes",0),
							"second":0
						})
						if getStory(task.get("story_flag","")) < time_total:
							return false
	return false

func start_pressed():
	pass

func recheck_vis():
	if is_visible_in_tree():
		var project_state = this_research_project.get("state",{})
		start_container.visible = !(project_state.active or project_state.completed)
		
		
		
		if mark_for_completion:
			var state = this_research_project.get("state",{})
			if state.completed:
				$AnimationPlayer.stop()
				$Icon/PanelContainer.self_modulate = Color(0,1,0,1)
			else:
				$AnimationPlayer.play("Complete")
		else:
			$AnimationPlayer.stop()
			$Icon/PanelContainer.self_modulate = Color(1,1,1,1)
