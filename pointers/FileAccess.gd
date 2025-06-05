extends Node

var developer_hint = {
		"__get_file_content":[
			"Returns the content from a file as a string"
		],
		"__config_parse":[
			"Parses a config file as a dictionary",
			"Supply the path to a text file containing the data",
			"File must be formatted using the ConfigFile module"
		]
	}

static func __get_file_content(file: String) -> String:
	var f = load("res://HevLib/globals/get_file_content.gd")
	var s = f.get_file_content(file)
	return s

static func __config_parse(file: String) -> Dictionary:
	var f = load("res://HevLib/scripts/config_parse.gd")
	var s = f.config_parse(file)
	return s
