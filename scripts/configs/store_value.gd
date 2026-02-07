extends Node

const DataFormat = preload("res://HevLib/pointers/DataFormat.gd")

static func store_value(mod, section, key, value, cfg_filename : String = "Mod_Configurations" + ".cfg"):
	mod = DataFormat.__array_to_string(mod.split("/"))
	mod = DataFormat.__array_to_string(mod.split(" "))
	section = DataFormat.__array_to_string(section.split("/"))
	var cfg_folder = "user://cfg/"
	var profiles_dir = "user://cfg/.profiles/"
	var cfg = ConfigFile.new()
	cfg.load(cfg_folder+cfg_filename)
	var modSection = mod + "/" + section
	cfg.set_value(modSection,key,value)
	var profile = cfg.get_value("HevLib/HEVLIB_CONFIG_SECTION_DRIVERS","profile_name","default")
	
	cfg.save(cfg_folder+cfg_filename)
	cfg.save(profiles_dir+profile + ".cfg")
	Loader.saved()
