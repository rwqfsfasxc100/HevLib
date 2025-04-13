extends Node

var developer_hint = {
	"__load_manifest_from_file":[
		"Loads manifest data and returns it as a dictionary",
		"less preferable than __get_mod_main outside of more specific use-cases"
	],
	"__load_file":[
		"Specific function for Mod Menu behaviour",
		"Requires 6 inputs",
		" -> modDir is the mod main's directory (form of res://Mod_Folder/ModMain.gd)",
		" -> zipDir is the directory of the mod's zip (form of mod_folder/mod.zip)",
		" -> hasManifest determines whether the manifest should be used",
		" -> manifestDirectory is the directory of the mod.manifest file (form of res://Mod_Folder/mod.manifest)",
		" -> hasIcon determines whether the custom mod icon should be used",
		" -> iconDir is the directory of the icon.stex file (form of res://Mod_Folder/icon.stex",
		"less preferable than __get_mod_main outside of more specific use-cases"
	],
	"__get_mod_main":[
		"Returns 16 lines of text, split by a newline (\n), of mod data in a single string using the mod menu data standard",
		"Optional split_into_array bool converts the data into an array preemptively",
		"Preferable use of fetching mod data compared to __load_file and __load_manifest_from_file as it combines several of the previous helper functions into one, and removes the need for overhead code"
	]
}

static func __load_manifest_from_file(manifest: String) -> Dictionary:
	var f = load("res://HevLib/globals/load_manifest_from_file.gd").new()
	var s = f.load_manifest_from_file(manifest)
	return s

static func __load_file(modDir: String, zipDir: String, hasManifest: bool, manifestDirectory: String, hasIcon: bool, iconDir: String) -> String:
	var f = load("res://HevLib/globals/load_file.gd").new()
	var s = f.load_file(modDir, zipDir, hasManifest, manifestDirectory, hasIcon, iconDir)
	return s

static func __get_mod_main(file: String, split_into_array: bool = false) -> String:
	var f = load("res://HevLib/globals/get_mod_main.gd").new()
	var s = f.get_mod_main(file, split_into_array)
	return s
