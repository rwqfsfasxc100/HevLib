extends VBoxContainer

var itemSlot = preload("res://enceladus/SystemShipUpgradeUI.tscn")

var ADDITIVES = [
# Hardpoint slots
"HARDPOINT", # - Any hardpoint
"HARDPOINT_LOW_STRESS", # - Any low-stress hardpoint
"HARDPOINT_HIGH_STRESS", # - Any high-stress hardpoint
"HARDPOINT_SPINAL", # - Any rear hardpoint
"HARDPOINT_DOCKING_BAY", # - A docking-bay type hardpoint
"HARDPOINT_DRONE_POINT", # - A drone hardpoint

# Equipment alignment
"ALIGNMENT_LEFT", # - Any left hardpoint
"ALIGNMENT_RIGHT", # - Any right hardpoint
"ALIGNMENT_CENTER", # - Any central hardpoint

# Hardpoint Capabilities
"CAPABILITY_SIDE_ACCESS", # - Equipment has access to the side of the hardpoint
"CAPABILITY_SHIP_REAR", # - Equipment can be placed in rear slots
"CAPABILITY_HEAVY_EQUIPMENT", # - Equipment that is heavy and requires high-stress only. E.G. NANI and AR-1500
"CAPABILITY_SHIP_SPINE", # - Equipment is heavy, but light enough to fit on any spinal mount
"CAPABILITY_TURRETS", # - Can fit turreted equipment
"CAPABILITY_CRADLES", # - Can fit cradles
"CAPABILITY_NANODRONES", # - Can fit nanodrones
"CAPABILITY_PLASMA_THROWER", # - Can fit plasma throwers
"CAPABILITY_FRONT_FACING", # - Can fit front-facing equipment

# Equipment capabilities
"EQUIPMENT_HEAVY_DUTY",
"EQUIPMENT_CARGO_CONTAINER", # - Any cargo container like equipment
"EQUIPMENT_MINING_COMPANION", # - Any mining companion like equipment
"EQUIPMENT_IMPACT_ABSORBER", # - Any impact absorber like equipment
"EQUIPMENT_FRONT_FACING_WEAPON", # - Any front-facing equipment
"EQUIPMENT_PLASMA_THROWER", # - Any plasma thrower equipment
"EQUIPMENT_MANIPULATION_ARM", # - Any manipulator
"EQUIPMENT_TURRET", # - Equipment is turreted
"EQUIPMENT_NANODRONE_PLANT", # - Equipment uses nanodrones
"EQUIPMENT_RAILGUN", # - Any railgun like equipment
"EQUIPMENT_COILGUN", # - Any coilgun like equipment
"EQUIPMENT_IRON_THROWER", # - Any iron thrower like equipment
"EQUIPMENT_MINING_LASER", # - Any mining laser like equipment
"EQUIPMENT_MICROWAVE", # - Any microwave emitter like equipment
"EQUIPMENT_SYNCHROTRON", # - Any synchrotron like equipment
"EQUIPMENT_BEACON", # - Any beacon like equipment

# Other slot tags
"MASS_DRIVER_AMMUNITION",
"NANODRONE_STORAGE",
"PROPELLANT_TANK",
"STANDARD_REACTION_CONTROL_THRUSTERS",
"STANDARD_MAIN_ENGINE",
"FISSION_RODS",
"ULTRACAPACITOR",
"FISSION_TURBINE",
"AUX_POWER_SLOT",
"CARGO_BAY",
"AUTOPILOT",
"HUD",
"LIDAR",
"RECON_DRONE",
]

var SUBTRACTIVES = []

var HARDPOINT_CAPABILITIES = {
	"HARDPOINT_LOW_STRESS":{
		"alignment":"ALIGNMENT_CENTER",
		"capabilities":[
			"CAPABILITY_SIDE_ACCESS",
			"CAPABILITY_TURRETS",
			"CAPABILITY_CRADLES",
			"CAPABILITY_NANODRONES",
			"CAPABILITY_FRONT_FACING",
		],
		"equipment_overrides":[]
	},
	"HARDPOINT_HIGH_STRESS":{
		"alignment":"ALIGNMENT_CENTER",
		"capabilities":[
			"CAPABILITY_HEAVY_EQUIPMENT",
			"CAPABILITY_SHIP_SPINE",
			"CAPABILITY_TURRETS",
			"CAPABILITY_NANODRONES",
			"CAPABILITY_PLASMA_THROWER",
			"CAPABILITY_FRONT_FACING",
		],
		"equipment_overrides":[]
	},
	"HARDPOINT_SPINAL":{
		"alignment":"ALIGNMENT_CENTER",
		"capabilities":[
			"CAPABILITY_SHIP_SPINE",
			"CAPABILITY_TURRETS",
			"CAPABILITY_NANODRONES",
			"CAPABILITY_PLASMA_THROWER",
			"CAPABILITY_FRONT_FACING",
		],
		"equipment_overrides":[]
	},
	"HARDPOINT_DOCKING_BAY":{
		"alignment":"ALIGNMENT_CENTER",
		"capabilities":[
			"CAPABILITY_TURRETS",
			"CAPABILITY_CRADLES",
			"CAPABILITY_NANODRONES",
		],
		"equipment_overrides":["NOT_EQUIPMENT_BEACON"]
	},
	"HARDPOINT_DRONE_POINT":{
		"alignment":"ALIGNMENT_CENTER",
		"capabilities":[
			"CAPABILITY_NANODRONES",
		],
		"equipment_overrides":[]
	},
}

var EQUIPMENT_CAPABILITIES = {
	"CAPABILITY_SIDE_ACCESS":["EQUIPMENT_CARGO_CONTAINER","EQUIPMENT_MINING_COMPANION","EQUIPMENT_IMPACT_ABSORBER","EQUIPMENT_BEACON"],
	"CAPABILITY_SHIP_REAR":["EQUIPMENT_CARGO_CONTAINER","EQUIPMENT_MINING_COMPANION","EQUIPMENT_IMPACT_ABSORBER","EQUIPMENT_TURRET"],
	"CAPABILITY_HEAVY_EQUIPMENT":["EQUIPMENT_HEAVY_DUTY"],
	"CAPABILITY_SHIP_SPINE":["EQUIPMENT_FRONT_FACING_WEAPON","EQUIPMENT_PLASMA_THROWER"],
	"CAPABILITY_TURRETS":["EQUIPMENT_TURRET"],
	"CAPABILITY_CRADLES":["EQUIPMENT_CARGO_CONTAINER","EQUIPMENT_MINING_COMPANION","EQUIPMENT_IMPACT_ABSORBER","EQUIPMENT_BEACON"],
	"CAPABILITY_NANODRONES":["EQUIPMENT_NANODRONE_PLANT"],
	"CAPABILITY_PLASMA_THROWER":["EQUIPMENT_PLASMA_THROWER"],
	"CAPABILITY_FRONT_FACING":["EQUIPMENT_FRONT_FACING_WEAPON"],
}

func _tree_entered():
	get_tags()
	make_subtractives()
	add_slots()
	add_slot_tags()
	add_equipment()

func add_slots():
	var slots = ModLoader.get_children()
	for slot in slots:
		var data = slot.get_property_list()
		var newSlot = null
		for item in data:
			if item.get("name") == "ADD_EQUIPMENT_SLOTS":
				newSlot = slot.get("ADD_EQUIPMENT_SLOTS")
		if typeof(newSlot) == TYPE_ARRAY:
			for spt in newSlot:
				add_child(spt)


func add_equipment():
	var slots = ModLoader.get_children()
	var equipment_slots = {}
	var child_slots = get_children()
	for child in child_slots:
		var cname = child.name
		var groups = child.slotGroups
		var dic = {cname:groups}
		equipment_slots.merge(dic)
	for slot in slots:
		var data = slot.get_property_list()
		var newSlot = null
		for item in data:
			if item.get("name") == "ADD_EQUIPMENT_ITEMS":
				newSlot = slot.get("ADD_EQUIPMENT_ITEMS")
		if typeof(newSlot) == TYPE_ARRAY:
			for spt in newSlot:
				var equipment = spt.get("equipment")
				var eq_slots = spt.get("slots")
				if typeof(eq_slots) == TYPE_ARRAY:
					pass
				else:
					eq_slots = []
				var groups = spt.get("slot_groups")
				if typeof(groups) == TYPE_ARRAY:
					pass
				else:
					groups = []
				var current_slots = get_children()
				for slt in current_slots:
					var pdoes = check_groups(groups, slt.slotGroups)
					if pdoes:
						var slname = slt.name
						if slname in eq_slots:
							pass
						else:
							eq_slots.append(slname)
				for panel in eq_slots:
					var parent = get_node(panel).get_node("VBoxContainer")
					var itemTemplate = itemSlot.instance()
					
					itemTemplate.numVal = equipment.get("num_val")
					itemTemplate.system = equipment.get("system")
					itemTemplate.capabilityLock = equipment.get("capability_lock")
					itemTemplate.nameOverride = equipment.get("name_override")
					itemTemplate.description = equipment.get("description")
					itemTemplate.manual = equipment.get("manual")
					itemTemplate.specs = equipment.get("specs")
					itemTemplate.price = equipment.get("price")
					itemTemplate.testProtocol = equipment.get("test_protocol")
					itemTemplate.default = equipment.get("default")
					itemTemplate.control = equipment.get("control")
					itemTemplate.storyFlag = equipment.get("story_flag")
					itemTemplate.storyFlagMin = equipment.get("story_flag_min")
					itemTemplate.storyFlagMax = equipment.get("story_flag_max")
					itemTemplate.warnIfThermalBelow = equipment.get("warn_if_thermal_below")
					itemTemplate.warnIfElectricBelow = equipment.get("warn_if_electric_below")
					itemTemplate.stickerPriceFormat = equipment.get("sticker_price_format")
					itemTemplate.stickerPriceMultiFormat = equipment.get("sticker_price_multi_format")
					itemTemplate.installedColor = equipment.get("installed_color")
					itemTemplate.disbledColor = equipment.get("disabled_color")
					if equipment.get("name_override") == "":
						itemTemplate.name = equipment.get("system")
					else:
						itemTemplate.name = equipment.get("name_override")
					parent.add_child(itemTemplate)


func check_groups(item_tags, compared_tags):
	pass
	
	
	
	
	
	
	

func get_tags():
	var slots = ModLoader.get_children()
	for slot in slots:
		var data = slot.get_property_list()
		var nodes = null
		for item in data:
			if item.get("name") == "EQUIPMENT_TAGS":
				nodes = slot.get("EQUIPMENT_TAGS")
		if not nodes == null:
			for tag in nodes:
				if tag in ADDITIVES:
					pass
				else:
					ADDITIVES.append(tag)

func make_subtractives():
	for add in ADDITIVES:
		SUBTRACTIVES.append("NOT_" + add)

func add_slot_tags():
	var slots = ModLoader.get_children()
	for slot in slots:
		var data = slot.get_property_list()
		var nodes = null
		for item in data:
			if item.get("name") == "SLOT_TAGS":
				nodes = slot.get("SLOT_TAGS")
			if not nodes == null:
				for equipment in nodes:
					var tags = nodes.get(equipment)
					var relevant_node = get_node(equipment)
					for tag in tags:
						if tag in relevant_node.slotGroups:
							pass
						else:
							relevant_node.slotGroups.append(tag)
		pass
