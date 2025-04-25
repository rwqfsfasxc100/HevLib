extends VBoxContainer

var itemSlot = preload("res://enceladus/SystemShipUpgradeUI.tscn")

const ADDITIVES = [
"HARDPOINT", # - Any hardpoint
"HARDPOINT_LOW_STRESS", # - Any low-stress hardpoint
"HARDPOINT_HIGH_STRESS", # - Any high-stress hardpoint
"HARDPOINT_SPINAL", # - Any hardpoint w/o side access
"HARDPOINT_LEFT", # - Any left hardpoint
"HARDPOINT_RIGHT", # - Any right hardpoint
"HARDPOINT_CENTER", # - Any central hardpoint
"HARDPOINT_SIDE", # - Any hardpoint with side access
"HARDPOINT_REAR", # - Any rear hardpoint
"HARDPOINT_DOCKING_BAY", # - A docking-bay type hardpoint
"HARDPOINT_DRONE_POINT", # - A drone hardpoint
"HARDPOINT_DRONE_EMITTER", # - Any drone equipment
"HARDPOINT_TURRET", # - Any turreted equipment
"HARDPOINT_CRADLE", # - Any cradled equipment
"HARDPOINT_CARGO_CONTAINER", # - Any cargo container like equipment
"HARDPOINT_MINING_COMPANION", # - Any mining companion like equipment
"HARDPOINT_IMPACT_ABSORBER", # - Any impact absorber like equipment
"HARDPOINT_FRONT_FACING_WEAPON", # - Any front-facing equipment
"HARDPOINT_PLASMA_THROWER", # - Any plasma thrower equipment
"HARDPOINT_MANIPULATION_ARM", #- Any manipulator
"HARDPOINT_MASS_DRIVER", # - Any mass driver equipment
"HARDPOINT_RAILGUN", # - Any railgun like equipment
"HARDPOINT_COILGUN", # - Any coilgun like equipment
"HARDPOINT_IRON_THROWER", # - Any iron thrower like equipment
"HARDPOINT_MINING_LASER", # - Any mining laser like equipment
"HARDPOINT_MICROWAVE", # - Any microwave emitter like equipment
"HARDPOINT_SYNCHROTRON", # - Any synchrotron like equipment
"HARDPOINT_BEACON", # - Any beacon like equipment
]
const SUBTRACTIVES = [
"NOT_HARDPOINT_LEFT", # - Any left hardpoint
"NOT_HARDPOINT_RIGHT", # - Any right hardpoint
"NOT_HARDPOINT_CENTER", # - Any central hardpoint
"NOT_HARDPOINT_SIDE", # - Any hardpoint with side access
"NOT_HARDPOINT_REAR", # - Any rear hardpoint
"NOT_HARDPOINT_HIGH_STRESS", # - Any high-stress hardpoint
"NOT_HARDPOINT_LOW_STRESS", # - Any low-stress hardpoint
"NOT_HARDPOINT_DRONE_EMITTER", # - Any drone equipment
"NOT_HARDPOINT_TURRET", # - Any turreted equipment
"NOT_HARDPOINT_CRADLE", # - Any cradled equipment
"NOT_HARDPOINT_CARGO_CONTAINER", # - Any cargo container like equipment
"NOT_HARDPOINT_MINING_COMPANION", # - Any mining companion like equipment
"NOT_HARDPOINT_IMPACT_ABSORBER", # - Any impact absorber like equipment
"NOT_HARDPOINT_FRONT_FACING_WEAPON", # - Any front-facing equipment
"NOT_HARDPOINT_PLASMA_THROWER", # - Any plasma thrower equipment
"NOT_HARDPOINT_MANIPULATION_ARM", # - Any manipulator
"NOT_HARDPOINT_MASS_DRIVER", # - Any mass driver equipment
"NOT_HARDPOINT_RAILGUN", # - Any railgun like equipment
"NOT_HARDPOINT_COILGUN", # - Any coilgun like equipment
"NOT_HARDPOINT_IRON_THROWER", # - Any iron thrower like equipment
"NOT_HARDPOINT_MINING_LASER", # - Any mining laser like equipment
"NOT_HARDPOINT_MICROWAVE", # - Any microwave emitter like equipment
"NOT_HARDPOINT_SYNCHROTRON", # - Any synchrotron like equipment
"NOT_HARDPOINT_BEACON", # - Any beacon like equipment
]
func _tree_entered():
	add_slots()
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
	var item_groups = []
	var compared_groups = []
	for item in item_tags:
		if item in ADDITIVES:
			item_groups.append(item)
		if item in SUBTRACTIVES:
			item_groups.append(item)
	for item in compared_tags:
		if item in ADDITIVES:
			compared_groups.append(item)
		if item in SUBTRACTIVES:
			compared_groups.append(item)
	var allowed = false
	var denied = false
	for item in item_groups:
		var is_negate = false
		if item.begins_with("NOT_"):
			is_negate = true
		if is_negate:
			var itmOpposite = item.split("NOT_")[1]
			if itmOpposite in compared_groups:
				denied = true
		else:
			if item in compared_groups:
				allowed = true
	if allowed == false or denied == true:
		return false
	if allowed == true and denied == false:
		return true
	else:
		return false






