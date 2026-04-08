extends CheckButton

var event = ""

onready var pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")
var isEnabled = true
#const ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")
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
#	if event in disabled_events and button_pressed:
#		var newEvents = []
#		for evnt in disabled_events:
#			if evnt == event:
#				pass
#			else:
#				newEvents.append(evnt)
#		disabled_events = newEvents
#	if not event in disabled_events and not button_pressed:
#		disabled_events.append(event)
#	isEnabled = button_pressed
	
	
	
#	get_parent().get_parent().all_events[event] = isEnabled
