extends "res://enceladus/ScrollWithAnalog.gd"

export var scrollWithKeyboard = false

func _input(event):
	if scrollWithKeyboard:
		if Settings.controlScheme == Settings.control.keyMouse or Settings.controlScheme == Settings.control.auto:
			var down = Input.get_action_strength("ui_down", true)
			var up = Input.get_action_strength("ui_up", true)
			speed = down - up
			if abs(speed) > minSpeed and is_visible_in_tree():
				set_process(true)
				smoothScrollTo = null
