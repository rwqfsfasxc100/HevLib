extends Node

var SCENE_HEADER = "[gd_scene load_steps=4 format=2]\n\n[ext_resource path=\"res://enceladus/Upgrades.tscn\" type=\"PackedScene\" id=1]\n[ext_resource path=\"res://HevLib/scenes/equipment/hardpoints/unmodified/WeaponSlotUpgradeTemplate.tscn\" type=\"PackedScene\" id=2]\n[ext_resource path=\"res://HevLib/scenes/equipment/hardpoints/unmodified/EquipmentItemTemplate.tscn\" type=\"PackedScene\" id=3]\n\n[node name=\"Upgrades\" instance=ExtResource( 1 )]\n\n"

var vanilla_equipment = load("res://HevLib/scenes/equipment/vanilla_defaults/equipment.gd").get_script_constant_map()
var vanilla_data = preload("res://HevLib/scenes/equipment/vanilla_defaults/slot_tagging.gd")
var hardpoint_types
var alignments
var equipment_types
var slot_types
var slot_defaults
var vanilla_equipment_defaults_for_reference

func _init():
	
	hardpoint_types = vanilla_data.hardpoint_types.duplicate()
	alignments = vanilla_data.alignments.duplicate()
	equipment_types = vanilla_data.equipment_types.duplicate()
	slot_types = vanilla_data.slot_types.duplicate()
	slot_defaults = vanilla_data.slot_defaults.duplicate()
	vanilla_equipment_defaults_for_reference = vanilla_data.vanilla_equipment_defaults_for_reference.duplicate()

func make_upgrades_scene() -> String:
	var Equipment = preload("res://HevLib/pointers/Equipment.gd")
	
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
	
	
	
	
	var all_slot_node_names = []
	all_slot_node_names.append_array(vanilla_slot_names)
	var slots_for_adding = []
	
	var tag_modifications = {}
	
	var equipment_for_adding = []
	
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
		var ns = its[0].get("ADD_EQUIPMENT_ITEMS",[])
		if ns.size() >= 1:
			for m in ns:
				equipment_for_adding.append(m)
	
	var slots_full : Array = []
	var slots_format : PoolStringArray = []
	var editable_paths : PoolStringArray = []
	
	var slot_eligibility : Array = []
	
	var equipment : PoolStringArray = []
	
	for slot in slots_for_adding:
		var m = slot.get("slot_node_name","")
		var format = Equipment.__make_slot_for_scene(slot)
		for tag in tag_modifications:
			var data = tag_modifications.get(tag)
			if m in data.keys():
				for check in format:
					if check.keys()[0] == m:
						var slot_override_additive = check[m][2]["override_additive"]
						var slot_override_subtractive = check[m][2]["override_subtractive"]
						var override_additive = data[m].get("override_additive",[])
						var override_subtractive = data[m].get("override_subtractive",[])
						for over in override_additive:
							if over in slot_override_additive:
								pass
							else:
								slot_override_additive.append(over)
						for over in override_subtractive:
							if over in slot_override_subtractive:
								pass
							else:
								slot_override_subtractive.append(over)
						slot_eligibility.append({m:[[],slot_override_additive,slot_override_subtractive]})
		slots_format.append(format.get(m)[0])
		editable_paths.append(format.get(m)[1])
		slots_full.append(format)
	
	
	
#	tag_vanilla_slots(vanilla_equipment_defaults_for_reference)
	
	
	UpgradeMenu.free()
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


func confirm_equipment(equipment_node, slot_type, slot_alignment, slot_restriction, slot_allowed_equipment) -> bool:
	var e_slot_type = equipment_node.get("slot_type","")
	var e_equipment = equipment_node.get("equipment_type","")
	var e_alignment = equipment_node.get("alignment","")
	var e_restriction = equipment_node.get("restriction","")
	
	if e_slot_type == slot_type:
		var passes_slot_check = false
		if e_equipment in slot_allowed_equipment:
			var tp = typeof(slot_type)
			if tp == TYPE_STRING:
				if slot_type == "HARDPOINT":
					if slot_alignment in alignments:
						if e_alignment in alignments:
							if e_alignment == slot_alignment:
								passes_slot_check = true
							else:
								return false
						else:
							passes_slot_check = true
					else:
						passes_slot_check = true
				else:
					passes_slot_check = true
			elif tp == TYPE_ARRAY:
				for s in slot_type:
					if s == "HARDPOINT":
						if slot_alignment in alignments:
							if e_alignment in alignments:
								if e_alignment == slot_alignment:
									passes_slot_check = true
								else:
									return false
							else:
								passes_slot_check = true
						else:
							passes_slot_check = true
					
					else:
						passes_slot_check = true
			else:
				passes_slot_check = false
		else:
			return false
		if passes_slot_check:
			if not slot_restriction == "":
				if not e_restriction == "":
					if e_restriction == slot_restriction:
						return true
					else:
						return false
				else:
					return true
			else:
				return true
		else:
			return false
	else:
		return false
	return false
