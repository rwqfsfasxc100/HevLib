extends "res://ships/WeaponSlot.gd"

var current_ship = ""

var WeaponSlot = preload("res://HevLib/pointers/WeaponSlot.gd")

func _enter_tree():
	var found_name = false
	var node_to_scan = self
	while not found_name:
		var scanning_beam = node_to_scan.get_parent()
		var properties = scanning_beam.get_property_list()
		for property in properties:
			if property.get("name") == "shipName":
				found_name = true
				current_ship = scanning_beam.shipName
		node_to_scan = scanning_beam
	
