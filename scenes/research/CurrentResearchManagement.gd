extends MarginContainer

const research_item = preload("res://HevLib/scenes/research/research_item_box/ResearchItem.tscn")
var research_state = {}

var current_mod_ids = []

onready var active_list = $VBoxContainer/ScrollContainer/Projects

var has_operated = false

func _initialize():
	research_state = CurrentGame.state.hevlib_research
	for project in research_state:
		var obj = research_state[project]
		
		if obj.state.active == true and obj.source in current_mod_ids:
			var p = research_item.instance()
			p.this_research_project = obj
			p.name = obj.source + "|" + obj.name
			active_list.add_child(p)
	
	
	
	pass
