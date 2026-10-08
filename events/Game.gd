extends "res://Game.gd"

func _ready():
	var event_menu:CanvasLayer = load("res://HevLib/events/EventMenu.tscn").instance()
	var ringspace_canvas:CanvasLayer = load("res://HevLib/logging/_HevLib_Ringspace_Canvas.tscn").instance()
	add_child(ringspace_canvas)
	add_child(event_menu)
	move_child(event_menu,3)
	
	
	
	
