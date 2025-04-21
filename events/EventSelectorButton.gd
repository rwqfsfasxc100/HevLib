extends CheckButton

var event = ""

var isEnabled = true

func _toggled(button_pressed):
	isEnabled = button_pressed
	
	get_parent().get_parent().all_events[event] = isEnabled
