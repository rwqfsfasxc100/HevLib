extends Node

static func store_config(configuration: Dictionary, mod_id: String):
	var cfg_folder = "user://cfg/"
	var cfg_file = "Mod_Configurations" + ".cfg"
	var check = Directory.new().file_exists(cfg_file)
	if not check:
		var tmpf = File.new()
		tmpf.open(cfg_folder+cfg_file,File.WRITE)
		tmpf.store_string("")
		tmpf.close()
	var FileCFG = File.new()
	FileCFG.open(cfg_folder+cfg_file,File.READ)
	var cfg = ConfigFile.new()
	var config_data = cfg.parse(FileCFG.get_as_text(true))
	FileCFG.close()
	var cfg_sections = cfg.get_sections()
	breakpoint
	var sections = configuration.keys()
	for section in sections:
		var sect_name = mod_id + "/" + section
		if sect_name in cfg_sections:
			pass
		else:
			pass
		
	
	for section in config_data:
		for key in config_data[section]:
			cfg.set_value(section,key,config_data[section][key])
	
	
	
	
	
	
	
