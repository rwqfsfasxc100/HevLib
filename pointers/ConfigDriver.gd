extends Node

var developer_hint = {
	"__config_parse":[
			"Parses a config file as a dictionary",
			"Supply the path to a text file containing the data",
			"File must be formatted using the ConfigFile module"
		]
}

static func __config_parse(file: String) -> Dictionary:
	var f = load("res://HevLib/scripts/configs/config_parse.gd")
	var s = f.config_parse(file)
	return s

static func __store_config(configuration: Dictionary, mod: String):
	var f = load("res://HevLib/scripts/configs/store_config.gd")
	f.store_config(configuration,mod)
