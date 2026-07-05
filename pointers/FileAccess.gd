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

static func __get_file_content(file: String) -> String:
	return ModLoader._savedObjects[0].FileAccess.__get_file_content(file)
static func __config_parse(file: String) -> Dictionary:
	return ModLoader._savedObjects[0].ConfigDriver.__config_parse(file)

static func __copy_file(file, folder):
	ModLoader._savedObjects[0].FileAccess.__copy_file(file,folder)

static func __load_png(path) -> Texture:
	return ModLoader._savedObjects[0].FileAccess.__load_png(path)
