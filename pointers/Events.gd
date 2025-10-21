extends Node

var developer_hint = {
	"__spawn_event":[
		"Spawns an event in the rings",
		"Must be in the rings zone for it to work"
	]
}
const se = preload("res://HevLib/events/event_handler.gd")
static func __spawn_event(event, thering):
	var f = se.new()
	f.spawn_event(event,thering)
const ce = preload("res://HevLib/events/clear_event.gd")
static func __clear_event(event,ring):
	var f = ce.new()
	f.clear_event(event,ring)
