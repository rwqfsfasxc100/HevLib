extends "res://enceladus/UpgradeGroup.gd"

# Ship limiting code was ported from IoE
# Thanks Space! The modding community misses you!

export (Array, String) var onlyForShipNames
export (bool) var invertNameLogic = false

# Variables used to tag equipment
export (bool) var needsVanillaEquipment = false
export (String) var slot_type = "HARDPOINT"
export (String) var hardpoint_type = ""
export (String) var alignment = ""
export (String) var restriction = ""
export (Array) var override_additive = []
export (Array) var override_subtractive = []

# Internal variable used to more easily assign equipment
# Should improve efficiency over the previous version, which calculated it on the fly
var allowed_equipment := []

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
