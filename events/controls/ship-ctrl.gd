extends "res://ships/ship-ctrl.gd"

func manualControl(delta):
	if CurrentGame.in_hevlib_menu:
		return
	else:
		.manualControl(delta)
