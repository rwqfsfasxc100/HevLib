extends MarginContainer

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
#const NodeAccess = preload("res://HevLib/pointers/NodeAccess.gd")
