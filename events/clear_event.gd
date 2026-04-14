extends Node

func clear_event(event: String, ring, clear_related_poi : bool = true):
	if event == "" or event == "none":
		var events = ring.all_oddities
		for e in events:
			if Tool.claim(e):
				if e.is_node_ready():
					ring.all_oddities.erase(e)
					Tool.release(e)
					Tool.remove(e)
					
	elif event in ring.group:
		var events = ring.group[event]
		if events.size():
			for e in events:
				if Tool.claim(e):
					if e.is_node_ready():
						if clear_related_poi:
							clear_poi_for(e.global_position,event)
						ring.group[event].erase(e)
						Tool.release(e)
						Tool.remove(e)
						

func clear_poi_for(globalPos : Vector2,this_event: String):
#	var focus = CurrentGame.getPlayerShip()
	
	var nearby = CurrentGame.getEventNear(CurrentGame.globalCoords(globalPos))
	
	if nearby and nearby.event == this_event:
		var astro = CurrentGame.state.astrogation
		for event in astro:
			var ev = astro[event]
			if ev.event == nearby.event and Vector2(ev.vector.x,ev.vector.y).distance_to(nearby.vector) < 2000:
				CurrentGame.forgetPoi(event)
