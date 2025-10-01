extends Node

static func get_value(mod: String, section: String, key: String, cfg_filename : String = "Mod_Configurations" + ".cfg"):
	var DataFormat = preload("res://HevLib/pointers/DataFormat.gd")
	mod = DataFormat.__array_to_string(mod.split("/"))
	mod = DataFormat.__array_to_string(mod.split(" "))
	var cfg_folder = "user://cfg/"
	
	var cfg = ConfigFile.new()
	var error = cfg.load(cfg_folder+cfg_filename)
	if error != OK:
#		Debug.l("HevLib Config File: Error loading settings %s" % error)
		return {}
	var full = mod+"/"+section
	if cfg.has_section(full):
		var keys = cfg.get_section_keys(full)
		if key in keys:
			var data = cfg.get_value(full,key)
			return data
		else:
			return null
	else:
		return null
