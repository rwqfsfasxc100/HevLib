extends "res://enceladus/UpgradeGroup.gd"

# Ported from IoE
# Thanks Space!

export (Array, String) var onlyForShipNames
export (bool) var invertNameLogic = false

func reexamine():	
	var ship = CurrentGame.getPlayerShip()
	.reexamine()
	if visible:
		var logic:bool
		if onlyForShipNames:
			if ship.shipName in onlyForShipNames:
				logic = true
			else:
				logic = false
			if invertNameLogic:
				visible = !logic
			else:
				visible = logic
