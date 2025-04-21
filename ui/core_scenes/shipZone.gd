extends Label

func _process(delta):
	var ship = CurrentGame.getPlayerShip()
	var tex = "null"
	if ship == null:
		tex = "null"
	else:
		tex = ship.zone
	text = tex
