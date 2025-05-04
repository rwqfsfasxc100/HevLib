extends Node

var developer_hint = {
	"__make_equipment":[
		"Inputs a dictionary to format it for adding via this library",
		"equipment slot variables are the exact same as they are usually, check res://enceladus/SystemShipUpgradeUI.tscn OR .gd for those values",
		" -> formatted in the form of {\"<variable_name>\":<variable_value>}",
		"Has two other variables not included in the usual selection for adding to slots:",
		" -> 'slots' is an array of the raw slot node names in Upgrades.tscn child to the Items node. Equivalent to the slot_node_name variable for __make_slot",
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
	]
}

static func __make_equipment(equipment_data: Dictionary):
	var num_val = equipment_data.get("numVal", -1)
	var system = equipment_data.get("system", "")
	var capability_lock = equipment_data.get("capabilityLock", false)
	var name_override = equipment_data.get("nameOverride", "")
	var description = equipment_data.get("description", "")
	var manual = equipment_data.get("manual", "")
	var specs = equipment_data.get("specs", "")
	var price = equipment_data.get("price", 0)
	var test_protocol = equipment_data.get("testProtocol", "fire")
	var default = equipment_data.get("default", false)
	var control = equipment_data.get("control", "")
	var story_flag = equipment_data.get("storyFlag", "")
	var story_flag_min = equipment_data.get("storyFlagMin", -1)
	var story_flag_max = equipment_data.get("storyFlagMax", -1)
	var warn_if_thermal_below = equipment_data.get("warnIfThermalBelow", 0)
	var warn_if_electric_below = equipment_data.get("warnIfElectricBelow", 0)
	var sticker_price_format = equipment_data.get("stickerPriceFormat", "%s E$")
	var sticker_price_multi_format = equipment_data.get("stickerPriceMultiFormat", "%s E$ (x%d)")
	var installed_color = equipment_data.get("installedColor", Color(0.0, 1.0, 0.0, 1.0))
	var disabled_color = equipment_data.get("disabledColor", Color(0.2, 0.2, 0.2, 1.0))
	var slots = equipment_data.get("slots", [])
	var slot_groups = equipment_data.get("slot_groups", {})
	var equipment_node = {
		"num_val":num_val,
		"system":system,
		"capability_lock":capability_lock,
		"name_override":name_override,
		"description":description,
		"manual":manual,
		"specs":specs,
		"price":price,
		"test_protocol":test_protocol,
		"default":default,
		"control":control,
		"story_flag":story_flag,
		"story_flag_min":story_flag_min,
		"story_flag_max":story_flag_max,
		"warn_if_thermal_below":warn_if_thermal_below,
		"warn_if_electric_below":warn_if_electric_below,
		"sticker_price_format":sticker_price_format,
		"sticker_price_multi_format":sticker_price_multi_format,
		"installed_color":installed_color,
		"disabled_color":disabled_color
	}
	var dict = {"equipment":equipment_node, "slots":slots, "slot_groups":slot_groups}
	return dict

static func __make_slot(slot_data: Dictionary) -> Node:
	var systemSlot = slot_data.get("system_slot", "")
	var slotNodeName = slot_data.get("slot_node_name", "MISSING_SLOT_NAME")
	var slotDisplayName = slot_data.get("slot_displayName", "SLOT_MISSING_DATA")
	var slotGroups = slot_data.get("slot_groups", {})
	var hasNone = slot_data.get("has_none", true)
	var alwaysDisplay = slot_data.get("always_display", true)
	var restrictType = slot_data.get("restrict_type", "")
	var openByDefault = slot_data.get("open_by_default", false)
	var limitShips = slot_data.get("limit_ships", [])
	var invertLimitLogic = slot_data.get("invert_limit_logic", false)
	
	var slotTemplate = load("res://HevLib/scenes/equipment/hardpoints/WeaponSlotUpgradeTemplate.tscn").instance()
	if hasNone:
		var itemTemplate = load("res://enceladus/SystemShipUpgradeUI.tscn").instance()
		itemTemplate.slot = "weaponSlot.main.type"
		itemTemplate.system = "SYSTEM_NONE"
		itemTemplate.default = true
		slotTemplate.get_node("VBoxContainer").add_child(itemTemplate)
	slotGroups.merge({"system_slot":systemSlot}, false)
	slotTemplate.slot = systemSlot
	slotTemplate.name = slotNodeName
	slotTemplate.get_node("VBoxContainer/HBoxContainer/CheckButton").text = slotDisplayName
	slotTemplate.always = alwaysDisplay
	slotTemplate.restrictType = restrictType
	slotTemplate.openByDefault = openByDefault
	slotTemplate.onlyForShipNames = limitShips
	slotTemplate.invertNameLogic = invertLimitLogic
	slotTemplate.slotGroups = slotGroups
	return slotTemplate

