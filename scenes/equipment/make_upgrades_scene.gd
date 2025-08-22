extends Node

var SCENE_HEADER = "[gd_scene load_steps=4 format=2]\n\n[ext_resource path=\"res://enceladus/Upgrades.tscn\" type=\"PackedScene\" id=1]\n[ext_resource path=\"res://HevLib/scenes/equipment/hardpoints/unmodified/WeaponSlotUpgradeTemplate.tscn\" type=\"PackedScene\" id=2]\n[ext_resource path=\"res://HevLib/scenes/equipment/hardpoints/unmodified/EquipmentItemTemplate.tscn\" type=\"PackedScene\" id=3]\n\n[node name=\"Upgrades\" instance=ExtResource( 1 )]\n\n"

func make_upgrades_scene() -> String:
	var Equipment = preload("res://HevLib/pointers/Equipment.gd")
	var vanilla_data = preload("res://HevLib/scenes/equipment/vanilla_defaults/slot_tagging.gd")
	var UpgradeMenu : Node = load("res://enceladus/Upgrades.tscn").instance()
	var nodes_parent = UpgradeMenu.get_node("VB/MarginContainer/ScrollContainer/MarginContainer/Items")
	var vanilla_slot_names = []
	for slot in nodes_parent.get_children():
		vanilla_slot_names.append(slot.name)
	
	var CRoot = Debug.get_parent().get_node("EquipmentDriver")
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
	
	var tag_modifications = {}
	
	
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
		
		
		for itm in slots:
			var node = itm[0].get("SLOT_TAGS",{})
			if node.keys().size() >= 1:
				tag_modifications.merge({itm[3].hash():node})
		
	
	
	
	
	
	
	
	
	tag_vanilla_slots(vanilla_equipment_defaults_for_reference)
	return ""

var tagged_vanilla_slots = PoolStringArray()

var MODULE_IDENTIFIER = "Equipment Driver"
func l(msg:String, ID:String = MODULE_IDENTIFIER, title:String = "HevLib"):
	Debug.l("[%s %s]: %s" % [title, ID, msg])

const SLOT_HEADER = "[node name=\"%s\" parent=\"VB/MarginContainer/ScrollContainer/MarginContainer/Items\" instance=ExtResource( 2 )]"

func tag_vanilla_slots(vanilla_equipment_defaults_for_reference):
	
	for item in vanilla_equipment_defaults_for_reference:
		var data = vanilla_equipment_defaults_for_reference.get(item)
		
		var string : String = ""
		
		string = SLOT_HEADER % item
		for tag in data:
			var content = data.get(tag)
			match tag:
				"limit_ships", "override_subtractive", "override_additive":
					string = format_for_arrays(string, tag, content)
				"add_vanilla_equipment", "invert_limit_logic":
					string = format_for_bools(string, tag, content)
				"slot_type", "hardpoint_type", "alignment", "restriction":
					string = format_for_strings(string, tag, content)
		tagged_vanilla_slots.append(string)

func format_for_arrays(string, tag, content) -> String:
	var initial = string + "\n" + tag + " = ["
	var one = false
	for item in content:
		if one == false:
			one = true
		else:
			initial = initial + ", "
		initial = initial + "\"" + item + "\""
	initial = initial + "]"
	return initial

func format_for_strings(string, tag, content) -> String:
	return string + "\n" + tag + " = \"" + str(content) + "\""

func format_for_bools(string, tag, content) -> String:
	return string + "\n" + tag + " = " + str(content)
