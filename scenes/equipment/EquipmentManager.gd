extends VBoxContainer

var itemSlot = preload("res://enceladus/SystemShipUpgradeUI.tscn")

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

var hardpoint_defaults = {
	"HARDPOINT_LOW_STRESS":["EQUIPMENT_MASS_DRIVERS","EQUIPMENT_TURRETS","EQUIPMENT_NANODRONES","EQUIPMENT_IRON_THROWERS","EQUIPMENT_MINING_LASERS","EQUIPMENT_MICROWAVES","EQUIPMENT_SYNCHROTRONS","EQUIPMENT_CARGO_CONTAINER","EQUIPMENT_MINING_COMPANION","EQUIPMENT_IMPACT_ABSORBER","EQUIPMENT_BEACON"],
	"HARDPOINT_HIGH_STRESS":["EQUIPMENT_MASS_DRIVERS","EQUIPMENT_PLASMA_THROWERS","EQUIPMENT_PLASMA_THROWERS_HEAVY","EQUIPMENT_MANIPULATION_ARMS","EQUIPMENT_TURRETS","EQUIPMENT_NANODRONES","EQUIPMENT_IRON_THROWERS","EQUIPMENT_MINING_LASERS","EQUIPMENT_MICROWAVES"],
	"HARDPOINT_SPINAL":["EQUIPMENT_MASS_DRIVERS","EQUIPMENT_PLASMA_THROWERS","EQUIPMENT_TURRETS","EQUIPMENT_NANODRONES","EQUIPMENT_IRON_THROWERS","EQUIPMENT_MINING_LASERS","EQUIPMENT_MICROWAVES"],
	"HARDPOINT_DOCKING_BAY":["EQUIPMENT_CARGO_CONTAINER","EQUIPMENT_MINING_COMPANION","EQUIPMENT_TURRETS","EQUIPMENT_NANODRONES"],
	"HARDPOINT_DRONE_POINT":["EQUIPMENT_NANODRONES"],
}

var slots = ModLoader.get_children()

func _tree_entered():
	get_tags()
	add_slots()
	add_slot_tags()
	add_equipment()
#	sort_slots()

func get_tags():
	var slots = ModLoader.get_children()
	for slot in slots:
		var data = slot.get_property_list()
		var nodes = null
		for item in data:
			if item.get("name") == "EQUIPMENT_TAGS":
				nodes = slot.get("EQUIPMENT_TAGS")
		if not nodes == null:
			for tag in nodes:
				var slotTypes = tag.get("slot_types",[])
				var equipmentItems = tag.get("equipment_types",[])
				var align = tag.get("alignments",[])
				var hardpointTypes = tag.get("hardpoint_types",[])
				var hardpointDefaults = tag.get("hardpoint_defaults",{})
				if slotTypes.size() > 0:
					for st in slotTypes:
						slot_types.append(st)
				if equipmentItems.size() > 0:
					for st in equipmentItems:
						equipment_types.append(st)
				if align.size() > 0:
					for st in align:
						alignments.append(st)
				if hardpointTypes.size() > 0:
					for st in hardpointTypes:
						hardpoint_types.append(st)
				if hardpointDefaults.keys().size() > 0:
					for st in hardpointDefaults:
						hardpoint_defaults.merge(st)

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

func add_slot_tags():
	var slot_tag_pool = {}
	for slot in slots:
		var data = slot.get_property_list()
		var nodes = null
		for item in data:
			if item.get("name") == "SLOT_TAGS":
				nodes = slot.get("SLOT_TAGS")
		if not nodes == null:
			for tag in nodes:
				var ptag = nodes.get(tag)
				var slot_dictionary = sort_equipment_assignment(tag, ptag)
				slot_tag_pool.merge(slot_dictionary)
	
	for slot in slot_tag_pool:
		var select = get_node(slot)
		var dta = slot_tag_pool.get(slot)
		select.slotGroups = dta
	
	
	

func add_equipment():
	var slots = ModLoader.get_children()
	var equipment_slots = {}
	var child_slots = get_children()
	for child in child_slots:
		var cname = child.name
		var groups = child.slotGroups
		var dic = {cname:groups}
		equipment_slots.merge(dic)
	for slot in slots:
		var data = slot.get_property_list()
		var newSlot = null
		for item in data:
			if item.get("name") == "ADD_EQUIPMENT_ITEMS":
				newSlot = slot.get("ADD_EQUIPMENT_ITEMS")
		if not newSlot == null:
			for equip in newSlot:
				var equipment = equip.get("equipment")
				var confirmed = equip.get("slots",[])
				var cnfmtp = typeof(confirmed)
				if cnfmtp == TYPE_ARRAY:
					pass
				elif cnfmtp == TYPE_STRING:
					confirmed = [confirmed]
				else:
					confirmed = []
				var groups = equip.get("slot_groups",{})
				var alignment = groups.get("alignment", "")
				var tags = groups.get("tags", "")
				if groups.keys().size() > 0:
					for sect in get_children():
						var sectName = sect.name
						var sectTags = sect.slotGroups
						var type = sectTags.get("type","")
						var sectAlignment = sectTags.get("alignment")
						var sectEquipment = sectTags.get("equipment")
						if type == "HARDPOINT":
							var doesAlign = false
							if alignment in alignments:
								if alignment == sectAlignment:
									doesAlign = true
							else:
								doesAlign = true
							if doesAlign and tags in sectEquipment:
								confirmed.append(sectName)
				for panel in confirmed:
					add_equipment_to_slot(panel, equipment)




func add_equipment_to_slot(panel: String, equipment: Dictionary):
	var parent = get_node(panel).get_node("VBoxContainer")
	var itemTemplate = itemSlot.instance()
	itemTemplate.slot = get_node(panel).slotGroups.get("system_slot", "")
	itemTemplate.numVal = equipment.get("num_val")
	itemTemplate.system = equipment.get("system")
	itemTemplate.capabilityLock = equipment.get("capability_lock")
	itemTemplate.nameOverride = equipment.get("name_override")
	itemTemplate.description = equipment.get("description")
	itemTemplate.manual = equipment.get("manual")
	itemTemplate.specs = equipment.get("specs")
	itemTemplate.price = equipment.get("price")
	itemTemplate.testProtocol = equipment.get("test_protocol")
	itemTemplate.default = equipment.get("default")
	itemTemplate.control = equipment.get("control")
	itemTemplate.storyFlag = equipment.get("story_flag")
	itemTemplate.storyFlagMin = equipment.get("story_flag_min")
	itemTemplate.storyFlagMax = equipment.get("story_flag_max")
	itemTemplate.warnIfThermalBelow = equipment.get("warn_if_thermal_below")
	itemTemplate.warnIfElectricBelow = equipment.get("warn_if_electric_below")
	itemTemplate.stickerPriceFormat = equipment.get("sticker_price_format")
	itemTemplate.stickerPriceMultiFormat = equipment.get("sticker_price_multi_format")
	itemTemplate.installedColor = equipment.get("installed_color")
	itemTemplate.disbledColor = equipment.get("disabled_color")
	if equipment.get("name_override") == "":
		itemTemplate.name = equipment.get("system")
	else:
		itemTemplate.name = equipment.get("name_override")
	parent.add_child(itemTemplate)

func sort_equipment_assignment(tag, ptag):
	var slot_dictionary = {}
	var type = ptag.get("slot_type")
	if type == "HARDPOINT":
		var hardpoint_type = ptag.get("hardpoint_type","HARDPOINT_HIGH_STRESS")
		var hardpoint_alignment = ptag.get("hardpoint_alignment","ALIGNMENT_CENTER")
		var overridesdef = ptag.get("equipment_overrides",[])
		var overrides = overridesdef.duplicate(true)
		var equipmentdef = hardpoint_defaults.get(hardpoint_type)
		var equipment = equipmentdef.duplicate(true)
		if overrides.size() > 0:
			var additives = overrides.get("additives",[])
			var subtractives = overrides.get("subtractives",[])
			for add in additives:
				if not add in equipment:
					equipment.append(add)
			if subtractives.size() > 0:
				var denied = []
				for eqp in equipment:
					if eqp in subtractives:
						pass
					else:
						denied.append(eqp)
				equipment = denied
		slot_dictionary = {tag:{"type":type, "alignment":hardpoint_alignment, "equipment":equipment, "system_slot":ptag.get("system_slot", "")}}
	else:
		slot_dictionary = {tag:{"type":type, "system_slot":ptag.get("system_slot", "")}}
	return slot_dictionary


func sort_slots():
	var slots = get_children()
	for slot in slots:
		var items = slot.get_node("VBoxContainer").get_children()
		var nodePositions = []
		for item in items:
			nodePositions.append([item, item.get_index()])
		var noFail = false
		var index = 2
		var maxIndex = items.size()
		while noFail == false:
			
			var hasDetectedInconsistency = false
			if index + 1 > maxIndex and not hasDetectedInconsistency:
				noFail = true
			
			elif index + 1 > maxIndex and hasDetectedInconsistency:
				pass
			else:
				var par = slot.get_node("VBoxContainer")
				var entryA = par.get_child(index - 1)
				var entryB = par.get_child(index)
				if entryA.price > entryB.price:
					hasDetectedInconsistency = true
					par.move_child(entryB, index - 1)
			index += 1
