extends "res://ships/WeaponSlot.gd"

var pointers

var shipName = ""
var baseShipName = ""

var this_file = ""

var this_modification = []
var this_addition = {}
var this_template = []

var c

var file = File.new()

func _ready():
	pointers = ModLoader._savedObjects[0]
	
	shipName=ship.shipName
	baseShipName=ship.baseShipName
	
	var equipment_templates = pointers.Equipment.ship_equipment_template_internals
	if not shipName in equipment_templates:
		equipment_templates[shipName] = {}
	equipment_templates = equipment_templates[shipName]
	
	if equipment_templates:
		
		var generic_modify_templates = pointers.Equipment.weaponslot_modify_templates
		var generic_modify_standalone = pointers.Equipment.weaponslot_modify_standalone
		var ship_modify_templates = pointers.Equipment.weaponslot_ship_templates
		var ship_modify_standalone = pointers.Equipment.weaponslot_ship_standalone
		var eqnames = pointers.Equipment.ws_equipment_names
		
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
					for property in data:
						if check in node_names:
							if not check in equipment_templates:
								equipment_templates[check] = {}
							equipment_templates[check][property.get("property")] = property.get("value")
						
			templates.merge({template:generic_modify_templates[template].get("equipment").duplicate(true)})
		for standalone in generic_modify_standalone:
			if standalone in node_names:
					if not standalone in equipment_templates:
						equipment_templates[standalone] = {}
					equipment_templates[standalone][standalone.get("property")] = standalone.get("value")
				
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
								for property in properties:
									if item in node_names:
										if not item in equipment_templates:
											equipment_templates[item] = {}
										equipment_templates[item][property.get("property")] = property.get("value")
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
									for property in properties:
										if item in node_names:
											if not item in equipment_templates:
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
									if not item in equipment_templates:
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
										if not item in equipment_templates:
											equipment_templates[item] = {}
										equipment_templates[item][property.get("property")] = property.get("value")

	var sysname = "weaponSlot.%s.type" % slot
	c = ship.getConfig(sysname)
	
	for item in pointers.Equipment.ws_stuff_to_modify:
		var iname = item.get("name")
		if iname == c:
			if not pointers.ConfigDriver.__validate_dictionary(item):
				return
			var this = {}
			this.name = iname
			this.data = {}
			var f = item.get("data",{})
			for n in f:
				var d = f[n]
				this["data"][n] = []
				for l in d:
					this["data"][n].append([l[0],pointers.DataFormat.__convert_var_from_string(l[1])])
			this_modification.append(this)
	for item in pointers.Equipment.ws_stuff_to_add:
		var iname = item.get("name")
		if iname == c:
			if not pointers.ConfigDriver.__validate_dictionary(item):
				return
			var this = {}
			this.name = iname
			this.data = {}
			this.path = item.get("path","")
			this.config = item.get("config",{})
			var f = item.get("data",{})
			for n in f:
				var d = f[n]
				this["data"][n] = []
				for l in d:
					this["data"][n].append([l[0],pointers.DataFormat.__convert_var_from_string(l[1])])
			this_addition = this
	if c in equipment_templates:
		var d = equipment_templates[c]
		for i in d:
			var s = [i,pointers.DataFormat.__convert_var_from_string(d[i])]
			this_template.append(s)
	
	

func loadPlaceholder():
	var t = "weaponSlot.%s.type" % slot
	var placeholder = get_node_or_null(String(mounted))
	if placeholder:
		if directMount:
			key = name + "_" + mounted
		else:
			key = t + "_" + mounted
		if placeholder.has_method("replace_by_instance"):
			var current = placeholder.get_stored_values(true)
			for i in this_template:
				var d = i[0]
				var g = i[1]
				placeholder[d] = g
			for f in this_modification:
				var data = f.get("data",{})
				for nodepath in data:
					var o = data[nodepath]
					var np = placeholder.get_node_or_null(nodepath)
					if np:
						for i in o:
							var d = i[0]
							var g = i[1]
							np[d] = g
			var now = placeholder.get_stored_values(true)
			placeholder.replace_by_instance()
		system = get_node_or_null(mounted)
		system.name = name + "_" + system.name
		system.visible = true
		if "slotName" in system:
			system.slotName = t + "_" + system.systemName
	else:
		var path = this_addition.get("path","")
		if not pointers.ConfigDriver.__validate_dictionary(this_addition):
			path = ""
		
		
		if pointers.DataFormat.__load_if_can(path):
			var pv = pointers.DataFormat.__get_load().instance()
			if directMount:
				key = name + "_" + mounted
			else:
				key = t + "_" + mounted
			var data = this_addition.get("data",{})
			for nodepath in data:
				var o = data[nodepath]
				var np = pv.get_node_or_null(nodepath)
				if np:
					for i in o:
						var d = i[0]
						var g = i[1]
						np[d] = g
			for i in this_template:
				var d = i[0]
				var g = i[1]
				pv[d] = g
			for f in this_modification:
				var db = f.get("data",{})
				for nodepath in db:
					var o = db[nodepath]
					var np = pv.get_node_or_null(nodepath)
					if np:
						for i in o:
							var d = i[0]
							var g = i[1]
							np[d] = g
			if "key" in pv:
				pv.key = key
			add_child(pv)
			system = pv
			system.name = name + "_" + system.name
			system.visible = true
			if "slotName" in system:
				system.slotName = t + "_" + system.systemName
			systemName = _getSystemName()
			slotName = _getSlotName()
			inspection = _getInspection()
			repairFixPrice = _getRepairFixPrice()
			repairFixTime = _getRepairFixTime()
			repairReplacementPrice = _repairReplacementPrice()
			repairReplacementTime = _repairReplacementTime()
			mass = _getMass()
	ship.changeExternalPlaceholders( - 1)
