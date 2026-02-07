extends Node

static func load_configs(cfg_filename : String = "Mod_Configurations" + ".cfg",ManifestV2 = null,FolderAccess = null):
	var ConfigDriver = load("res://HevLib/pointers/ConfigDriver.gd")
	var file = File.new()
	var dir = Directory.new()
	var c = ConfigFile.new()
	var cfg_file = "user://cfg/" + cfg_filename
	var profiles_dir = "user://cfg/.profiles/"
	var profiles_setter = ".profiles.ini"
	dir.make_dir_recursive(profiles_dir)
	if not file.file_exists(profiles_dir + profiles_setter):
		c.clear()
		c.set_value("profiles","selected","Default")
		c.save(profiles_dir + profiles_setter)
		c.clear()
	if not file.file_exists(cfg_file):
		file.open(cfg_file,File.WRITE)
		file.store_string("")
		file.close()
	c.load(profiles_dir + profiles_setter)
	var desired_profile = c.get_value("profiles","selected","Default")
	c.clear()
	c.load(cfg_file)
	var current_profile = c.get_value("HevLib/HEVLIB_CONFIG_SECTION_DRIVERS","profile_name","Default")
	var profile_is_current = true
	if current_profile != desired_profile:
		profile_is_current = false
		dir.remove(cfg_file)
		for m in FolderAccess.__fetch_folder_files("user://cfg/.profiles/"):
			if m != ".profiles.ini":
				c.load(profiles_dir + m)
				var this_profile = c.get_value("HevLib/HEVLIB_CONFIG_SECTION_DRIVERS","profile_name")
				if this_profile == desired_profile:
					dir.copy(profiles_dir + m,cfg_file)
					profile_is_current = true
				c.clear()
	if not profile_is_current:
		c.clear()
		c.set_value("HevLib/HEVLIB_CONFIG_SECTION_DRIVERS","profile_name",desired_profile)
		c.save(cfg_file)
	
	var f = ManifestV2.__get_mod_data()
	var mod_entries = f["mods"]
	var configs = {}
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
				var key_data = sectData[key]
				if key in current_config[sect]:
					pass
				else:
					
					match typeof(key_data):
						TYPE_DICTIONARY:
							if "type" in key_data:
								match key_data["type"]:
									"action":
										current_config[sect].merge({key:key_data.get("method","_pressed")})
									_:
										if "default" in key_data:
											current_config[sect].merge({key:key_data["default"]})
								
						_:
							pass
	if not "profile_name" in current_config.get("HevLib/HEVLIB_CONFIG_SECTION_DRIVERS",{}):
		current_config["HevLib/HEVLIB_CONFIG_SECTION_DRIVERS"]["profile_name"] = "Default"
	for section in current_config:
		for key in current_config[section]:
			c.set_value(section,key,current_config[section][key])
	c.save(cfg_file)
	c.save(profiles_dir + current_config.get("HevLib/HEVLIB_CONFIG_SECTION_DRIVERS",{}).get("profile_name","Default") + ".cfg")
	for mod in configs:
		var data = ConfigDriver.__get_config(mod)
		for section in configs[mod]:
			var sectData = configs[mod][section]
			for key in sectData:
				var key_data = sectData[key]
				if key_data["type"].to_lower() == "input":
					var p = ConfigDriver.__get_value(mod,section,key)
					if p == null:
						p = key_data["default"]
					var addAction = true
					for m in InputMap.get_actions():
						if m == key:
							addAction = false
					if addAction:
						InputMap.add_action(key)
					for i in p:
						if i.begins_with("Mouse "):
							var event = InputEventMouseButton.new()
							event.button_index = int(i.split("Mouse ")[1])
							InputMap.action_add_event(key, event)
						if i.begins_with("JoyButton "):
							var event = InputEventJoypadButton.new()
							event.button_index = int(i.split("JoyButton ")[1])
							InputMap.action_add_event(key, event)
						if i.begins_with("JoyAxis "):
							var event = InputEventJoypadMotion.new()
							event.axis = abs(int(i.split("JoyAxis ")[1]))
							if i.split("JoyAxis ")[1].begins_with("-"):
								event.axis_value = -1.0
							else:
								event.axis_value = 1.0
							InputMap.action_add_event(key, event)
							
						else:
							var event = InputEventKey.new()
							event.scancode = OS.find_scancode_from_string(i)
							InputMap.action_add_event(key, event)
	
