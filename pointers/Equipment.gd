extends Node

static func __make_equipment_data(data):
	
	
	pass

static func __make_equipment(slot, equipment_data):
	var itemTemplate = load("res://enceladus/SystemShipUpgradeUI.tscn").instance()
	
	
	
	
	pass

static func __make_slot(systemSlot: String, slotNodeName: String, slotDisplayName: String, hasNone: bool = true, alwaysDisplay: bool = true, restrictType: String = "", openByDefault: bool = false, limitShips: Array = [], invertLimitLogic: bool = false) -> Node:
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
	return slotTemplate
