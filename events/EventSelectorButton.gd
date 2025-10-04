extends CheckButton

var event = ""

var isEnabled = true
const ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")
func _toggled(button_pressed):
	var disabled_events = ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_EVENTS","disabled_events")
	if event in disabled_events and button_pressed:
		var newEvents = []
		for evnt in disabled_events:
			if evnt == event:
				pass
			else:
				newEvents.append(evnt)
		disabled_events = newEvents
	if not event in disabled_events and not button_pressed:
		disabled_events.append(event)
	isEnabled = button_pressed
	ConfigDriver.__store_value("HevLib","HEVLIB_CONFIG_SECTION_EVENTS","disabled_events",disabled_events)
#	get_parent().get_parent().all_events[event] = isEnabled
