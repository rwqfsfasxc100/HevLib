extends VBoxContainer

# Stating HevLib pointers
var Equipment = preload("res://HevLib/pointers/Equipment.gd")
var FolderAccess = preload("res://HevLib/pointers/FolderAccess.gd")
var DataFormat = preload("res://HevLib/pointers/DataFormat.gd")

var cache_folder = "user://cache/.HevLib_Cache/Equipment_Driver/"

var NEW_INSTALL = false

var hardpoint_types = [
	# Hardpoint slots
	"HARDPOINT_LOW_STRESS", # - Any low-stress hardpoint
	"HARDPOINT_HIGH_STRESS", # - Any high-stress hardpoint
	"HARDPOINT_SPINAL", # - Any spinal hardpoint
	"HARDPOINT_DOCKING_BAY", # - A docking-bay type hardpoint
	"HARDPOINT_DRONE_POINT", # - A drone hardpoint
]
var alignments = [
	# Equipment alignment
	"ALIGNMENT_LEFT", # - Any left hardpoint
	"ALIGNMENT_RIGHT", # - Any right hardpoint
	"ALIGNMENT_CENTER", # - Any central hardpoint
]

var equipment_types = [
	# Cradled equipment
	"EQUIPMENT_CARGO_CONTAINER",
	"EQUIPMENT_MINING_COMPANION",
	"EQUIPMENT_IMPACT_ABSORBER",
	"EQUIPMENT_BEACON",

	# Weapon tools
	"EQUIPMENT_PLASMA_THROWERS",
	"EQUIPMENT_PLASMA_THROWERS_HEAVY",
	"EQUIPMENT_MANIPULATION_ARMS",
	"EQUIPMENT_MASS_DRIVERS",
	"EQUIPMENT_TURRETS",
	"EQUIPMENT_NANODRONES",
	"EQUIPMENT_IRON_THROWERS",
	"EQUIPMENT_MINING_LASERS",
	"EQUIPMENT_MICROWAVES",
	"EQUIPMENT_SYNCHROTRONS",
	
	# Non-hardpoint equipment
	"CONSUMABLE_MASS_DRIVER_AMMUNITION",
	"CONSUMABLE_NANODRONES",
	"CONSUMABLE_PROPELLANT",
	"THRUSTER_STANDARD_REACTION_CONTROL_THRUSTERS",
	"THRUSTER_STANDARD_MAIN_ENGINE",
	"POWER_FISSION_RODS",
	"POWER_ULTRACAPACITOR",
	"POWER_FISSION_TURBINE",
	"POWER_AUX_POWER_SLOT",
	"CARGO_BAY",
	"COMPUTER_AUTOPILOT",
	"COMPUTER_HUD",
	"SENSOR_LIDAR",
	"SENSOR_RECON_DRONE",
]
var slot_types = [
# Slot type tags
	"HARDPOINT",
	"MASS_DRIVER_AMMUNITION",
	"NANODRONE_STORAGE",
	"PROPELLANT_TANK",
	"STANDARD_REACTION_CONTROL_THRUSTERS",
	"STANDARD_MAIN_ENGINE",
	"FISSION_RODS",
	"ULTRACAPACITOR",
	"FISSION_TURBINE",
	"AUX_POWER_SLOT",
	"CARGO_BAY",
	"AUTOPILOT",
	"HUD",
	"LIDAR",
	"RECON_DRONE",
]

var slot_defaults = {
	"HARDPOINT_LOW_STRESS":["EQUIPMENT_MASS_DRIVERS","EQUIPMENT_TURRETS","EQUIPMENT_NANODRONES","EQUIPMENT_IRON_THROWERS","EQUIPMENT_MINING_LASERS","EQUIPMENT_MICROWAVES","EQUIPMENT_SYNCHROTRONS","EQUIPMENT_CARGO_CONTAINER","EQUIPMENT_MINING_COMPANION","EQUIPMENT_IMPACT_ABSORBER","EQUIPMENT_BEACON"],
	"HARDPOINT_HIGH_STRESS":["EQUIPMENT_MASS_DRIVERS","EQUIPMENT_PLASMA_THROWERS","EQUIPMENT_PLASMA_THROWERS_HEAVY","EQUIPMENT_MANIPULATION_ARMS","EQUIPMENT_TURRETS","EQUIPMENT_NANODRONES","EQUIPMENT_IRON_THROWERS","EQUIPMENT_MINING_LASERS","EQUIPMENT_MICROWAVES"],
	"HARDPOINT_SPINAL":["EQUIPMENT_MASS_DRIVERS","EQUIPMENT_PLASMA_THROWERS","EQUIPMENT_TURRETS","EQUIPMENT_NANODRONES","EQUIPMENT_IRON_THROWERS","EQUIPMENT_MINING_LASERS","EQUIPMENT_MICROWAVES"],
	"HARDPOINT_DOCKING_BAY":["EQUIPMENT_CARGO_CONTAINER","EQUIPMENT_MINING_COMPANION","EQUIPMENT_TURRETS","EQUIPMENT_NANODRONES"],
	"HARDPOINT_DRONE_POINT":["EQUIPMENT_NANODRONES"],
	"MASS_DRIVER_AMMUNITION":["CONSUMABLE_MASS_DRIVER_AMMUNITION"],
	"NANODRONE_STORAGE":["CONSUMABLE_NANODRONES"],
	"PROPELLANT_TANK":["CONSUMABLE_PROPELLANT"],
	"STANDARD_REACTION_CONTROL_THRUSTERS":["THRUSTER_STANDARD_REACTION_CONTROL_THRUSTERS"],
	"STANDARD_MAIN_ENGINE":["THRUSTER_STANDARD_MAIN_ENGINE"],
	"FISSION_RODS":["POWER_FISSION_RODS"],
	"ULTRACAPACITOR":["POWER_ULTRACAPACITOR"],
	"FISSION_TURBINE":["POWER_FISSION_TURBINE"],
	"AUX_POWER_SLOT":["POWER_AUX_POWER_SLOT"],
	"CARGO_BAY":["CARGO_BAY"],
	"AUTOPILOT":["COMPUTER_AUTOPILOT"],
	"HUD":["COMPUTER_HUD"],
	"LIDAR":["SENSOR_LIDAR"],
	"RECON_DRONE":["SENSOR_RECON_DRONE"],
}

# Slot defaults for vanilla equipment
# This is formatted exactly like how it is done in a mod main, so can be used as reference

const vanilla_equipment_defaults_for_reference = {
	"MainWeaponSlot":{"slot_type":"HARDPOINT","hardpoint_type":"HARDPOINT_HIGH_STRESS","alignment":"ALIGNMENT_CENTER"},
	"MainLowWeaponSlot":{"slot_type":"HARDPOINT","hardpoint_type":"HARDPOINT_SPINAL","alignment":"ALIGNMENT_CENTER"},
	"LeftHighStress":{"slot_type":"HARDPOINT","hardpoint_type":"HARDPOINT_HIGH_STRESS","alignment":"ALIGNMENT_LEFT"},
	"RightHighStress":{"slot_type":"HARDPOINT","hardpoint_type":"HARDPOINT_HIGH_STRESS","alignment":"ALIGNMENT_RIGHT"},
	"LeftWeaponSlot":{"slot_type":"HARDPOINT","hardpoint_type":"HARDPOINT_LOW_STRESS","alignment":"ALIGNMENT_LEFT"},
	"MiddleLeftWeaponSlot":{"slot_type":"HARDPOINT","hardpoint_type":"HARDPOINT_LOW_STRESS","alignment":"ALIGNMENT_LEFT","override_subtractive":["EQUIPMENT_BEACON","EQUIPMENT_CARGO_CONTAINER","EQUIPMENT_MINING_COMPANION","EQUIPMENT_IMPACT_ABSORBER"]},
	"RightWeaponSlot":{"slot_type":"HARDPOINT","hardpoint_type":"HARDPOINT_LOW_STRESS","alignment":"ALIGNMENT_RIGHT"},
	"MiddleRightWeaponSlot":{"slot_type":"HARDPOINT","hardpoint_type":"HARDPOINT_LOW_STRESS","alignment":"ALIGNMENT_RIGHT","override_subtractive":["EQUIPMENT_BEACON","EQUIPMENT_CARGO_CONTAINER","EQUIPMENT_MINING_COMPANION","EQUIPMENT_IMPACT_ABSORBER"]},
	"LeftDroneSlot":{"slot_type":"HARDPOINT","hardpoint_type":"HARDPOINT_DRONE_POINT","alignment":"ALIGNMENT_LEFT"},
	"RightDroneSlot":{"slot_type":"HARDPOINT","hardpoint_type":"HARDPOINT_DRONE_POINT","alignment":"ALIGNMENT_RIGHT"},
	"LeftRearSlot":{"slot_type":"HARDPOINT","hardpoint_type":"HARDPOINT_LOW_STRESS","alignment":"ALIGNMENT_LEFT","override_subtractive":["EQUIPMENT_MASS_DRIVERS","EQUIPMENT_IRON_THROWERS","EQUIPMENT_MINING_LASERS","EQUIPMENT_MICROWAVES","EQUIPMENT_SYNCHROTRONS","EQUIPMENT_BEACON"]},
	"RightRearSlot":{"slot_type":"HARDPOINT","hardpoint_type":"HARDPOINT_LOW_STRESS","alignment":"ALIGNMENT_RIGHT","override_subtractive":["EQUIPMENT_MASS_DRIVERS","EQUIPMENT_IRON_THROWERS","EQUIPMENT_MINING_LASERS","EQUIPMENT_MICROWAVES","EQUIPMENT_SYNCHROTRONS","EQUIPMENT_BEACON"]},
	"LeftBay1":{"slot_type":"HARDPOINT","hardpoint_type":"HARDPOINT_DOCKING_BAY","alignment":"ALIGNMENT_LEFT","override_additive":["EQUIPMENT_BEACON"]},
	"RightBay1":{"slot_type":"HARDPOINT","hardpoint_type":"HARDPOINT_DOCKING_BAY","alignment":"ALIGNMENT_RIGHT","override_additive":["EQUIPMENT_BEACON"]},
	"LeftBay2":{"slot_type":"HARDPOINT","hardpoint_type":"HARDPOINT_DOCKING_BAY","alignment":"ALIGNMENT_LEFT"},
	"RightBay2":{"slot_type":"HARDPOINT","hardpoint_type":"HARDPOINT_DOCKING_BAY","alignment":"ALIGNMENT_RIGHT"},
	"LeftBay3":{"slot_type":"HARDPOINT","hardpoint_type":"HARDPOINT_DOCKING_BAY","alignment":"ALIGNMENT_LEFT"},
	"RightBay3":{"slot_type":"HARDPOINT","hardpoint_type":"HARDPOINT_DOCKING_BAY","alignment":"ALIGNMENT_RIGHT"},
	"AmmunitionDelivery":{"slot_type":"MASS_DRIVER_AMMUNITION"},
	"DisposableDrones":{"slot_type":"NANODRONE_STORAGE"},
	"Propellant":{"slot_type":"PROPELLANT_TANK"},
	"Thrusters":{"slot_type":"STANDARD_REACTION_CONTROL_THRUSTERS"},
	"Torches":{"slot_type":"STANDARD_MAIN_ENGINE"},
	"Rods":{"slot_type":"FISSION_RODS"},
	"Capacitor":{"slot_type":"ULTRACAPACITOR"},
	"Turbine":{"slot_type":"FISSION_TURBINE"},
	"AuxilaryPower":{"slot_type":"AUX_POWER_SLOT"},
	"CargoBay":{"slot_type":"CARGO_BAY"},
	"Autopilot":{"slot_type":"AUTOPILOT"},
	"Hud":{"slot_type":"HUD"},
	"Lidar":{"slot_type":"LIDAR"},
	"ReconDrone":{"slot_type":"RECON_DRONE"},
}



# Actual code started

var slots := []

var vanilla_equipment = load("res://HevLib/scenes/equipment/vanilla_defaults/equipment.gd").get_script_constant_map()

var has = false

func _tree_entered():
	var sTime = OS.get_system_time_msecs()
	l("Started checking and modifying equipment")
	var CRoot = get_tree().get_root().get_node("EquipmentDriver")
	slots = CRoot.conv
	var paths = CRoot.paths
	l("Finished scanning mods. %s mods are using HevLib Equipment Driver." % slots.size())
	var installed_hash = str(str(paths).hash() + str(load("res://HevLib/ModMain.gd").MOD_VERSION_MAJOR).hash() + str(load("res://HevLib/ModMain.gd").MOD_VERSION_MINOR).hash() + str(load("res://HevLib/ModMain.gd").MOD_VERSION_BUGFIX).hash() + str(load("res://HevLib/ModMain.gd").MOD_VERSION_METADATA).hash())
	var ddFile = cache_folder + "driver_index"
	var dir = Directory.new()
	dir.open(cache_folder)
	var de2 = dir.file_exists(ddFile)
	if not de2:
		var f03 = File.new()
		f03.open(ddFile,File.WRITE)
		f03.store_string("")
		f03.close()
	var hFile = File.new()
	hFile.open(ddFile, File.READ)
	var hData = hFile.get_as_text()
	hFile.close()
	var de = DataFormat.__compare_with_byte_array(installed_hash, str(hData))
	if not de:
		NEW_INSTALL = !de
		FolderAccess.__recursive_delete(cache_folder)
		FolderAccess.__check_folder_exists(cache_folder)
		l("Attempting to clear EquipmentDriver cache. Check later logs for success from other processes")
	l("Handled cache, starting to operate on mods.")
#func start_processing():
	has = Settings.HevLib["equipment"]["do_sort_equipment_by_price"]
	var does = 1 if has else 0
	l("Starting to operate on mod data. Will slots be sorted? [%s]" % has)
	get_tags()
	add_slots()
	add_slot_tags()
	add_equipment()
	var finish_time = OS.get_system_time_msecs()
	var total_time = str(float(finish_time - sTime)/1000)
	var spl = total_time.split(".")
	var secs = str(spl[0])
	var msecs = str(spl[1])
	while msecs.begins_with("0"):
		msecs = msecs.substr(1)
	l("Finished adding equipment. Process took a total time of %s seconds, %s milliseconds" % [secs,msecs])
	var f2 = File.new()
	f2.open(ddFile, File.WRITE)
	f2.store_string(installed_hash)
	f2.close()
#	call_deferred("repack",get_parent().get_parent().get_parent().get_parent().get_parent(), "user://cache/.HevLib_Cache/Test.tscn")
#	var node = get_parent().get_parent().get_parent().get_parent().get_parent()
#	for main in ModLoader.get_children():
#		var packs = main.get_property_list()
#		for item in packs:
#			var nname = item.get("name")
#			if nname == "HevLibModMain":
#				if main.HevLibModMain:
#					main.repack(node)
func get_tags():
	for its in slots:
		var nodes = its[0].get("EQUIPMENT_TAGS",{})
		if nodes.keys().size() >= 1:
#			var check = is_current_mod_cached(slot, "EQUIPMENT_TAGS", nodes)
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
var slots_that_need_vanilla_validation := []
var slots_with_cache := []

func add_slots():
	for its in slots:
		var newSlot = its[0].get("ADD_EQUIPMENT_SLOTS",[])
		var mod_hash = str(its[2])
		if newSlot.size() >= 1:
			l("Adding slots for %s" % mod_hash)
			for slotDict in newSlot:
				var spt = Equipment.__make_slot(slotDict)
				var slot_name = spt.name
				var slot_folder = cache_folder + mod_hash + "/ADD_EQUIPMENT_SLOTS/" + slot_name + "/"
				var ddFile = slot_folder + "data_dictionary"
				FolderAccess.__check_folder_exists(slot_folder)
				var dir = Directory.new()
				dir.open(slot_folder)
				var does = dir.file_exists(ddFile)
				if not does:
					var f2 = File.new()
					f2.open(ddFile, File.WRITE)
					f2.store_string("")
					f2.close()
				var file = File.new()
				file.open(ddFile, File.READ_WRITE)
				var slot_file_data = file.get_as_text()
				file.close()
				var slot_data_dictionary = str(spt.data_dictionary)
				var comp = DataFormat.__compare_with_byte_array(slot_data_dictionary, slot_file_data)
				if comp and not NEW_INSTALL:
					slots_with_cache.append(mod_hash + ":" + slot_name)
					add_child(spt)
					l("Added slot %s from cache." % slot_name)
				else:
					var file2 = File.new()
					file2.open(ddFile, File.WRITE)
					file2.store_string(slot_data_dictionary)
					file2.close()
					slots_that_need_vanilla_validation.append(mod_hash + ":" + slot_name)
					add_child(spt)
					l("Added slot %s without cache, will process and recache during equipment process" % slot_name)

var slot_dictionary_temps = {}

var validated_equipment = {}
var unvalidated_equipment = {}

func add_equipment():
	
	for slot in display_slots():
		var slot_name = slot.name
		l("Working on slot %s" % slot_name)
		l("Adding tags to slot")
		var current_default_equipment := []
		if slot.slot_type == "HARDPOINT":
			var hardpoint = slot.hardpoint_type
			var items = slot_defaults.get(hardpoint,[])
			slot.allowed_equipment.append_array(items)
		else:
			var items = slot_defaults.get(slot.slot_type,[])
			slot.allowed_equipment.append_array(items)
		for add in slot.override_additive:
			if add in slot.allowed_equipment:
				pass
			else:
				slot.allowed_equipment.append(add)
		var current = slot.allowed_equipment
		var rewrite = []
		for it in current:
			if it in slot.override_subtractive:
				pass
			else:
				rewrite.append(it)
		slot.allowed_equipment = rewrite
	
	
	for its in slots:
		var newSlot = its[0].get("ADD_EQUIPMENT_ITEMS",[])
		var mod_hash = str(its[2])
		if newSlot.size() >= 1:
			l("Adding equipment for %s" % mod_hash)
			for equip in newSlot:
				
				var slot_name = equip.get("system","OOPS! MISSING SYSTEM NAME!")
				var slot_folder = cache_folder + mod_hash + "/ADD_EQUIPMENT_ITEMS/" + slot_name + "/"
				FolderAccess.__check_folder_exists(slot_folder)
				var ddFile = slot_folder + "data_dictionary"
				var dir = Directory.new()
				dir.open(slot_folder)
				var does = dir.file_exists(ddFile)
				if not does:
					var f2 = File.new()
					f2.open(ddFile, File.WRITE)
					f2.store_string("")
					f2.close()
				var file = File.new()
				file.open(ddFile, File.READ)
				var slot_file_data = file.get_as_text()
				file.close()
				var slot_data_dictionary = str(equip)
				var comp = DataFormat.__compare_with_byte_array(str(slot_data_dictionary), str(slot_file_data))
				if comp and not NEW_INSTALL:
					var slot_appendages = []
					var indexFile = slot_folder + "index"
					var d = Directory.new()
					d.open(slot_folder)
					var dd = d.file_exists(indexFile)
					if not dd:
						var fs = File.new()
						fs.open(indexFile, File.WRITE)
						fs.store_string("")
						fs.close()
					var f = File.new()
					f.open(indexFile, File.READ)
					var index_data = f.get_as_text()
					f.close()
					var index = index_data.split("\n")
					validated_equipment.merge({slot_name:[equip,index]})
					l("Equipment %s is already cached, appending to cached equipment process list" % slot_name)
				else:
					var f = File.new()
					f.open(slot_folder + "data_dictionary", File.WRITE)
					f.store_string(str(slot_data_dictionary))
					f.close()
					unvalidated_equipment.merge({slot_name:[equip,slot_folder]})
					l("Equipment %s is not cached, appending to caching process list" % slot_name)
				
	
	
	
	for slot in slots_that_need_vanilla_validation:
		var slot_mod = slot.split(":")
		var mod = slot_mod[0]
		var item = get_node(slot_mod[1])
		var vanilla_store = cache_folder + mod + "/ADD_EQUIPMENT_SLOTS/" + slot_mod[1] + "/vanilla_slots/"
		l("Adding vanilla equipment to uncached slot %s from mod %s" % [slot_mod[1],mod])
		FolderAccess.__check_folder_exists(vanilla_store)
		for v_equipment in vanilla_equipment:
			var V2 = Equipment.__make_equipment(vanilla_equipment.get(v_equipment))
			var does = confirm_equipment(V2, item.slot_type, item.alignment, item.restriction, item.allowed_equipment)
			if does:
				repack(V2,vanilla_store + v_equipment + ".tscn")
				item.get_node("VBoxContainer").add_child(V2)
				l("Vanilla equipment %s is applicable, adding & caching" % v_equipment)
			else:
				l("%s was not applicable, skipping" % v_equipment)
	
	
	
	
	for slot in slots_with_cache:
		var slot_mod = slot.split(":")
		var mod = slot_mod[0]
		var item = get_node(slot_mod[1])
		l("Adding vanilla equipment from slot cache of %s from mod %s" % [slot_mod[1],mod])
		var vanilla_store = cache_folder + mod + "/ADD_EQUIPMENT_SLOTS/" + slot_mod[1] + "/vanilla_slots/"
		var files = FolderAccess.__fetch_folder_files(vanilla_store, false, true)
		for file in files:
			item.get_node("VBoxContainer").add_child(load(file).instance())
	
	
	
	for slot in display_slots():
		var slot_name = slot.name
		
		
		var num_of_equipment_added_total = 0
		var num_of_cached_equipment = 0
		var num_of_uncached_equipment = 0
		l("Adding equipment from cache")
		for equip in validated_equipment:
			var data = validated_equipment.get(equip)
			if slot_name in data[1]:
				slot.get_node("VBoxContainer").add_child(Equipment.__make_equipment(data[0]))
				num_of_cached_equipment += 1
				num_of_equipment_added_total += 1
				
		
		l("Adding non-cached equipment")
		for equip in unvalidated_equipment:
			var data = unvalidated_equipment.get(equip)
			var V2 = Equipment.__make_equipment(data[0])
			var does = confirm_equipment(V2, slot.slot_type, slot.alignment, slot.restriction, slot.allowed_equipment)
			if does:
				var folder = data[1]
				var ddFile = folder + "index"
				var dir = Directory.new()
				dir.open(folder)
				var do = dir.file_exists(ddFile)
				if not do:
					var f2 = File.new()
					f2.open(ddFile,File.WRITE)
					f2.store_string("")
					f2.close()
				var f = File.new()
				f.open(ddFile, File.READ_WRITE)
				var sData = f.get_as_text()
				var returnData = sData + "\n" + slot_name
				f.store_string(returnData)
				f.close()
				slot.get_node("VBoxContainer").add_child(V2)
#				l("Added %s to slot %s and adding to cache" % [V2.name, slot_name])
				num_of_equipment_added_total += 1
				num_of_uncached_equipment += 1
			else:
#				l("%s denied from slot %s" % [V2.name, slot_name])
				V2.queue_free()
		l("Added %s equipment items to slot %s. [%s from cache, %s added to cache]" % [num_of_equipment_added_total, slot_name, num_of_cached_equipment, num_of_uncached_equipment])
		
#		for equip in equipments:
#				var V2 = equip.duplicate()
#				var does = confirm_equipment(V2, slot.slot_type, slot.alignment, slot.restriction, slot.allowed_equipment)
#				if does:
#					slot.get_node("VBoxContainer").add_child(V2)
#				else:
#					V2.queue_free()
		
		
		
		if has:
			l("Sorting equipment for slot %s" % slot_name)
			var items = slot.get_node("VBoxContainer").get_children()
			var nodePositions = []
			for item in items:
				nodePositions.append([item, item.get_index()])
			var noFail = false
			var maxIndex = items.size()
			while noFail == false:
				var doesFailThisLoop = false
				for item in slot.get_child(0).get_children():
					if item.get_index() < 2:
						pass
					else:
						var A = item
						var B = A.get_parent().get_child(A.get_index() - 1)
						if A.price < B.price:
							doesFailThisLoop = true
							A.get_parent().move_child(A, B.get_index())
				if doesFailThisLoop:
					noFail = false
				else:
					noFail = true

func add_slot_tags():
	var slot_tag_pool = {}
	for item in vanilla_equipment_defaults_for_reference:
		var data = vanilla_equipment_defaults_for_reference.get(item)
		for tag in data:
			var content = data.get(tag)
			match tag:
				"limit_ships":
					get_node(item).limit_ships = content
				"invert_limit_logic":
					get_node(item).invert_limit_logic = content
				"add_vanilla_equipment":
					get_node(item).add_vanilla_equipment = content
				"slot_type":
					get_node(item).slot_type = content
				"hardpoint_type":
					get_node(item).hardpoint_type = content
				"alignment":
					get_node(item).alignment = content
				"restriction":
					get_node(item).restriction = content
				"override_additive":
					get_node(item).override_additive = content
				"override_subtractive":
					get_node(item).override_subtractive = content
	for its in slots:
		var nodes = its[0].get("SLOT_TAGS",{})
		if nodes.keys().size() >= 1:
			slot_dictionary_temps.merge({its[3].hash():nodes})
	var master_slot_record = {}
	for node in slot_dictionary_temps:
		var nodes = slot_dictionary_temps.get(node)
		var tags = slot_dictionary_temps.get(node)
		for tag in tags:
			var ptag = nodes.get(tag)
			var limit_ships = ptag.get("limit_ships",[])
			var invert_limit_logic = ptag.get("invert_limit_logic",false)
			var add_vanilla_equipment = ptag.get("add_vanilla_equipment",false)
			var slot_type = ptag.get("slot_type","")
			var hardpoint_type = ptag.get("hardpoint_type","")
			var alignment = ptag.get("alignment","")
			var restriction = ptag.get("restriction","")
			var override_additive = ptag.get("override_additive",[])
			var override_subtractive = ptag.get("override_subtractive",[])
			
			var slot_node = get_node_or_null(tag)
			if slot_node:
				var slot_limit_ships = slot_node.limit_ships
				var slot_invert_limit_logic = slot_node.invert_limit_logic
				var slot_add_vanilla_equipment = slot_node.add_vanilla_equipment
				var slot_slot_type = slot_node.slot_type
				var slot_hardpoint_type = slot_node.hardpoint_type
				var slot_alignment = slot_node.alignment
				var slot_restriction = slot_node.restriction
				var slot_override_additive = slot_node.override_additive
				var slot_override_subtractive = slot_node.override_subtractive
				if slot_limit_ships == []:
					slot_node.limit_ships = limit_ships
					slot_node.invert_limit_logic = invert_limit_logic
				if slot_add_vanilla_equipment:
					slot_node.add_vanilla_equipment = add_vanilla_equipment
				if slot_slot_type == "":
					slot_node.slot_type = slot_type
				if slot_hardpoint_type == "":
					slot_node.hardpoint_type = hardpoint_type
				if slot_alignment == "":
					slot_node.alignment = alignment
				if slot_restriction == "":
					slot_node.restriction = restriction
				for over in override_additive:
					if over in slot_override_additive:
						pass
					else:
						slot_node.override_additive.append(over)
				for over in override_subtractive:
					if over in slot_override_subtractive:
						pass
					else:
						slot_node.override_subtractive.append(over)

func display_slots() -> Array:
	var children = self.get_children()
	var list = []
	for child in children:
		if child.get_parent() == self:
			list.append(child)
	return list

func is_current_mod_cached(mod_node: Node, tag_type: String, data) -> bool:
	var path = mod_node.get_script().get_path()
	var path_hash = path.hash()
	var tags_text = str(data)
	var tags_hash = tags_text.hash()
	var mod_cache_file = cache_folder + str(path_hash) + "/" + tag_type
	var mod_cache_folder = cache_folder + str(path_hash) + "/"
	var file = File.new()
	file.open(mod_cache_file, File.READ)
	var current_file_hash = file.get_as_text().hash()
	file.close()
	if current_file_hash == tags_hash:
		return true
	else:
		return false

func confirm_equipment(equipment_node, slot_type, slot_alignment, slot_restriction, slot_allowed_equipment) -> bool:
	var e_slot_type = equipment_node.slot_type
	var e_equipment = equipment_node.equipment_type
	var e_alignment = equipment_node.alignment
	var e_restriction = equipment_node.restriction
	
	if e_slot_type == slot_type:
		var passes_slot_check = false
		if e_equipment in slot_allowed_equipment:
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
	

func repack(node, save_path):
	var save = PackedScene.new()
	var NodeAccess = preload("res://HevLib/pointers/NodeAccess.gd").new()
	NodeAccess.__claim_child_ownership(node)
	save.pack(node)
	var save_folder = save_path.split(save_path.split("/")[save_path.split("/").size() - 1])[0]
	FolderAccess.__check_folder_exists(save_folder)
	ResourceSaver.save(save_path, save)

var MODULE_IDENTIFIER = "Equipment Driver"
func l(msg:String, ID:String = MODULE_IDENTIFIER, title:String = "HevLib"):
	Debug.l("[%s %s]: %s" % [title, ID, msg])
