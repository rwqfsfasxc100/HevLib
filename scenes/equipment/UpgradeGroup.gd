extends "res://enceladus/UpgradeGroup.gd"

# Ship limiting code was ported from IoE
# Thanks Space!

export (Array, String) var onlyForShipNames
export (bool) var invertNameLogic = false

export (Array) var slotGroups = [] 

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
