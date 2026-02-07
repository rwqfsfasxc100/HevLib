extends Node

static func store_config(configuration: Dictionary, mod_id: String, cfg_filename : String = "Mod_Configurations" + ".cfg",DataFormat = null):
	var profiles_dir = "user://cfg/.profiles/"
	var cfg_folder = "user://cfg/"
	mod_id = DataFormat.__array_to_string(mod_id.split("/"))
	mod_id = DataFormat.__array_to_string(mod_id.split(" "))
	var tmpf = File.new()
	var cfg_file = cfg_folder + cfg_filename
	if not tmpf.file_exists(cfg_file):
		tmpf.open(cfg_folder+cfg_file,File.WRITE)
		tmpf.store_string("")
		tmpf.close()
	var FileCFG = File.new()
	FileCFG.open(cfg_file,File.READ)
	var cfg = ConfigFile.new()
	var txt = FileCFG.get_as_text(true)
	cfg.parse(txt)
	FileCFG.close()
	var cfg_sections = cfg.get_sections()
	var sections = configuration.keys()
	for section in sections:
		var sect_name = mod_id + "/" + section
		var sect_data = configuration[section]
		for s in sect_data:
			var sr = sect_data[s]
			cfg.set_value(sect_name,s,sr)
	
	var profile = cfg.get_value("HevLib/HEVLIB_CONFIG_SECTION_DRIVERS","profile_name","default")
	cfg.save(cfg_file)
	cfg.save(profiles_dir+profile + ".cfg")
	Loader.saved()
