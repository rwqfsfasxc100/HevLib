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

export (String) var config_id = ""
export (String) var config_section = ""
export (String) var config_setting = ""
export (bool) var invert_config = false

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
	if config_id and config_section and config_setting:
		var pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")
		var cv = pointers.ConfigDriver.__get_value(config_id,config_section,config_setting)
		if cv != null:
			if invert_config:
				if cv:
					visible = false
			else:
				if !cv:
					visible = false
	if visible:
		if restrict_hold_type != "":
			if restrict_hold_type.to_upper() == ship.base_storage_type.to_upper():
				visible = true
			else:
				visible = false
