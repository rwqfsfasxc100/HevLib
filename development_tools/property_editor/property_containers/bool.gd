extends MarginContainer

func get_property_value():
	var value = $CheckButton.pressed
	return [value,"true" if value else "false"]

func set_property_value(property):
	var cb = $CheckButton
	if property:
		cb.pressed = true
	else:
		cb.pressed = false
