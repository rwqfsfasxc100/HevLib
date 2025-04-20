extends Node

var developer_hint = {
	"__spawn_event":[
		"Spawns an event in the rings",
		"Must be in the rings zone for it to work"
	]
}

static func __spawn_event(event):
	var f = load("res://HevLib/events/event_handler.gd")
	f.spawn_event(event)
