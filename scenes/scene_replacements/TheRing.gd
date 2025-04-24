extends "res://TheRing.gd"

var event_names = {}

func _ready():
	for events in get_children():
		var ename = events.name
		var dict = {ename:events}
		event_names.merge(dict)
	var disabled_events = Settings.HevLib["events"]["disabled_events"]
	for event in disabled_events:
		var evnt = null
		for child in get_children():
			if child.name == event:
				evnt = child
		if evnt == null:
			pass
		else:
			remove_child(evnt)
