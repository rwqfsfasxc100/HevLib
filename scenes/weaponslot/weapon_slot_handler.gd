extends "res://ships/WeaponSlot.gd"

#export var slot_group = ""

#var current_ship = ""


#func _enter_tree():
func _ready():
	var equipment_templates = {}
	var eqt_file = "user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/weapon_slot/internal_equipment_templates.json"
	
	var FolderAccess = preload("res://HevLib/pointers/FolderAccess.gd")
	var NodeAccess = preload("res://HevLib/pointers/NodeAccess.gd")

	var shipName = ""
	var baseShipName = ""

	
	var parent = get_parent()
	
	
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
	
	
	
	var node_names = []
	var children = self.get_children()
	for child in children:
		node_names.append(child.name)
	
	for template in generic_modify_templates:
		var equipment = generic_modify_templates[template]["equipment"]
		var data = generic_modify_templates[template]["data"]
		for check in node_names:
			if check in equipment:
#				var node = get_node(check)
				for property in data:
					if check in node_names:
						if check in equipment_templates.keys():
							pass
						else:
							equipment_templates[check] = {}
						equipment_templates[check][property.get("property")] = property.get("value")
					
#					node[property.get("property")] = property.get("value")
		equipment_templates.merge({template:generic_modify_templates[template].get("equipment").duplicate(true)})
	for standalone in generic_modify_standalone:
		if standalone in node_names:
				if standalone in equipment_templates.keys():
					pass
				else:
					equipment_templates[standalone] = {}
				equipment_templates[standalone][standalone.get("property")] = standalone.get("value")
			
#			breakpoint
#			var node = get_node(standalone)
#			node[standalone.get("property")] = standalone.get("value")
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
#							var node = get_node(item)
							for property in properties:
								if item in node_names:
#								breakpoint
									if item in equipment_templates.keys():
										pass
									else:
										equipment_templates[item] = {}
									equipment_templates[item][property.get("property")] = property.get("value")
					
								
								
#								node[property.get("property")] = property.get("value")
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
#								var node = get_node(item)
								for property in properties:
									if item in node_names:
										if item in equipment_templates.keys():
											pass
										else:
											equipment_templates[item] = {}
										equipment_templates[item][property.get("property")] = property.get("value")
	for standalone in ship_modify_standalone:
		if baseShipName == standalone:
			var sldta = ship_modify_standalone[baseShipName]
			for key in sldta:
				if slot == key:
					var eq = sldta[key]
					for item in eq:
						var properties = eq[item]
						for property in properties:
							if item in node_names:
#								breakpoint
								if item in equipment_templates.keys():
									pass
								else:
									equipment_templates[item] = {}
								equipment_templates[item][property.get("property")] = property.get("value")
		if shipName != baseShipName:
			if shipName == standalone:
				var sldta = ship_modify_standalone[shipName]
				for key in sldta:
					if slot == key:
						var eq = sldta[key]
						for item in eq:
							var properties = eq[item]
							for property in properties:
								if item in node_names:
	#								breakpoint
									if item in equipment_templates.keys():
										pass
									else:
										equipment_templates[item] = {}
									equipment_templates[item][property.get("property")] = property.get("value")

	file.open(eqt_file,File.WRITE)
	file.store_string(JSON.print(equipment_templates))
	file.close()

func loadPlaceholder():
	var t = "weaponSlot.%s.type" % slot
	var sysname = ""
	var placeholder: InstancePlaceholder = get_node_or_null(String(mounted))
	if placeholder:
		if directMount:
			key = name + "_" + mounted
		else:
			key = t + "_" + mounted
		placeholder.replace_by_instance()
		system = get_node_or_null(mounted)
		sysname = system.name
		system.name = name + "_" + system.name
		system.visible = true
		
		if "slotName" in system:
			system.slotName = t + "_" + system.systemName
	ship.changeExternalPlaceholders( - 1)
	var file = File.new()
	var eqt_file = "user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/weapon_slot/internal_equipment_templates.json"
	file.open(eqt_file,File.READ)
	var equipment_templates = JSON.parse(file.get_as_text(true)).result
	file.close()
	if sysname in equipment_templates:
		var FolderAccess = preload("res://HevLib/pointers/FolderAccess.gd")
		var NodeAccess = preload("res://HevLib/pointers/NodeAccess.gd")
		var datapoint = equipment_templates[sysname]
		for property in datapoint:
			var value = datapoint.get(property)
			var current = system.get(property)
			var newVal = NodeAccess.__convert_var_from_string(value)
			system.set_deferred(property,newVal)
