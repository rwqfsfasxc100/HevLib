extends "res://ships/ship-ctrl.gd"

func manualControl(delta):
	if CurrentGame.in_hevlib_menu:
#		handleDoubleTap()
		return
	else:
		.manualControl(delta)
