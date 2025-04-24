extends CheckButton

var event = ""

var isEnabled = true

func _toggled(button_pressed):
	var disabled_events = Settings.HevLib["events"]["disabled_events"]
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
	Settings.HevLib["events"]["disabled_events"] = disabled_events
	Settings.save_HevLib_ToFile()
#	get_parent().get_parent().all_events[event] = isEnabled
