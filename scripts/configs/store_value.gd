extends Node

static func store_value(mod, section, key, value, cfg_filename : String = "Mod_Configurations" + ".cfg"):
	var DataFormat = preload("res://HevLib/pointers/DataFormat.gd")
	mod = DataFormat.__array_to_string(mod.split("/"))
	section = DataFormat.__array_to_string(section.split("/"))
	var cfg_folder = "user://cfg/"
	var cfg = ConfigFile.new()
	cfg.load(cfg_folder+cfg_filename)
	var modSection = mod + "/" + section
	cfg.set_value(modSection,key,value)
	cfg.save(cfg_folder+cfg_filename)
