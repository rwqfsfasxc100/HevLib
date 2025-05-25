extends Node

static func __get_vanilla_position(system_name: String) -> Vector2:
	var f = load("res://HevLib/scenes/weaponslot/data_storage/vanilla_data.gd").equipment_position_defaults
	var s = f.get(system_name,Vector2(0,0))
	return s
