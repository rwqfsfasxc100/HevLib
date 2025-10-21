extends Node

func clear_event(event: String, ring):
	var nodes = ring.group
	if event == "" or event == "none":
		var events = ring.all_oddities
		for e in events:
			if Tool.claim(e):
				if e.is_node_ready():
					Tool.release(e)
					Tool.remove(e)
					events.erase(e)
	elif event in nodes:
		var events = nodes[event]
		if events.size() >= 1:
			for e in events:
				if Tool.claim(e):
					if e.is_node_ready():
						Tool.release(e)
						Tool.remove(e)
						nodes[event].erase(e)
