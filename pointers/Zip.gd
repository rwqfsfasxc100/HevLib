extends Node

var developer_hint = {
	"__get_zip_content":[
		"Lists all files in the zip by paths relative to the mod's name folder",
		" -> i.e. a zip only containing a folder and a text file return [folder/, file.txt]",
		"Returns an array of file paths in zip-relative form, stored alphabetically",
		"Optional Strip_Parent_Folder boolean removes the first folder item before the slash.",
		"Optional To_Lower_Case boolean converts all characters to lower"
	],
	"__fetch_file_from_zip":[
		"Loads a zip file and stores the requested files from paths relative to the root",
		"If you intend on taking data from a zip multiple times, this is a preferable method as it loads it to disk for future reference instead",
		"Does not work for fetching compressed data from within a zip (images, archives, .stex streams, etc)",
		"Defer to external programs for full unzip control",
		"Generates all folders in the zip file before handling the files to ensure they can save properly, but may cause clutter",
		"Outputs an array of all files saved to disk",
		"Handles case insensitivities"
	]
}

static func __get_zip_content(path: String, Strip_Parent_Folder: bool = false, To_Lower_Case: bool = false) -> Array:
	var HevLib = load("res://HevLib/Functions.gd").new()
	var s = HevLib.__get_zip_content(path, Strip_Parent_Folder, To_Lower_Case)
	return s

static func __fetch_file_from_zip(path: String, Destination_Folder_Path: String, Desired_File_Paths: Array) -> Array:
	var HevLib = load("res://HevLib/Functions.gd").new()
	var s = HevLib.__fetch_file_from_zip(path, Destination_Folder_Path, Desired_File_Paths)
	return s
