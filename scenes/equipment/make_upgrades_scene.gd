extends Node

var SCENE_HEADER = "[gd_scene load_steps=4 format=2]\n\n[ext_resource path=\"res://enceladus/Upgrades.tscn\" type=\"PackedScene\" id=1]\n[ext_resource path=\"res://HevLib/scenes/equipment/hardpoints/unmodified/WeaponSlotUpgradeTemplate.tscn\" type=\"PackedScene\" id=2]\n[ext_resource path=\"res://enceladus/SystemShipUpgradeUI.tscn\" type=\"PackedScene\" id=3]\n\n[sub_resource type=\"ViewportTexture\" id=1]\nflags = 5\nviewport_path = NodePath(\"VB/WindowMargin/TabHintContainer/Window/UPGRADE_SIMULATION/VP/Contain1/Viewport\")\n\n[sub_resource type=\"ViewportTexture\" id=2]\nviewport_path = NodePath(\"VB/WindowMargin/TabHintContainer/Window/UPGRADE_SIMULATION/VP/Contain2/Control\")\n\n[node name=\"Upgrades\" instance=ExtResource( 1 )]\n\n[node name=\"TextureRect\" parent=\"VB/WindowMargin/TabHintContainer/Window/UPGRADE_SIMULATION/VP\"]\ntexture = SubResource( 1 )\n\n[node name=\"ControlTexture\" parent=\"VB/WindowMargin/TabHintContainer/Window/UPGRADE_SIMULATION/VP\"]\ntexture = SubResource( 2 )\n\n[node name=\"TextureRect2\" parent=\"VB/WindowMargin/TabHintContainer/Window/UPGRADE_MANUAL/Sims\"]\ntexture = SubResource( 1 )\n\n[node name=\"ControlTexture2\" parent=\"VB/WindowMargin/TabHintContainer/Window/UPGRADE_MANUAL/Sims\"]\ntexture = SubResource( 2 )"

var vanilla_equipment = load("res://HevLib/scenes/equipment/vanilla_defaults/equipment.gd").get_script_constant_map()
var vanilla_data = preload("res://HevLib/scenes/equipment/vanilla_defaults/slot_tagging.gd")
var hardpoint_types
var alignments
var equipment_types
var slot_types
var slot_defaults
var vanilla_equipment_defaults_for_reference

func _init():
	
	hardpoint_types = vanilla_data.hardpoint_types.duplicate(true)
	alignments = vanilla_data.alignments.duplicate(true)
	equipment_types = vanilla_data.equipment_types.duplicate(true)
	slot_types = vanilla_data.slot_types.duplicate(true)
	slot_defaults = vanilla_data.slot_defaults.duplicate(true)
	vanilla_equipment_defaults_for_reference = vanilla_data.vanilla_equipment_defaults_for_reference.duplicate(true)

func make_upgrades_scene(file_save_path : String = "user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/upgrades/Upgrades.tscn", weaponslot_save_path : String = "user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/weapon_slot/WeaponSlot.tscn"):
	var Equipment = preload("res://HevLib/pointers/Equipment.gd")
	var FolderAccess = preload("res://HevLib/pointers/FolderAccess.gd")
	var UpgradeMenu : Node = load("res://enceladus/Upgrades.tscn").instance()
	var nodes_parent = UpgradeMenu.get_node("VB/MarginContainer/ScrollContainer/MarginContainer/Items")
	var vanilla_slot_names = []
	var vanilla_slot_types = {}
	var p = load("res://ModLoader.gd")
	var ps = p.get_script_constant_map()
	var running_in_debugged = false
	var debugged_defined_mods = []
	for item in ps:
		if item == "is_debugged":
			running_in_debugged = true
			var pf = File.new()
			pf.open("res://ModLoader.gd",File.READ)
			var fs = pf.get_as_text(true)
			pf.close()
			var lines = fs.split("\n")
			var reading = false
			var contents = []
			for line in lines:
				
				
				
				if line.begins_with("var addedMods"):
					reading = true
				if reading:
					var split = line.split("\"")
					if split.size() > 1 and split.size() == 3:
						if split[0].begins_with("#"):
							contents.append(split[1])
			
			debugged_defined_mods = contents.duplicate(true)
	for slot in nodes_parent.get_children():
		var children = slot.get_node("VBoxContainer").get_children()
		if children.size() <= 1:
			continue
		vanilla_slot_names.append(slot.name)
		var sys_slot = slot.slot
		var index = 1
		if sys_slot == "":
			while not sys_slot:
				sys_slot = children[index].slot
				index += 1
		vanilla_slot_types.merge({slot.name:sys_slot})
	var weaponslot_modify_templates_file = "user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/weapon_slot/WSLT_MODIFY_TEMPLATES.json"
	var weaponslot_modify_standalone_file = "user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/weapon_slot/WSLT_MODIFY_STANDALONE.json"
	var folders = FolderAccess.__fetch_folder_files("res://", true, true)
	var data_state : Array = []
	var ws_state : Array = []
	FolderAccess.__check_folder_exists(file_save_path.split(file_save_path.split("/")[file_save_path.split("/").size() - 1])[0])
	FolderAccess.__check_folder_exists(weaponslot_save_path.split(weaponslot_save_path.split("/")[weaponslot_save_path.split("/").size() - 1])[0])
	var wpfl = File.new()
	var ws_default_templates = load("res://HevLib/scenes/weaponslot/data_storage/templates.gd").get_script_constant_map()
	wpfl.open(weaponslot_modify_templates_file,File.WRITE)
	wpfl.store_string(JSON.print(ws_default_templates.get("TEMPLATES",{})))
	wpfl.close()
	wpfl.open(weaponslot_modify_standalone_file,File.WRITE)
	wpfl.store_string("{}")
	wpfl.close()
	for folder in folders:
		var semi_root = folder.split("/")[2]
		if semi_root.begins_with("."):
			continue
					
		if folder.ends_with("/"):
			var mods_to_avoid = []
			if running_in_debugged:
				for mod in debugged_defined_mods:
					var home = mod.split("/")[2]
					if home == semi_root:
						mods_to_avoid.append(home)
			var folder_2 = FolderAccess.__fetch_folder_files(folder, true, true)
			for check in folder_2:
				if semi_root in mods_to_avoid:
					continue
				if check.ends_with("HEVLIB_EQUIPMENT_DRIVER_TAGS/"):
					var files = FolderAccess.__fetch_folder_files(check, false, true)
					var mod = check.hash()
					var dicti = {}
					var dictr = {}
					var dictf = {}
					for file in files:
						var last_bit = file.split("/")[file.split("/").size() - 1]
						match last_bit:
							"ADD_EQUIPMENT_ITEMS.gd":
								var data = load(check + last_bit)
								var constants = data.get_script_constant_map()
								var arr2 = []
								for item in constants:
									var equipment = data.get(item).duplicate(true)
									arr2.append(equipment)
								dicti.merge({"ADD_EQUIPMENT_ITEMS":arr2})
							"ADD_EQUIPMENT_SLOTS.gd":
								var data = load(check + last_bit)
								var constants = data.get_script_constant_map()
								var arr2 = []
								for item in constants:
									var equipment = data.get(item).duplicate(true)
									arr2.append(equipment)
								dicti.merge({"ADD_EQUIPMENT_SLOTS":arr2})
							"EQUIPMENT_TAGS.gd":
								var data = load(check + last_bit)
								var constants = data.get_script_constant_map()
								var ar = constants.get("EQUIPMENT_TAGS",{}).duplicate(true)
								dicti.merge({"EQUIPMENT_TAGS":ar})
							"SLOT_TAGS.gd":
								var data = load(check + last_bit)
								var constants = data.get_script_constant_map()
								var ar = constants.get("SLOT_TAGS",{}).duplicate(true)
								dicti.merge({"SLOT_TAGS":ar})
							"WEAPONSLOT_ADD.gd":
								var data = load(check + last_bit)
								var constants = data.get_script_constant_map()
								var arr2 = []
								for item in constants:
									var equipment = data.get(item).duplicate(true)
									arr2.append(equipment)
								dictr.merge({"WEAPONSLOT_ADD":arr2})
							"WEAPONSLOT_ADD_TEMPLATES.gd":
								var data = load(check + last_bit)
								var constants = data.get_script_constant_map()
								var ar = constants.get("WEAPONSLOT_ADD_TEMPLATES",{}).duplicate(true)
								dictf.merge({"WEAPONSLOT_ADD_TEMPLATES":ar})
							"WEAPONSLOT_MODIFY_TEMPLATES.gd":
								var data = load(check + last_bit)
								var constants = data.get_script_constant_map()
								var ar = constants.get("WEAPONSLOT_MODIFY_TEMPLATES",{}).duplicate(true)
								var fi = File.new()
								fi.open(weaponslot_modify_templates_file,File.READ_WRITE)
								var filedata = fi.get_as_text(true)
								var sort = JSON.parse(filedata)
								var founddata : Dictionary = sort.result
								for template in ar:
									if template in founddata.keys():
										for datapoint in ar[template]:
											match datapoint:
												"equipment":
													for item in ar[template][datapoint]:
														if item in founddata[template][datapoint]:
															pass
														else:
															founddata[template][datapoint].append(item)
												"data":
													var datadict = {}
													for prop in ar[template][datapoint]:
														datadict.merge({prop.get("property"):prop.get("value")})
													var totalindex = ar[template][datapoint].size()
													var index = 0
													while index < totalindex:
														var datai = founddata[template][datapoint][index]
														if datai.get("property") in datadict:
															founddata[template][datapoint][index]["value"] = datadict.get(datai.get("property"))
														else:
															var additiondict = {"property":datai.get("property"),"value":datai.get("value")}
															founddata[template][datapoint].append(additiondict)
															breakpoint
														
														index += 1
													breakpoint
									else:
										founddata[template] = ar.get(template).duplicate(true)
								
								fi.store_string(JSON.print(founddata))
								fi.close()
							"WEAPONSLOT_MODIFY.gd":
								var data = load(check + last_bit)
								var constants = data.get_script_constant_map()
								var ar = constants.get("WEAPONSLOT_MODIFY",{}).duplicate(true)
								var fi = File.new()
								fi.open(weaponslot_modify_standalone_file,File.READ_WRITE)
								var filedata = fi.get_as_text(true)
								var sort = JSON.parse(filedata)
								var founddata : Dictionary = sort.result
								founddata.merge(ar, true)
								fi.store_string(JSON.print(founddata))
								fi.close()
								
					var mname = check.split("/")[2]
					if dicti.keys().size() >= 1:
						data_state.append([dicti,check,mod,mname])
					if dictr.keys().size() >= 1:
						ws_state.append([dictr,check,mod,mname])
	
	
	
	var slots = data_state
	
	for item in slots:
		var files = item[0]
		if "ADD_EQUIPMENT_ITEMS" in files.keys():
			var data = files.get("ADD_EQUIPMENT_ITEMS")
			var for_ws = [{"WEAPONSLOT_ADD":[]}]
			for object in data:
				if "weapon_slot" in object.keys():
					var obj = object.get("weapon_slot").duplicate(true)
					var wname = object.get("system","")
					var wprice = object.get("price",0)
					var objdata = obj.get("data",[])
					var has_price = false
					var has_invis = false
					var price_string = str(wprice)
					if "name" in obj.keys():
						pass
					else:
						object["weapon_slot"].merge({"name":wname})
					for d in objdata:
						if d.get("property","") == "repairReplacementPrice":
							d["value"] = price_string
							has_price = true
						if d.get("property","") == "visible":
							has_invis = true
					if not has_price:
						objdata.append({"property":"repairReplacementPrice","value":price_string})
					if not has_invis:
						objdata.append({"property":"visible","value":"false"})
					object["weapon_slot"]["data"] = objdata.duplicate(true)
					var eq_for_ws = object["weapon_slot"].duplicate(true)
					for_ws[0]["WEAPONSLOT_ADD"].append(eq_for_ws)
			ws_state.append(for_ws)
	
	var all_slot_node_names = []
	all_slot_node_names.append_array(vanilla_slot_names)
	var slots_for_adding = []
	var slots_for_adding_dict = {}
	var tag_modifications = {}
	
	var equipment_for_adding = {}
	
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
				slots_for_adding_dict.merge({slotDict.get("slot_node_name",""):slotDict})
				all_slot_node_names.append(slotDict.get("slot_node_name",""))
		for itm in slots:
			var node = itm[0].get("SLOT_TAGS",{})
			if node.keys().size() >= 1:
				tag_modifications.merge({itm[3].hash():node})
		var ns = its[0].get("ADD_EQUIPMENT_ITEMS",[])
		if ns.size() >= 1:
			for m in ns:
				equipment_for_adding.merge({m.get("system",""):m})
	
	var slots_full : Array = []
	var slots_format : PoolStringArray = []
	var editable_paths : PoolStringArray = []
	
	var slot_eligibility : Array = []
	
	var equipment : PoolStringArray = []
	
	var slot_allowed_equipment : Dictionary = {}
	
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
	for slot in vanilla_equipment_defaults_for_reference:
		var vslot_data = vanilla_equipment_defaults_for_reference[slot]
		var vslot_additives = vslot_data.get("override_additive",[])
		var vslot_subtractives = vslot_data.get("override_subtractive",[])
		for mod in tag_modifications:
			var dict = tag_modifications[mod]
			if slot in dict.keys():
				var tag_data = dict[slot]
				var tag_add = tag_data.get("override_additive",[])
				var tag_sub = tag_data.get("override_subtractive",[])
				if vslot_additives != []:
					for add in tag_add:
						if add in vslot_additives:
							pass
						else:
							vslot_additives.append(add)
				else:
					vslot_additives = tag_add.duplicate()
				if vslot_subtractives != []:
					for sub in tag_sub:
						if sub in vslot_subtractives:
							pass
						else:
							vslot_subtractives.append(sub)
				else:
					vslot_subtractives = tag_sub.duplicate()
		if vslot_additives != []:
			vslot_data["override_additive"] = vslot_additives
		if vslot_subtractives != []:
			vslot_data["override_subtractive"] = vslot_subtractives
		
		
	for slot in all_slot_node_names:
		if slot in vanilla_equipment_defaults_for_reference.keys():
			var data = vanilla_equipment_defaults_for_reference[slot]
			var slot_type = data.get("slot_type","HARDPOINT").to_upper()
			if slot_type == "HARDPOINT":
				var hardpoint = data.get("hardpoint_type", "")
				var yk = slot_defaults.get(hardpoint,[]).duplicate(true)
				var items = yk.duplicate(true)
				var additives = data.get("override_additive",[])
				var subtractives = data.get("override_subtractive",[])
				for item in additives:
					if item in items:
						pass
					else:
						items.append(item)
				for item in subtractives:
					var tmp = []
					for i in items:
						if i in subtractives:
							pass
						else:
							tmp.append(i)
					items = tmp.duplicate(true)
				
				slot_allowed_equipment.merge({slot:items})
			else:
				var items = slot_defaults.get(slot_type,[])
				slot_allowed_equipment.merge({slot:items})
		elif slot in slots_for_adding_dict.keys():
			var data = slots_for_adding_dict[slot]
			var slot_type = data.get("slot_type","HARDPOINT").to_upper()
			if slot_type == "HARDPOINT":
				var hardpoint = data.get("hardpoint_type", "")
				var yk = slot_defaults.get(hardpoint,[]).duplicate(true)
				var items = yk.duplicate(true)
				var additives = data.get("override_additive",[])
				var subtractives = data.get("override_subtractive",[])
				for item in additives:
					if item in items:
						pass
					else:
						items.append(item)
				for item in subtractives:
					var tmp = []
					for i in items:
						if i in subtractives:
							pass
						else:
							tmp.append(i)
					items = tmp.duplicate(true)
				
				slot_allowed_equipment.merge({slot:items})
			else:
				var items = slot_defaults.get(slot_type,[])
				slot_allowed_equipment.merge({slot:items})
		
		
	var equipment_format : PoolStringArray = []
	
	for slot in slots_for_adding:
		if slot.get("add_vanilla_equipment",true):
			for equip in vanilla_equipment:
				var item = vanilla_equipment[equip]
				var allowed_equipment = slot_allowed_equipment.get(slot.get("slot_node_name",""),[]).duplicate(true)
				
				var does = confirm_equipment(vanilla_equipment[equip], slot.get("slot_type",""), slot.get("alignment",""), slot.get("restriction",""), allowed_equipment)
				if does:
					var system_slot = slot.get("system_slot","")
					var string = Equipment.__make_equipment_for_scene(item, slot.get("slot_node_name",""), system_slot)
					if system_slot == "":
						pass
					equipment_format.append(string)
	for slot in all_slot_node_names:
		if slot in slot_allowed_equipment.keys():
			for equip in equipment_for_adding:
				var item = equipment_for_adding[equip]
				var allowed_equipment = slot_allowed_equipment.get(slot,[]).duplicate(true)
				var slot_type = ""
				var alignment = ""
				var restriction = ""
				var system_slot = ""
				if slot in vanilla_equipment_defaults_for_reference.keys():
					slot_type = vanilla_equipment_defaults_for_reference[slot].get("slot_type","")
					alignment = vanilla_equipment_defaults_for_reference[slot].get("alignment","")
					restriction = vanilla_equipment_defaults_for_reference[slot].get("restriction","")
					system_slot = vanilla_slot_types[slot]
				elif slot in slots_for_adding_dict.keys():
					slot_type = slots_for_adding_dict[slot].get("slot_type","")
					alignment = slots_for_adding_dict[slot].get("alignment","")
					restriction = slots_for_adding_dict[slot].get("restriction","")
					system_slot = slots_for_adding_dict[slot].get("system_slot","")
				var does = confirm_equipment(equipment_for_adding[equip], slot_type, alignment, restriction, allowed_equipment)
				if does:
					var string = Equipment.__make_equipment_for_scene(item, slot, system_slot)
					if system_slot == "":
						pass
					if string in equipment_format:
						pass
					else:
						equipment_format.append(string)
			
	var concat = ""
	concat = SCENE_HEADER
	for ref in slots_format:
		concat = concat + "\n\n" + ref
	for equip in equipment_format:
		concat = concat + "\n\n" + equip
	for path in editable_paths:
		concat = concat + "\n\n" + path
#	FolderAccess.__check_folder_exists(file_save_path.split("/")[file_save_path.split("/").size() - 1])
	
	for entry in ws_state:
		for opt in entry[0].keys():
			match opt:
				"WEAPONSLOT_TAGS":
					pass
	
	
	
	var ws_header = "[gd_scene load_steps=2 format=2]\n\n[ext_resource path=\"res://weapons/WeaponSlot.tscn\" type=\"PackedScene\" id=1]\n\n[node name=\"WeaponSlot\" instance=ExtResource( 1 )]"
	
	var equipment_header = "[node name=\"%s\" parent=\"%s\" instance_placeholder=\"%s\"]"
	var equipment_header_noref = "[node name=\"%s\" parent=\"%s\"]"
	var equipment_editable_path_base = "[editable path=\"%s\"]"
	
	
	var weaponslot_string = ws_header
	var ws_editable_paths = ""
	var weaponslot_properties = {}
	for entry in ws_state:
		var d = entry[0]
		var opts = d.keys()
		for opt in opts:
			match opt:
				"WEAPONSLOT_ADD":
					var additions = d.get(opt)
					
	
					for add in additions:
						var aname = add.get("name","SYSTEM_ERROR")
						var apath = add.get("path","")
						var add_header = ""
						if apath == "":
							add_header = equipment_header_noref % [aname,"."]
						else:
							add_header = equipment_header % [aname,".",apath]
						weaponslot_properties.merge({add_header:[]})
						if ws_editable_paths == "":
							ws_editable_paths = equipment_editable_path_base % aname
						else:
							ws_editable_paths = ws_editable_paths + "\n" + equipment_editable_path_base % aname
						
						for it in add.get("data",[]):
							var ws_property_string = ""
							var ws_property = it.get("property")
							var ws_value = it.get("value")
							var split = ws_property.split("/")
							var property = split[split.size() - 1]
							var parent_path = "."
							if split.size() >= 3:
								var node = split[split.size() - 2]
								var nonode = ws_property.split(node)
								if nonode[0].ends_with("/"):
									nonode[0] = nonode[0].rstrip("/")
								if nonode[1].begins_with("/"):
									nonode[1] = nonode[1].lstrip("/")
								var prop_header = equipment_header_noref % [node,aname + "/" + nonode[0]]
								if prop_header in weaponslot_properties.keys():
									pass
								else:
									weaponslot_properties.merge({prop_header:[]})
								weaponslot_properties[prop_header].append([nonode[1],ws_value])
							elif split.size() == 2:
								var prop_header = equipment_header_noref % [split[0],aname]
								if prop_header in weaponslot_properties.keys():
									pass
								else:
									weaponslot_properties.merge({prop_header:[]})
								weaponslot_properties[prop_header].append([split[1],ws_value])
							else:
								if add_header in weaponslot_properties.keys():
									pass
								else:
									weaponslot_properties.merge({add_header:[]})
								weaponslot_properties[add_header].append([ws_property,ws_value])
	
	for property in weaponslot_properties:
		weaponslot_string = weaponslot_string + "\n\n" + property
		var data = weaponslot_properties.get(property)
		for dp in data:
			weaponslot_string = weaponslot_string + "\n" + dp[0] + " = " + dp[1]
	
	
	
	
	
	if not ws_editable_paths == "":
		weaponslot_string = weaponslot_string + "\n\n" + ws_editable_paths
	var f = File.new()
	f.open(weaponslot_save_path,File.WRITE)
	f.store_string(weaponslot_string)
	f.close()
	
	f.open(file_save_path,File.WRITE)
	f.store_string(concat)
	f.close()
	UpgradeMenu.free()

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
