extends VBoxContainer

var Equipment = preload("res://HevLib/pointers/Equipment.gd")

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

var slots = ModLoader.get_children()

var vanilla_equipment = load("res://HevLib/scenes/equipment/vanilla_defaults/equipment.gd").get_script_constant_map()

func _tree_entered():
	var has = Settings.HevLib["equipment"]["do_sort_equipment_by_price"]
	var does = 1 if has else 0
	get_tags()
	add_slots()
	add_slot_tags()
	add_equipment()
	if has:
		sort_slots()

func get_tags():
	for slot in slots:
		var data = slot.get_property_list()
		var nodes = []
		for item in data:
			if item.get("name") == "EQUIPMENT_TAGS":
				nodes.append(slot.get("EQUIPMENT_TAGS"))
		if not nodes == []:
#			var check = is_current_mod_cached(slot, "EQUIPMENT_TAGS", nodes)
			
			
			for tag in nodes:
				var slotTypes = tag.get("slot_types",[])
				var equipmentItems = tag.get("equipment_types",[])
				var align = tag.get("alignments",[])
				var hardpointTypes = tag.get("hardpoint_types",[])
				var slotDefaults = tag.get("slot_defaults",{})
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

func add_slots():
	for slot in slots:
		var data = slot.get_property_list()
		var newSlot = null
		for item in data:
			if item.get("name") == "ADD_EQUIPMENT_SLOTS":
				newSlot = slot.get("ADD_EQUIPMENT_SLOTS")
		if typeof(newSlot) == TYPE_ARRAY:
			for spt in newSlot:
				add_child(spt)

var slot_dictionary_temps = {}

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
	for slot in slots:
		var data = slot.get_property_list()
		var nodes = null
		for item in data:
			if item.get("name") == "SLOT_TAGS":
				nodes = slot.get("SLOT_TAGS")
		if not nodes == null:
			if nodes.keys().size() >= 1:
				slot_dictionary_temps.merge({slot.name.hash():nodes})
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
	for item in display_slots():
		var current_default_equipment := []
		if item.slot_type == "HARDPOINT":
			var hardpoint = item.hardpoint_type
			var items = slot_defaults.get(hardpoint,[])
			item.allowed_equipment.append_array(items)
		else:
			var items = slot_defaults.get(item.slot_type,[])
			item.allowed_equipment.append_array(items)
		for add in item.override_additive:
			if add in item.allowed_equipment:
				pass
			else:
				item.allowed_equipment.append(add)
		var current = item.allowed_equipment
		var rewrite = []
		for it in current:
			if it in item.override_subtractive:
				pass
			else:
				rewrite.append(it)
		item.allowed_equipment = rewrite
		
		if item.add_vanilla_equipment:
			for v_equipment in vanilla_equipment:
				var V2 = Equipment.__make_equipment(vanilla_equipment.get(v_equipment))
				var does = confirm_equipment(V2, item.slot_type, item.alignment, item.restriction, item.allowed_equipment)
				if does:
					item.get_node("VBoxContainer").add_child(V2)

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
	

func add_equipment():
	var equipments = []
	for slot in slots:
		var data = slot.get_property_list()
		var newSlot = null
		for item in data:
			if item.get("name") == "ADD_EQUIPMENT_ITEMS":
				newSlot = slot.get("ADD_EQUIPMENT_ITEMS")
		if not newSlot == null and newSlot.size() >= 1:
			for equip in newSlot:
				equipments.append(equip)
	for item in display_slots():
		for equip in equipments:
				var V2 = equip.duplicate()
				var does = confirm_equipment(V2, item.slot_type, item.alignment, item.restriction, item.allowed_equipment)
				if does:
					item.get_node("VBoxContainer").add_child(V2)
				else:
					V2.queue_free()

func sort_slots():
	var SLOTS = display_slots()
	for slot in SLOTS:
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
	var mod_cache_file = "user://cache/.HevLib_Cache/Equipment_Driver/" + str(path_hash) + "/" + tag_type
	var mod_cache_folder = "user://cache/.HevLib_Cache/Equipment_Driver/" + str(path_hash) + "/"
	var file = File.new()
	file.open(mod_cache_file, File.READ)
	var current_file_hash = file.get_as_text().hash()
	file.close()
	if current_file_hash == tags_hash:
		return true
	else:
		return false
