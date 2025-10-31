extends "res://enceladus/Enceladus.gd"

var research_overhead = null

func _ready():
	research_overhead = get_tree().get_root().get_node("ResearchOverheadHandle")
	
	
	if research_overhead:
		research_overhead.loading_enceladus()
		connect("tree_exiting",research_overhead,"unloading")
		connect("tree_exiting",self,"unloading")
	
	
	
func unloading():
	if research_overhead:
		disconnect("tree_exiting",research_overhead,"unloading")
