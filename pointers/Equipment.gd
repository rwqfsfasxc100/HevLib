extends Node

var developer_hint = {
	"__make_equipment":[
		"Inputs a dictionary to format it for adding via this library",
		"equipment slot variables are the exact same as they are usually, check res://enceladus/SystemShipUpgradeUI.tscn OR .gd for those values",
		" -> formatted in the form of {\"<variable_name>\":<variable_value>}",
		"Has two other variables not included in the usual selection for adding to slots:",
		" -> 'slots' is an array of the raw slot node names in Upgrades.tscn child to the Items equip_node. Equivalent to the slot_node_name variable for __make_slot",
		" -> 'slot_groups' is an array of tags used to base their addition. A list of tags can be found in the file at res://HevLib/scenes/equipment/slot_tags.gd. They are also listed on this project's wiki @ https://github.com/rwqfsfasxc100/HevLib/wiki/Equipment-Slot-Grouping",
		"Check this mod's ModMain.gd file for an example as to how they're added with the addEquipmentItem function"
	],
	"__make_slot":[
		"Inputs a dictionary to format a new slot addition for adding via this library",
		" -> 'system_slot' is a string for the system name of the slot used by equipment. Required",
		" -> 'slot_node_name' is a string used as the node's name, used for the slots variable in __make_equipment. Required",
		" -> 'slot_displayName' is a string used for the translation string to display in the equipment menu. Required",
		" -> 'slot_groups' is an array of string used for the group tags, see above for the tags note",
		" -> 'has_none' is a boolean to see if an empty slot is used in the slot's list",
		" -> 'always_display' is a boolean to decide whether the slot is available at all times, or if false only on ships with a slot node attached",
		" -> 'restrict_type' is a string for restricting the slot to ship reactor types. Vanilla currently supports 'fission' and 'fusion'. leave blank for all ships",
		" -> 'open_by_default' is a boolean to decide if the slot list is open when the equipment list is opened",
		" -> 'limit_ships' is an array of ship names that limits the slot to. Courtesy of spaceDOTexe for it's implementation in IoE",
		" -> 'invert_limit_logic' is a boolean to invert the previous array to avoid the ships in that list. Again courtesy of spaceDOTexe",
	],
	"__add_vanilla_equipment":[
		"Internal function used to list vanilla equipment to be added to a slot based on a set of provided tags",
		" -> 'tags' is an array of strings for applicable tags"
	],
	"__match_vanilla":[
		"Internal function used to return an array of viable vanilla equipment options from a set of tags"
	],
	"__make_upgrades_scene":[
		"Creates Upgrades.tscn and WeaponSlot.tscn files based on data from mods' equipment data tags",
		"is_onready -> (optional) depends on whether the scenes are being made after the onready phase. defaults to true"
	],
	"__make_equipment_for_scene":[
		"Returns a string containing PackedScene data for Upgrades.tscn based on provided data",
		"equipment_data -> a dictionary containing a standard equipment data dictionary, as by EquipmentDriver standards",
		"slot_node_name -> a string for the desired node to add the equipment to",
		"system_slot -> a string for the slot type",
		"This function is typically used internally for __make_upgrades_scene, preferrably use that to make scene files"
	],
	"__make_slot_for_scene":[
		"Returns a string containing PackedScene data for Upgrades.tscn based on provided data",
		"slot_data -> a dictionary containing a standard slot data dictionary, as by EquipmentDriver standards",
		"This function is typically used internally for __make_upgrades_scene, preferrably use that to make scene files"
	]
}

static func __make_equipment_for_scene(equipment_data: Dictionary, slot_node_name : String, system_slot: String) -> String:
	return ModLoader._savedObjects[0].Equipment.__make_equipment_for_scene(equipment_data,slot_node_name,system_slot)
static func __make_slot_for_scene(slot_data: Dictionary) -> Dictionary:
	return ModLoader._savedObjects[0].Equipment.__make_slot_for_scene(slot_data)
