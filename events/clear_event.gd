extends Node

func clear_event(event: String, ring):
	if event == "" or event == "none":
		var events = ring.all_oddities
		for e in events:
			if Tool.claim(e):
				if e.is_node_ready():
					Tool.release(e)
					Tool.remove(e)
					ring.all_oddities.erase(e)
	elif event in ring.group:
		var events = ring.group[event]
		if events.size():
			for e in events:
				if Tool.claim(e):
					if e.is_node_ready():
						Tool.release(e)
						Tool.remove(e)
						ring.group[event].erase(e)
