extends "res://ships/WeaponSlot.gd"

export var slot_group = ""

var current_ship = ""
var WeaponSlot = preload("res://HevLib/pointers/WeaponSlot.gd")
var FolderAccess = preload("res://HevLib/pointers/FolderAccess.gd")

var shipName = ""
var baseShipName = ""

onready var parent = get_parent()
#func _enter_tree():
func _ready():
	
	shipName=ship.shipName
	baseShipName=ship.baseShipName
	
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
	
	var equipment_templates = {}
	
	
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
					node[property.get("property")] = property.get("value")
		equipment_templates.merge({template:generic_modify_templates[template].get("equipment").duplicate(true)})
	for standalone in generic_modify_standalone:
		if standalone in node_names:
			var node = get_node(standalone)
			node[standalone.get("property")] = standalone.get("value")
	for template in ship_modify_templates:
		if baseShipName == template:
			var data = ship_modify_templates[template]
			for reg in data:
				if slot == reg:
					var slot_data = data[reg]
					for tmp in slot_data:
						var equipment = equipment_templates[tmp]
						var properties = slot_data[tmp]
						for item in equipment:
							var node = get_node(item)
							for property in properties:
								node[property.get("property")] = property.get("value")
		if shipName != baseShipName:
			if shipName == template:
				var data = ship_modify_templates[template]
				for reg in data:
					if slot == reg:
						var slot_data = data[reg]
						for tmp in slot_data:
							var equipment = equipment_templates[tmp]
							var properties = slot_data[tmp]
							for item in equipment:
								var node = get_node(item)
								for property in properties:
									node[property.get("property")] = property.get("value")
		
		
#		breakpoint
	
	
	
	
#	breakpoint
