extends "res://ships/WeaponSlot.gd"

#export var slot_group = ""

#var current_ship = ""
var eqt_file = "user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/weapon_slot/ship_data/%s/internal_equipment_templates_-_%s.json"

var ws_add = "user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/weapon_slot/WeaponSlot_additions.json"
var ws_modify = "user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/weapon_slot/WeaponSlot_modifications.json"

var shipName = ""
var baseShipName = ""
var FolderAccess = preload("res://HevLib/pointers/FolderAccess.gd")
var NodeAccess = preload("res://HevLib/pointers/NodeAccess.gd")
#func _enter_tree():
func _ready():
	var file = File.new()
	var equipment_templates = {}
	shipName=ship.shipName
	baseShipName=ship.baseShipName
	
	FolderAccess.__check_folder_exists("user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/weapon_slot/ship_data/%s/" % shipName)

	
	
	
	
	
	
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
	file.open("user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/weapon_slot/WSLT_MODIFIED_NAMES.json",File.READ)
	var eqnames = JSON.parse(file.get_as_text(true)).result
	file.close()
	
	
	
	var node_names = []
	var children = self.get_children()
	for child in children:
		node_names.append(child.name)
	for item in eqnames:
		if not item in node_names:
			node_names.append(item)
	var templates = {}
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
		templates.merge({template:generic_modify_templates[template].get("equipment").duplicate(true)})
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
						var equipment = templates[tmp]
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
							var equipment = templates[tmp]
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

	file.open(eqt_file % [shipName,slot],File.WRITE)
	file.store_string(JSON.print(equipment_templates))
	file.close()



func loadPlaceholder():
	.loadPlaceholder()
	yield(get_tree().create_timer(0.05),"timeout")
	modify()
func modify():
	var file = File.new()
	var dir = Directory.new()
	
	var node
	
	file.open(ws_add,File.READ)
	var additions = JSON.parse(file.get_as_text()).result
	file.close()
	file.open(ws_modify,File.READ)
	var modifications = JSON.parse(file.get_as_text()).result
	file.close()
	var sysname = "weaponSlot.%s.type" % slot
	var c = ship.getConfig(sysname)
	var properties_to_modify = []
	for item in additions:
		var iname = item.get("name")
		if iname == c and dir.file_exists(item.get("path")):
			node = load(item.get("path")).instance()
			for obj in item.get("data",{}):
				var properties = item.get("data",{})[obj]
				for property in properties:
					var p = property[0]
					var value = property[1]
					var newVal = NodeAccess.__convert_var_from_string(value)
					var sn = node.get_node(obj)
					if sn == null:
						breakpoint
					properties_to_modify.append([sn,p,newVal])
			var sysn = name + "_" + iname
			system = node
			node.name = sysn
	for item in modifications:
		var iname = item.get("name")
		if iname == c:
			for obj in item.get("data",{}):
				var properties = item.get("data",{})[obj]
				for property in properties:
					var p = property[0]
					var value = property[1]
					var newVal = NodeAccess.__convert_var_from_string(value)
					var n = get_node(item.get("name"))
					var sn = n.get_node(obj)
					if sn == null:
						breakpoint
					properties_to_modify.append([sn,p,newVal])
	
	
	file.open(eqt_file % [shipName,slot],File.READ)
	var equipment_templates = JSON.parse(file.get_as_text(true)).result
	file.close()
	var equipment_modifications = {}
	for item in equipment_templates:
		var data = equipment_templates[item]
		match typeof(data):
			TYPE_DICTIONARY:
				equipment_modifications[item] = data
			TYPE_ARRAY:
				breakpoint
	
	
	if c in equipment_modifications:
		var datapoint = equipment_modifications[c]
		for property in datapoint:
			var value = datapoint.get(property)
			var current = system.get(property)
			var newVal = NodeAccess.__convert_var_from_string(value)
			if system == null:
				breakpoint
			properties_to_modify.append([system,property,newVal])
	if properties_to_modify.size() >= 1:
		for property in properties_to_modify:
			match property[1]:
				"visible":
					property[0].set(property[1],true)
				_:
					property[0].set(property[1],property[2])
	if node:
		add_child(node)
		key = name + "_" + mounted
		systemName = _getSystemName()
		slotName = _getSlotName()
		inspection = _getInspection()
		repairFixPrice = _getRepairFixPrice()
		repairFixTime = _getRepairFixTime()
		repairReplacementPrice = _repairReplacementPrice()
		repairReplacementTime = _repairReplacementTime()
		mass = _getMass()
