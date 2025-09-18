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
	],
	"__get_tags":[
		"Returns a dictionary containing all tag data for installed mods"
	],
	"__get_mod_tags":[
		"Returns a dictionary containing the tag data for a provided mod id",
		"mod_id -> string for the desired mod id. Returns blank if the provided mod isn't installed"
	],
	"__get_mods_from_tag":[
		"Returns an array of strings for all mods that have the provided tag",
		"tag_name -> string to fetch the mods that use the provided tag"
	],
	"__get_mods_and_tags_from_tag":[
		"Returns a dictionary containing the data of all mods with the provided tag",
		"tag_name -> string to fetch the mods and tag data of the tag"
	],
	"__get_manifest_section":[
		"Gets a manifest section from all mods or a specific mod",
		"section -> string for the desired section to fetch",
		"mod_id -> (optional) string that defines a specific mod to look through. If omitted or left blank (\"\"), the sections for all installed mods will be returned instead"
	],
	"__get_mod_ids":[
		"Returns an array of the mod IDs of all installed mods with an applicable manifest"
	],
	"__get_manifest_entry":[
		"Gets an entry from a manifest section from all mods or a specific mod",
		"section -> string for the section where the entry resides",
		"entry -> string for the desired entry field",
		"mod_id -> (optional) string for the desired mod id",
		"If a mod id is provided, returns the value of the entry",
		"Otherwise, a dictionary will list all applicable mod ids with their values set to the entry for the mod",
		"If all checks fail, returns an empty dictionary"
	],
	"__check_complementary":[
		"Returns a dictionary containing the complementary mod ids for all installed mods"
	],
	"__check_mod_complementary":[
		"Returns an array containing the compliementary mod ids for for the provided mod id",
		"mod_id -> string for the mod id of the requested mod"
	],
	"__check_conflicts":[
		"Returns a dictionary containing the conflicting mod ids for all installed mods"
	],
	"__check_mod_conflicts":[
		"Returns an array containing the conflicting mod ids for for the provided mod id",
		"mod_id -> string for the mod id of the requested mod"
	],
	"__check_dependancies":[
		"Returns a dictionary containing the dependancy mod ids for all installed mods"
	],
	"__check_mod_dependancies":[
		"Returns an array containing the dependancy mod ids for for the provided mod id",
		"mod_id -> string for the mod id of the requested mod"
	],
	"__parse_tags":[
		"Trims a formatted dictionary from __parse_file_as_manifest to only display values changed from the default",
		"A notable exception is the language tag, which is provided regardless",
		"tag_data -> dictionary from __parse_file_as_manifest to trim down. Must have been made with 'format_to_manifest_version' set to true"
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

static func __parse_file_as_manifest(file_path: String, format_to_manifest_version: bool = false) -> Dictionary: # UPDATED FOR MANIFESTV2.2
	var f = load("res://HevLib/scripts/manifest_v2/parse_file_as_manifest.gd").new()
	var s = f.parse_file_as_manifest(file_path, format_to_manifest_version)
	return s

static func __get_mod_by_id(id: String, case_sensitive: bool = true) -> Dictionary:
	var f = load("res://HevLib/scripts/manifest_v2/get_mod_by_id.gd").new()
	var s = f.get_mod_by_id(id, case_sensitive)
	return s

static func __get_tags() -> Dictionary:
	var f = load("res://HevLib/scripts/manifest_v2/get_tags.gd")
	var s = f.get_tags()
	return s

static func __get_mod_tags(mod_id: String) -> Dictionary:
	var f = load("res://HevLib/scripts/manifest_v2/get_mod_tags.gd")
	var s = f.get_mod_tags(mod_id)
	return s

static func __get_mods_from_tag(tag_name: String) -> Array:
	var f = load("res://HevLib/scripts/manifest_v2/get_mods_from_tag.gd")
	var s = f.get_mods_from_tag(tag_name)
	return s

static func __get_mods_and_tags_from_tag(tag_name: String) -> Dictionary:
	var f = load("res://HevLib/scripts/manifest_v2/get_mods_and_tags_from_tag.gd")
	var s = f.get_mods_and_tags_from_tag(tag_name)
	return s

static func __get_manifest_section(section: String, mod_id: String = "") -> Dictionary:
	var f = load("res://HevLib/scripts/manifest_v2/get_manifest_section.gd")
	var s = f.get_manifest_section(section, mod_id)
	return s

static func __get_mod_ids() -> Array:
	var f = load("res://HevLib/scripts/manifest_v2/get_mod_ids.gd")
	var s = f.get_mod_ids()
	return s

static func __get_manifest_entry(section: String, entry: String, mod_id: String = ""):
	var f = load("res://HevLib/scripts/manifest_v2/get_manifest_entry.gd")
	var s = f.get_manifest_entry(section, entry, mod_id)
	return s

static func __check_complementary() -> Array:
	var f = load("res://HevLib/scripts/manifest_v2/mod_checking/check_complementary.gd")
	var s = f.check_complementary()
	return s

static func __check_mod_complementary(mod_id) -> Array:
	var f = load("res://HevLib/scripts/manifest_v2/mod_checking/check_mod_complementary.gd")
	var s = f.check_mod_complementary(mod_id)
	return s

static func __check_dependancies() -> Array:
	var f = load("res://HevLib/scripts/manifest_v2/mod_checking/check_dependancies.gd")
	var s = f.check_dependancies()
	return s

static func __check_mod_dependancies(mod_id) -> Array:
	var f = load("res://HevLib/scripts/manifest_v2/mod_checking/check_mod_dependancies.gd")
	var s = f.check_mod_dependancies(mod_id)
	return s

static func __check_conflicts() -> Array:
	var f = load("res://HevLib/scripts/manifest_v2/mod_checking/check_conflicts.gd")
	var s = f.check_conflicts()
	return s

static func __check_mod_conflicts(mod_id) -> Array:
	var f = load("res://HevLib/scripts/manifest_v2/mod_checking/check_mod_conflicts.gd")
	var s = f.check_mod_conflicts(mod_id)
	return s

static func __parse_tags(tag_data) -> Dictionary: # UPDATING FOR MANIFESTV2.2
	var f = load("res://HevLib/scripts/manifest_v2/parse_tags.gd")
	var s = f.parse_tags(tag_data)
	return s
