extends Node

var developer_hint = {
	"__make_equipment":[
		"Inputs a dictionary to format it for adding via this library",
		"equipment slot variables are the exact same as they are usually, check res://enceladus/SystemShipUpgradeUI.tscn OR .gd for those values",
		" -> formatted in the form of {\"<variable_name>\":<variable_value>}",
		"Has two other variables not included in the usual selection for adding to slots:",
		" -> 'slots' is an array of the raw slot node names in Upgrades.tscn child to the Items equip_node. Equivalent to the slot_node_name variable for __make_slot",
		" -> 'slot_groups' is an array of tags used to base their addition. A list of tags can be found in the file at res://HevLib/scenes/equipment/slot_tags.gd. They are also listed on this project's wiki @ https://github.com/rwqfsfasxc100/HevLib/wiki/Equipment-Slot-Grouping",
		"Check this mod's ModMain.gd file for an example as to how they're added with the addEquipmentItem function"
	],
	"__make_slot":[
		"Inputs a dictionary to format a new slot addition for adding via this library",
		" -> 'system_slot' is a string for the system name of the slot used by equipment. Required",
		" -> 'slot_node_name' is a string used as the node's name, used for the slots variable in __make_equipment. Required",
		" -> 'slot_displayName' is a string used for the translation string to display in the equipment menu. Required",
		" -> 'slot_groups' is an array of string used for the group tags, see above for the tags note",
		" -> 'has_none' is a boolean to see if an empty slot is used in the slot's list",
		" -> 'always_display' is a boolean to decide whether the slot is available at all times, or if false only on ships with a slot node attached",
		" -> 'restrict_type' is a string for restricting the slot to ship reactor types. Vanilla currently supports 'fission' and 'fusion'. leave blank for all ships",
		" -> 'open_by_default' is a boolean to decide if the slot list is open when the equipment list is opened",
		" -> 'limit_ships' is an array of ship names that limits the slot to. Courtesy of spaceDOTexe for it's implementation in IoE",
		" -> 'invert_limit_logic' is a boolean to invert the previous array to avoid the ships in that list. Again courtesy of spaceDOTexe",
	],
	"__add_vanilla_equipment":[
		"Internal function used to list vanilla equipment to be added to a slot based on a set of provided tags",
		" -> 'tags' is an array of strings for applicable tags"
	],
	"__match_vanilla":[
		"Internal function used to return an array of viable vanilla equipment options from a set of tags"
	]
}

static func __make_equipment(equipment_data: Dictionary) -> Node:
	var num_val = equipment_data.get("num_val", -1)
	var system = equipment_data.get("system", "")
	var capability_lock = equipment_data.get("capability_lock", false)
	var name_override = equipment_data.get("name_override", "")
	var description = equipment_data.get("description", "")
	var manual = equipment_data.get("manual", "")
	var specs = equipment_data.get("specs", "")
	var price = equipment_data.get("price", 0)
	var test_protocol = equipment_data.get("test_protocol", "fire")
	var default = equipment_data.get("default", false)
	var control = equipment_data.get("control", "")
	var story_flag = equipment_data.get("story_flag", "")
	var story_flag_min = equipment_data.get("story_flag_min", -1)
	var story_flag_max = equipment_data.get("story_flag_max", -1)
	var warn_if_thermal_below = equipment_data.get("warn_if_thermal_below", 0)
	var warn_if_electric_below = equipment_data.get("warn_if_electric_below", 0)
	var sticker_price_format = equipment_data.get("sticker_price_format", "%s E$")
	var sticker_price_multi_format = equipment_data.get("sticker_price_multi_format", "%s E$ (x%d)")
	var installed_color = equipment_data.get("installed_color", Color(0.0, 1.0, 0.0, 1.0))
	var disabled_color = equipment_data.get("disabled_color", Color(0.2, 0.2, 0.2, 1.0))
	var slots = equipment_data.get("slots",[])
	var alignment = equipment_data.get("alignment","")
	var equipment_type = equipment_data.get("equipment_type","")
	var slot_type = equipment_data.get("slot_type","")
	var restriction = equipment_data.get("restriction","")
#	var equip_node = preload("res://HevLib/scenes/equipment/hardpoints/EquipmentItemTemplate.tscn").instance() # Old preload. Commented out because of possible bug with it
	var equip_node = load("res://HevLib/scenes/equipment/hardpoints/unmodified/EquipmentItemTemplate.tscn").instance()
	equip_node.numVal = num_val
	equip_node.system = system
	equip_node.name = system
	equip_node.capabilityLock = capability_lock
	equip_node.nameOverride = name_override
	equip_node.description = description
	equip_node.manual = manual
	equip_node.specs = specs
	equip_node.price = price
	equip_node.testProtocol = test_protocol
	equip_node.default = default
	equip_node.control = control
	equip_node.storyFlag = story_flag
	equip_node.storyFlagMin = story_flag_min
	equip_node.storyFlagMax = story_flag_max
	equip_node.warnIfThermalBelow = warn_if_thermal_below
	equip_node.warnIfElectricBelow = warn_if_electric_below
	equip_node.stickerPriceFormat = sticker_price_format
	equip_node.stickerPriceMultiFormat = sticker_price_multi_format
	equip_node.installedColor = installed_color
	equip_node.disbledColor = disabled_color
	equip_node.slots = slots
	equip_node.alignment = alignment
	equip_node.equipment_type = equipment_type
	equip_node.slot_type = slot_type
	equip_node.restriction = restriction
	return equip_node

static func __make_slot(slot_data: Dictionary) -> Node:
	var systemSlot = slot_data.get("system_slot", "")
	var slotNodeName = slot_data.get("slot_node_name", "MISSING_SLOT_NAME")
	var slotDisplayName = slot_data.get("slot_display_name", "SLOT_MISSING_DATA")
	var hasNone = slot_data.get("has_none", true)
	var alwaysDisplay = slot_data.get("always_display", true)
	var restrictType = slot_data.get("restrict_type", "")
	var openByDefault = slot_data.get("open_by_default", false)
	var limitShips = slot_data.get("limit_ships", [])
	var invertLimitLogic = slot_data.get("invert_limit_logic", false)
	var add_vanilla_equipment = slot_data.get("add_vanilla_equipment", true)
#	var slotTemplate = preload("res://HevLib/scenes/equipment/hardpoints/WeaponSlotUpgradeTemplate.tscn").instance() # Old preload. Commented out because of possible bug with it
	var slotTemplate = load("res://HevLib/scenes/equipment/hardpoints/unmodified/WeaponSlotUpgradeTemplate.tscn").instance()
	var slot_type = slot_data.get("slot_type","HARDPOINT")
	var hardpoint_type = slot_data.get("hardpoint_type","")
	var alignment = slot_data.get("alignment","")
	var restriction = slot_data.get("restriction","")
	var override_additive = slot_data.get("override_additive",[])
	var override_subtractive = slot_data.get("override_subtractive",[])
	if hasNone:
#		var itemTemplate = load("res://HevLib/scenes/equipment/hardpoints/EquipmentItemTemplate.tscn").instance() # Old load. Commented out because of possible bug with it
		var itemTemplate = load("res://HevLib/scenes/equipment/hardpoints/unmodified/EquipmentItemTemplate.tscn").instance()
		itemTemplate.slot = "weaponSlot.main.type"
		itemTemplate.system = "SYSTEM_NONE"
		itemTemplate.default = true
		itemTemplate.name = "None"
		slotTemplate.get_node("VBoxContainer").add_child(itemTemplate)
	slotTemplate.slot = systemSlot
	slotTemplate.name = slotNodeName
	slotTemplate.get_node("VBoxContainer/HBoxContainer/CheckButton").text = slotDisplayName
	slotTemplate.always = alwaysDisplay
	slotTemplate.restrictType = restrictType
	slotTemplate.openByDefault = openByDefault
	slotTemplate.limit_ships = limitShips
	slotTemplate.invert_limit_logic = invertLimitLogic
	slotTemplate.add_vanilla_equipment = add_vanilla_equipment
	slotTemplate.slot_type = slot_type
	slotTemplate.hardpoint_type = hardpoint_type
	slotTemplate.alignment = alignment
	slotTemplate.restriction = restriction
	slotTemplate.override_additive = override_additive
	slotTemplate.override_subtractive = override_subtractive
	return slotTemplate

static func __add_vanilla_equipment(tags: Dictionary, hardpoint_types: Array, alignments: Array, equipment_types: Array, slot_types: Array, hardpoint_defaults: Dictionary):
	var type = tags.get("type")
	if not type in slot_types:
		return []
	if type == "HARDPOINT":
		var alignment = tags.get("alignment", "")
		var equipment = tags.get("equipment")
		var result = __match_vanilla(type, alignment, equipment, alignments)
		return result
	else:
		var alignment = ""
		var equipment = tags.get("equipment")
		var alignments3 = []
		var result = __match_vanilla(type, alignment, equipment, alignments3)
		return result

static func __match_vanilla(type: String, align_to_match: String, desired_equipment: Array, list_of_alignments: Array):
	var vanilla = load("res://HevLib/scenes/equipment/vanilla_defaults/equipment.gd").get_script_constant_map()
	var matching = []
	for item in vanilla:
		var itemDict = vanilla.get(item)
		var ps = itemDict.get("slot_groups")
		var itemSlotType = ps.get("slot_type","")
		if itemSlotType == type:
			var itemAlign = ps.get("alignment", "")
			var itemType = ps.get("tags","")
			var alignmentMatches = true
			if itemAlign in list_of_alignments and not itemAlign == "":
				if not itemAlign == align_to_match:
					alignmentMatches = false
			if alignmentMatches and itemType in desired_equipment:
				matching.append(itemDict)
	return matching
