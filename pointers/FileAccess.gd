extends Node

var developer_hint = {
		"__get_file_content":[
			"Returns the content from a file as a string"
		],
		"__config_parse":[
			"Parses a config file as a dictionary",
			"Supply the path to a text file containing the data",
			"File must be formatted using the ConfigFile module"
		],
		"__copy_file":[
			"Copies (and overrides) a file to a folder, and can account for globalized and Windows paths",
			"file -> string for the path to the file, can be global or local path",
			"folder -> string for the path to the folder, can be global or local path"
		]
	}
const gfc = preload("res://HevLib/globals/get_file_content.gd")
static func __get_file_content(file: String) -> String:
	var s = gfc.get_file_content(file)
	return s
const cfg = preload("res://HevLib/scripts/configs/config_parse.gd")
static func __config_parse(file: String) -> Dictionary:
	var s = cfg.config_parse(file)
	return s

static func __copy_file(file, folder):
	var prepfile = ProjectSettings.localize_path(file)
#	var current_mods = FolderAccess.__fetch_folder_files(folder)
	var fn = prepfile.split("/")[prepfile.split("/").size() - 1]
	
	var dir = Directory.new()
	dir.copy(prepfile,folder + "/" + fn)

const lp = preload("res://HevLib/scripts/load_png.gd")
static func __load_png(path) -> Texture:
	var s = lp.load_png(path)
	return s
