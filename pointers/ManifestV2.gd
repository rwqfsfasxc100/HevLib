extends Node

var developer_hint = {
	"__get_mod_data":[
		"Returns a dictionary containing info on all mods currently installed"
	],
	"__match_mod_path_to_zip":[
		"Matches a mod zip file to the provided mod main path. Will pick the first zip found, if multiple zips contain the same mod.",
		"mod_main_path -> string containing the path to the mod main. Must be a full path to the file",
		"Returns a string containing the zip file, returns empty if not found"
	],
	"__compare_versions":[
		"Checks a dictionary containing a singular mod against the currently installed mods.",
		"Best used in conjunction with __get_mod_data_from_files(), with format_to_manifest_version set to false, as this lets you generate a mod dictionary for inputting",
		"checked_mod_data -> the generated mod dictionary to compare against",
		"Returns a bool of whether the mod is installed or not"
	],
	"__get_mod_data_from_files":[
		"Creates a mod dictionary from a mod's ModMain script.",
		"If a mod.manifest file is in the same directory, it will pick it up and process it",
		"script_path -> string that is the full path to the ModMain script. Can be stored anywhere but must have valid ModMain data (and optional mod.manifest file in the same directory)",
		"format_to_manifest_version -> (optional) whether to format the dictionary to the manifest's provided version instead of generating a raw dictionary from it. Defaults to false",
		"Returns a dictionary with the mod main processed"
	],
	"__parse_file_as_manifest":[
		"Parses a file as a mod.manifest file. Does not care the file type, just the contents",
		"file_path -> string of that is the full path to the file.",
		"format_to_manifest_version -> (optional) bool whether to conform the returning dictionary to the manifest's version rather than a raw dictionary. Defaults to false",
		"Returns a dictionary containing the formatted data"
	],
	"__get_mod_by_id":[
		"Fetches information about a mod by it's ID (found in the mod_information -> id section in the manifest)",
		"ID is case sensitive, an incorrect capitalization will not make a match unless case_insensitive is set to true",
		"id -> string for the ID that is being looked for",
		"case_sensitive -> (optional) boolean that decides whether the ID being looked for should care about capitalization. Enabled by default",
		"Returns a dictionary containing manifest-formatted information. Returns an empty dictionary if not found."
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

static func __parse_file_as_manifest(file_path: String, format_to_manifest_version: bool = false) -> Dictionary:
	var f = load("res://HevLib/scripts/manifest_v2/parse_file_as_manifest.gd").new()
	var s = f.parse_file_as_manifest(file_path, format_to_manifest_version)
	return s

static func __get_mod_by_id(id: String, case_sensitive: bool = true) -> Dictionary:
	var f = load("res://HevLib/scripts/manifest_v2/get_mod_by_id.gd").new()
	var s = f.get_mod_by_id(id, case_sensitive)
	return s

