extends Node

static func __make_equipment(equipment_data: Dictionary):
	var itemTemplate = load("res://enceladus/SystemShipUpgradeUI.tscn").instance()
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
	var sticker_price_multi_format = equipment_data.get("stickerPriceMultiFormat", "%s E$ (x$d)")
	var installed_color = equipment_data.get("installedColor", Color(0.0, 1.0, 0.0, 1.0))
	var disabled_color = equipment_data.get("disabledColor", Color(0.2, 0.2, 0.2, 1.0))
	var slots = equipment_data.get("slots", [])
	var slot_groups = equipment_data.get("slot_groups", [])
	
	
	
	
	
	
	

static func __make_slot(slot_data: Dictionary) -> Node:
	var systemSlot = slot_data.get("system_slot")
	var slotNodeName = slot_data.get("slot_node_name")
	var slotDisplayName = slot_data.get("slot_displayName")
	var slotGroups = slot_data.get("slot_groups", [])
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
