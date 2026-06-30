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

const pointers = preload("res://HevLib/pointers.gd")

static func __get_file_content(file: String) -> String:
	return pointers.new().FileAccess.__get_file_content(file)
static func __config_parse(file: String) -> Dictionary:
	return pointers.new().ConfigDriver.__config_parse(file)

static func __copy_file(file, folder):
	pointers.new().FileAccess.__copy_file(file,folder)

static func __load_png(path) -> Texture:
	return pointers.new().FileAccess.__load_png(path)
