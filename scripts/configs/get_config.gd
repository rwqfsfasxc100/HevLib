extends Node

static func get_config(mod, cfg_filename : String = "Mod_Configurations" + ".cfg") -> Dictionary:
	var DataFormat = preload("res://HevLib/pointers/DataFormat.gd")
	mod = DataFormat.__array_to_string(mod.split("/"))
	mod = DataFormat.__array_to_string(mod.split(" "))
	var cfg_folder = "user://cfg/"
	var cfg = ConfigFile.new()
	var error = cfg.load(cfg_folder+cfg_filename)
	if error != OK:
#		Debug.l("HevLib Config File: Error loading settings %s" % error)
		return {}
	var dictionary = {}
	var config_sections = cfg.get_sections()
	for section in config_sections:
		var split = section.split("/")
		if split[0] == mod:
			var sub = {}
			var keys = cfg.get_section_keys(section)
			for key in keys:
				var value = cfg.get_value(section, key)
				sub.merge({key:value})
			dictionary.merge({split[1]:sub})
	return dictionary
