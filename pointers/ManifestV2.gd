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

static func __match_mod_path_to_zip(mod_main_path:String) -> String:
	var f = load("res://HevLib/scripts/manifest_v2/match_mod_path_to_zip.gd").new()
	var s = f.match_mod_path_to_zip(mod_main_path)
	return s

static func __compare_versions(checked_mod_data:Dictionary) -> bool:
	var f = load("res://HevLib/scripts/manifest_v2/compare_versions.gd").new()
	var s = f.compare_versions(checked_mod_data)
	return s

static func __get_mod_data_from_files(script_path:String, format_to_manifest_version: bool = false) -> Dictionary:
	var f = load("res://HevLib/scripts/manifest_v2/get_mod_data_from_files.gd").new()
	var s = f.get_mod_data_from_files(script_path,format_to_manifest_version)
	return s
