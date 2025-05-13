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

func _tree_entered():
	get_tags()
	add_slots()
	add_slot_tags()
#	add_equipment()
	if Settings.HevLib["equipment"]["do_sort_equipment_by_price"]:
		sort_slots()

func get_tags():
	for slot in slots:
		var data = slot.get_property_list()
		var nodes = []
		for item in data:
			if item.get("name") == "EQUIPMENT_TAGS":
				nodes.append(slot.get("EQUIPMENT_TAGS"))
		if not nodes == []:
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
	slot_dictionary_temps.merge({"EquipmentManager.gd":vanilla_equipment_defaults_for_reference})
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
#	for node in slot_dictionary_temps:
#		var nodes = slot_dictionary_temps.get(node)
#		var tags = slot_dictionary_temps.get(node)
#		for tag in tags:
#			var ptag = nodes.get(tag)
#			var slot_dictionary = sort_equipment_assignment(tag, ptag)
#			if slot_dictionary.keys().size() >= 1:
#				for try in slot_dictionary:
#					if try in master_slot_record:
#						var msrInstance = master_slot_record.get(try)
#						var msrEquipment = msrInstance.get("equipment",[])
#						var slot_dictionary_equipment = slot_dictionary.get(try).get("equipment",[])
#						if msrEquipment.size() >= 1 and slot_dictionary_equipment.size() >= 1:
#							for quip in slot_dictionary_equipment:
#								if quip in msrEquipment:
#									pass
#								else:
#									master_slot_record[try]["equipment"].append(quip)
#						elif msrEquipment.size() == 0 and slot_dictionary_equipment.size() >= 1:
#							master_slot_record[try]["equipment"] = slot_dictionary_equipment
#
#					else:
#						master_slot_record.merge({try:slot_dictionary.get(try)})
#				slot_tag_pool.merge(slot_dictionary)
#	for slot in slot_tag_pool:
#		var select = get_node(slot)
#		var dta = slot_tag_pool.get(slot)
#		select.slotGroups = dta
#		if select.needsVanillaEquipment:
#			var vanilla = Equipment.__add_vanilla_equipment(select.slotGroups, hardpoint_types, alignments, equipment_types, slot_types, hardpoint_defaults)
#			for item in vanilla:
#				add_equipment_to_slot(slot, item)
#			select.needsVanillaEquipment = false


#func add_equipment():
#	var equipment_slots = {}
#	var child_slots = get_children()
#	for child in child_slots:
#		var cname = child.name
#		var groups = child.slotGroups
#		var dic = {cname:groups}
#		equipment_slots.merge(dic)
#	for slot in slots:
#		var data = slot.get_property_list()
#		var newSlot = null
#		for item in data:
#			if item.get("name") == "ADD_EQUIPMENT_ITEMS":
#				newSlot = slot.get("ADD_EQUIPMENT_ITEMS")
#		if not newSlot == null and newSlot.size() >= 1:
#			for equip in newSlot:
#				var equipment = equip.get("equipment")
#				var confirmed = equip.get("slots",[])
#				var cnfmtp = typeof(confirmed)
#				if cnfmtp == TYPE_ARRAY:
#					pass
#				elif cnfmtp == TYPE_STRING:
#					confirmed = [confirmed]
#				else:
#					confirmed = []
#				var groups = equip.get("slot_groups",{})
#				var desired_slot_type = groups.get("slot_type", "")
#				var alignment = groups.get("alignment", "")
#				var tags = groups.get("tags", "")
#				if groups.keys().size() > 0:
#					for sect in get_children():
#						var sectName = sect.name
#						var sectTags = sect.slotGroups
#						var type = sectTags.get("type","")
#						if type == desired_slot_type and not desired_slot_type == "":
#							var does = check_equipment_validity(equip, sect, type)
#							if does:
#								confirmed.append(sectName)
#								Debug.l("Slot %s allowed the addition of %s" % [sectName, equipment.get("system","!!OOPS, someone forgot to provide a SYSTEM value to their equipment!! How was this allowed to be added??")])
#							else:
#								Debug.l("Slot %s did not permit the addition of %s" % [sectName, equipment.get("system","anything, actually. Someone forgot to provide a SYSTEM value to their equipment, and they wonder why it's not being added!! :P")])
#				for panel in confirmed:
#					add_equipment_to_slot(panel, equipment)

#func check_equipment_validity(raw_equipment_data, raw_slot_node, type):
#	var does_pass_check = false
#
#	var slot_groups = raw_slot_node.slotGroups.duplicate()
#	var equipment_groups = raw_equipment_data.get("slot_groups").duplicate()
#
#	if type == "HARDPOINT":
#		var passes_equipment_check = true
#		var slot_allowed_equipment = slot_groups.get("equipment",[])
#		var equipment_tag = equipment_groups.get("tags","")
#		if equipment_tag in slot_allowed_equipment:
#			pass
#		else:
#			passes_equipment_check = false
#		if passes_equipment_check:
#			var passes_alignment_check = true
#			var slot_alignment = slot_groups.get("alignment","")
#			var equipment_alignment = equipment_groups.get("alignment","")
#			if slot_alignment in alignments and equipment_alignment in alignments:
#				if slot_alignment == equipment_alignment:
#					pass
#				else:
#					passes_alignment_check = false
#			if passes_alignment_check:
#				does_pass_check = true
#			else:
#				return false
#	else:
#		does_pass_check = true
#	if does_pass_check:
#		var does_pass_restriction = true
#		var equipment_restriction = equipment_groups.get("restriction","")
#		var slot_restriction = slot_groups.get("restriction","")
#		if not equipment_restriction == "":
#			if equipment_restriction == slot_restriction:
#				does_pass_restriction = true
#			else:
#				does_pass_restriction = false
#		if does_pass_restriction:
#			return true
#		else:
#			return false
#	else:
#		return false


#func add_equipment_to_slot(panel: String, equipment: Dictionary):
#	var parent = get_node(panel).get_node("VBoxContainer")
#	var itemTemplate = itemSlot.instance()
#	itemTemplate.slot = get_node(panel).slotGroups.get("system_slot", "")
#	itemTemplate.numVal = equipment.get("num_val", -1)
#	itemTemplate.system = equipment.get("system", "")
#	itemTemplate.capabilityLock = equipment.get("capability_lock", false)
#	itemTemplate.nameOverride = equipment.get("name_override", "")
#	itemTemplate.description = equipment.get("description", "")
#	itemTemplate.manual = equipment.get("manual", "")
#	itemTemplate.specs = equipment.get("specs", "")
#	itemTemplate.price = equipment.get("price", 0)
#	itemTemplate.testProtocol = equipment.get("test_protocol", "fire")
#	itemTemplate.default = equipment.get("default", false)
#	itemTemplate.control = equipment.get("control", "")
#	itemTemplate.storyFlag = equipment.get("story_flag", "")
#	itemTemplate.storyFlagMin = equipment.get("story_flag_min", -1)
#	itemTemplate.storyFlagMax = equipment.get("story_flag_max", -1)
#	itemTemplate.warnIfThermalBelow = equipment.get("warn_if_thermal_below", 0)
#	itemTemplate.warnIfElectricBelow = equipment.get("warn_if_electric_below", 0)
#	itemTemplate.stickerPriceFormat = equipment.get("sticker_price_format", "%s E$")
#	itemTemplate.stickerPriceMultiFormat = equipment.get("sticker_price_multi_format", "%s E$ (x%d)")
#	itemTemplate.installedColor = equipment.get("installed_color", Color(0.0, 1.0, 0.0, 1.0))
#	itemTemplate.disbledColor = equipment.get("disabled_color", Color(0.2, 0.2, 0.2, 1.0))
#	if equipment.get("name_override", "") == "":
#		itemTemplate.name = equipment.get("system", "MISSING_SYSTEM_NAME")
#	else:
#		itemTemplate.name = equipment.get("name_override", "MISSING_SYSTEM_NAME")
#	parent.add_child(itemTemplate)

#func sort_equipment_assignment(tag, ptag):
#	var slot_dictionary = {}
#	var type = ptag.get("slot_type")
#	var restriction = ptag.get("restriction","")
#	if type == "HARDPOINT":
#		var hardpoint_type = ptag.get("hardpoint_type","HARDPOINT_HIGH_STRESS")
#		var hardpoint_alignment = ptag.get("hardpoint_alignment","ALIGNMENT_CENTER")
#		var overridesdef = ptag.get("equipment_overrides",[])
#		var overrides = overridesdef.duplicate(true)
#		var equipmentdef = hardpoint_defaults.get(hardpoint_type, {})
#		var equipment = equipmentdef.duplicate(true)
#		if overrides.size() > 0:
#			var additives = overrides.get("additives",[])
#			var subtractives = overrides.get("subtractives",[])
#			for add in additives:
#				if not add in equipment:
#					equipment.append(add)
#			if subtractives.size() > 0:
#				var denied = []
#				for eqp in equipment:
#					if eqp in subtractives:
#						pass
#					else:
#						denied.append(eqp)
#				equipment = denied
#		slot_dictionary = {tag:{"type":type, "alignment":hardpoint_alignment, "equipment":equipment, "system_slot":ptag.get("system_slot", ""), "restriction":restriction}}
#	else:
#		slot_dictionary = {tag:{"type":type, "system_slot":ptag.get("system_slot", ""), "restriction":restriction}}
#	return slot_dictionary


func sort_slots():
	var slots = get_children()
	for slot in slots:
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
