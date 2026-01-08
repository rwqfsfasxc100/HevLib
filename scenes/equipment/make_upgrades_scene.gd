extends Node

var SCENE_HEADER = "[gd_scene load_steps=4 format=2]\n\n[ext_resource path=\"res://enceladus/Upgrades.tscn\" type=\"PackedScene\" id=1]\n[ext_resource path=\"res://HevLib/scenes/equipment/hardpoints/unmodified/WeaponSlotUpgradeTemplate.tscn\" type=\"PackedScene\" id=2]\n[ext_resource path=\"res://enceladus/SystemShipUpgradeUI.tscn\" type=\"PackedScene\" id=3]\n\n[sub_resource type=\"ViewportTexture\" id=1]\nflags = 5\nviewport_path = NodePath(\"VB/WindowMargin/TabHintContainer/Window/UPGRADE_SIMULATION/VP/Contain1/Viewport\")\n\n[sub_resource type=\"ViewportTexture\" id=2]\nviewport_path = NodePath(\"VB/WindowMargin/TabHintContainer/Window/UPGRADE_SIMULATION/VP/Contain2/Control\")\n\n[node name=\"Upgrades\" instance=ExtResource( 1 )]\n\n[node name=\"TextureRect\" parent=\"VB/WindowMargin/TabHintContainer/Window/UPGRADE_SIMULATION/VP\"]\ntexture = SubResource( 1 )\n\n[node name=\"ControlTexture\" parent=\"VB/WindowMargin/TabHintContainer/Window/UPGRADE_SIMULATION/VP\"]\ntexture = SubResource( 2 )\n\n[node name=\"TextureRect2\" parent=\"VB/WindowMargin/TabHintContainer/Window/UPGRADE_MANUAL/Sims\"]\ntexture = SubResource( 1 )\n\n[node name=\"ControlTexture2\" parent=\"VB/WindowMargin/TabHintContainer/Window/UPGRADE_MANUAL/Sims\"]\ntexture = SubResource( 2 )"

const ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")
var vanilla_equipment = preload("res://HevLib/scenes/equipment/vanilla_defaults/equipment.gd").get_script_constant_map()
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

var version = [1,0,0]
func make_upgrades_scene(is_onready: bool = true):
	
	
	# FILE PATHS
	var FILE_PATHS = [
		"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/upgrades/Upgrades.tscn",
		"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/power/Exhaust_Cache",
		"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/power/AuxSlot.tscn",
		
		"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/weapon_slot/WSLT_MODIFY_TEMPLATES.json",
		"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/weapon_slot/WSLT_MODIFY_STANDALONE.json",
		"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/upgrades/slot_order.json",
		"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/weapon_slot/WSLT_SHIP_TEMPLATES.json",
		"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/weapon_slot/WSLT_SHIP_STANDALONE.json",
		"user://cache/.HevLib_Cache/MenuDriver/save_buttons.json",
		"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/ships/processed_storage_mods.json",
		"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/ships/node_definitions.json",
		"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/ships/ship_node_register.json",
		"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/power/AuxSlot.json",
		"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/weapon_slot/WeaponSlot_additions.json",
		"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/weapon_slot/WeaponSlot_modifications.json",
		"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/weapon_slot/WSLT_MODIFIED_NAMES.json",
		"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/upgrades/Slot_Limits.tscn",
		"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/ships/ship_node_modify.json",
		"user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/ships/ship_thruster_colors.json",
	]
	
	var file_save_path : String = FILE_PATHS[0]
	var exhaust_cache_path : String = FILE_PATHS[1]
	var auxslot_save_path : String = FILE_PATHS[2]
	var weaponslot_modify_templates_file = FILE_PATHS[3]
	var weaponslot_modify_standalone_file = FILE_PATHS[4]
	var slot_order_cache_file = FILE_PATHS[5]
	var weaponslot_ship_templates_file = FILE_PATHS[6]
	var weaponslot_ship_standalone_file = FILE_PATHS[7]
	var save_menu_file = FILE_PATHS[8]
	var processed_storage_file = FILE_PATHS[9]
	var node_definitions_file = FILE_PATHS[10]
	var ship_node_register_file = FILE_PATHS[11]
	var auxslot_data_path = FILE_PATHS[12]
	var weaponslot_additions = FILE_PATHS[13]
	var weaponslot_modifications = FILE_PATHS[14]
	var weaponslot_modify_equipment_names = FILE_PATHS[15]
	var upgrades_slot_limits = FILE_PATHS[16]
	var ship_node_modify_file = FILE_PATHS[17]
	var ship_thruster_color_file = FILE_PATHS[18]
	var DataFormat = load("res://HevLib/pointers/DataFormat.gd")
	if is_onready:
		
		var version = DataFormat.__get_vanilla_version()
		var text = "HevLib make_upgrades_scene manager: observed game version of %s"  % str(version)
		Debug.l(text)
	var Equipment = load("res://HevLib/pointers/Equipment.gd")
	var FolderAccess = load("res://HevLib/pointers/FolderAccess.gd")
	var UpgradeMenu : Node = load("res://enceladus/Upgrades.tscn").instance()
	var nodes_parent = UpgradeMenu.get_node("VB/MarginContainer/ScrollContainer/MarginContainer/Items")
	var vanilla_slot_names = []
	var vanilla_slot_types = {}
	var running_in_debugged = false
	var debugged_defined_mods = []
	FolderAccess.__check_folder_exists("user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/weapon_slot/ship_data/")
	var onready_mod_paths = []
	var onready_mod_folders = []
	
	# Use when not loading from ready
	if not is_onready:
		var p = load("res://ModLoader.gd")
		var ps = p.get_script_constant_map()
		for item in ps:
			if item == "is_debugged":
				running_in_debugged = true
				var pf = File.new()
#				if pf.file_exists("res://ModLoader.gd"):
#					l("Can see ModLoader.gd")
#				else:
#					l("Cannot see ModLoader.tscn")
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
	
	
	# Use when running on ready
	if is_onready:
		var mods = ModLoader.get_children()
		for mod in mods:
			var path = mod.get_script().get_path()
			onready_mod_paths.append(path)
			var split = path.split("/")
			onready_mod_folders.append(split[2])
	
	
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
	
	
	var folders = FolderAccess.__fetch_folder_files("res://", true, true)
	var data_state : Array = []
	var ws_state : Array = []
	var power_state = []
	
	var ws_equipment_names = []
	
	for item in FILE_PATHS:
		FolderAccess.__check_folder_exists(item.split(item.split("/")[item.split("/").size() - 1])[0])
	var wpfl = File.new()
	var ws_default_templates = load("res://HevLib/scenes/weaponslot/data_storage/templates.gd").get_script_constant_map()
	var ws_ship_templates = load("res://HevLib/scenes/weaponslot/data_storage/ship_templates.gd").get_script_constant_map()
	var ws_ship_templates_2 = load("res://HevLib/scenes/weaponslot/data_storage/ship_templates_2.gd").get_script_constant_map()
	var ship_register = load("res://HevLib/scenes/equipment/ShipModificationDriver/ship_register_vanilla.gd").get_script_constant_map()
	var register_default_ships = []
	for item in ship_register:
		register_default_ships.append(ship_register[item])
	
	wpfl.open(weaponslot_modify_templates_file,File.WRITE)
	wpfl.store_string(JSON.print(ws_default_templates.get("TEMPLATES",{})))
	wpfl.close()
	wpfl.open(weaponslot_modify_standalone_file,File.WRITE)
	wpfl.store_string("{}")
	wpfl.close()
	wpfl.open(weaponslot_ship_standalone_file,File.WRITE)
	wpfl.store_string(JSON.print(ws_ship_templates.get("SHIP_MODIFY",{})))
	wpfl.close()
	wpfl.open(weaponslot_ship_templates_file,File.WRITE)
	wpfl.store_string(JSON.print(ws_ship_templates_2.get("SHIP_TEMPLATES",{})))
	wpfl.close()
	wpfl.open(slot_order_cache_file,File.WRITE)
	wpfl.store_string("[]")
	wpfl.close()
	wpfl.open(save_menu_file,File.WRITE)
	wpfl.store_string("[]")
	wpfl.close()
	wpfl.open(processed_storage_file,File.WRITE)
	wpfl.store_string("[]")
	wpfl.close()
	wpfl.open(node_definitions_file,File.WRITE)
	wpfl.store_string("{}")
	wpfl.close()
	wpfl.open(ship_thruster_color_file,File.WRITE)
	wpfl.store_string("{}")
	wpfl.close()
#	wpfl.open(exhaust_cache_file,File.WRITE)
#	wpfl.store_string("{}")
#	wpfl.close()
	wpfl.open(auxslot_data_path,File.WRITE)
	wpfl.store_string("{}")
	wpfl.close()
	wpfl.open(weaponslot_modify_equipment_names,File.WRITE)
	wpfl.store_string("[]")
	wpfl.close()
	wpfl.open(ship_node_register_file,File.WRITE)
	wpfl.store_string(JSON.print(register_default_ships))
	wpfl.close()
	wpfl.open(ship_node_modify_file,File.WRITE)
	wpfl.store_string("{}")
	wpfl.close()
	wpfl.open(weaponslot_additions,File.WRITE)
	wpfl.store_string("[]")
	wpfl.close()
	wpfl.open(weaponslot_modifications,File.WRITE)
	wpfl.store_string("[]")
	wpfl.close()
	
	
	for folder in folders:
		var semi_root = folder.split("/")[2]
		if semi_root.begins_with("."):
			continue
					
		if folder.ends_with("/"):
			var mods_to_avoid = []
			if not is_onready:
				if running_in_debugged:
					for mod in debugged_defined_mods:
						var home = mod.split("/")[2]
						if home == semi_root:
							mods_to_avoid.append(home)
			var folder_2 = FolderAccess.__fetch_folder_files(folder, true, true)
			for check in folder_2:
				if not is_onready:
					if semi_root in mods_to_avoid:
						continue
				else:
					if not semi_root in onready_mod_folders:
						continue
				if check.ends_with("HEVLIB_EQUIPMENT_DRIVER_TAGS/"): # EQUIPMENTDRIVER FILES
					var files = FolderAccess.__fetch_folder_files(check, false, true)
					var mod = check.hash()
					var dicti = {}
					var dictr = {}
					var OneOff = {}
					for file in files:
						var last_bit = file.split("/")[file.split("/").size() - 1]
						match last_bit:
							"ADD_EQUIPMENT_ITEMS.gd":
								var data = load(check + last_bit)
								var constants = data.get_script_constant_map()
								var arr2 = []
								for item in constants:
									var equipment = data.get(item).duplicate(true)
									var allow = true
									if "config" in equipment:
										var cf = equipment["config"]
										var id = cf.get("id",null)
										var section = cf.get("section",null)
										var opt = cf.get("entry",null)
										if id and section and opt:
											var cv = ConfigDriver.__get_value(id,section,opt)
											if typeof(cv) == TYPE_BOOL:
												allow = cv
									if allow:
										arr2.append(equipment)
								dicti.merge({"ADD_EQUIPMENT_ITEMS":arr2})
							"ADD_EQUIPMENT_SLOTS.gd":
								var data = load(check + last_bit)
								var constants = data.get_script_constant_map()
								var arr2 = []
								for item in constants:
									var equipment = data.get(item).duplicate(true)
									var allow = true
									if "config" in equipment:
										var cf = equipment["config"]
										var id = cf.get("id",null)
										var section = cf.get("section",null)
										var opt = cf.get("entry",null)
										if id and section and opt:
											var cv = ConfigDriver.__get_value(id,section,opt)
											if typeof(cv) == TYPE_BOOL:
												allow = cv
									if allow:
										arr2.append(equipment)
								dicti.merge({"ADD_EQUIPMENT_SLOTS":arr2})
							"EQUIPMENT_TAGS.gd":
								var data = load(check + last_bit)
								var constants = data.get_script_constant_map()
								var ar = constants.get("EQUIPMENT_TAGS",{}).duplicate(true)
								dicti.merge({"EQUIPMENT_TAGS":ar})
							"SLOT_ORDER.gd":
								var f = File.new()
#								if wpfl.file_exists(slot_order_cache_file):
#									l("Can see %s" % slot_order_cache_file)
#								else:
#									l("Cannot see %s" % slot_order_cache_file)
								f.open(slot_order_cache_file,File.READ_WRITE)
								var data = JSON.parse(f.get_as_text()).result
								var cache = load(check + last_bit).get_script_constant_map()
								var orders = cache.get("SLOT_ORDER")
								for order in orders:
									if order in data:
										pass
									else:
										data.append(order)
								f.store_string(JSON.print(data))
								f.close()
							"SLOT_TAGS.gd":
								var data = load(check + last_bit)
								var constants = data.get_script_constant_map()
								var ar = constants.get("SLOT_TAGS",{}).duplicate(true)
								dicti.merge({"SLOT_TAGS":ar})


							"AUX_POWER_SLOT.gd","THRUSTERS.gd","AUX_POWER_AND_THRUSTERS.gd":
								var data = load(check + last_bit)
								var constants = data.get_script_constant_map()
								var arr2 = []
								for item in constants:
									var equipment = data.get(item).duplicate(true)
									arr2.append(equipment)
								if "AUX_POWER_SLOT" in OneOff:
									pass
								else:
									OneOff.merge({"AUX_POWER_SLOT":[]})
								OneOff["AUX_POWER_SLOT"].append_array(arr2)


							"MODIFY_INTERNALS.gd":
								var data = load(check + last_bit)
								var constants = data.get_script_constant_map()
#								if wpfl.file_exists(processed_storage_file):
#									l("Can see %s" % processed_storage_file)
#								else:
#									l("Cannot see %s" % processed_storage_file)
								wpfl.open(processed_storage_file,File.READ_WRITE)
								var pfdata = JSON.parse(wpfl.get_as_text()).result
								if "MODIFY_INTERNALS" in constants:
									var pdata = constants.MODIFY_INTERNALS
									pfdata.append_array(pdata)
									wpfl.store_string(JSON.print(pfdata))
								wpfl.close()
							"NODE_DEFINITIONS.gd":
								var data = load(check + last_bit)
								var constants = data.get_script_constant_map()
#								if wpfl.file_exists(node_definitions_file):
#									l("Can see %s" % node_definitions_file)
#								else:
#									l("Cannot see %s" % node_definitions_file)
								wpfl.open(node_definitions_file,File.READ_WRITE)
								var pfdata = JSON.parse(wpfl.get_as_text()).result
								for item in constants:
									pfdata.merge({item:constants.get(item)})
								wpfl.store_string(JSON.print(pfdata))
								wpfl.close()
							"SHIP_NODE_REGISTER.gd":
								var data = load(check + last_bit)
								var constants = data.get_script_constant_map()
#								if wpfl.file_exists(ship_node_register_file):
#									l("Can see %s" % ship_node_register_file)
#								else:
#									l("Cannot see %s" % ship_node_register_file)
								wpfl.open(ship_node_register_file,File.READ_WRITE)
								var pfdata = JSON.parse(wpfl.get_as_text()).result
								for item in constants:
									pfdata.append(constants.get(item))
								wpfl.store_string(JSON.print(pfdata))
								wpfl.close()
							"SHIP_NODE_MODIFY.gd":
								var data = load(check + last_bit)
								var constants = data.get_script_constant_map()
								wpfl.open(ship_node_modify_file,File.READ_WRITE)
								var pfdata = JSON.parse(wpfl.get_as_text()).result
								for item in constants:
									var ship = constants[item].get("ship_name","")
									if ship != "":
										if ship in pfdata:
											pass
										else:
											pfdata[ship] = []
										for modification in constants[item].get("modifications",[]):
											
											pfdata[ship].append(modification)
								wpfl.store_string(JSON.print(pfdata))
								wpfl.close()
							"SHIP_THRUSTER_COLORS.gd":
								var data = load(check + last_bit)
								var cd = data.get_script_constant_map().get("SHIP_THRUSTER_COLORS",{})
								if cd.keys().size() > 0:
									wpfl.open(ship_thruster_color_file,File.READ)
									var current = JSON.parse(wpfl.get_as_text()).result
									wpfl.close()
									for ship in cd:
										if ship in current:
											pass
										else:
											current.merge({ship:{"node":{},"type":{}}})
										if "type" in cd[ship]:
											current[ship]["type"].merge(cd[ship]["type"],true)
										if "node" in cd[ship]:
											current[ship]["node"].merge(cd[ship]["node"],true)
										if "recurse_to_variants" in cd[ship]:
											current[ship]["recurse_to_variants"] = cd[ship]["recurse_to_variants"]
										
									wpfl.open(ship_thruster_color_file,File.WRITE)
									wpfl.store_string(JSON.print(current))
									wpfl.close()
									
								
								pass

							"WEAPONSLOT_ADD.gd":
								var data = load(check + last_bit)
								var constants = data.get_script_constant_map()
								var arr2 = []
								for item in constants:
									var equipment = data.get(item).duplicate(true)
									var n = equipment.get("name",null)
									if n:
										if not n in ws_equipment_names:
											ws_equipment_names.append(n)
										arr2.append(equipment)
								dictr.merge({"WEAPONSLOT_ADD":arr2})
							"WEAPONSLOT_MODIFY_TEMPLATES.gd":
								var data = load(check + last_bit)
								var constants = data.get_script_constant_map()
								var ar = constants.get("WEAPONSLOT_MODIFY_TEMPLATES",{}).duplicate(true)
								var fi = File.new()
#								if wpfl.file_exists(weaponslot_modify_templates_file):
#									l("Can see %s" % weaponslot_modify_templates_file)
#								else:
#									l("Cannot see %s" % weaponslot_modify_templates_file)
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
														if not item in ws_equipment_names:
															ws_equipment_names.append(item)
														if item in founddata[template][datapoint]:
															pass
														else:
															founddata[template][datapoint].append(item)
												"data":
													var data_formatted = {}
													for item in ar[template][datapoint]:
														data_formatted.merge({item.get("property"):item.get("value")})
													for key in data_formatted.keys():
														var is_in_dict = false
														for lps in founddata[template][datapoint]:
															if lps.get("property") == key:
																is_in_dict = true
																lps["value"] = data_formatted[key]
														if not is_in_dict:
															founddata[template][datapoint].append({"property":key,"value":data_formatted.get(key)})
									else:
										founddata[template] = ar.get(template).duplicate(true)
								
								fi.store_string(JSON.print(founddata))
								fi.close()
							"WEAPONSLOT_MODIFY.gd":
								var data = load(check + last_bit)
								var constants = data.get_script_constant_map()
								var ar = constants.get("WEAPONSLOT_MODIFY",{}).duplicate(true)
								var fi = File.new()
#								if wpfl.file_exists(weaponslot_modify_standalone_file):
#									l("Can see %s" % weaponslot_modify_standalone_file)
#								else:
#									l("Cannot see %s" % weaponslot_modify_standalone_file)
								fi.open(weaponslot_modify_standalone_file,File.READ_WRITE)
								var filedata = fi.get_as_text(true)
								var sort = JSON.parse(filedata)
								var founddata : Dictionary = sort.result
								for item in ar:
									if not item in ws_equipment_names:
										ws_equipment_names.append(item)
									if item in founddata:
										var new_dict = {}
										for c in ar.get(item):
											var prop = c.get("property")
											var val = c.get("value")
											new_dict.merge({prop:val})
										var old_dict = {}
										var current_item_data = founddata.get(item)
										for c in current_item_data:
											var prop = c.get("property")
											var val = c.get("value")
											old_dict.merge({prop:val})
										for op in new_dict:
											old_dict[op] = new_dict[op]
										var processed = []
										for u in old_dict:
											processed.append({"property":u,"value":old_dict.get(u)})
										founddata.merge({item:processed},true)
									else:
										founddata.merge({item:ar.get(item)})
								fi.store_string(JSON.print(founddata))
								fi.close()
							"WEAPONSLOT_SHIP_TEMPLATES.gd":
								var data = load(check + last_bit)
								var constants = data.get_script_constant_map()
								var ar = constants.get("WEAPONSLOT_SHIP_TEMPLATES",{}).duplicate(true)
								var fi = File.new()
#								if wpfl.file_exists(weaponslot_ship_templates_file):
#									l("Can see %s" % weaponslot_ship_templates_file)
#								else:
#									l("Cannot see %s" % weaponslot_ship_templates_file)
								fi.open(weaponslot_ship_templates_file,File.READ_WRITE)
								var filedata = fi.get_as_text(true)
								var sort = JSON.parse(filedata)
								var founddata : Dictionary = sort.result
								
								for ship in ar:
									if ship in founddata.keys():
										var shipdata = ar.get(ship)
										for slot in shipdata:
											if slot in founddata[ship]:
												var compile = {}
												var current_dict = {}
												var new_dict = {}
												for type in founddata[ship][slot]:
													compile.merge({type:[]},true)
													current_dict.merge({type:{}},true)
													for equip in founddata[ship][slot][type]:
														current_dict[type].merge({equip.get("property"):equip.get("value")})
												for type in shipdata[slot]:
													compile.merge({type:[]},true)
													new_dict.merge({type:{}},true)
													for equip in shipdata[slot][type]:
														new_dict[type].merge({equip.get("property"):equip.get("value")})
												current_dict.merge(new_dict,true)
												for item in current_dict:
													for equip in current_dict[item]:
														compile[item].append({"property":equip,"value":current_dict[item].get(equip)})
												founddata[ship][slot] = compile.duplicate(true)
											else:
												founddata[ship][slot] = shipdata.get(slot).duplicate(true)
									else:
										founddata.merge(ar)
								fi.store_string(JSON.print(founddata))
								fi.close()
							"WEAPONSLOT_SHIP_MODIFY.gd":
								var data = load(check + last_bit)
								var constants = data.get_script_constant_map()
								var ar = constants.get("WEAPONSLOT_SHIP_MODIFY",{}).duplicate(true)
								var fi = File.new()
#								if wpfl.file_exists(weaponslot_ship_standalone_file):
#									l("Can see %s" % weaponslot_ship_standalone_file)
#								else:
#									l("Cannot see %s" % weaponslot_ship_standalone_file)
								fi.open(weaponslot_ship_standalone_file,File.READ_WRITE)
								var filedata = fi.get_as_text(true)
								var sort = JSON.parse(filedata)
								var founddata : Dictionary = sort.result
								
								
								for ship in ar:
									var slots = ar[ship]
									for slot in slots:
										var equipment = slots[slot]
										for item in equipment:
											if not item in ws_equipment_names:
												ws_equipment_names.append(item)
									
									if ship in founddata.keys():
										var shipdata = ar.get(ship)
										for slot in shipdata:
											if slot in founddata[ship]:
												var compile = {}
												var current_dict = {}
												var new_dict = {}
												for type in founddata[ship][slot]:
													compile.merge({type:[]},true)
													current_dict.merge({type:{}},true)
													for equip in founddata[ship][slot][type]:
														current_dict[type].merge({equip.get("property"):equip.get("value")})
												for type in shipdata[slot]:
													compile.merge({type:[]},true)
													new_dict.merge({type:{}},true)
													for equip in shipdata[slot][type]:
														new_dict[type].merge({equip.get("property"):equip.get("value")})
												current_dict.merge(new_dict,true)
												for item in current_dict:
													for equip in current_dict[item]:
														compile[item].append({"property":equip,"value":current_dict[item].get(equip)})
												founddata[ship][slot] = compile.duplicate(true)
											else:
												founddata[ship][slot] = shipdata.get(slot).duplicate(true)
									else:
										founddata.merge(ar)
								fi.store_string(JSON.print(founddata))
								fi.close()
					var mname = check.split("/")[2]
					if dicti.keys().size() >= 1:
						data_state.append([dicti,check,mod,mname])
					if dictr.keys().size() >= 1:
						ws_state.append([dictr,check,mod,mname])
					if OneOff.keys().size() >= 1:
						power_state.append(OneOff)
				if check.ends_with("HEVLIB_MENU/"): # MENUDRIVER FILES
					var files = FolderAccess.__fetch_folder_files(check, false, true)
					var mod = check.hash()
					var dicti = {}
					var dictr = {}
					for file in files:
						var last_bit = file.split("/")[file.split("/").size() - 1]
						match last_bit:
							"SAVE_BUTTONS.gd":
								var data = load(check + last_bit)
								var constants = data.get_script_constant_map()
								var ar = constants.get("SAVE_BUTTONS",[]).duplicate(true)
								var fi = File.new()
#								if wpfl.file_exists(save_menu_file):
#									l("Can see %s" % save_menu_file)
#								else:
#									l("Cannot see %s" % save_menu_file)
								fi.open(save_menu_file,File.READ_WRITE)
								var filedata = fi.get_as_text(true)
								var sort = JSON.parse(filedata)
								var founddata = sort.result
								
								for button in ar:
									founddata.append(button)
								
								fi.store_string(JSON.print(founddata))
								fi.close()
								
	var slots = data_state
	
	wpfl.open(weaponslot_modify_equipment_names,File.WRITE)
	wpfl.store_string(JSON.print(ws_equipment_names))
	wpfl.close()
	
	for item in slots:
		var files = item[0]
		if "ADD_EQUIPMENT_ITEMS" in files.keys():
			var data = files.get("ADD_EQUIPMENT_ITEMS")
			var for_ws = [{"WEAPONSLOT_ADD":[]}]
			var for_aux_power = {"AUX_POWER_SLOT":[]}
			for object in data:
				if object.get("slot_type","HARDPOINT") == "HARDPOINT":
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
				if object.get("slot_type","HARDPOINT") == "AUX_POWER_SLOT":
					if "auxiliary_power_unit" in object.keys():
						var bp = object.get("auxiliary_power_unit")
						if "system" in bp.keys():
							pass
						else:
							bp.merge({"system":object.get("system","SYSTEM_MISSING_NAME")})
						if "price" in bp.keys():
							pass
						else:
							bp.merge({"price":object.get("price",0)})
						
						for_aux_power["AUX_POWER_SLOT"].append(bp)
			power_state.append(for_aux_power)
			ws_state.append(for_ws)
	
	var all_slot_node_names = []
	all_slot_node_names.append_array(vanilla_slot_names)
	var slots_for_adding = []
	var slots_for_adding_dict = {}
	var tag_modifications = {}
	
	var ship_limitations = {}
	var ship_limitation_string = ""
	
	var equipment_for_adding = []
#	var equipment_for_adding = {}
	
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
				var snn = slotDict.get("slot_node_name","")
				var spp = ship_limitations.get(snn,{})
				if "limit_ships" in slotDict:
					var val = slotDict["limit_ships"].duplicate()
					if snn in ship_limitations:
						if "limit_ships" in spp:
							for i in val:
								if i in spp:
									pass
								else:
									ship_limitations[snn]["limit_ships"] = i
						else:
							ship_limitations[snn]["limit_ships"] = spp["limit_ships"]
					else:
						ship_limitations.merge({snn:{}})
						ship_limitations[snn]["limit_ships"] = val
				if "prevent_ships" in slotDict:
					var val = slotDict["prevent_ships"].duplicate()
					if snn in ship_limitations:
						if "prevent_ships" in spp:
							for i in val:
								if i in spp:
									pass
								else:
									ship_limitations[snn]["prevent_ships"] = i
						else:
							ship_limitations[snn]["prevent_ships"] = spp["prevent_ships"]
					else:
						ship_limitations.merge({snn:{}})
						ship_limitations[snn]["prevent_ships"] = val
				slots_for_adding.append(slotDict)
				slots_for_adding_dict.merge({slotDict.get("slot_node_name",""):slotDict})
				all_slot_node_names.append(slotDict.get("slot_node_name",""))
		for itm in slots:
			var node = itm[0].get("SLOT_TAGS",{})
			if node.keys().size() >= 1:
				tag_modifications.merge({itm[3].hash():node})
				for i in node:
					var data = node[i]
					var snn = i
					var spp = ship_limitations.get(snn,{})
					if "limit_ships" in data:
						var val = data["limit_ships"].duplicate()
						if snn in ship_limitations:
							if "limit_ships" in spp:
								for f in val:
									if f in spp:
										pass
									else:
										ship_limitations[snn]["limit_ships"] = f
							else:
								ship_limitations[snn]["limit_ships"] = spp["limit_ships"]
						else:
							ship_limitations.merge({snn:{}})
							ship_limitations[snn]["limit_ships"] = val.duplicate()
					if "prevent_ships" in data:
						var val = data["prevent_ships"].duplicate()
						if snn in ship_limitations:
							if "prevent_ships" in spp:
								for f in val:
									if f in spp:
										pass
									else:
										ship_limitations[snn]["prevent_ships"] = f
							else:
								ship_limitations[snn]["prevent_ships"] = spp["prevent_ships"]
						else:
							ship_limitations.merge({snn:{}})
							ship_limitations[snn]["prevent_ships"] = val.duplicate()
		var ns = its[0].get("ADD_EQUIPMENT_ITEMS",[])
		if ns.size() >= 1:
			for m in ns:
#				equipment_for_adding.merge({m.get("system",""):m})
				equipment_for_adding.append(m)
	
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
		vanilla_equipment_defaults_for_reference[slot] = vslot_data
		
		
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
#			for equip in equipment_for_adding:
			for item in equipment_for_adding:
#				var item = equipment_for_adding[equip]
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
#				var does = confirm_equipment(equipment_for_adding[equip], slot_type, alignment, restriction, allowed_equipment)
				var does = confirm_equipment(item, slot_type, alignment, restriction, allowed_equipment)
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
	
	var ws_stuff_to_add = []
	var ws_stuff_to_modify = []
	
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
						var item_data = {}
						for it in add.get("data",[]):
							var ws_property_string = ""
							var ws_property = it.get("property")
							var ws_value = it.get("value")
							var split = ws_property.split("/")
							var property = split[split.size() - 1]
							if split.size() >= 3:
								var node = split[split.size() - 2]
								var nonode = ws_property.split(node)
								if nonode[0].ends_with("/"):
									nonode[0] = nonode[0].rstrip("/")
								if nonode[1].begins_with("/"):
									nonode[1] = nonode[1].lstrip("/")
								if nonode[0] in item_data:
									pass
								else:
									item_data.merge({nonode[0]:[]})
								item_data[nonode[0]].append([nonode[1],ws_value])
							elif split.size() == 2:
								if split[0] in item_data:
									pass
								else:
									item_data.merge({split[0]:[]})
								item_data[split[0]].append([split[1],ws_value])
							else:
								if "." in item_data:
									pass
								else:
									item_data.merge({".":[]})
								item_data["."].append([ws_property,ws_value])
						if apath == "":
							ws_stuff_to_modify.append({"name":aname,"data":item_data})
						else:
							ws_stuff_to_add.append({"name":aname,"path":apath,"data":item_data})
	
	
	
	
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
	
	var aux_power_header = "[gd_scene load_steps=2 format=2]\n\n[ext_resource path=\"res://ships/modules/AuxSlot.tscn\" type=\"PackedScene\" id=1]\n\n[node name=\"AuxSlot\" instance=ExtResource( 1 )]"
	
	var MPDG_header = "[node name=\"%s\" parent=\".\" instance_placeholder=\"res://ships/modules/AuxMpd.tscn\"]"
	var SMES_header = "[node name=\"%s\" parent=\".\" instance_placeholder=\"res://ships/modules/AuxSmes.tscn\"]"
	
	var aux_power_string = aux_power_header
	
	var thruster_header = "[gd_scene load_steps=3 format=2]\n\n[ext_resource path=\"res://sfx/exhaust.tscn\" type=\"PackedScene\" id=1]\n[ext_resource path=\"%s\" type=\"%s\" id=2]\n\n[sub_resource type=\"CircleShape2D\" id=1]\nradius = %s\n\n[node name=\"exhaust\" instance=ExtResource( 1 )]"
	var thruster_footer = "[node name=\"Sprite\" parent=\".\" index=\"1\"]\ntexture = ExtResource( 2 )"
	
	
	
	var property = "%s = %s"
	var file = File.new()
	
	file.open(weaponslot_additions,File.WRITE)
	file.store_string(JSON.print(ws_stuff_to_add))
	file.close()
	file.open(weaponslot_modifications,File.WRITE)
	file.store_string(JSON.print(ws_stuff_to_modify))
	file.close()
	
	
	
	for mod in power_state:
		for type in mod:
			match type:
				"AUX_POWER_SLOT","THRUSTERS","AUX_POWER_AND_THRUSTERS":
					for data in mod.get(type):
						file.open(auxslot_data_path,File.READ_WRITE)
						var a = JSON.parse(file.get_as_text()).result
						var equipSlots = data.get("slots",[])
						for slot in equipSlots:
							slot = slot.split(".")[0]
							if slot in a:
								pass
							else:
								a.merge({slot:[]})
							a[slot].append(data)
						file.store_string(JSON.print(a))
						file.close()
						var aux_path = data.get("path","")
						var aux_type = data.get("type","MPDG").to_upper()
						match aux_type:
							"THRUSTER","RCS","TORCH","MAIN_PROPULSION":
								var sys = data.get("system","SYSTEM_NAME_MISSING")
								var light_lag_chance = data.get("exhaust_light_lag_chance",0)
								var base_lifetime = data.get("exhaust_base_lifetime",0.25)
								var lifetime = data.get("exhaust_lifetime",0.25)
								var end_scale = data.get("exhaust_end_scale",0.02)
								var self_remove = data.get("exhaust_self_remove",0.02)
								var mass = data.get("exhaust_mass",0.1)
								var sprite = data.get("exhaust_sprite","res://sfx/ball-of-flame.png")
								var sprite_scale = data.get("exhaust_sprite_scale",[0.5,0.5])
								var radius = data.get("exhaust_collider_radius",2.87)
								
								var tex_type = ""
								if sprite.ends_with(".png"):
									tex_type = "Texture"
								elif sprite.ends_with(".stex"):
									tex_type = "StreamTexture"
								else:
									tex_type = "Texture"
									sprite = "res://sfx/ball-of-flame.png"
								
								var thruster_text = thruster_header % [sprite,tex_type,str(radius)]
								
								thruster_text = thruster_text + "\nmass = %s" % mass
								thruster_text = thruster_text + "\nlightLagChance = %s" % light_lag_chance
								thruster_text = thruster_text + "\nbaseLifetime = %s" % base_lifetime
								thruster_text = thruster_text + "\nlifetime = %s" % lifetime
								thruster_text = thruster_text + "\nendScale = %s" % end_scale
								if self_remove:
									thruster_text = thruster_text + "\nselfRemove = true"
								else:
									thruster_text = thruster_text + "\nselfRemove = false"
								
								thruster_text = thruster_text + "\n\n[node name=\"CollisionShape2D\" parent=\".\" index=\"0\"]\nshape = SubResource( 1 )\n\n" + thruster_footer
								thruster_text = thruster_text + "\nscale = Vector2(%s,%s)" % [sprite_scale[0],sprite_scale[1]]
								
								FolderAccess.__check_folder_exists(exhaust_cache_path + "/" + aux_type)
								
								file.open(exhaust_cache_path + "/" + aux_type + "/" + sys + ".tscn",File.WRITE)
								file.store_string(thruster_text)
								file.close()
							
							
							
#							"MPDG":
#								var system = data.get("system","SYSTEM_NAME_MISSING")
#								var system_display = "\n" + property % ["systemName","\"" + system + "\""]
#								var price = "\n" + property % ["repairReplacementPrice",str(data.get("price",30000))]
#								var repair_time = "\n" + property % ["repairReplacementTime",str(data.get("repair_time",1))]
#								var fix_price = "\n" + property % ["repairFixPrice",str(data.get("fix_price",5000))]
#								var fix_time = "\n" + property % ["repairFixTime",str(data.get("fix_time",4))]
#								var command = "\n" + property % ["command","\"" + data.get("command","") + "\""]
#								var power_draw = "\n" + property % ["powerDraw",str(float(data.get("power_draw",50000.0)))]
#								var thermal = "\n" + property % ["thermal",str(float(data.get("thermal",500000.0)))]
#								var power_supply = "\n" + property % ["powerSupply",str(float(data.get("power_supply",350000.0)))]
#								var windup_time = "\n" + property % ["windupTime",str(data.get("windup_time",2))]
#								var mass = "\n" + property % ["mass",str(float(data.get("mass",0.0)))]
#
#								var cc = price + repair_time + fix_price + fix_time + command + power_draw + thermal + power_supply + windup_time + mass + system_display
#
#								var MPDG = "\n\n" + MPDG_header % system + cc
#
#								aux_power_string = aux_power_string + MPDG
#
#							"SMES":
#								var system = data.get("system","SYSTEM_NAME_MISSING")
#								var system_display = "\n" + property % ["systemName","\"" + system + "\""]
#								var price = "\n" + property % ["repairReplacementPrice",str(data.get("price",40000))]
#								var repair_time = "\n" + property % ["repairReplacementTime",str(data.get("repair_time",1))]
#								var fix_price = "\n" + property % ["repairFixPrice",str(data.get("fix_price",25000))]
#								var fix_time = "\n" + property % ["repairFixTime",str(data.get("fix_time",4))]
#								var capacitor_ratio = "\n" + property % ["capacitorRatio",str(float(data.get("capacitor_ratio",0.9)))]
#								var command = "\n" + property % ["command","\"" + data.get("command","") + "\""]
#								var power_draw = "\n" + property % ["powerDraw",str(float(data.get("power_draw",50000.0)))]
#								var capacity = "\n" + property % ["capacity",str(float(data.get("capacity",600000.0)))]
#								var power_supply = "\n" + property % ["powerSupply",str(float(data.get("power_supply",200000.0)))]
#								var switch_time = "\n" + property % ["switchTime",str(float(data.get("switch_time",2)))]
#								var mass = "\n" + property % ["mass",str(data.get("mass",0))]
#
#								var cc = price + repair_time + fix_price + fix_time + capacitor_ratio + command + power_draw + power_supply + capacity + system_display + switch_time + mass
#
#								var SMES = "\n\n" + SMES_header % system + cc
#
#								aux_power_string = aux_power_string + SMES
	var lim_header = "[gd_scene load_steps=2 format=2]\n\n[ext_resource path=\"res://enceladus/Upgrades.tscn\" type=\"PackedScene\" id=1]\n\n[node name=\"Upgrades\" instance=ExtResource( 1 )]"
	var lim_item = "[node name=\"%s\" parent=\"VB/MarginContainer/ScrollContainer/MarginContainer/Items\"]"
	ship_limitation_string = lim_header
	for i in ship_limitations:
		var cc = "\n\n" + lim_item % i
		var data = ship_limitations[i]
		if "limit_ships" in data:
			var sl = "limit_ships = [ "
			if typeof(data["limit_ships"]) == TYPE_STRING:
				data["limit_ships"] = [data["limit_ships"]]
			for f in range(0,data["limit_ships"].size()):
				if f < data["limit_ships"].size() - 1:
					sl = sl + "\"" + data["limit_ships"][f] + "\", "
				else:
					sl = sl + "\"" + data["limit_ships"][f] + "\" ]"
			cc = cc + "\n" + sl
		if "prevent_ships" in data:
			var sl = "prevent_ships = [ "
			if typeof(data["prevent_ships"]) == TYPE_STRING:
				data["prevent_ships"] = [data["prevent_ships"]]
			for f in range(0,data["prevent_ships"].size()):
				if f < data["prevent_ships"].size() - 1:
					sl = sl + "\"" + data["prevent_ships"][f] + "\", "
				else:
					sl = sl + "\"" + data["prevent_ships"][f] + "\" ]"
			cc = cc + "\n" + sl
		ship_limitation_string = ship_limitation_string + cc




	if not ws_editable_paths == "":
		weaponslot_string = weaponslot_string + "\n\n" + ws_editable_paths
	
	var f = File.new()
#	f.open(exhaust_cache_file,File.WRITE)
#	f.store_string(JSON.print(exhaust_state))
#	f.close()
	
	f.open(file_save_path,File.WRITE)
	f.store_string(concat)
	f.close()
	
	f.open(auxslot_save_path,File.WRITE)
	f.store_string(aux_power_string)
	f.close()
	
	f.open(upgrades_slot_limits,File.WRITE)
	f.store_string(ship_limitation_string)
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
				"limit_ships", "prevent_ships", "override_subtractive", "override_additive":
					string = format_for_arrays(string, tag, content)
				"add_vanilla_equipment":
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
	if equipment_node.get("system","") in vanilla_data.min_version:
		var data = vanilla_data.min_version.get(equipment_node.system)
		var failtext = "Equipment %s not adding due to old game version. Needed min version: %s ; observed game version: %s" % [str(equipment_node.get("system","")), str(data), str(version)]
		if data[0] < version[0]:
			pass
		elif data[0] == version[0]:
			if data[1] < version[1]:
				pass
			elif data[1] == version[1]:
				if data[2] <= version[2]:
					pass
				else:
					Debug.l(failtext)
					return false
			else:
				Debug.l(failtext)
				return false
		else:
			Debug.l(failtext)
			return false
		
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
