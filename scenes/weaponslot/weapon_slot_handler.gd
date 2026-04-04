extends "res://ships/WeaponSlot.gd"

var eqt_file = "user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/weapon_slot/ship_data/%s/internal_equipment_templates_-_%s.json"

var ws_add = "user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/weapon_slot/WeaponSlot_additions.json"
var ws_modify = "user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/weapon_slot/WeaponSlot_modifications.json"

onready var pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")

var shipName = ""
var baseShipName = ""

var this_file = ""

var this_modification = []
var this_addition = {}
var this_template = []

var c

var file = File.new()

func _ready():
	
	
	shipName=ship.shipName
	baseShipName=ship.baseShipName
	
	pointers.FolderAccess.__check_folder_exists("user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/weapon_slot/ship_data/%s/" % shipName)

	this_file = eqt_file % [shipName,slot]
	
	var equipment_templates = {}
	
	if not file.file_exists(this_file):
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
		file.open(this_file,File.WRITE)
		file.store_string(JSON.print(equipment_templates))
		file.close()
	else:
		file.open(this_file,File.READ)
		equipment_templates = JSON.parse(file.get_as_text(true)).result
		file.close()
	
	file.open(ws_add,File.READ)
	var additions = JSON.parse(file.get_as_text()).result
	file.close()
	file.open(ws_modify,File.READ)
	var modifications = JSON.parse(file.get_as_text()).result
	file.close()
	var sysname = "weaponSlot.%s.type" % slot
	c = ship.getConfig(sysname)
	
	for item in modifications:
		var iname = item.get("name")
		if iname == c:
			var this = {}
			this.name = iname
			this.data = {}
			var f = item.get("data",{})
			for n in f:
				var d = f[n]
				this["data"][n] = []
				for l in d:
#					this_modification.append([l[0],pointers.NodeAccess.__convert_var_from_string(l[1])])
					this["data"][n].append([l[0],pointers.NodeAccess.__convert_var_from_string(l[1])])
			this_modification.append(this)
	for item in additions:
		var iname = item.get("name")
		if iname == c:
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
#					this_addition.append([l[0],pointers.NodeAccess.__convert_var_from_string(l[1])])
					this["data"][n].append([l[0],pointers.NodeAccess.__convert_var_from_string(l[1])])
			this_addition = this
	if c in equipment_templates:
		var d = equipment_templates[c]
		for i in d:
			var s = [i,pointers.NodeAccess.__convert_var_from_string(d[i])]
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
		var path = this_addition.get("path",null)
		if "config" in this_addition:
			var how = true
			var cfg = this_addition["config"]
			var config_id = cfg.get("id","")
			var config_section = cfg.get("section","")
			var config_setting = cfg.get("entry","")
			var invert_config = cfg.get("invert_config",false)
			if config_id and config_section and config_setting:
				var pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")
				var cfg_opt = pointers.ConfigDriver.__get_value(config_id,config_section,config_setting)
				if cfg_opt != null:
					if invert_config:
						if cfg_opt:
							how = false
					else:
						if !cfg_opt:
							how = false
			if not how:
				path = ""
		
		
		if path and file.file_exists(path):
			if directMount:
				key = name + "_" + mounted
			else:
				key = t + "_" + mounted
			var pv = load(path).instance()
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
