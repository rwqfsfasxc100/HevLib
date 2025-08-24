extends "res://ships/WeaponSlot.gd"

export var slot_group = ""

var current_ship = ""
var WeaponSlot = preload("res://HevLib/pointers/WeaponSlot.gd")
var FolderAccess = preload("res://HevLib/pointers/FolderAccess.gd")

#func _enter_tree():
#	var found_name = false
#	var node_to_scan = self
#	while not found_name:
#		var scanning_beam = node_to_scan.get_parent()
#		var properties = scanning_beam.get_property_list()
#		for property in properties:
#			if property.get("name") == "shipName":
#				found_name = true
#				current_ship = scanning_beam.shipName
#		node_to_scan = scanning_beam
#	var file = File.new()
#	file.open("user://cache/.HevLib_Cache/WSLT.json",File.READ)
#	var text = file.get_as_text(true)
#	file.close()
#	var ws_data = JSON.parse(text).result
#	for item in ws_data:
#		var data = item[0]
#		var weaponslot_add = data.get("WEAPONSLOT_ADD",[])
#		for addition in weaponslot_add:
#			var node = Node2D.new()
#			node.set_script(load("res://tools/Placeholder.gd"))
#			var nodeName = addition.get("name","")
#			var path = addition.get("path","")
#			node.name = nodeName
#			node.placeholder = path
#			add_child(node)
