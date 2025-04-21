extends "res://TheRing.gd"

var event_selector = {}

func _process(delta):
	var rnode = get_parent().get_node_or_null("EventMenu")
	if rnode == null:
		pass
	else:
		event_selector = rnode.selected_events

func canEventBeAt(event: String, position: Vector2) -> bool:
	var allow = event_selector.get(event)
	if allow:
		return .canEventBeAt(event, position)
	else:
		return false
