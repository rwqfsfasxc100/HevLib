extends Node

var developer_hint = {
	"__config_parse":[
			"Parses a config file as a dictionary",
			"Supply the path to a text file containing the data",
			"File must be formatted to ini standards, e.g. through using the ConfigFile module"
		]
}

static func __config_parse(file: String) -> Dictionary:
	var f = load("res://HevLib/scripts/configs/config_parse.gd")
	var s = f.config_parse(file)
	return s

static func __store_config(configuration: Dictionary, mod_id: String):
	var f = load("res://HevLib/scripts/configs/store_config.gd")
<<<<<<< Updated upstream
	f.store_config(configuration,mod_id)
=======
	f.store_config(configuration,mod)

static func __store_value(mod: String, section: String, key: String, value):
	var f = load("res://HevLib/scripts/configs/store_value.gd")
	f.store_value(mod, section, key, value)

static func __get_config(mod: String) -> Dictionary:
	var f = load("res://HevLib/scripts/configs/get_config.gd")
	var s = f.get_config(mod)
	return s

static func __get_value(mod: String, section: String, key: String):
	var f = load("res://HevLib/scripts/configs/get_value.gd")
	var s = f.get_value(mod, section, key)
	return s

static func __load_configs():
	var f = load("res://HevLib/scripts/configs/load_configs.gd")
	f.load_configs()
>>>>>>> Stashed changes
