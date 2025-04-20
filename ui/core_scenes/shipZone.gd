extends Label

func _process(delta):
	var ship = CurrentGame.getPlayerShip()
	var tex = "null"
	if not ship == null:
		tex = ship.zone
	else:
		tex = "null"
	text = tex
