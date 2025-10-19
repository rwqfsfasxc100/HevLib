extends Node

var developer_hint = {
	"__spawn_event":[
		"Spawns an event in the rings",
		"Must be in the rings zone for it to work"
	]
}
const se = preload("res://HevLib/events/event_handler.gd")
static func __spawn_event(event):
	var f = se.new()
	f.spawn_event(event)
