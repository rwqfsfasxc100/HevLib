extends HBoxContainer

onready var label = $Label
var data = {}
var modname = ""
var parent

func set_text(how:String):
	yield(CurrentGame.get_tree(),"idle_frame")
	label.text = how


func _toggled(button_pressed):
	parent.toggled(modname,button_pressed)
