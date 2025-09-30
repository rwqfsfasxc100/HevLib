extends Node

static func load_configs(cfg_filename : String = "Mod_Configurations" + ".cfg"):
	var ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")
	var ManifestV2 = preload("res://HevLib/pointers/ManifestV2.gd")
	var f = ManifestV2.__get_mod_data()
	var mod_entries = f["mods"]
	var configs = {}
	var file = File.new()
	var cfg_file = "user://cfg/" + cfg_filename
	if not file.file_exists(cfg_file):
		file.open(cfg_file,File.WRITE)
		file.store_string("")
		file.close()
	var current_config = ConfigDriver.__config_parse(cfg_file)
	for mod in mod_entries:
		var manifest = mod_entries[mod]["manifest"]
		var has_manifest = manifest["has_manifest"]
		if has_manifest:
			var mod_name = mod_entries[mod]["name"]
			var manifest_version = manifest["manifest_version"]
			if manifest_version >= 2.1:
				var cfg = manifest["manifest_data"]["configs"]
				if not cfg.hash() == {}.hash():
					configs.merge({mod_name:cfg})
	for mod in configs:
		var data = configs[mod]
		var DataFormat = preload("res://HevLib/pointers/DataFormat.gd")
		mod = DataFormat.__array_to_string(mod.split("/"))
		mod = DataFormat.__array_to_string(mod.split(" "))
		for section in data:
			var sectData = data[section]
			var sect = mod + "/" + section
			if sect in current_config:
				pass
			else:
				current_config.merge({sect:{}})
			for key in sectData:
				if key in current_config[sect]:
					pass
				else:
					current_config[sect].merge({key:sectData[key]})
	var c = ConfigFile.new()
	for section in current_config:
		for key in current_config[section]:
			c.set_value(section,key,current_config[section][key])
	c.save(cfg_file)
	
	
