extends Node

func make_upgrades_scene() -> String:
	var Equipment = preload("res://HevLib/pointers/Equipment.gd")
	var vanilla_data = preload("res://HevLib/scenes/equipment/vanilla_defaults/slot_tagging.gd")
	var UpgradeMenu : Node = load("res://enceladus/Upgrades.tscn").instance()
	var nodes_parent = UpgradeMenu.get_node("VB/MarginContainer/ScrollContainer/MarginContainer/Items")
	var vanilla_slot_nodes = []
	for slot in nodes_parent.get_children():
		vanilla_slot_nodes.append(slot.name)
	
	var CRoot = get_tree().get_root().get_node("EquipmentDriver")
	var slots = CRoot.conv
	
	var hardpoint_types = vanilla_data.hardpoint_types.duplicate()
	var alignments = vanilla_data.alignments.duplicate()
	var equipment_types = vanilla_data.equipment_types.duplicate()
	var slot_types = vanilla_data.slot_types.duplicate()
	var slot_defaults = vanilla_data.slot_defaults.duplicate()
	var vanilla_equipment_defaults_for_reference = vanilla_data.vanilla_equipment_defaults_for_reference.duplicate()
	
	UpgradeMenu.free()
	
	
	
	return ""
