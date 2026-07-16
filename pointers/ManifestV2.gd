extends Node

# [license]
# 3-Clause BSD NON-AI License
# 
# Copyright 2026 __hev (Benjamin Buckhurst)
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.
# 
# 4. The source code and the binary form, and any modifications made to them may not be used for the purpose of input data, the training of, or improvment of machine learning algorithms,
# including but not limited to artificial intelligence, natural language processing, or data mining. This condition applies to any derivatives,
# modifications, or updates based on the Software code. Any usage of the source code or the binary form in an AI-training dataset is considered a breach of this License.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# [/license]

var developer_hint = {
	"__get_mod_data":[
		"Returns a dictionary containing info on all mods currently installed",
		"print_json -> (optional) bool for whether the returned data is a JSON-formatted string. Defaults to false"
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
	],
	"__have_mods_updated":[
		"Checks all installed mods for a differing mod version against the previous runtime",
		"Returns a dictionary containing relevant information for each mod ID that runs a differing version to equivalents contained in the file",
		"Works only on mods with a valid manifest using MV2.0 or newer",
		"Will always trigger for new installs",
		"File and folder paths can be changed, but only if you intend on using your own version checking system. See '__get_mod_versions'",
		"folder -> (optional) string for the folder containing the version cache file. Defaults to 'user://cache/.Mod_Menu_2_Cache/changelogs/'",
		"previous_file -> (optional) string for the file name containing the version cache data from the previous game session. Defaults to 'mods_from_last_launch.json'",
	],
	"__get_mod_versions":[
		"Returns version info on all installed mods running MV2.0 or newer.",
		"Intended to be used in tandem with __have_mods_updated, as this function is used to write the file it reads from.",
		"Unless you plan on writing your own implementation, store should be left false.",
		"store -> (optional) bool for whether it should store the cache to file, dictated by the following folder and file variables. Defaults to false",
		"folder -> (optional) string for the folder containing the version cache file. Defaults to 'user://cache/.Mod_Menu_2_Cache/changelogs/'",
		"previous_file -> (optional) string for the file name containing the version cache data from the previous game session. Defaults to 'mods_from_last_launch.json'",
		"this_file -> (optional) string for the file name containing the version cache data from the current game session. Defaults to 'mods_from_this_launch.json'",
	],
	"__parse_changelog":[
		"Reads and converts a formatted changelog file to a dictionary usable by this library",
		"Changelogs are ini-formatted, with the version number [MUST be major.minor.bugfix], and each entry incrementing by one (e.g. 1=\"\",2=\"\", etc.).",
		"Subsections are done similarly, with an appended .x against it's parent increment with x meaning it's index (e.g. 1.1, 1.2, etc.) This can be done up to a fourth depth (1.1.1.1), nothing past will be parsed.",
		"file_path -> absolute file path for the changelog file."
	]
}

static func __get_mod_data(print_json: bool = false) -> Dictionary:
	return preload("res://HevLib/pointers.gd").new().ManifestV2.__get_mod_data(print_json)
static func __match_mod_path_to_zip(mod_main_path:String) -> String:
	return preload("res://HevLib/pointers.gd").new().ManifestV2.__match_mod_path_to_zip(mod_main_path)
static func __compare_versions(checked_mod_data:Dictionary) -> bool:
	return preload("res://HevLib/pointers.gd").new().ManifestV2.__compare_versions(checked_mod_data)
static func __get_mod_data_from_files(script_path:String, format_to_manifest_version: bool = true) -> Dictionary: # NOT UPDATED YET
	return preload("res://HevLib/pointers.gd").new().ManifestV2.__get_mod_data_from_files(script_path)
static func __parse_file_as_manifest(file_path: String, format_to_manifest_version: bool = true) -> Dictionary:
	return preload("res://HevLib/pointers.gd").new().ManifestV2.__parse_file_as_manifest(file_path,format_to_manifest_version)
static func __get_mod_by_id(id: String, case_sensitive: bool = true) -> Dictionary:
	return preload("res://HevLib/pointers.gd").new().ManifestV2.__get_mod_by_id(id,case_sensitive)
static func __get_tags() -> Dictionary:
	return preload("res://HevLib/pointers.gd").new().ManifestV2.__get_tags()
static func __get_mod_tags(mod_id: String) -> Dictionary:
	return preload("res://HevLib/pointers.gd").new().ManifestV2.__get_mod_tags(mod_id)
static func __get_mods_from_tag(tag_name: String) -> Array:
	return preload("res://HevLib/pointers.gd").new().ManifestV2.__get_mods_from_tag(tag_name)
static func __get_mods_and_tags_from_tag(tag_name: String) -> Dictionary:
	return preload("res://HevLib/pointers.gd").new().ManifestV2.__get_mods_and_tags_from_tag(tag_name)
static func __get_manifest_section(section: String, mod_id: String = "") -> Dictionary:
	return preload("res://HevLib/pointers.gd").new().ManifestV2.__get_manifest_section(section,mod_id)
static func __get_mod_ids() -> Array:
	return preload("res://HevLib/pointers.gd").new().ManifestV2.__get_mod_ids()
static func __get_manifest_entry(section: String, entry: String, mod_id: String = ""):
	return preload("res://HevLib/pointers.gd").new().ManifestV2.__get_manifest_entry(section,entry,mod_id)
static func __check_complementary() -> Array:
	return preload("res://HevLib/pointers.gd").new().ManifestV2.__check_complementary()
static func __check_mod_complementary(mod_id) -> Array:
	return preload("res://HevLib/pointers.gd").new().ManifestV2.__check_mod_complementary(mod_id)
static func __check_dependancies() -> Array:
	return preload("res://HevLib/pointers.gd").new().ManifestV2.__check_dependancies()
static func __check_mod_dependancies(mod_id) -> Array:
	return preload("res://HevLib/pointers.gd").new().ManifestV2.__check_mod_dependancies(mod_id)
static func __check_conflicts() -> Array:
	return preload("res://HevLib/pointers.gd").new().ManifestV2.__check_conflicts()
static func __check_mod_conflicts(mod_id) -> Array:
	return preload("res://HevLib/pointers.gd").new().ManifestV2.__check_mod_conflicts(mod_id)
static func __parse_tags(tag_data) -> Dictionary:
	return preload("res://HevLib/pointers.gd").new().ManifestV2.__parse_tags(tag_data)
static func __have_mods_updated(folder = "user://cache/.Mod_Menu_2_Cache/changelogs/",previous_file = "mods_from_last_launch.json"):
	return preload("res://HevLib/pointers.gd").new().ManifestV2.__have_mods_updated(folder,previous_file)
static func __get_mod_versions(store = false,folder = "user://cache/.Mod_Menu_2_Cache/changelogs/",previous_file = "mods_from_last_launch.json",this_file = "mods_from_this_launch.json"):
	return preload("res://HevLib/pointers.gd").new().ManifestV2.__get_mod_versions(store,folder,previous_file,this_file)
static func __parse_changelog(file_path):
	return preload("res://HevLib/pointers.gd").new().ManifestV2.__parse_changelogs(file_path)
