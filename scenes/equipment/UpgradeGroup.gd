extends "res://enceladus/UpgradeGroup.gd"

# Ship limiting code was ported from IoE
# Thanks Space! The modding community misses you!

export (Array) var limit_ships = []
export (Array) var prevent_ships = []

# REMEMBER TO ADD SUPPORT FOR THESE IN EQUIPMENT DRIVER

# Variables used to tag equipment
export (bool) var add_vanilla_equipment = false
export (String) var slot_type = "HARDPOINT"
export (String) var hardpoint_type = ""
export (String) var alignment = ""
export (String) var restriction = ""
export (Array) var override_additive = []
export (Array) var override_subtractive = []
export (String) var restrict_hold_type = ""

# Internal variable used to more easily assign equipment
# Should improve efficiency over the previous version, which calculated it on the fly
var allowed_equipment := []

var data_dictionary = ""

func reexamine():	
	var ship = CurrentGame.getPlayerShip()
	var shipname = ship.shipName
	if limit_ships:
		if shipname in limit_ships:
			visible = true
		else:
			visible = false
	if prevent_ships:
		if shipname in prevent_ships:
			visible = false
		else:
			visible = true
	.reexamine()
	if visible:
		if restrict_hold_type != "":
			if restrict_hold_type.to_upper() == ship.base_storage_type.to_upper():
				visible = true
			else:
				visible = false
