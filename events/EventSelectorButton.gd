extends CheckButton

var event = ""

var pointers = ModLoader._savedObjects[0]

var isEnabled = true

onready var is_ready = true
func _toggled(button_pressed):
	if is_ready:
		var disabled_events = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_EVENTS","disabled_events")
		if button_pressed:
			if not event in disabled_events:
				disabled_events.append(event)
		else:
			disabled_events.erase(event)
		
		pointers.ConfigDriver.__store_value("HevLib","HEVLIB_CONFIG_SECTION_EVENTS","disabled_events",disabled_events)
