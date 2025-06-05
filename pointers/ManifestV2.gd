extends Node

var developer_hint = {
	"__get_mod_data":[
		"Returns a dictionary containing info on all mods currently installed"
	]
}

static func __get_mod_data(format_to_manifest_version:bool = false, print_json: bool = false) -> Dictionary:
	var f = load("res://HevLib/scripts/manifest_v2/get_mod_data.gd").new()
	var s = f.get_mod_data(format_to_manifest_version,print_json)
	return s
