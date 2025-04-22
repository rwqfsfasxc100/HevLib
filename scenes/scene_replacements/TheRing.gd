extends "res://TheRing.gd"

var event_selector = {}

func _process(delta):
	var rnode = get_parent().get_node_or_null("EventMenu")
	if rnode == null:
		pass
	else:
		event_selector = rnode.selected_events

func getNextOnPlaylist():
	var par = 0
	var evnt = .getNextOnPlaylist()
	var ename = evnt.name
	var enabled = event_selector[ename]
	if enabled:
		return playlist[playNr]
		par = 0
	elif par < playlist.size():
		par += 1
		getNextOnPlaylist()
	else:
		par = 0
		return playlist[0]

#func canEventBeAt(event: String, position: Vector2) -> bool:
#	var allow = event_selector.get(event)
#	if allow:
#		return .canEventBeAt(event, position)
#	else:
#		return false
