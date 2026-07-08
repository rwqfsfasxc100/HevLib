extends "res://ships/ship-ctrl.gd"

func _ready():
	CurrentGame.connect("eventDriverVisibilityChanged",self,"_eventdriver_visibility_changed")

var in_hevlib_menu = false

func _eventdriver_visibility_changed(how):
	in_hevlib_menu = how

func manualControl(delta):
	if in_hevlib_menu:
		return
	else:
		.manualControl(delta)
