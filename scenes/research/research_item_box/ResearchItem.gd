extends HBoxContainer

export var this_research_project = {}

onready var sub_progress_container = $Progress/SubBarProgress/HBoxContainer
onready var total_progress_container = $Progress/FullProgress

const progress_bar = preload("res://HevLib/scenes/research/research_item_box/ResearchProgressBar.tscn")

var mark_for_completion = false

func _ready():
	
#	breakpoint
	var project_mode = this_research_project.get("mode","story_only")
	match project_mode:
		"story_only":
			var story_flag = this_research_project.get("story_flag")
			var story_val = getStory(story_flag)
			var project_name = this_research_project.get("name","RESEARCH_TEMPLATE")
			var project_description = this_research_project.get("tooltip_text","RESEARCH_DESC_TEMPLATE")
			var story_min = this_research_project.get("story_min",0)
			var story_max = this_research_project.get("story_max",1000)
			var progress_min = this_research_project.get("progress_zero",0)
			var progress_max = this_research_project.get("progress_complete",1000)
			
			var source = this_research_project.get("source","missing.mod.id")
			var project_state = this_research_project.get("state",{})
			
			if story_val < story_min or story_val > story_max:
#				project_state
				exit()
			
			
			$Progress/Button.text = project_name
			
			var bar = progress_bar.instance()
			bar.source = source
			bar.mode = project_mode
			bar.story_flag = story_flag
			bar.story_min = progress_min
			bar.story_max = progress_max
			bar.parent = self
			bar.is_total = true
			bar.connect("storyFlag",self,"handle_story")
			$Progress/FullProgress.add_child(bar)
			
#			breakpoint
		"story_progress":
			var story_flag = this_research_project.get("story_flag")
			var story_val = getStory(story_flag)
			var project_name = this_research_project.get("name","RESEARCH_TEMPLATE")
			var project_description = this_research_project.get("tooltip_text","RESEARCH_DESC_TEMPLATE")
			var story_min = this_research_project.get("story_min",0)
			var story_max = this_research_project.get("story_max",1000)
			var progress_min = this_research_project.get("progress_zero",0)
			var progress_max = this_research_project.get("progress_complete",1000)
			
			var unlock_story = this_research_project.get("unlock_story","")
			var unlock_set = this_research_project.get("unlock_set",1000)
			
			var source = this_research_project.get("source","missing.mod.id")
			var project_state = this_research_project.get("state",{})
			
			if story_val < story_min or story_val > story_max:
				exit()
			
			$Progress/Button.text = project_name
			
			
			
			
#			breakpoint
		"isolated":
			
			var show_when = this_research_project.get("show_when")
			var tasks = this_research_project.get("tasks",[])
			var project_name = this_research_project.get("name","RESEARCH_TEMPLATE")
			var project_description = this_research_project.get("tooltip_text","RESEARCH_DESC_TEMPLATE")
			var initiation_price = this_research_project.get("initiation_price",100000)
			
			var unlock_story = this_research_project.get("unlock_story","")
			var unlock_set = this_research_project.get("unlock_set",1000)
			
			var source = this_research_project.get("source","missing.mod.id")
			var project_state = this_research_project.get("state",{})
			
			$Progress/Button.text = project_name
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
							
						
						
					
			
			
			

func handle_story(flag,value):
	
	pass

func exit():
	Tool.remove(self)

func getStory(story):
	return int(CurrentGame.state.story.get(story, -1))
#const NodeAccess = preload("res://HevLib/pointers/NodeAccess.gd")

var default_vp_positioning = {"position":Vector2(0,0),"rotation":90,"scale":Vector2(1,1)}

func _process(_delta):
	if is_visible_in_tree():
		if mark_for_completion:
			$AnimationPlayer.play("Complete")
		else:
			$AnimationPlayer.stop()
			$Icon/PanelContainer.self_modulate = Color(1,1,1,1)
