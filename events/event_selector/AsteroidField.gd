extends "res://AsteroidSpawner.gd"

var event_selector = {}

func _process(delta):
	var rnode = get_parent().get_node_or_null("EventMenu")
	if rnode == null:
		pass
	else:
		event_selector = rnode.selected_events

func spawnOdditites(oddity, point, chaos) -> bool:
	var names = []
	if typeof(oddity) == TYPE_ARRAY:
		for item in oddity:
			var name = item.name
			names.append(name)
	else:
		names.append(oddity.name)
	var event = names[0]
	var allow = event_selector.get(event)
	if allow:
		return .spawnOdditites(oddity, point, chaos)
	else:
		return false
