extends Node

func make_upgrades_scene() -> String:
	var Equipment = preload("res://HevLib/pointers/Equipment.gd")
	var vanilla_data = preload("res://HevLib/scenes/equipment/vanilla_defaults/slot_tagging.gd")
	var UpgradeMenu : Node = load("res://enceladus/Upgrades.tscn").instance()
	var nodes_parent = UpgradeMenu.get_node("VB/MarginContainer/ScrollContainer/MarginContainer/Items")
	var vanilla_slot_names = []
	for slot in nodes_parent.get_children():
		vanilla_slot_names.append(slot.name)
	
	var CRoot = get_tree().get_root().get_node("EquipmentDriver")
	var slots = CRoot.conv
	
	var hardpoint_types = vanilla_data.hardpoint_types.duplicate()
	var alignments = vanilla_data.alignments.duplicate()
	var equipment_types = vanilla_data.equipment_types.duplicate()
	var slot_types = vanilla_data.slot_types.duplicate()
	var slot_defaults = vanilla_data.slot_defaults.duplicate()
	var vanilla_equipment_defaults_for_reference = vanilla_data.vanilla_equipment_defaults_for_reference.duplicate()
	
	UpgradeMenu.free()
	
	var all_slot_node_names = []
	all_slot_node_names.append_array(vanilla_slot_names)
	var slots_for_adding = []
	
	
	
	for its in slots:
		var nodes = its[0].get("EQUIPMENT_TAGS",{})
		if nodes.keys().size() >= 1:
			l("Adding equipment tags for %s" % str(its[2]))
			
			var slotTypes = nodes.get("slot_types",[])
			var equipmentItems = nodes.get("equipment_types",[])
			var align = nodes.get("alignments",[])
			var hardpointTypes = nodes.get("hardpoint_types",[])
			var slotDefaults = nodes.get("slot_defaults",{})
			if slotTypes.size() > 0:
				for st in slotTypes:
					if not st in slot_types:
						slot_types.append(st)
			if equipmentItems.size() > 0:
				for st in equipmentItems:
					if not st in equipment_types:
						equipment_types.append(st)
			if align.size() > 0:
				for st in align:
					if not st in alignments:
						alignments.append(st)
			if hardpointTypes.size() > 0:
				for st in hardpointTypes:
					if not st in hardpoint_types:
						hardpoint_types.append(st)
			if slotDefaults.keys().size() > 0:
				for st in slotDefaults:
					if st in slot_defaults.keys():
						for item in slotDefaults.get(st):
							if item in slot_defaults.get(st):
								pass
							else:
								slot_defaults[st].append(item)
					else:
						slot_defaults.merge({st:slotDefaults.get(st)})
		var newSlot = its[0].get("ADD_EQUIPMENT_SLOTS",[])
		var mod_hash = str(its[2])
		if newSlot.size() >= 1:
			l("Adding slots for %s" % mod_hash)
			for slotDict in newSlot:
				slots_for_adding.append(slotDict)
				all_slot_node_names.append(slotDict.get("slot_node_name",""))
		
	return ""



var MODULE_IDENTIFIER = "Equipment Driver"
func l(msg:String, ID:String = MODULE_IDENTIFIER, title:String = "HevLib"):
	Debug.l("[%s %s]: %s" % [title, ID, msg])

