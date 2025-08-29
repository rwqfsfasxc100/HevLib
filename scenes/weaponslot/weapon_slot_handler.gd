extends "res://ships/WeaponSlot.gd"

export var slot_group = ""

var current_ship = ""
var WeaponSlot = preload("res://HevLib/pointers/WeaponSlot.gd")
var FolderAccess = preload("res://HevLib/pointers/FolderAccess.gd")

var shipName = ""
var baseShipName = ""

func _enter_tree():
	var found = false
	
	breakpoint
	
	
	var file = File.new()
	file.open("user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/weapon_slot/WSLT_MODIFY_TEMPLATES.json",File.READ)
	
	var generic_modify_templates = JSON.parse(file.get_as_text(true)).result
	file.close()
	file.open("user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/weapon_slot/WSLT_MODIFY_STANDALONE.json",File.READ)
	var generic_modify_standalone = JSON.parse(file.get_as_text(true)).result
	file.close()
	file.open("user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/weapon_slot/WSLT_SHIP_TEMPLATES.json",File.READ)
	var ship_modify_templates = JSON.parse(file.get_as_text(true)).result
	file.close()
	file.open("user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/weapon_slot/WSLT_SHIP_STANDALONE.json",File.READ)
	var ship_modify_standalone = JSON.parse(file.get_as_text(true)).result
	file.close()
	
	
	
	
	var node_names = []
	var children = self.get_children()
	for child in children:
		node_names.append(child.name)
	
	for template in generic_modify_templates:
		var equipment = generic_modify_templates[template]["equipment"]
		var data = generic_modify_templates[template]["data"]
		for check in node_names:
			if check in equipment:
				var node = get_node(check)
				for property in data:
					
					breakpoint
		
	
