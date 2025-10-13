extends "res://hud/AstrogatorPanel.gd"

func _ready():
#	var scroll = ScrollContainer.new()
#	scroll.set_script(load("res://enceladus/ScrollWithAnalog.gd"))
#	scroll.rect_min_size = Vector2(32,226)
#	var container = $HBoxContainer2/MarginContainer
	var icons = $HBoxContainer2/MarginContainer/Icons
#	icons.get_parent().remove_child(icons)
#	container.add_child(scroll)
#	scroll.call_deferred("add_child",icons)
	icons.auto_height = false
