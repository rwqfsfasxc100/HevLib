extends Node

const gdunzip = preload("res://HevLib/scripts/vendor/gdunzip.gd")

var Achievements : _Achievements = _Achievements.new()
var DataFormat : _DataFormat = _DataFormat.new()
var FolderAccess : _FolderAccess = _FolderAccess.new()
var FileAccess : _FileAccess = _FileAccess.new()
var ManifestV2 : _ManifestV2 = _ManifestV2.new(DataFormat,FolderAccess,FileAccess)
var ConfigDriver : _ConfigDriver = _ConfigDriver.new(DataFormat,ManifestV2,FolderAccess)
var DriverManagement : _DriverManagement = _DriverManagement.new(FolderAccess,DataFormat,ManifestV2)
var Equipment : _Equipment = _Equipment.new(DataFormat)
var Events : _Events = _Events.new()
var Github : _Github = _Github.new()
var HevLib : _HevLib = _HevLib.new(FolderAccess)
var Zip : _Zip = _Zip.new()
var ManifestV1 : _ManifestV1 = _ManifestV1.new(DataFormat,Zip)
var NodeAccess : _NodeAccess = _NodeAccess.new(FolderAccess)
var RingInfo : _RingInfo = _RingInfo.new()
var TimeAccess : _TimeAccess = _TimeAccess.new()
var Translations : _Translations = _Translations.new(ConfigDriver)
var WebTranslate : _WebTranslate = _WebTranslate.new(FolderAccess)


class _Achievements:
	var scripts = [
		
	]
	func __get_achievement_data(achievementID: String) -> Dictionary:
		var currentAchievements = Achivements.achivements
		var playtimeStats = Achivements.playtimeStats
		var playtimeAchievements = Achivements.playtimeAchievements
		# each entry in this variable should be [achievement name, stat name, stat limit, other associated data]
		var playtimeAchAndData = []
		
		for p in playtimeAchievements:
			for o in playtimeStats:
				if p[0] == o[0]:
					playtimeAchAndData.append([p[2],o[1],p[1],p[0]])
		
		var statsWithAchievements = Achivements.statsWithAchievements
		for a in statsWithAchievements:
			var stat = a
			var ps = statsWithAchievements.get(a)
			for s in ps:
				var limit = s
				var achievement = ps.get(s)
				playtimeAchAndData.append([achievement,stat,limit])
		
		var annoyingAsFuckAchievements = {"DIVER_10":10,"DIVER_50":50,"DIVER_ENCKE":3000,"DIVER_DRAGONS":3005,"LEAF_2":2000,"LEAF_5":5000,"LEAF_20":20000,"PLAYSTYLE_MANUAL":900}
		for each in annoyingAsFuckAchievements:
			var prefix = each.split("_")[0]
			var limit = annoyingAsFuckAchievements.get(each)
			var stat = ""
			match prefix:
				"DIVER":
					stat = "maxDepth"
				"LEAF":
					stat = "leaf"
				"PLAYSTYLE":
					stat = "manual"
			playtimeAchAndData.append([each,stat,limit])
		
		var isUnlocked = false
		for ach in currentAchievements:
			
			
			if ach == achievementID:
			
			
				isUnlocked = true
		var statAssociation = []
		
		
		
		
		var currentStatData = []
		for each in playtimeAchAndData:
			if each[0] == achievementID:
				currentStatData = each
		if currentStatData.size() == 0:
			currentStatData = [achievementID,null,null,null]
		elif currentStatData.size() == 3:
			currentStatData = [currentStatData[0],currentStatData[1],currentStatData[2],null]
		var isRareVal = 0
		var rarity = Achivements.achievementRarity
		for r in rarity:
			if achievementID == r:
				isRareVal = rarity.get(r)
		var isRare = false
		if isRareVal == 1:
			isRare = true
		
		var hasSpoiler = false
		var spoiler = ["DISCOVER_PHAGE","DISCOVER_MOONLET","DISCOVER_FROZEN_BODY","DISCOVER_DESTROYED_HABITAT","DISCOVER_URANIUM","ESCAPE_VELOCITY","DISCOVER_ANARCHY","LEAF_20","PLAYSTYLE_B8BACK","STORY_TESLA","SHIP_CAT","TOUCH_SINGULARITY","PLAYSTYLE_CRAZYIVAN","LEVEL_TOP","STORY_BBW_DESTROYED","STORY_G4A_DESTROYED","STORY_LOTR_DESTROYED"]
		for m in spoiler:
			if m == achievementID:
				hasSpoiler = true
		
		var returnData = {"name":currentStatData[0],"isUnlocked":isUnlocked,"stat":currentStatData[1],"limit":currentStatData[2],"data":currentStatData[3],"rare":isRare,"spoiler":hasSpoiler}
		return returnData
	
	func __get_stat_data(STAT: String) -> int:
		var achievements = Achivements.achivements
		var stat = achievements.get(STAT)
		return stat
	

class _ConfigDriver:
	var scripts = [
		
	]
	var DataFormat
	var ManifestV2
	var FolderAccess
	func _init(d,m,f):
		DataFormat = d
		ManifestV2 = m
		FolderAccess = f
	
	signal config_changed()
	
	var settingsHash = 0
	var has_loaded = false
	var settings = {}
	
	var file = File.new()
	
	func __config_parse(file_path: String):
		file.open(file_path,File.READ)
		var txt = file.get_as_text()
		file.close()
		var cfg = ConfigFile.new()
		cfg.parse(txt)
		var cfg_sections = cfg.get_sections()
		var cfg_dictionary = {}
		for section in cfg_sections:
			var data = {}
			var keys = cfg.get_section_keys(section)
			for key in keys:
				var item = cfg.get_value(section,key)
				data.merge({key:item})
			cfg_dictionary.merge({section:data})
		return cfg_dictionary
	
	func __store_config(configuration: Dictionary, mod_id: String, cfg_filename : String = "Mod_Configurations" + ".cfg",DataFormat = null):
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
	
	func __store_value(mod_id, section, key, value, cfg_filename : String = "Mod_Configurations" + ".cfg"):
		mod_id = DataFormat.__array_to_string(mod_id.split("/"))
		mod_id = DataFormat.__array_to_string(mod_id.split(" "))
		section = DataFormat.__array_to_string(section.split("/"))
		var cfg_folder = "user://cfg/"
		var profiles_dir = "user://cfg/.profiles/"
		var cfg = ConfigFile.new()
		cfg.load(cfg_folder+cfg_filename)
		var modSection = mod_id + "/" + section
		cfg.set_value(modSection,key,value)
		var profile = cfg.get_value("HevLib/HEVLIB_CONFIG_SECTION_DRIVERS","profile_name","default")
		
		cfg.save(cfg_folder+cfg_filename)
		cfg.save(profiles_dir+profile + ".cfg")
		Loader.saved()
	
	func __get_config(mod_id, cfg_filename : String = "Mod_Configurations" + ".cfg") -> Dictionary:
		mod_id = DataFormat.__array_to_string(mod_id.split("/"))
		mod_id = DataFormat.__array_to_string(mod_id.split(" "))
		var cfg_folder = "user://cfg/"
		var cfg = ConfigFile.new()
		var error = cfg.load(cfg_folder+cfg_filename)
		if error != OK:
			return {}
		var dictionary = {}
		var config_sections = cfg.get_sections()
		for section in config_sections:
			var split = section.split("/")
			if split[0] == mod_id:
				var sub = {}
				var keys = cfg.get_section_keys(section)
				for key in keys:
					var value = cfg.get_value(section, key)
					sub.merge({key:value})
				dictionary.merge({split[1]:sub})
		return dictionary
	
	func __get_value(mod_id: String, section: String, key: String, cfg_filename : String = "Mod_Configurations" + ".cfg"):
		mod_id = DataFormat.__array_to_string(mod_id.split("/"))
		mod_id = DataFormat.__array_to_string(mod_id.split(" "))
		var cfg_folder = "user://cfg/"
		
		var cfg = ConfigFile.new()
		var error = cfg.load(cfg_folder+cfg_filename)
		if error != OK:
	#		Debug.l("HevLib Config File: Error loading settings %s" % error)
			return {}
		var full = mod_id+"/"+section
		if cfg.has_section(full):
			var keys = cfg.get_section_keys(full)
			if key in keys:
				var data = cfg.get_value(full,key)
				return data
			else:
				return null
		else:
			return null
	
	func __load_configs(cfg_filename : String = "Mod_Configurations" + ".cfg"):
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
		var current_config = __config_parse(cfg_file)
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
			var data = __get_config(mod)
			for section in configs[mod]:
				var sectData = configs[mod][section]
				for key in sectData:
					var key_data = sectData[key]
					if key_data["type"].to_lower() == "input":
						var p = __get_value(mod,section,key)
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
	
	func __set_button_focus(button,check_button):
		var parent = button.get_parent()
		var children = parent.get_children()
		var pos = button.get_position_in_parent()
		var icon_button
		var reset_button
		match button.get_script().get_path():
			"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/option_button.gd":
				icon_button = button.get_node("button/Label/LABELBUTTON")
				reset_button = button.get_node("button/reset")
	#		"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/action.gd":
	#			icon_button = button.get_node("Label/LABELBUTTON")
	#			reset_button = Button.new()
			_:
				icon_button = button.get_node("Label/LABELBUTTON")
				reset_button = button.get_node("reset")
		
		if children.size() == 1:
			icon_button.focus_neighbour_top = "."
			reset_button.focus_neighbour_top = "."
			check_button.focus_neighbour_top = "."
	#		icon_button.focus_neighbour_bottom = "."
	#		reset_button.focus_neighbour_bottom = "."
	#		check_button.focus_neighbour_bottom = "."
		elif pos == 0:
			icon_button.focus_neighbour_top = "."
			reset_button.focus_neighbour_top = "."
			check_button.focus_neighbour_top = "."
			var script_path = parent.get_child(pos+1).get_script().get_path()
			
			match parent.get_child(pos + 1).get_script().get_path():
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/option_button.gd":
					icon_button.focus_neighbour_bottom = icon_button.get_path_to(parent.get_child(pos + 1).get_node("button/Label/LABELBUTTON"))
					reset_button.focus_neighbour_bottom = reset_button.get_path_to(parent.get_child(pos + 1).get_node("button/reset"))
				_:
					icon_button.focus_neighbour_bottom = icon_button.get_path_to(parent.get_child(pos + 1).get_node("Label/LABELBUTTON"))
					reset_button.focus_neighbour_bottom = reset_button.get_path_to(parent.get_child(pos + 1).get_node("reset"))
			
			match script_path:
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/bool.gd":
					check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node("CheckButton"))
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/action.gd":
					check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node("Button"))
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/int-float.gd":
					var style = parent.get_child(pos+1).style
					check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node_or_null(style))
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/string.gd":
					check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node("LineEdit"))
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/option_button.gd":
					check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node("OptionButton"))
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/input.gd":
					check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node("Label/LABELBUTTON"))
				_:
					breakpoint
		elif pos == children.size() - 1:
			pass
	#		icon_button.focus_neighbour_bottom = "."
	#		reset_button.focus_neighbour_bottom = "."
	#		check_button.focus_neighbour_bottom = "."

			var script_path = parent.get_child(pos-1).get_script().get_path()
			
			match parent.get_child(pos - 1).get_script().get_path():
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/option_button.gd":
					icon_button.focus_neighbour_top = icon_button.get_path_to(parent.get_child(pos - 1).get_node("button/Label/LABELBUTTON"))
					reset_button.focus_neighbour_top = reset_button.get_path_to(parent.get_child(pos - 1).get_node("button/reset"))
				_:
					icon_button.focus_neighbour_top = icon_button.get_path_to(parent.get_child(pos - 1).get_node("Label/LABELBUTTON"))
					reset_button.focus_neighbour_top = reset_button.get_path_to(parent.get_child(pos - 1).get_node("reset"))
			match script_path:
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/bool.gd":
					check_button.focus_neighbour_top = check_button.get_path_to(parent.get_child(pos - 1).get_node("CheckButton"))
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/action.gd":
					check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos - 1).get_node("Button"))
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/int-float.gd":
					var style = parent.get_child(pos-1).style
					check_button.focus_neighbour_top = check_button.get_path_to(parent.get_child(pos - 1).get_node_or_null(style))
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/string.gd":
					check_button.focus_neighbour_top = check_button.get_path_to(parent.get_child(pos - 1).get_node("LineEdit"))
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/option_button.gd":
					check_button.focus_neighbour_top = check_button.get_path_to(parent.get_child(pos - 1).get_node("OptionButton"))
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/input.gd":
					check_button.focus_neighbour_top = check_button.get_path_to(parent.get_child(pos - 1).get_node("Label/LABELBUTTON"))
				_:
					breakpoint
		else:
			var script_path = parent.get_child(pos-1).get_script().get_path()
			match parent.get_child(pos - 1).get_script().get_path():
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/option_button.gd":
					icon_button.focus_neighbour_top = icon_button.get_path_to(parent.get_child(pos - 1).get_node("button/Label/LABELBUTTON"))
					reset_button.focus_neighbour_top = reset_button.get_path_to(parent.get_child(pos - 1).get_node("button/reset"))
				_:
					icon_button.focus_neighbour_top = icon_button.get_path_to(parent.get_child(pos - 1).get_node("Label/LABELBUTTON"))
					reset_button.focus_neighbour_top = reset_button.get_path_to(parent.get_child(pos - 1).get_node("reset"))
			match script_path:
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/bool.gd":
					check_button.focus_neighbour_top = check_button.get_path_to(parent.get_child(pos - 1).get_node("CheckButton"))
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/action.gd":
					check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos - 1).get_node("Button"))
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/int-float.gd":
					var style = parent.get_child(pos-1).style
					check_button.focus_neighbour_top = check_button.get_path_to(parent.get_child(pos - 1).get_node_or_null(style))
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/string.gd":
					check_button.focus_neighbour_top = check_button.get_path_to(parent.get_child(pos - 1).get_node("LineEdit"))
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/option_button.gd":
					check_button.focus_neighbour_top = check_button.get_path_to(parent.get_child(pos - 1).get_node("OptionButton"))
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/input.gd":
					check_button.focus_neighbour_top = check_button.get_path_to(parent.get_child(pos - 1).get_node("Label/LABELBUTTON"))
				_:
					breakpoint

			var script_path2 = parent.get_child(pos+1).get_script().get_path()
			
			match parent.get_child(pos + 1).get_script().get_path():
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/option_button.gd":
					icon_button.focus_neighbour_bottom = icon_button.get_path_to(parent.get_child(pos + 1).get_node("button/Label/LABELBUTTON"))
					reset_button.focus_neighbour_bottom = reset_button.get_path_to(parent.get_child(pos + 1).get_node("button/reset"))
				_:
					icon_button.focus_neighbour_bottom = icon_button.get_path_to(parent.get_child(pos + 1).get_node("Label/LABELBUTTON"))
					reset_button.focus_neighbour_bottom = reset_button.get_path_to(parent.get_child(pos + 1).get_node("reset"))
			match script_path2:
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/bool.gd":
					check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node("CheckButton"))
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/action.gd":
					check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node("Button"))
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/int-float.gd":
					var style = parent.get_child(pos+1).style
					check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node_or_null(style))
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/string.gd":
					check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node("LineEdit"))
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/option_button.gd":
					check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node("OptionButton"))
				"res://HevLib/ui/mod_menu/settings_menus/entry_inputs/input.gd":
					check_button.focus_neighbour_bottom = check_button.get_path_to(parent.get_child(pos + 1).get_node("Label/LABELBUTTON"))
				_:
					breakpoint
	
	func __change_made():
		var shs = settings.hash()
		if shs != settingsHash:
			emit_signal("config_changed")
			settingsHash = shs
	
	

class _DataFormat:
	var scripts = [
		
	]
	
	var file = File.new()
	
	func __array_to_string(arr: Array) -> String:
		var s = ""
		for i in arr:
			s += String(i)
		return s
	
	func __format_for_large_numbers(num) -> String:
		var length = num.length()
		if length > 3:
			var concat = []
			var times = length/3
			var offset = length % 3
			var count = 0
			if offset > 0:
				var spl = str(num).substr(0, offset)
				concat.append(spl)
			while times > 0:
				var spl = str(num).substr(offset + (count * 3), 3)
				concat.append(spl)
				count += 1
				times -= 1
			var total = ""
			for m in concat:
				if total == "":
					total = m
				else:
					total = total + TranslationServer.translate("SEPARATOR_THOUSAND") + m
			return total
		else:
			return str(num)
	
	func __compare_with_byte_array(input_string: String, comparison_string: String) -> bool:
		var input_array = input_string.to_utf8()
		var comparison_array = comparison_string.to_utf8()
		var input_size = input_array.size()
		var comparison_size = comparison_array.size()
		if input_size != comparison_size:
			return false
		var isize = input_size
		while isize > 0:
			isize = isize - 1
			if input_array[isize] != comparison_array[isize]:
				return false
		return true
	
	func __rotate_point(point: Vector2, angle: float, degrees:bool = true) -> Vector2:
		if degrees:
			angle = deg2rad(angle)
		angle = -angle
		var x = point[0]
		var y = point[1]
		var xca = x*cos(angle)
		var ysa = y*sin(angle)
		var yca = y*cos(angle)
		var xsa = x*sin(angle)
		var p2 = Vector2(0,yca+xsa)
		p2.x = xca-ysa
		return p2
	
	func __get_vanilla_version(get_from_files: bool = false) -> Array:
		var version = [1,0,0]
		if get_from_files:
			var pls = File.new()
			var v = "res://VersionLabel.tscn"
			if pls.file_exists(v):
				Debug.l("get_vanilla_version: Version Label exists")
			else:
				v = "res://VersionLabel.tscn.converted.res"
				Debug.l("get_vanilla_version: Version Label does not exist")
				
				if pls.file_exists(v):
					Debug.l("get_vanilla_version: Version Label RES exists")
				else:
					v = "res://.autoconverted/VersionLabel.tscn.converted.res"
					Debug.l("get_vanilla_version: Version Label RES does not exist")
					
					if pls.file_exists(v):
						Debug.l("get_vanilla_version: Version Label RES AC exists")
					else:
						v = ""
						Debug.l("get_vanilla_version: Version Label RES AC does not exist")
			if v == "":
				Debug.l("get_vanilla_version: Returning default due to no available scene")
				return version
			pls.open(v,File.READ)
			if v.ends_with(".res"):
				var txt = []
				while not pls.eof_reached():
					var line = pls.get_line()
					if line:
						txt.append(line)
				for ln in txt:
					var split = ln.split(".")
					if split.size() == 3:
						var all_ints = true
						for item in split:
							var tp = typeof(item)
							if tp != TYPE_INT:
								all_ints = false
						if all_ints:
							version[0] = int(split[0])
							version[1] = int(split[1])
							version[2] = int(split[2])
			else:
				var ptxt = pls.get_as_text(true)
				for line in ptxt.split("\n"):
					if line.begins_with("text = "):
						var data = line.split(" = ")[1].split(".")
						version[0] = int(data[0])
						version[1] = int(data[1])
						version[2] = int(data[2])
			pls.close()
		else:
			var pls = CurrentGame.version
			var data = pls.split(".")
			version[0] = int(data[0])
			version[1] = int(data[1])
			version[2] = int(data[2])
		return version
	
	func __sift_dictionary(dictionary: Dictionary,search_keys: Array) -> Array:
		var returning_keys = []
		for key in dictionary:
			if key in search_keys:
				returning_keys.append(key)
			var kdata = dictionary[key]
			if kdata in search_keys:
				returning_keys.append(kdata)
			if typeof(kdata) == TYPE_DICTIONARY:
				returning_keys.append_array(__sift_dictionary(kdata,search_keys))
		return returning_keys
	
	func __convert_arr_to_vec2arr(array: Array) -> PoolVector2Array:
		var converted = PoolVector2Array([])
		var size = array.size()
		if size % 2 == 1:
			Debug.l("Cannot convert array to PoolVector2Array with an odd number of entries")
			return PoolVector2Array([])
		var index = 0
		while index < size:
			var a = array[index]
			var b = array[index + 1]
			var atype = typeof(a)
			var btype = typeof(b)
			if atype == TYPE_INT:
				pass
			elif atype == TYPE_REAL:
				pass
			else:
				Debug.l("Cannot convert type %s for PoolVector2Array" % atype)
				return PoolVector2Array([])
			if btype == TYPE_INT:
				pass
			elif btype == TYPE_REAL:
				pass
			else:
				Debug.l("Cannot convert type %s for PoolVector2Array" % btype)
				return PoolVector2Array([])
			var pooling = Vector2(a,b)
			converted.append(pooling)
			index += 2
		return converted
	
	func __compare_versions(primary_major : int,primary_minor : int,primary_bugfix : int, compare_major : int, compare_minor : int, compare_bugfix : int) -> bool:
		var mod_exists = true
		if primary_major < compare_major:
			mod_exists = false
		elif primary_major == compare_major:
			if primary_minor < compare_minor:
				mod_exists = false
			elif primary_minor == compare_minor:
				if primary_bugfix < compare_bugfix:
					mod_exists = false
		return mod_exists
	
	func __sift_ship_config(dictionary: Dictionary,search_keys: Array,cfgs_to_ignore:Array,parent = "") -> Array:
		for i in cfgs_to_ignore:
			dictionary.erase(i)
		var arr = []
		var splitter = "."
		var prefab = ""
		if parent != "":
			prefab = parent + splitter
		for key in dictionary:
			var kdata = dictionary[key]
			var p = prefab + key
			match typeof(kdata):
				TYPE_STRING:
					if kdata in search_keys:
						arr.append(p + splitter + kdata)
				TYPE_DICTIONARY:
					arr.append_array(__sift_ship_config(kdata,search_keys,[],p))
		return arr
	
	func __get_script_constant_map_without_load(script_path) -> Dictionary:
		var filepath = "user://cache/.HevLib_Cache/"
		var pathway = __trim_scripts(script_path)
		if pathway[2].size() == 0:
			return {}
		var file = File.new()
		var dir = Directory.new()
		var n = filepath + str(Time.get_ticks_usec()) + ".gd"
		file.open(n,File.WRITE)
		file.store_string(pathway[0])
		file.close()
		var dict = {}
		var l = load(n).new().get_script().get_script_constant_map()
		for i in pathway[2]:
			dict[i] = l[i]
		dir.remove(n)
		return dict
		
	const function_prefixes = ["func ","static func ","remote func ","master func ","puppet func ","remotesync func ","mastersync func ","puppetsync func ","sync func "]
	func __trim_scripts(file_path : String):
		var file = File.new()
		file.open(file_path,File.READ)
		var data = file.get_as_text(true)
		file.close()
		var streaming = false
		var this_stream : String = ""
		var concat : String = ""
		var const_names = []
		var var_names = []
		var lines = data.split("\n")
		for line in lines:
			var result : String = ""
			var is_part_of_string = false
			var prev_char_escape = false
			while line != "":
				var part:String = line.substr(0,1)
				if part == "\\":
					prev_char_escape = !prev_char_escape
				else:
					prev_char_escape = false
				if part == "\"" and not prev_char_escape:
					is_part_of_string = !is_part_of_string
				if part == "#" and (not is_part_of_string and not prev_char_escape):
					break
				line.erase(0,1)
				result += part
			line = result
			var has_prefix = false
			for prefix in function_prefixes:
				if line.begins_with(prefix):
					has_prefix = true
			if has_prefix:
				if streaming:
					concat = concat + this_stream.strip_edges() + "\n"
					this_stream = ""
					streaming = false
			elif line.begins_with("const "):
				if streaming:
					concat = concat + this_stream.strip_edges() + "\n"
					this_stream = ""
					streaming = false
				var cname = line.split("=",false)[0].strip_edges().split("const ",true)[1].strip_edges().split(":",false)[0].strip_edges()
				const_names.append(cname)
				streaming = true
			elif line.begins_with("var "):
				if streaming:
					concat = concat + this_stream.strip_edges() + "\n"
					this_stream = ""
					streaming = false
				var vname = line.split("=",false)[0].strip_edges().split("var ",true)[1].strip_edges().split(":",false)[0].strip_edges()
				var_names.append(vname)
				streaming = true
			elif line.begins_with("export") and " var " in line:
				if streaming:
					concat = concat + this_stream.strip_edges() + "\n"
					this_stream = ""
					streaming = false
				var vname = line.split("=",false)[0].strip_edges().split("var ",true)[1].strip_edges().split(":",false)[0].strip_edges()
				var_names.append(vname)
				streaming = true
			elif line.begins_with("onready") and " var " in line:
				if streaming:
					concat = concat + this_stream.strip_edges() + "\n"
					this_stream = ""
					streaming = false
				var vname = line.split("=",false)[0].strip_edges().split("var ",true)[1].strip_edges().split(":",false)[0].strip_edges()
				var_names.append(vname)
				streaming = true
			elif line.begins_with("extends "):
				if streaming:
					concat = concat + this_stream.strip_edges() + "\n"
					this_stream = ""
					streaming = false
				streaming = true
			if streaming:
				this_stream = this_stream + "\n" + line
		if streaming:
			concat = concat + this_stream.strip_edges() + "\n"
			this_stream = ""
			streaming = false
		return [concat,var_names,const_names]
		
		

class _DriverManagement:
	var scripts = [
		
	]
	var FolderAccess
	var DataFormat
	var ManifestV2
	func _init(f,d,m):
		FolderAccess = f
		DataFormat = d
		ManifestV2 = m
	
	func __get_drivers(get_ids : Array = []) -> Array:
		var is_onready = CurrentGame != null
		var running_in_debugged = false
		var debugged_defined_mods = []
		var onready_mod_paths = []
		var onready_mod_folders = []
		var folders = FolderAccess.__fetch_folder_files("res://", true, true)
		
		var mod_drivers = []
		
		if is_onready:
			var mods = ModLoader.get_children()
			for mod in mods:
				var path = mod.get_script().get_path()
				onready_mod_paths.append(path)
				var split = path.split("/")
				onready_mod_folders.append(split[2])
		else:
			var ps = DataFormat.__get_script_constant_map_without_load("res://ModLoader.gd")
			for item in ps:
				if item == "is_debugged":
					running_in_debugged = true
					var pf = File.new()
					pf.open("res://ModLoader.gd",File.READ)
					var fs = pf.get_as_text(true)
					pf.close()
					var lines = fs.split("\n")
					var reading = false
					var contents = []
					for line in lines:

						if line.begins_with("var addedMods"):
							reading = true
						if reading:
							var split = line.split("\"")
							if split.size() > 1 and split.size() == 3:
								if split[0].begins_with("#"):
									contents.append(split[1])

					debugged_defined_mods = contents.duplicate(true)
		
		if not is_onready and onready_mod_folders.size() == 0:
			var mods_to_avoid = []
			for folder in folders:
				var semi_root = folder.split("/")[2]
				if semi_root.begins_with("."):
					continue
							
				if folder.ends_with("/"):
					
					if running_in_debugged:
						for mod in debugged_defined_mods:
							var home = mod.split("/")[2]
							if home == semi_root:
									mods_to_avoid.append(home)
					var folderCheck = FolderAccess.__fetch_folder_files(folder,true)
					var has_mod = false
					var has_manifest = false
					var modmain_path = ""
					var manifest_path = ""
					for item in folderCheck:
						var modEntryName = item.to_lower()
						if modEntryName.begins_with("modmain") and modEntryName.ends_with(".gd"):
							if (folder + item) in debugged_defined_mods:
								has_mod = false
							else:
								has_mod = true
							modmain_path = item
						if modEntryName.begins_with("mod") and modEntryName.ends_with("manifest"):
							has_manifest = true
							manifest_path = item
						
					if has_mod:
						var this_mod_data = {"drivers":{}}
						var id = ""
						if has_manifest:
							var manifest = ManifestV2.__parse_file_as_manifest(folder + manifest_path)
							id = manifest.get("mod_information",{}).get("id","")
						if id != "":
							this_mod_data.merge({"id":id})
						var mm_prio = 0
						var modmain = DataFormat.__get_script_constant_map_without_load(folder + modmain_path)
						if "MOD_PRIORITY" in modmain:
							mm_prio = modmain["MOD_PRIORITY"]
						this_mod_data.merge({"priority":mm_prio})
						
						
						if "HEVLIB_EQUIPMENT_DRIVER_TAGS/" in folderCheck:
							var driverFolder = folder + "HEVLIB_EQUIPMENT_DRIVER_TAGS/"
							for driver in FolderAccess.__fetch_folder_files(driverFolder):
								if driver in this_mod_data["drivers"]:
									pass
								else:
									this_mod_data["drivers"].merge({driver:{}})
								var consts = DataFormat.__get_script_constant_map_without_load(driverFolder + driver)
								for i in consts:
									this_mod_data["drivers"][driver].merge({i:consts[i]})
						if "HEVLIB_MENU/" in folderCheck:
							var driverFolder = folder + "HEVLIB_MENU/"
							for driver in FolderAccess.__fetch_folder_files(driverFolder):
								if driver in this_mod_data["drivers"]:
									pass
								else:
									this_mod_data["drivers"].merge({driver:{}})
								var consts = DataFormat.__get_script_constant_map_without_load(driverFolder + driver)
								for i in consts:
									this_mod_data["drivers"][driver].merge({i:consts[i]})
						if "HEVLIB_MINERAL_DRIVER_TAGS/" in folderCheck:
							var driverFolder = folder + "HEVLIB_MINERAL_DRIVER_TAGS/"
							for driver in FolderAccess.__fetch_folder_files(driverFolder):
								if driver in this_mod_data["drivers"]:
									pass
								else:
									this_mod_data["drivers"].merge({driver:{}})
								var consts = DataFormat.__get_script_constant_map_without_load(driverFolder + driver)
								for i in consts:
									this_mod_data["drivers"][driver].merge({i:consts[i]})
						if "HEVLIB_DRIVERS/" in folderCheck:
							var driverFolder = folder + "HEVLIB_DRIVERS/"
							for driver in FolderAccess.__fetch_folder_files(driverFolder):
								if driver in this_mod_data["drivers"]:
									pass
								else:
									this_mod_data["drivers"].merge({driver:{}})
								var consts = DataFormat.__get_script_constant_map_without_load(driverFolder + driver)
								for i in consts:
									this_mod_data["drivers"][driver].merge({i:consts[i]})
						this_mod_data.merge({"mod_directory":folder})
						if this_mod_data["drivers"].size() > 0:
							if (get_ids.size()) == 0 or (get_ids.size() > 0 and id in get_ids):
								mod_drivers.append(this_mod_data)
		else:
			var mods = ManifestV2.__get_mod_data()["mods"]
			for mod in mods:
				var this_mod_data = {"drivers":{}}
				
				var mod_data = mods[mod]
				var prio = mod_data.get("priority",0)
				this_mod_data.merge({"priority":prio})
				var id = ""
				if mod_data["manifest"]["has_manifest"]:
					id = mod_data["manifest"]["manifest_data"]["mod_information"]["id"]
				if id != "":
					this_mod_data.merge({"id":id})
				
	#			var mp = mod_data["node"].get_script().get_path()
				
				var folder = mod.split(mod.split("/")[mod.split("/").size() - 1])[0]
				var folderCheck = FolderAccess.__fetch_folder_files(folder,true)
				
				
				if "HEVLIB_EQUIPMENT_DRIVER_TAGS/" in folderCheck:
					var driverFolder = folder + "HEVLIB_EQUIPMENT_DRIVER_TAGS/"
					for driver in FolderAccess.__fetch_folder_files(driverFolder):
						if driver in this_mod_data["drivers"]:
							pass
						else:
							this_mod_data["drivers"].merge({driver:{}})
						var consts = DataFormat.__get_script_constant_map_without_load(driverFolder + driver)
						for i in consts:
							this_mod_data["drivers"][driver].merge({i:consts[i]})
				if "HEVLIB_MENU/" in folderCheck:
					var driverFolder = folder + "HEVLIB_MENU/"
					for driver in FolderAccess.__fetch_folder_files(driverFolder):
						if driver in this_mod_data["drivers"]:
							pass
						else:
							this_mod_data["drivers"].merge({driver:{}})
						var consts = DataFormat.__get_script_constant_map_without_load(driverFolder + driver)
						for i in consts:
							this_mod_data["drivers"][driver].merge({i:consts[i]})
				if "HEVLIB_MINERAL_DRIVER_TAGS/" in folderCheck:
					var driverFolder = folder + "HEVLIB_MINERAL_DRIVER_TAGS/"
					for driver in FolderAccess.__fetch_folder_files(driverFolder):
						if driver in this_mod_data["drivers"]:
							pass
						else:
							this_mod_data["drivers"].merge({driver:{}})
						var consts = DataFormat.__get_script_constant_map_without_load(driverFolder + driver)
						for i in consts:
							this_mod_data["drivers"][driver].merge({i:consts[i]})
				if "HEVLIB_DRIVERS/" in folderCheck:
					var driverFolder = folder + "HEVLIB_DRIVERS/"
					for driver in FolderAccess.__fetch_folder_files(driverFolder):
						if driver in this_mod_data["drivers"]:
							pass
						else:
							this_mod_data["drivers"].merge({driver:{}})
						var consts = DataFormat.__get_script_constant_map_without_load(driverFolder + driver)
						for i in consts:
							this_mod_data["drivers"][driver].merge({i:consts[i]})
				this_mod_data.merge({"mod_directory":folder})
				if this_mod_data["drivers"].size() > 0:
					if (get_ids.size()) == 0 or (get_ids.size() > 0 and id in get_ids):
						mod_drivers.append(this_mod_data)
		mod_drivers.sort_custom(self,"__compare_driver_dictionaries")
		return mod_drivers
	
	func __compare_driver_dictionaries(a, b):
		var aPrio = a.get("priority",0)
		var bPrio = b.get("priority",0)
		if aPrio != bPrio:
			return aPrio < bPrio

		
		var aPath = a.get("mod_directory")
		var bPath = b.get("mod_directory")
		if aPath != bPath:
			return aPath < bPath

		return false
	
	
	

class _Equipment:
	var scripts = [
		
	]
	
	var DataFormat
	func _init(d):
		DataFormat = d
	
	func __make_equipment(equipment_data: Dictionary) -> Node:
		var num_val = equipment_data.get("num_val", -1)
		var system = equipment_data.get("system", "")
		var capability_lock = equipment_data.get("capability_lock", false)
		var name_override = equipment_data.get("name_override", "")
		var description = equipment_data.get("description", "")
		var manual = equipment_data.get("manual", "")
		var specs = equipment_data.get("specs", "")
		var price = equipment_data.get("price", 0)
		var test_protocol = equipment_data.get("test_protocol", "fire")
		var default = equipment_data.get("default", false)
		var control = equipment_data.get("control", "")
		var story_flag = equipment_data.get("story_flag", "")
		var story_flag_min = equipment_data.get("story_flag_min", -1)
		var story_flag_max = equipment_data.get("story_flag_max", -1)
		var warn_if_thermal_below = equipment_data.get("warn_if_thermal_below", 0)
		var warn_if_electric_below = equipment_data.get("warn_if_electric_below", 0)
		var sticker_price_format = equipment_data.get("sticker_price_format", "%s E$")
		var sticker_price_multi_format = equipment_data.get("sticker_price_multi_format", "%s E$ (x%d)")
		var installed_color = equipment_data.get("installed_color", Color(0.0, 1.0, 0.0, 1.0))
		var disabled_color = equipment_data.get("disabled_color", Color(0.2, 0.2, 0.2, 1.0))
		var slots = equipment_data.get("slots",[])
		var alignment = equipment_data.get("alignment","")
		var equipment_type = equipment_data.get("equipment_type","")
		var slot_type = equipment_data.get("slot_type","")
		var restriction = equipment_data.get("restriction","")
	#	var equip_node = preload("res://HevLib/scenes/equipment/hardpoints/EquipmentItemTemplate.tscn").instance() # Old preload. Commented out because of possible bug with it
		var equip_node = load("res://HevLib/scenes/equipment/hardpoints/unmodified/EquipmentItemTemplate.tscn").instance()
		equip_node.numVal = num_val
		equip_node.system = system
		equip_node.name = system
		equip_node.capabilityLock = capability_lock
		equip_node.nameOverride = name_override
		equip_node.description = description
		equip_node.manual = manual
		equip_node.specs = specs
		equip_node.price = price
		equip_node.testProtocol = test_protocol
		equip_node.default = default
		equip_node.control = control
		equip_node.storyFlag = story_flag
		equip_node.storyFlagMin = story_flag_min
		equip_node.storyFlagMax = story_flag_max
		equip_node.warnIfThermalBelow = warn_if_thermal_below
		equip_node.warnIfElectricBelow = warn_if_electric_below
		equip_node.stickerPriceFormat = sticker_price_format
		equip_node.stickerPriceMultiFormat = sticker_price_multi_format
		equip_node.installedColor = installed_color
		equip_node.disbledColor = disabled_color
		equip_node.slots = slots
		equip_node.alignment = alignment
		equip_node.equipment_type = equipment_type
		equip_node.slot_type = slot_type
		equip_node.restriction = restriction
		equip_node.data_dictionary = str(equipment_data)
		return equip_node
	
	func __make_slot(slot_data: Dictionary) -> Node:
		var systemSlot = slot_data.get("system_slot", "")
		var slotNodeName = slot_data.get("slot_node_name", "MISSING_SLOT_NAME")
		var slotDisplayName = slot_data.get("slot_display_name", "SLOT_MISSING_DATA")
		var hasNone = slot_data.get("has_none", true)
		var alwaysDisplay = slot_data.get("always_display", true)
		var restrictType = slot_data.get("restrict_type", "")
		var openByDefault = slot_data.get("open_by_default", false)
		var limitShips = slot_data.get("limit_ships", [])
		var invertLimitLogic = slot_data.get("invert_limit_logic", false)
		var add_vanilla_equipment = slot_data.get("add_vanilla_equipment", true)
	#	var slotTemplate = preload("res://HevLib/scenes/equipment/hardpoints/WeaponSlotUpgradeTemplate.tscn").instance() # Old preload. Commented out because of possible bug with it
		var slotTemplate = load("res://HevLib/scenes/equipment/hardpoints/unmodified/WeaponSlotUpgradeTemplate.tscn").instance()
		var slot_type = slot_data.get("slot_type","HARDPOINT")
		var hardpoint_type = slot_data.get("hardpoint_type","")
		var alignment = slot_data.get("alignment","")
		var restriction = slot_data.get("restriction","")
		var override_additive = slot_data.get("override_additive",[])
		var override_subtractive = slot_data.get("override_subtractive",[])
		if hasNone:
	#		var itemTemplate = load("res://HevLib/scenes/equipment/hardpoints/EquipmentItemTemplate.tscn").instance() # Old load. Commented out because of possible bug with it
			var itemTemplate = load("res://HevLib/scenes/equipment/hardpoints/unmodified/EquipmentItemTemplate.tscn").instance()
			itemTemplate.slot = "weaponSlot.main.type"
			itemTemplate.system = "SYSTEM_NONE"
			itemTemplate.default = true
			itemTemplate.name = "None"
			slotTemplate.get_node("VBoxContainer").add_child(itemTemplate)
		slotTemplate.slot = systemSlot
		slotTemplate.name = slotNodeName
		slotTemplate.get_node("VBoxContainer/HBoxContainer/CheckButton").text = slotDisplayName
		slotTemplate.always = alwaysDisplay
		slotTemplate.restrictType = restrictType
		slotTemplate.openByDefault = openByDefault
		slotTemplate.limit_ships = limitShips
		slotTemplate.invert_limit_logic = invertLimitLogic
		slotTemplate.add_vanilla_equipment = add_vanilla_equipment
		slotTemplate.slot_type = slot_type
		slotTemplate.hardpoint_type = hardpoint_type
		slotTemplate.alignment = alignment
		slotTemplate.restriction = restriction
		slotTemplate.override_additive = override_additive
		slotTemplate.override_subtractive = override_subtractive
		slotTemplate.data_dictionary = str(slot_data)
		return slotTemplate
	
	func __add_vanilla_equipment(tags: Dictionary, hardpoint_types: Array, alignments: Array, equipment_types: Array, slot_types: Array, hardpoint_defaults: Dictionary):
		var type = tags.get("type")
		if not type in slot_types:
			return []
		if type == "HARDPOINT":
			var alignment = tags.get("alignment", "")
			var equipment = tags.get("equipment")
			var result = __match_vanilla(type, alignment, equipment, alignments)
			return result
		else:
			var alignment = ""
			var equipment = tags.get("equipment")
			var alignments3 = []
			var result = __match_vanilla(type, alignment, equipment, alignments3)
			return result
	
	func __match_vanilla(type: String, align_to_match: String, desired_equipment: Array, list_of_alignments: Array):
		var vanilla = DataFormat.__get_script_constant_map_without_load("res://HevLib/scenes/equipment/vanilla_defaults/equipment.gd")
		var matching = []
		for item in vanilla:
			var itemDict = vanilla.get(item)
			var ps = itemDict.get("slot_groups")
			var itemSlotType = ps.get("slot_type","")
			if itemSlotType == type:
				var itemAlign = ps.get("alignment", "")
				var itemType = ps.get("tags","")
				var alignmentMatches = true
				if itemAlign in list_of_alignments and not itemAlign == "":
					if not itemAlign == align_to_match:
						alignmentMatches = false
				if alignmentMatches and itemType in desired_equipment:
					matching.append(itemDict)
		return matching
	
	func __make_upgrades_scene(is_onready: bool = true):
		var f = load("res://HevLib/scenes/equipment/make_upgrades_scene.gd").new()
		f.make_upgrades_scene(is_onready)
	
	func __make_equipment_for_scene(equipment_data: Dictionary, slot_node_name : String, system_slot: String) -> String:
		var num_val = equipment_data.get("num_val", -1)
		var system = equipment_data.get("system", "")
		var capability_lock = equipment_data.get("capability_lock", false)
		var name_override = equipment_data.get("name_override", "")
		var description = equipment_data.get("description", "")
		var manual = equipment_data.get("manual", "")
		var specs = equipment_data.get("specs", "")
		var price = equipment_data.get("price", 0)
		var test_protocol = equipment_data.get("test_protocol", "fire")
		var default = equipment_data.get("default", false)
		var control = equipment_data.get("control", "")
		var story_flag = equipment_data.get("story_flag", "")
		var story_flag_min = equipment_data.get("story_flag_min", -1)
		var story_flag_max = equipment_data.get("story_flag_max", -1)
		var warn_if_thermal_below = equipment_data.get("warn_if_thermal_below", 0)
		var warn_if_electric_below = equipment_data.get("warn_if_electric_below", 0)
		var sticker_price_format = equipment_data.get("sticker_price_format", "%s E$")
		var sticker_price_multi_format = equipment_data.get("sticker_price_multi_format", "%s E$ (x%d)")
		var installed_color = equipment_data.get("installed_color", Color(0.0, 1.0, 0.0, 1.0))
		var disabled_color = equipment_data.get("disabled_color", Color(0.2, 0.2, 0.2, 1.0))
		var slots = equipment_data.get("slots",[])
		var alignment = equipment_data.get("alignment","")
		var equipment_type = equipment_data.get("equipment_type","")
		var slot_type = equipment_data.get("slot_type","")
		var restriction = equipment_data.get("restriction","")
		
		var base = "[node name=\"%s\" parent=\"VB/MarginContainer/ScrollContainer/MarginContainer/Items/%s/VBoxContainer\" instance=ExtResource( 3 )]" % [system.to_upper(),slot_node_name]
		if num_val != -1:
			base = base + "\nnumVal = " + str(num_val)
		base = base + "\nslot = \"" + system_slot + "\""
		if system != "":
			base = base + "\nsystem = \"" + system + "\""
		if capability_lock:
			base = base + "\ncapabilityLock = true"
		else:
			base = base + "\ncapabilityLock = false"
		if name_override != "":
			base = base + "\nnameOverride = \"" + name_override + "\""
		if description != "":
			base = base + "\ndescription = \"" + description + "\""
		if manual != "":
			base = base + "\nmanual = \"" + manual + "\""
		if specs != "":
			base = base + "\nspecs = \"" + specs + "\""
		if price != 0:
			base = base + "\nprice = " + str(price)
		if test_protocol != "":
			base = base + "\ntestProtocol = \"" + test_protocol + "\""
		if default:
			base = base + "\ndefault = true"
		else:
			base = base + "\ndefault = false"
		if control != "":
			base = base + "\ncontrol = \"" + control + "\""
		if story_flag != "":
			base = base + "\nstoryFlag = \"" + story_flag + "\""
		if story_flag_min != -1:
			base = base + "\nstoryFlagMin = " + str(story_flag_min)
		if story_flag_max != -1:
			base = base + "\nstoryFlagMax = " + str(story_flag_max)
		if warn_if_thermal_below != 0:
			base = base + "\nwarnIfThermalBelow = " + str(warn_if_thermal_below)
		if warn_if_electric_below != 0:
			base = base + "\nwarnIfElectricBelow = " + str(warn_if_thermal_below)
		if sticker_price_format != "%s E$":
			base = base + "\nstickerPriceFormat = \"" + sticker_price_format + "\""
		if sticker_price_multi_format != "%s E$ (x%d)":
			base = base + "\nstickerPriceMultiFormat" + sticker_price_multi_format + "\""
		if installed_color != Color(0.0, 1.0, 0.0, 1.0):
			base = base + "\ninstalledColor = " + str(Color(0.0, 1.0, 0.0, 1.0))
		if disabled_color != Color(0.2, 0.2, 0.2, 1.0):
			base = base + "\ndisabledColor = " + str(Color(0.2, 0.2, 0.2, 1.0))
		return base
	
	func __make_slot_for_scene(slot_data: Dictionary) -> Dictionary:
		var systemSlot = slot_data.get("system_slot", "")
		var slotNodeName = slot_data.get("slot_node_name", "MISSING_SLOT_NAME")
		var slotDisplayName = slot_data.get("slot_display_name", "SLOT_MISSING_DATA")
		var hasNone = slot_data.get("has_none", true)
		var alwaysDisplay = slot_data.get("always_display", true)
		var restrictType = slot_data.get("restrict_type", "")
		var openByDefault = slot_data.get("open_by_default", false)
		var limitShips = slot_data.get("limit_ships", [])
		var preventShips = slot_data.get("prevent_ships", [])
		var add_vanilla_equipment = slot_data.get("add_vanilla_equipment", true)
		var slot_type = slot_data.get("slot_type","HARDPOINT")
		var hardpoint_type = slot_data.get("hardpoint_type","")
		var alignment = slot_data.get("alignment","")
		var restriction = slot_data.get("restriction","")
		var override_additive = slot_data.get("override_additive",[])
		var override_subtractive = slot_data.get("override_subtractive",[])
		var restrict_hold_type = slot_data.get("restrict_hold_type","")
		
		
		var base = "[node name=\"%s\" parent=\"VB/MarginContainer/ScrollContainer/MarginContainer/Items\" instance=ExtResource( 2 )]" % slotNodeName
		if systemSlot != "":
			base = base + "\nslot = \"" + systemSlot + "\""
		if alwaysDisplay:
			base = base + "\nalways = true"
		else:
			base = base + "\nalways = false"
		if openByDefault:
			base = base + "\nopenByDefault = true"
		else:
			base = base + "\nopenByDefault = false"
		if restrictType != "":
			base = base + "\nslot = \"" + restrictType + "\""
		if limitShips != []:
			var initial = base + "\nlimit_ships = ["
			var one = false
			for item in limitShips:
				if one == false:
					one = true
				else:
					initial = initial + ", "
				initial = initial + "\"" + item + "\""
			initial = initial + "]"
			base = initial
		if preventShips != []:
			var initial = base + "\nprevent_ships = ["
			var one = false
			for item in preventShips:
				if one == false:
					one = true
				else:
					initial = initial + ", "
				initial = initial + "\"" + item + "\""
			initial = initial + "]"
			base = initial
		if restrict_hold_type != "":
			base = base + "\nrestrict_hold_type = \"%s\"" % restrict_hold_type
		base = base + "\n\n[node name=\"CheckButton\" parent=\"VB/MarginContainer/ScrollContainer/MarginContainer/Items/%s/VBoxContainer/HBoxContainer\"]\ntext = \"%s\"" % [slotNodeName,slotDisplayName]
		
		if hasNone:
			var dta = __make_equipment_for_scene({"system":"SYSTEM_NONE","default":true,"name":"None"}, slotNodeName, systemSlot)
			base = base + "\n\n" + dta
		var editable_path = "[editable path=\"VB/MarginContainer/ScrollContainer/MarginContainer/Items/%s\"]" % slotNodeName
		
		var dict = {}
		dict.merge(
			{
				"add_vanilla_equipment":add_vanilla_equipment,
				"hardpoint_type":hardpoint_type,
				"alignment":alignment,
				"restriction":restriction,
				"override_additive":override_additive,
				"override_subtractive":override_subtractive,
			}
		)
		
		return {slotNodeName:[base, editable_path, dict]}
	
	
	

class _Events:
	var scripts = [
		preload("res://HevLib/events/event_handler.gd"),
		preload("res://HevLib/events/clear_event.gd"),
	]
	
	func __spawn_event(event, thering):
		var f = scripts[0].new()
		f.spawn_event(event,thering)
	
	func __clear_event(event,ring):
		var f = scripts[1].new()
		f.clear_event(event,ring)
	

class _FileAccess:
	var scripts = [
		
	]
	
	func __get_file_content(file: String) -> String:
		var n = File.new()
		n.open(file, File.READ)
		var s = n.get_as_text()
		n.close()
		return s
	
	func __config_parse(file: String) -> Dictionary:
		var f2 = File.new()
		f2.open(file,File.READ)
		var txt = f2.get_as_text()
		f2.close()
	#	Debug.l("Config Parse: Loading config as ||\n\n%s\n\n||" % txt)
		var cfg = ConfigFile.new()
		cfg.parse(txt)
		var cfg_sections = cfg.get_sections()
		var cfg_dictionary = {}
		for section in cfg_sections:
			var data = {}
			var keys = cfg.get_section_keys(section)
			for key in keys:
				var item = cfg.get_value(section,key)
				data.merge({key:item})
			cfg_dictionary.merge({section:data})
		return cfg_dictionary
	
	func __copy_file(file, folder):
		var prepfile = ProjectSettings.localize_path(file)
		var fn = prepfile.split("/")[prepfile.split("/").size() - 1]
		
		var dir = Directory.new()
		dir.copy(prepfile,folder + "/" + fn)
	
	func __load_png(path) -> Texture:
		var tex_file = File.new()
		tex_file.open(path, File.READ)
		var bytes = tex_file.get_buffer(tex_file.get_len())
		var img = Image.new()
		var data = img.load_png_from_buffer(bytes)
		var imgtex = ImageTexture.new()
		imgtex.create_from_image(img)
		tex_file.close()
		return imgtex
	

class _FolderAccess:
	var scripts = [
		
	]
	func __check_folder_exists(folder: String, status_array: bool = false):
		var value = false
		var exists = false
		var directory = Directory.new()
		if directory.dir_exists(folder):
			value = true
			exists = true
		else:
			exists = false
			var error_code = directory.make_dir_recursive(folder)
			if error_code != OK:
				value = false
			else:
				value = true
	#			Debug.l("HevLib: Folder created @%s" % folder)
		if status_array:
			return [value,exists]
		else:
			return value
	
	func __recursive_delete(path: String) -> bool:
		var dTest = Directory.new()
		if not dTest.open(path) == OK:
			return false
		if not path.ends_with("/"):
			path = path + "/"
		var filesForDeletion = []
		var foldersForDeletion = []
		var pms = __fetch_folder_files(path, true, true)
		for entry in pms:
			if str(entry).ends_with("/"):
				foldersForDeletion.append(entry)
			else:
				filesForDeletion.append(entry)
		for f in filesForDeletion:
			var splitFiles = str(f).split("/")[str(f).split("/").size()-1]
			var dir = Directory.new()
			dir.open(path)
			dir.remove(splitFiles)
		for folder in foldersForDeletion:
			__recursive_delete(folder)
		var dm = Directory.new()
		dm.open(path)
		dm.remove(path)
		return true
	
	func __fetch_folder_files(folder: String, showFolders: bool = false, returnFullPath: bool = false,globalizePath: bool = false):
		var fileList = []
		var dir = Directory.new()
		var does = dir.dir_exists(folder)
		if not does:
			return []
		dir.open(folder)
		var dirName = dir.get_current_dir()
		dir.list_dir_begin(true)
		while true:
			var fileName = dir.get_next()
			var capture = true
			if fileName.ends_with("/"):
				capture = false
			if fileName == "." or fileName == "..":
				capture = false
			if capture:
				dirName = dir.get_current_dir()
				if fileName == "":
					break
				if dir.current_is_dir() and not showFolders:
					continue
				elif dir.current_is_dir() and showFolders and not fileName.ends_with("/"):
					fileName = fileName + "/"
				if returnFullPath:
					fileName = folder + fileName
				if globalizePath:
					fileList.append(ProjectSettings.globalize_path(fileName))
				else:
					fileList.append(fileName)
	
	
	#	m = m.split(m.split("/")[0] + "/")[1].to_lower()
		var dFiles = ""
		for m in fileList:
			if dFiles == "":
				dFiles = m
			else:
				dFiles = dFiles + ", " + m
	#	Debug.l("HevLib: fetch_folder_files returning as %s" % dFiles)
		return fileList
	
	func __get_first_file(folder: String):
		var firstFile
		var fileNo = 0
		var fileList = __fetch_folder_files(folder)
		for file in fileList:
			if fileNo == 0:
				firstFile = file
				fileNo = 1
		if firstFile == null:
			return false
		else:
			return firstFile
	
	func __copy_file(file, folder):
		var prepfile = ProjectSettings.localize_path(file)
		var fn = prepfile.split("/")[prepfile.split("/").size() - 1]
		
		var dir = Directory.new()
		dir.copy(prepfile,folder + "/" + fn)
	
	func __get_folder_structure(folder,store_file_content = false):
		var file = File.new()
		var folder_structure = {}
		var files = __fetch_folder_files(folder,true,false)
		for object in files:
			if object.ends_with("/"):
				var data = __get_folder_structure(folder+object,store_file_content)
				folder_structure.merge({object:data})
			else:
				var fd = "FILE"
				if store_file_content:
					file.open(folder + object,File.READ)
					fd = file.get_as_text(true)
					file.close()
				folder_structure.merge({object:fd})
		return folder_structure
	
	
	
	
	
	

class _Github:
	var scripts = [
		
	]
	
	func __get_github_filesystem(URL: String, node_to_return_to: Node, behaviour: String = "normal", special_behaviour_data = ""):
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var CRoot = Tool.get_tree().get_root()
		var gitHubFS = preload("res://HevLib/scenes/fetch_from_github/fs/FetchGithubData.tscn").instance()
		gitHubFS.URL = URL
		gitHubFS.ActOnModData = behaviour
		gitHubFS.mod_version = special_behaviour_data
		gitHubFS.nodeToReturnTo = node_to_return_to
		gitHubFS.name = "git_filesystem_" + str(rng.randi_range(1, 32767))
		CRoot.call_deferred("add_child",gitHubFS)
	
	func __get_github_release(URL: String, folder: String, node_to_return_to: Node, get_pre_releases: bool = false, file_preference: String = "any", file_to_download: String = "first"):
		var cancel = false
		if node_to_return_to == null or (not node_to_return_to is Node):
			cancel = true
			var e = "HevLib Github Release Downloader: ERROR! Provided node [%s] either does not exist or is not of [Node] type." % str(node_to_return_to)
			Debug.l(e)
			printerr(e)
		if not node_to_return_to.has_method("_downloaded_zip"):
			cancel = true
			var e = "HevLib Github Release Downloader: ERROR! Provided node [%s] does not have the method [_downloaded_zip]" % str(node_to_return_to)
			Debug.l(e)
			printerr(e)
		if cancel:
			return
		var CRoot = Tool.get_tree().get_root()
		var gitHubFS = preload("res://HevLib/scenes/fetch_from_github/releases/NetHandles.tscn").instance()
		if not node_to_return_to.has_method("_get_github_progress"):
			gitHubFS.state_progress = false
			Debug.l("HevLib Github Release Downloader: NOTICE! Provided node [%s] does not have the method [_get_github_progress]. No download progress will be reported." % str(node_to_return_to))
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		gitHubFS.releases_URL = URL
		gitHubFS.folder = folder
		gitHubFS.get_pre_releases = get_pre_releases
		gitHubFS.file_preference = file_preference
		gitHubFS.file_to_download = file_to_download
		gitHubFS.nodeToReturnTo = node_to_return_to
		gitHubFS.name = "git_release_" + str(rng.randi_range(1, 32767))
		CRoot.call_deferred("add_child",gitHubFS)
	

class _HevLib:
	var scripts = [
		
	]
	
	var FolderAccess
	func _init(f):
		FolderAccess = f
	
	func __get_lib_variables():
		var varNode = ModLoader.get_node("/root/HevLib~Variables")
		var aData = varNode.AchievementData
		var aPercentData = varNode.AchievementPercentageStats
		return {"AchievementData":aData,"AchievementPercentageStats":aPercentData}
	
	func __get_lib_pointers(return_as_full_path: bool = false) -> Array:
		var path = "res://HevLib/pointers/"
		var files = FolderAccess.__fetch_folder_files(path)
		if return_as_full_path:
			var compileArray = []
			for f in files:
				compileArray.append(path + f)
			return compileArray
		else:
			return files
	
	func __get_pointer_functions(pointer: String, return_JSON: bool = false) -> Dictionary:
		var path = "res://HevLib/pointers/"
		var pSplit = pointer.split("/")
		var actualPointer = path + pSplit[pSplit.size() - 1]
		var pointerLoad = load(actualPointer).new()
		var pFuncs = pointerLoad.get_method_list()
		var methods = {}
		for pFunc in pFuncs:
			var pFuncName = pFunc.name
			if pFuncName.begins_with("__"):
				var data = pointerLoad.get_property_list()
				var devHint = {}
				for item in data:
					if item.get("name") == "developer_hint":
						devHint = pointerLoad.developer_hint
				var desc = devHint.get(pFuncName, [TranslationServer.translate("HEVLIB_MISSING_DOCUMENTATION_1"),TranslationServer.translate("HEVLIB_MISSING_DOCUMENTATION_2")])
				methods.merge({pFuncName:desc})
		if return_JSON:
			var psj = JSON.print(methods, "\t")
			return psj
		else:
			return methods
	
	func __get_library_functionality(return_JSON: bool = false) -> Dictionary:
		var path = "res://HevLib/pointers/"
		var functions = {}
		var files = FolderAccess.__fetch_folder_files(path)
		for pointer in files:
			var pSplit = pointer.split("/")
			var actualPointer = path + pSplit[pSplit.size() - 1]
			var pl = load(actualPointer)
			var pointerLoad = pl.new()
			var pFuncs = pointerLoad.get_method_list()
			var methods = {}
			for pFunc in pFuncs:
				var pFuncName = pFunc.name
				if pFuncName.begins_with("__"):
					var data = pointerLoad.get_property_list()
					var devHint = {}
					for item in data:
						if item.get("name") == "developer_hint":
							devHint = pointerLoad.developer_hint
					var desc = devHint.get(pFuncName, [TranslationServer.translate("HEVLIB_MISSING_DOCUMENTATION_1"),TranslationServer.translate("HEVLIB_MISSING_DOCUMENTATION_2")])
					methods.merge({pFuncName:desc})
			var concat = {pointer:methods}
			functions.merge(concat)
		if return_JSON:
			var psj = JSON.print(functions, "\t")
			return psj
		else:
			return functions
	
	
	
	

class _ManifestV1:
	var scripts = [
		
	]
	
	var DataFormat
	var Zip
	func _init(d,z):
		DataFormat = d
		Zip = z
	
	func __load_manifest_from_file(manifest):
		var manifestConfig = {
		"package":{
			"id":null,
			"name":null,
			"version":"unknown",
			"description":"MODMENU_DESCRIPTION_PLACEHOLDER",
			"group":"",
			"github_homepage":"",
			"github_releases":"",
			"discord_thread":"",
			"nexus_page":"",
			"donations_page":"",
			"wiki_page":"",
			"custom_link":"",
			"custom_link_name":"",
			}
		}
		var manifestFile = ConfigFile.new()
		var error = manifestFile.load(manifest)
		if error != OK:
			return
		for section in manifestConfig:
			var currentManifest = Array(manifestFile.get_section_keys(section))
			for key in manifestFile.get_section_keys(section):
				manifestConfig[section][key] = manifestFile.get_value(section, key)
		return manifestConfig
	
	func __load_file(modDir, zipDir, hasManifest, manifestDirectory, hasIcon, iconDir):
		var manifestName = ""
		var manifestId = ""
		var manifestVersion = ""
		var manifestDescription = ""
		var manifestGroup = ""
		var github_homepage = ""
		var github_releases = ""
		var discord_thread = ""
		var nexus_page = ""
		var donations_page = ""
		var wiki_page = ""
		var custom_link = "MODMENU_CUSTOM_LINK_PLACEHOLDER"
		var custom_link_name = "MODMENU_CUSTOM_LINK_NAME_PLACEHOLDER"
		var dirSplit = zipDir.split("/")
		var dirSplitSize = dirSplit.size()
		var fallbackDir = dirSplit[dirSplitSize - 1]
		var parentFolder = str(dirSplit[dirSplitSize - 2])
		var f = File.new()
		if hasManifest and not parentFolder == "disabled_mod_cache":
			f.open(manifestDirectory, File.READ)
			var manifestData = __load_manifest_from_file(manifestDirectory)
			manifestName = manifestData["package"]["name"]
			manifestId = manifestData["package"]["id"]
			manifestVersion = manifestData["package"]["version"]
			manifestDescription = manifestData["package"]["description"]
			manifestGroup = manifestData["package"]["group"]
			github_homepage = manifestData["package"]["github_homepage"]
			github_releases = manifestData["package"]["github_releases"]
			discord_thread = manifestData["package"]["discord_thread"]
			nexus_page = manifestData["package"]["nexus_page"]
			donations_page = manifestData["package"]["donations_page"]
			wiki_page = manifestData["package"]["wiki_page"]
			custom_link = manifestData["package"]["custom_link"]
			custom_link_name = manifestData["package"]["custom_link_name"]
			f.close()
	#	Debug.l("HevLib: load_file attempting to reload file @%s" % modDir)
		f.open(modDir, File.READ)
		var modFolderSplit = modDir.split("/ModMain.gd")
		var modFolderCount = modFolderSplit.size()
		var separateModFolderDir = modFolderSplit[modFolderCount - 2].split("/")
		var modFolderSecondCount = separateModFolderDir.size()
		var modFolder = separateModFolderDir[modFolderSecondCount - 1]
		var nameCheck = 0
		var modName = ""
		var prioCheck = 0
		var modPrio = 0
		var modVer = ""
		var verCheck = 0
		var content = f.get_as_text(true)
		var modMainLines = content.split("\n")
		for l in modMainLines:
			if not hasManifest or manifestName == "" or manifestName == null:
				var modNameCheck = l.split("const MOD_NAME = ")
				var modNameCheckSize = modNameCheck.size()
				if modNameCheckSize >= 2:
					var splitName = DataFormat.__array_to_string(modNameCheck[1].split("\""))
					while splitName.begins_with(" "):
						var beginningSpaceRemover = splitName.split(" ")
						splitName = DataFormat.__array_to_string(beginningSpaceRemover[1])
					while splitName.ends_with(" "):
						var endSpaceRemover = splitName.split(" ")
						splitName = DataFormat.__array_to_string(endSpaceRemover[0])
					nameCheck = 1
					modName = splitName
			else:
				nameCheck = 1
				modName = manifestName
			var priorityCheck = l.split("const MOD_PRIORITY = ")
			var priorityCheckSize = priorityCheck.size()
			if priorityCheckSize >= 2:
				prioCheck += 1
				modPrio = priorityCheck[1]
			if not nameCheck == 1:
				modName = fallbackDir
			if not prioCheck == 1:
				modPrio = 0
			var versionCheck = l.split("const MOD_VERSION = ")
			var versionCheckSize = versionCheck.size()
			if not manifestVersion == "":
				verCheck = 1
				modVer = manifestVersion
			elif versionCheckSize >= 2 and not manifestVersion == modVer:
				verCheck = 1
				modVer = versionCheck[1]
			else:
				modVer = "unknown"
		var prioStr = String(modPrio)
		var ver = ""
		if verCheck == 1:
			ver = modVer
		else:
			ver = "unknown"
		var verData = String(ver)
		if manifestDescription == null or manifestDescription == "":
			manifestDescription = "MODMENU_DESCRIPTION_PLACEHOLDER"
		if manifestGroup == null or manifestGroup == "":
			manifestGroup = "MODMENU_GROUP_PLACEHOLDER"
		if manifestId == null or manifestId == "":
			manifestId = "MODMENU_ID_PLACEHOLDER"
		if github_homepage == null or github_homepage == "":
			github_homepage = "MODMENU_GITHUB_HOMEPAGE_PLACEHOLDER"
		if github_releases == null or github_releases == "":
			github_releases = "MODMENU_GITHUB_RELEASES_PLACEHOLDER"
		if discord_thread == null or discord_thread == "":
			discord_thread = "MODMENU_DISCORD_PLACEHOLDER"
		if nexus_page == null or nexus_page == "":
			nexus_page = "MODMENU_NEXUS_PLACEHOLDER"
		if donations_page == null or donations_page == "":
			donations_page = "MODMENU_DONATIONS_PLACEHOLDER"
		if wiki_page == null or wiki_page == "":
			wiki_page = "MODMENU_WIKI_PLACEHOLDER"
		if custom_link == null or custom_link == "":
			custom_link = "MODMENU_CUSTOM_LINK_PLACEHOLDER"
		if custom_link_name == null or custom_link_name == "":
			custom_link_name = "MODMENU_CUSTOM_LINK_NAME_PLACEHOLDER"
		if hasIcon:
			iconDir = iconDir
		else:
			iconDir = "empty"
		var compiledData = modName + "\n" + fallbackDir + "\n" + prioStr + "\n" + modFolder + "\n" + verData + "\n" + manifestDescription + "\n" + github_homepage + "\n" + github_releases + "\n" + discord_thread + "\n" + nexus_page + "\n" + donations_page + "\n" + wiki_page + "\n" + custom_link + "\n" + custom_link_name + "\n" + iconDir + "\n" + manifestId
	#	Debug.l("HevLib: load_file returning as %s" % compiledData)
		return compiledData
	
	func __get_mod_main(file, split_into_array = false):
		var hasManifest = false
		var manifestDir = ""
		var hasIcon = false
		var iconDir = ""
		var modData
		var modMainPath = ""
		var filesInZip = Zip.__get_zip_content(file)
		for m in filesInZip:
			var modPath = "res://" + m
			m = m.split(m.split("/")[0] + "/")[1].to_lower()
			if m.begins_with("mod") and m.ends_with(".manifest"):
				hasManifest = true
				manifestDir = modPath
			if m.begins_with("icon") and m.ends_with(".stex"):
				hasIcon = true
				iconDir = modPath
			if m.begins_with("modmain") and m.ends_with(".gd"):
				modMainPath = modPath
		modData = __load_file(modMainPath, file, hasManifest, manifestDir, hasIcon, iconDir)
		if split_into_array:
			modData = modData.split("\n")
		if modMainPath != null:
			return modData
		else:
			return null
	
	
	
	
	
	

class _ManifestV2:
	var scripts = [
		
	]
	
	var DataFormat
	var FolderAccess
	var FileAccess
	func _init(d,f,a):
		DataFormat = d
		FolderAccess = f
		FileAccess = a
	
	var file = File.new()
	
	var cached_mod_list : Dictionary = {}
	
	func __get_mod_data(print_json: bool = false) -> Dictionary:
		if not cached_mod_list.empty():
			if print_json:
				var psj = JSON.print(cached_mod_list, "\t")
				return psj
			else:
				return cached_mod_list.duplicate(true)
		else:
			var mod_dictionary = {}
			var manifest_count = 0
			var library_count = 0
			var non_library_count = 0
			var total_mod_count = 0
			# FUTURE ME: FIX THIS TO USE PARSE TAGS
			var stat_tags = {}
			
			var modListArr = []
			var is_onready = CurrentGame != null
			if is_onready:
				var mods = ModLoader.get_children()
				for mod in mods:
					var constants = mod.get_script().get_script_constant_map()
					var script_path = mod.get_script().get_path()
					modListArr.append({"constants":constants,"script_path":script_path,"node":mod})
			
			else:
				var running_in_debugged = false
				var debugged_defined_mods = []
				
				var ps = DataFormat.__get_script_constant_map_without_load("res://ModLoader.gd")
				for item in ps:
					if item == "is_debugged":
						running_in_debugged = true
						var pf = File.new()
						pf.open("res://ModLoader.gd",File.READ)
						var fs = pf.get_as_text(true)
						pf.close()
						var lines = fs.split("\n")
						var reading = false
						var contents = []
						for line in lines:

							if line.begins_with("var addedMods"):
								reading = true
							if reading:
								var split = line.split("\"")
								if split.size() > 1 and split.size() == 3:
									if split[0].begins_with("#"):
										contents.append(split[1])

						debugged_defined_mods = contents.duplicate(true)
				
				
				
				var folders = FolderAccess.__fetch_folder_files("res://", true, true)
				var mods_to_avoid = []
				for folder in folders:
					var semi_root = folder.split("/")[2]
					if semi_root.begins_with("."):
						continue
								
					if folder.ends_with("/"):
						
						if running_in_debugged:
							for mod in debugged_defined_mods:
								var home = mod.split("/")[2]
								if home == semi_root:
										mods_to_avoid.append(home)
						var folderCheck = FolderAccess.__fetch_folder_files(folder,true)
						var has_mod = false
						var has_manifest = false
						var modmain_path = ""
						var manifest_path = ""
						for item in folderCheck:
							var modEntryName = item.to_lower()
							if modEntryName.begins_with("modmain") and modEntryName.ends_with(".gd"):
								if (folder + item) in debugged_defined_mods:
									has_mod = false
								else:
									has_mod = true
								modmain_path = item
						if has_mod:
							var mv = folder + modmain_path
							var constants = DataFormat.__get_script_constant_map_without_load(mv)
							modListArr.append({"constants":constants,"script_path":mv,"node":null})
			total_mod_count = modListArr.size()
			modListArr.sort_custom(self,"sortModList")
			for mod in modListArr:
				
				var constants = mod.get("constants")
				var script_path = mod.get("script_path")
				var node = mod.get("node")
				
				var folder_path = str(script_path.split(script_path.split("/")[script_path.split("/").size() - 1])[0])
				var mod_priority = constants.get("MOD_PRIORITY",0)
				var mod_name = str(constants.get("MOD_NAME",script_path.split("/")[2]))
				var legacy_mod_version = constants.get("MOD_VERSION","1.0.0")
				var mod_version_major = constants.get("MOD_VERSION_MAJOR",1)
				var mod_version_minor = constants.get("MOD_VERSION_MINOR",0)
				var mod_version_bugfix = constants.get("MOD_VERSION_BUGFIX",0)
				var mod_version_metadata = constants.get("MOD_VERSION_METADATA","")
				var is_library = constants.get("MOD_IS_LIBRARY",false)
				var always_display = constants.get("ALWAYS_DISPLAY",false)
				var content = FolderAccess.__fetch_folder_files(folder_path)
				var has_mod_manifest = false
				var manifest_data = {}
				var manifest_version = 1
				var has_icon_file = false
				var icon_path = ""
				for file in content:
					if file.to_lower() == "mod.manifest":
						has_mod_manifest = true
						manifest_count += 1
						manifest_data = __parse_file_as_manifest(folder_path + file, true)
						mod_name = manifest_data["mod_information"].get("name",mod_name)
						legacy_mod_version = manifest_data["version"].get("version_string",legacy_mod_version)
						mod_version_major = manifest_data["version"].get("version_major",mod_version_major)
						mod_version_minor = manifest_data["version"].get("version_minor",mod_version_minor)
						mod_version_bugfix = manifest_data["version"].get("version_bugfix",mod_version_bugfix)
						mod_version_metadata = manifest_data["version"].get("version_metadata",mod_version_metadata)
						is_library = manifest_data["library"].get("is_library",false)
						always_display = manifest_data["library"].get("always_display",false)
						manifest_version = manifest_data["manifest_definitions"].get("manifest_version",1)
						
						if "tags" in manifest_data.keys():
							for tag in manifest_data["tags"]:
								if tag in stat_tags:
									stat_tags[tag] += 1
								else:
									stat_tags.merge({tag:1})
						
					if file.to_lower().begins_with("icon") and file.to_lower().ends_with(".stex"):
						has_icon_file = true
						icon_path = folder_path + file
				var icon_dict = {"has_icon_file":has_icon_file,"icon_path":icon_path}
				var manifestEntry = {"has_manifest":has_mod_manifest,"manifest_version":manifest_version,"manifest_data":manifest_data}
				var mod_version_array = [mod_version_major,mod_version_minor,mod_version_bugfix]
				var mod_version_string = str(mod_version_major) + "." + str(mod_version_minor) + "." + str(mod_version_bugfix)
				if not str(mod_version_metadata) == "":
					mod_version_array.append(mod_version_metadata)
					mod_version_string = mod_version_string + "-" + str(mod_version_metadata)
				var version_dictionary = {"version_major":mod_version_major,"version_minor":mod_version_minor,"version_bugfix":mod_version_bugfix,"version_metadata":mod_version_metadata,"full_version_array":mod_version_array,"full_version_string":mod_version_string,"legacy_mod_version":legacy_mod_version}
				var mod_entry = {str(script_path):{"name":mod_name,"priority":mod_priority,"version_data":version_dictionary,"mod_icon":icon_dict,"library_information":{"is_library":is_library,"always_display":always_display},"node":node,"manifest":manifestEntry}}
				mod_dictionary.merge(mod_entry)
				if is_library:
					library_count += 1
				else:
					non_library_count += 1
			
			
			var stat_count = {"total_mod_count":total_mod_count,"mods_using_manifests":manifest_count,"mods":non_library_count,"libraries":library_count}
			var statistics = {"counts":stat_count,"tags":stat_tags}
			var returnValues = {"mods":mod_dictionary,"statistics":statistics}
			cached_mod_list = returnValues.duplicate(true)
			if print_json:
				var psj = JSON.print(cached_mod_list, "\t")
				return psj
			else:
				return cached_mod_list.duplicate(true)
	
	static func sortModList(a,b):
		var c1 = a.get("constants",{}).get("MOD_PRIORITY",0)
		var c2 = b.get("constants",{}).get("MOD_PRIORITY",0)
		if c1 != c2:
			return c1 < c2
		var b1 = a.get("mod_path","").to_ascii().split("/")
		var b2 = b.get("mod_path","").to_ascii().split("/")
		if b1 != b2:
			return b1 < b2
		return false
	
	var cached_zip_refs = {}
	
	func __match_mod_path_to_zip(mod_main_path:String) -> String:
		if mod_main_path in cached_zip_refs:
			return cached_zip_refs[mod_main_path]
		else:
			var zip_ref_store = "user://cache/.HevLib_Cache/zip_ref_store.json"
			var file = File.new()
			file.open(zip_ref_store,File.READ)
			var data = JSON.parse(file.get_as_text()).result
			file.close()
			var return_val = data.get(mod_main_path,"")
			cached_zip_refs[mod_main_path] = return_val
			return return_val
	
	func __old_match_mod_path_to_zip(mod_main_path:String) -> String:
		var _modZipFiles = []
		var gameInstallDirectory = OS.get_executable_path().get_base_dir()
		if OS.get_name() == "OSX":
			gameInstallDirectory = gameInstallDirectory.get_base_dir().get_base_dir().get_base_dir()
		var modPathPrefix = gameInstallDirectory.plus_file("mods")

		var dir = Directory.new()
		if dir.open(modPathPrefix) != OK:
			return ""
		if dir.list_dir_begin() != OK:
			return ""

		while true:
			var fileName = dir.get_next()
			if fileName == "":
				break
			if dir.current_is_dir():
				continue
			var modFSPath = modPathPrefix.plus_file(fileName)
			var modGlobalPath = ProjectSettings.globalize_path(modFSPath)
			if not ProjectSettings.load_resource_pack(modGlobalPath, true):
				continue
			_modZipFiles.append(modFSPath)
		dir.list_dir_end()
		
		var initScripts = []
		for modFSPath in _modZipFiles:
			var gd = gdunzip.new()
			gd.load(modFSPath)
			for modEntryPath in gd.files:
				var modEntryName = modEntryPath.get_file().to_lower()
				if modEntryName.begins_with("modmain") and modEntryName.ends_with(".gd"):
					var modGlobalPath = "res://" + modEntryPath
					var zipName = modFSPath.split("/")[modFSPath.split("/").size() - 1]
					initScripts.append([modGlobalPath,zipName])
		for item in initScripts:
			if item[0] == mod_main_path:
				return item[1]
		return ""
	
	func __compare_versions(checked_mod_data:Dictionary) -> bool:
		var installed_mods = __get_mod_data()
		var check_name = checked_mod_data[checked_mod_data.keys()[0]].get("name","")
		var installed_dict = {}
		for installed_mod in installed_mods["mods"]:
			var installed_mName = installed_mods["mods"][installed_mod].get("name","")
			if installed_mName == check_name:
				installed_dict = installed_mods["mods"][installed_mod].duplicate()
		if installed_dict.keys().size() == 0:
			return false
		var checked_manifest_version = checked_mod_data[checked_mod_data.keys()[0]]["manifest"]["manifest_version"]
		var installed_manifest_version = installed_dict["manifest"]["manifest_version"]
		if checked_manifest_version <= 1:
			return false
		if checked_manifest_version > installed_manifest_version:
			return true
		var checked_mod_version = checked_mod_data[checked_mod_data.keys()[0]]["version_data"]["full_version_array"]
		var installed_mod_version = installed_dict["version_data"]["full_version_array"]
		if checked_mod_version[0] > installed_mod_version[0]:
			return true
		if checked_mod_version[1] > installed_mod_version[1]:
			return true
		if checked_mod_version[2] > installed_mod_version[2]:
			return true
		return false
	
	func __get_mod_data_from_files(script_path:String) -> Dictionary:
		var constants = DataFormat.__get_script_constant_map_without_load(script_path)
		var folder_path = str(script_path.split(script_path.split("/")[script_path.split("/").size() - 1])[0])
		var mod_priority = constants.get("MOD_PRIORITY",0)
		var mod_name = str(constants.get("MOD_NAME",script_path.split("/")[2]))
		var legacy_mod_version = constants.get("MOD_VERSION","1.0.0")
		var mod_version_major = constants.get("MOD_VERSION_MAJOR",1)
		var mod_version_minor = constants.get("MOD_VERSION_MINOR",0)
		var mod_version_bugfix = constants.get("MOD_VERSION_BUGFIX",0)
		var mod_version_metadata = constants.get("MOD_VERSION_METADATA","")
		
		var mod_is_library = constants.get("MOD_IS_LIBRARY",false)
		
		var hide_library = constants.get("LIBRARY_HIDDEN_BY_DEFAULT",true)
		var content = FolderAccess.__fetch_folder_files(folder_path)
		var has_mod_manifest = false
		var manifest_data = {}
		var manifest_version = 1
		var has_icon_file = false
		var icon_path = ""
		for file in content:
			if file.to_lower() == "mod.manifest":
				has_mod_manifest = true
				manifest_data = __parse_file_as_manifest(folder_path + file, true)
				mod_name = manifest_data["mod_information"].get("name",mod_name)
				legacy_mod_version = manifest_data["version"].get("version_string",legacy_mod_version)
				mod_version_major = manifest_data["version"].get("version_major",mod_version_major)
				mod_version_minor = manifest_data["version"].get("version_minor",mod_version_minor)
				mod_version_bugfix = manifest_data["version"].get("version_bugfix",mod_version_bugfix)
				mod_version_metadata = manifest_data["version"].get("version_metadata",mod_version_metadata)
				mod_is_library = manifest_data["tags"].get("is_library_mod",false)
				hide_library = manifest_data["tags"].get("library_hidden_by_default",true)
			if file.to_lower().begins_with("icon") and file.to_lower().ends_with(".stex"):
				has_icon_file = true
				icon_path = folder_path + file
		var icon_dict = {"has_icon_file":has_icon_file,"icon_path":icon_path}
		var manifestEntry = {"has_manifest":has_mod_manifest,"manifest_version":manifest_version,"manifest_data":manifest_data}
		var mod_version_array = [mod_version_major,mod_version_minor,mod_version_bugfix]
		var mod_version_string = str(mod_version_major) + "." + str(mod_version_minor) + "." + str(mod_version_bugfix)
		if not str(mod_version_metadata) == "":
			mod_version_array.append(mod_version_metadata)
			mod_version_string = mod_version_string + "-" + str(mod_version_metadata)
		var version_dictionary = {"version_major":mod_version_major,"version_minor":mod_version_minor,"version_bugfix":mod_version_bugfix,"version_metadata":mod_version_metadata,"full_version_array":mod_version_array,"full_version_string":mod_version_string,"legacy_mod_version":legacy_mod_version}
		var mod_entry = {str(script_path):{"name":mod_name,"priority":mod_priority,"version_data":version_dictionary,"mod_icon":icon_dict,"library_information":{"is_library":mod_is_library,"keep_library_hidden":hide_library},"manifest":manifestEntry}}
		return(mod_entry)
	
	var cached_manifests = {}
	
	func __parse_file_as_manifest(file_path: String, format_to_manifest_version: bool = true) -> Dictionary:
		var cachevar = file_path + ":" + str(format_to_manifest_version)
		if cachevar in cached_manifests:
			return cached_manifests[cachevar]
		else:
			var out = {}
			var cfg = FileAccess.__config_parse(file_path)
			var manifest_data : Dictionary = {}
			var manifest_version = 1
			if "manifest_definitions" in cfg.keys():
				manifest_version = cfg["manifest_definitions"].get("manifest_version",manifest_version)
				var tpf = typeof(manifest_version)
				if tpf == TYPE_INT or tpf == TYPE_REAL:
					pass
				else:
					manifest_version = 1
			manifest_data = cfg
			if format_to_manifest_version:
				var dict_template = {
					"mod_information":{
						"name":null,
						"id":null,
						"description":"",
						"brief":"",
						"author":"",
						"credits":PoolStringArray([])
					},
					"version":{
						"version_major":1,
						"version_minor":0,
						"version_bugfix":0,
						"version_metadata":"",
						"version_string":"1.0.0"
					},
					"tags":{
						
					},
					"links":{
						
					},
					"configs":{
						
					},
					"languages":{
						
					},
					"library":{
						"is_library":false,
						"always_display":false,
					},
					"manifest_definitions":{
						"manifest_version":1,
						"dependancy_mod_ids":PoolStringArray([]),
						"conflicting_mod_ids":PoolStringArray([]),
						"complementary_mod_ids":PoolStringArray([]),
						"manifest_url":"", # EXAMPLE: https://raw.githubusercontent.com/rwqfsfasxc100/HevLib/main/Mod.manifest
						"changelog_path":"", # This is relative to the ModMain.gd file. EXAMPLE: for a file at 'res://Example Mod/data/folder/changelogs.txt', you would put 'data/folder/changelogs.txt'
					}
				}
				match manifest_version:
					1, 1.0:
						dict_template["mod_information"]["id"] = manifest_data["package"].get("id",null)
						dict_template["mod_information"]["name"] = manifest_data["package"].get("name",null)
						var version = manifest_data["package"].get("version","unknown")
						dict_template["mod_information"]["description"] = manifest_data["package"].get("description","MODMENU_DESCRIPTION_PLACEHOLDER")
						
						if typeof(manifest_data["package"].get("github_homepage","")) == TYPE_STRING:
							var url = manifest_data["package"]["github_homepage"]
							if url != "":
								dict_template["links"].merge({"HEVLIB_GITHUB":{"URL":url}})
						var discURL = manifest_data["package"].get("discord","")
						if discURL != "":
							dict_template["links"].merge({"HEVLIB_DISCORD":{"URL":discURL}})
						var nexusURL = manifest_data["package"].get("nexus","")
						if nexusURL != "":
							dict_template["links"].merge({"HEVLIB_NEXUS":{"URL":nexusURL}})
						var donationURL = manifest_data["package"].get("donations","")
						if donationURL != "":
							dict_template["links"].merge({"HEVLIB_DONATIONS":{"URL":donationURL}})
						var wikiURL = manifest_data["package"].get("wiki","")
						if wikiURL != "":
							dict_template["links"].merge({"HEVLIB_WIKI":{"URL":wikiURL}})
						
					2, 2.0:
						dict_template["mod_information"]["id"] = manifest_data["package"].get("id",null)
						dict_template["mod_information"]["name"] = manifest_data["package"].get("name",null)
						dict_template["version"]["version_major"] = manifest_data["package"].get("version_major",1)
						dict_template["version"]["version_minor"] = manifest_data["package"].get("version_minor",0)
						dict_template["version"]["version_bugfix"] = manifest_data["package"].get("version_bugfix",0)
						dict_template["version"]["version_metadata"] = manifest_data["package"].get("version_metadata","")
						dict_template["mod_information"]["description"] = manifest_data["package"].get("description","HEVLIB_DESCRIPTION_PLACEHOLDER")
						if typeof(manifest_data["package"].get("github","")) == TYPE_DICTIONARY:
							var url = manifest_data["package"]["github"]["link"]
							if url != "":
								dict_template["links"].merge({"HEVLIB_GITHUB":{"URL":url}})
						elif typeof(manifest_data["package"].get("github","")) == TYPE_STRING:
							var url = manifest_data["package"]["github"]
							if url != "":
								dict_template["links"].merge({"HEVLIB_GITHUB":{"URL":url}})
						var discURL = manifest_data["package"].get("discord","")
						if discURL != "":
							dict_template["links"].merge({"HEVLIB_DISCORD":{"URL":discURL}})
						var nexusURL = manifest_data["package"].get("nexus","")
						if nexusURL != "":
							dict_template["links"].merge({"HEVLIB_NEXUS":{"URL":nexusURL}})
						var donationURL = manifest_data["package"].get("donations","")
						if donationURL != "":
							dict_template["links"].merge({"HEVLIB_DONATIONS":{"URL":donationURL}})
						var wikiURL = manifest_data["package"].get("wiki","")
						if wikiURL != "":
							dict_template["links"].merge({"HEVLIB_WIKI":{"URL":wikiURL}})
						dict_template["mod_information"]["author"] = manifest_data["package"].get("author","Unknown")
						dict_template["mod_information"]["credits"] = manifest_data["package"].get("credits",[])
						
					2.1:
						# information
						if "mod_information" in manifest_data.keys():
							dict_template["mod_information"]["id"] = String(manifest_data["mod_information"].get("id",null))
							dict_template["mod_information"]["name"] = String(manifest_data["mod_information"].get("name",null))
							dict_template["mod_information"]["description"] = String(manifest_data["mod_information"].get("description","HEVLIB_DESCRIPTION_PLACEHOLDER"))
							dict_template["mod_information"]["author"] = String(manifest_data["mod_information"].get("author","Unknown"))
							dict_template["mod_information"]["credits"] = PoolStringArray(manifest_data["mod_information"].get("credits",[]))
						
						# versioning
						if "version" in manifest_data.keys():
							dict_template["version"]["version_major"] = int(manifest_data["version"].get("version_major",1))
							dict_template["version"]["version_minor"] = int(manifest_data["version"].get("version_minor",0))
							dict_template["version"]["version_bugfix"] = int(manifest_data["version"].get("version_bugfix",0))
							dict_template["version"]["version_metadata"] = String(manifest_data["version"].get("version_metadata",""))
						
						# tags
						if "tags" in manifest_data.keys():
							var current_tags = manifest_data["tags"].keys()
							if "allowself" in current_tags:
								dict_template["tags"].merge({"TAG_ALLOWself":{"type":"boolean","value":manifest_data["tags"].get("allowself")}})
							if "quality_of_life" in current_tags:
								dict_template["tags"].merge({"TAG_QOL":{"type":"boolean","value":manifest_data["tags"].get("quality_of_life")}})
							if "is_library_mod" in current_tags:
								dict_template["library"]["is_library"] = manifest_data["tags"].get("is_library_mod")
							if "uses_hevlib_research" in current_tags:
								dict_template["tags"].merge({"TAG_USING_HEVLIB_RESEARCH":{"type":"boolean","value":manifest_data["tags"].get("uses_hevlib_research")}})
							if "overhaul" in current_tags:
								dict_template["tags"].merge({"TAG_OVERHAUL":{"type":"bool","value":manifest_data["tags"].get("overhaul")}})
							if "visual" in current_tags:
								dict_template["tags"].merge({"TAG_VISUAL":{"type":"bool","value":manifest_data["tags"].get("visual")}})
							if "fun" in current_tags:
								dict_template["tags"].merge({"TAG_FUN":{"type":"bool","value":manifest_data["tags"].get("fun")}})
							if "user_interface" in current_tags:
								dict_template["tags"].merge({"TAG_UI":{"type":"bool","value":manifest_data["tags"].get("user_interface")}})
							
							if "adds_ships" in current_tags:
								dict_template["tags"].merge({"TAG_ADDS_SHIPS":{"type":"array","value":manifest_data["tags"].get("adds_ships")}})
							if "adds_equipment" in current_tags:
								dict_template["tags"].merge({"TAG_ADDS_EQUIPMENT":{"type":"array","value":manifest_data["tags"].get("adds_equipment")}})
							if "adds_gameplay_mechanics" in current_tags:
								dict_template["tags"].merge({"TAG_ADDS_GAMEPLAY_MECHANICS":{"type":"array","value":manifest_data["tags"].get("adds_gameplay_mechanics")}})
							if "adds_events" in current_tags:
								dict_template["tags"].merge({"TAG_ADDS_EVENTS":{"type":"array","value":manifest_data["tags"].get("adds_events")}})
							
							if "handle_extra_crew" in current_tags:
								dict_template["tags"].merge({"TAG_HANDLE_EXTRA_CREW":{"type":"integer","value":manifest_data["tags"].get("handle_extra_crew")}})
							
						# links
						if "links" in manifest_data.keys():
							if typeof(manifest_data["links"].get("github","")) == TYPE_DICTIONARY:
								var url = manifest_data["links"]["github"]["link"]
								if url != "":
									dict_template["links"].merge({"HEVLIB_GITHUB":{"URL":url}})
							elif typeof(manifest_data["links"].get("github","")) == TYPE_STRING:
								var url = manifest_data["links"]["github"]
								if url != "":
									dict_template["links"].merge({"HEVLIB_GITHUB":{"URL":url}})
							var discURL = manifest_data["links"].get("discord","")
							if discURL != "":
								dict_template["links"].merge({"HEVLIB_DISCORD":{"URL":discURL}})
							var nexusURL = manifest_data["links"].get("nexus","")
							if nexusURL != "":
								dict_template["links"].merge({"HEVLIB_NEXUS":{"URL":nexusURL}})
							var donationURL = manifest_data["links"].get("donations","")
							if donationURL != "":
								dict_template["links"].merge({"HEVLIB_DONATIONS":{"URL":donationURL}})
							var wikiURL = manifest_data["links"].get("wiki","")
							if wikiURL != "":
								dict_template["links"].merge({"HEVLIB_WIKI":{"URL":wikiURL}})
							var bugreportsURL = manifest_data["links"].get("bug_reports","")
							if bugreportsURL != "":
								dict_template["links"].merge({"HEVLIB_BUGREPORTS":{"URL":bugreportsURL}})
						
						# manifest definitions
						if "manifest_definitions" in manifest_data.keys():
							dict_template["manifest_definitions"]["manifest_version"] = float(manifest_data["manifest_definitions"].get("manifest_version",manifest_version))
							dict_template["manifest_definitions"]["dependancy_mod_ids"] = PoolStringArray(manifest_data["manifest_definitions"].get("dependancy_mod_ids",[]))
							dict_template["manifest_definitions"]["conflicting_mod_ids"] = PoolStringArray(manifest_data["manifest_definitions"].get("conflicting_mod_ids",[]))
							dict_template["manifest_definitions"]["complementary_mod_ids"] = PoolStringArray(manifest_data["manifest_definitions"].get("complementary_mod_ids",[]))
					2.2:
						
						if "mod_information" in manifest_data.keys():
							dict_template["mod_information"]["id"] = String(manifest_data["mod_information"].get("id",null))
							dict_template["mod_information"]["name"] = String(manifest_data["mod_information"].get("name",null))
							dict_template["mod_information"]["description"] = String(manifest_data["mod_information"].get("description","HEVLIB_DESCRIPTION_PLACEHOLDER"))
							dict_template["mod_information"]["brief"] = String(manifest_data["mod_information"].get("brief",""))
							dict_template["mod_information"]["author"] = String(manifest_data["mod_information"].get("author","Unknown"))
							dict_template["mod_information"]["credits"] = PoolStringArray(manifest_data["mod_information"].get("credits",[]))
						
						if "version" in manifest_data.keys():
							dict_template["version"]["version_major"] = int(manifest_data["version"].get("version_major",1))
							dict_template["version"]["version_minor"] = int(manifest_data["version"].get("version_minor",0))
							dict_template["version"]["version_bugfix"] = int(manifest_data["version"].get("version_bugfix",0))
							dict_template["version"]["version_metadata"] = String(manifest_data["version"].get("version_metadata",""))
						
						if "manifest_definitions" in manifest_data.keys():
							dict_template["manifest_definitions"]["manifest_version"] = float(manifest_data["manifest_definitions"].get("manifest_version",manifest_version))
							dict_template["manifest_definitions"]["dependancy_mod_ids"] = PoolStringArray(manifest_data["manifest_definitions"].get("dependancy_mod_ids",[]))
							dict_template["manifest_definitions"]["conflicting_mod_ids"] = PoolStringArray(manifest_data["manifest_definitions"].get("conflicting_mod_ids",[]))
							dict_template["manifest_definitions"]["complementary_mod_ids"] = PoolStringArray(manifest_data["manifest_definitions"].get("complementary_mod_ids",[]))
							dict_template["manifest_definitions"]["manifest_url"] = String(manifest_data["manifest_definitions"].get("manifest_url",""))
							dict_template["manifest_definitions"]["changelog_path"] = String(manifest_data["manifest_definitions"].get("changelog_path",""))
						
						if "links" in manifest_data.keys():
							var links = manifest_data["links"]
							for link in links:
								dict_template["links"].merge({link:links.get(link)})
						if "tags" in manifest_data.keys():
							var tags = manifest_data["tags"]
							for tag in tags:
								dict_template["tags"].merge({tag:tags.get(tag)})
						if "languages" in manifest_data.keys():
							var languages = manifest_data["languages"]
							for language in languages:
								dict_template["languages"].merge({language:languages.get(language)})
						else:
							dict_template["languages"].merge({"en":"100%"})
						if "library" in manifest_data.keys():
							dict_template["library"]["is_library"] = manifest_data["library"].get("is_library",false)
							dict_template["library"]["always_display"] = manifest_data["library"].get("always_display",false)
							
						if "configs" in manifest_data.keys():
							var configs = manifest_data["configs"]
							dict_template["configs"].merge(configs)
						
						
				var version_metadata = dict_template["version"]["version_metadata"]
				var version_string = str(dict_template["version"]["version_major"]) + "." + str(dict_template["version"]["version_minor"]) + "." + str(dict_template["version"]["version_bugfix"])
				if not version_metadata == "":
					version_string = version_string + "-" + version_metadata
				dict_template["version"]["version_string"] = version_string
				
				out = dict_template
			out = manifest_data
			cached_manifests[cachevar] = out.duplicate(true)
			return out
	
	func __get_mod_by_id(id:String, case_sensitive: bool = true) -> Dictionary:
		var mods = {}
		if not cached_mod_list.empty():
			mods = cached_mod_list["mods"]
		else:
			var data = __get_mod_data()
			mods = data["mods"]
		for mod in mods:
			var ID = ""
			var moddata = mods.get(mod)
			var manifest = moddata["manifest"]["manifest_data"]
			var keys = manifest.keys()
			if keys.size() > 0:
				if "mod_information" in keys:
					ID = manifest["mod_information"].get("id","")
			var matches = false
			if case_sensitive:
				if id.to_upper() == ID.to_upper():
					matches = true
			else:
				if id == ID:
					matches = true
			if matches:
				return moddata
		return {}
	
	func __get_tags() -> Dictionary:
#		var mods = ModLoader.get_children()
		
		var tag_dict = {}
		var modListArr = []
		var is_onready = CurrentGame != null
		if is_onready:
			var mods = ModLoader.get_children()
			for mod in mods:
				var constants = mod.get_script().get_script_constant_map()
				var script_path = mod.get_script().get_path()
				modListArr.append({"constants":constants,"script_path":script_path})
		
		else:
			var running_in_debugged = false
			var debugged_defined_mods = []
			
			var ps = DataFormat.__get_script_constant_map_without_load("res://ModLoader.gd")
			for item in ps:
				if item == "is_debugged":
					running_in_debugged = true
					var pf = File.new()
					pf.open("res://ModLoader.gd",File.READ)
					var fs = pf.get_as_text(true)
					pf.close()
					var lines = fs.split("\n")
					var reading = false
					var contents = []
					for line in lines:

						if line.begins_with("var addedMods"):
							reading = true
						if reading:
							var split = line.split("\"")
							if split.size() > 1 and split.size() == 3:
								if split[0].begins_with("#"):
									contents.append(split[1])

					debugged_defined_mods = contents.duplicate(true)
			
			
			
			var folders = FolderAccess.__fetch_folder_files("res://", true, true)
			var mods_to_avoid = []
			for folder in folders:
				var semi_root = folder.split("/")[2]
				if semi_root.begins_with("."):
					continue
							
				if folder.ends_with("/"):
					
					if running_in_debugged:
						for mod in debugged_defined_mods:
							var home = mod.split("/")[2]
							if home == semi_root:
									mods_to_avoid.append(home)
					var folderCheck = FolderAccess.__fetch_folder_files(folder,true)
					var has_mod = false
					var has_manifest = false
					var modmain_path = ""
					var manifest_path = ""
					for item in folderCheck:
						var modEntryName = item.to_lower()
						if modEntryName.begins_with("modmain") and modEntryName.ends_with(".gd"):
							if (folder + item) in debugged_defined_mods:
								has_mod = false
							else:
								has_mod = true
							modmain_path = item
					if has_mod:
						var mv = folder + modmain_path
						var constants = DataFormat.__get_script_constant_map_without_load(mv)
						modListArr.append({"constants":constants,"script_path":mv})
		
		for mod in modListArr:
			var constants = mod.get("constants")
			var script_path = mod.get("script_path")
			
			var folder_path = str(script_path.split(script_path.split("/")[script_path.split("/").size() - 1])[0])
			var content = FolderAccess.__fetch_folder_files(folder_path)
			var has_mod_manifest = false
			for file in content:
				if file.to_lower() == "mod.manifest":
					has_mod_manifest = true
					var manifest_data = __parse_file_as_manifest(folder_path + file, true)
					var mod_id = manifest_data["mod_information"]["id"]
					var manifest_version = manifest_data["manifest_definitions"]["manifest_version"]
					if mod_id:
						if manifest_version >= 2.1:
							var tag_data = manifest_data["tags"]
							var p = __parse_tags(tag_data)
							for entry in p:
								if not entry in tag_dict:
									tag_dict.merge({entry:{}})
								tag_dict[entry].merge({mod_id:p[entry]})
		return tag_dict
	
	func __get_mod_tags(mod_id: String) -> Dictionary:
#		var mods = ModLoader.get_children()
		
		var tag_dict = {}
		
		var modListArr = []
		var is_onready = CurrentGame != null
		if is_onready:
			var mods = ModLoader.get_children()
			for mod in mods:
				var constants = mod.get_script().get_script_constant_map()
				var script_path = mod.get_script().get_path()
				modListArr.append({"constants":constants,"script_path":script_path})
		
		else:
			var running_in_debugged = false
			var debugged_defined_mods = []
			
			var ps = DataFormat.__get_script_constant_map_without_load("res://ModLoader.gd")
			for item in ps:
				if item == "is_debugged":
					running_in_debugged = true
					var pf = File.new()
					pf.open("res://ModLoader.gd",File.READ)
					var fs = pf.get_as_text(true)
					pf.close()
					var lines = fs.split("\n")
					var reading = false
					var contents = []
					for line in lines:

						if line.begins_with("var addedMods"):
							reading = true
						if reading:
							var split = line.split("\"")
							if split.size() > 1 and split.size() == 3:
								if split[0].begins_with("#"):
									contents.append(split[1])

					debugged_defined_mods = contents.duplicate(true)
			
			
			
			var folders = FolderAccess.__fetch_folder_files("res://", true, true)
			var mods_to_avoid = []
			for folder in folders:
				var semi_root = folder.split("/")[2]
				if semi_root.begins_with("."):
					continue
							
				if folder.ends_with("/"):
					
					if running_in_debugged:
						for mod in debugged_defined_mods:
							var home = mod.split("/")[2]
							if home == semi_root:
									mods_to_avoid.append(home)
					var folderCheck = FolderAccess.__fetch_folder_files(folder,true)
					var has_mod = false
					var has_manifest = false
					var modmain_path = ""
					var manifest_path = ""
					for item in folderCheck:
						var modEntryName = item.to_lower()
						if modEntryName.begins_with("modmain") and modEntryName.ends_with(".gd"):
							if (folder + item) in debugged_defined_mods:
								has_mod = false
							else:
								has_mod = true
							modmain_path = item
					if has_mod:
						var mv = folder + modmain_path
						var constants = DataFormat.__get_script_constant_map_without_load(mv)
						modListArr.append({"constants":constants,"script_path":mv})
		
		for mod in modListArr:
			var constants = mod.get("constants")
			var script_path = mod.get("script_path")
			
			var folder_path = str(script_path.split(script_path.split("/")[script_path.split("/").size() - 1])[0])
			var content = FolderAccess.__fetch_folder_files(folder_path)
			var has_mod_manifest = false
			for file in content:
				if file.to_lower() == "mod.manifest":
					has_mod_manifest = true
					var manifest_data = __parse_file_as_manifest(folder_path + file, true)
					var this_mod_id = manifest_data["mod_information"]["id"]
					if this_mod_id == mod_id:
						var manifest_version = manifest_data["manifest_definitions"]["manifest_version"]
						if manifest_version >= 2.1:
							var tag_data = manifest_data["tags"]
							return __parse_tags(tag_data)
		return tag_dict
	
	func __get_mods_from_tag(tag_name: String) -> Array:
		var alldata = __get_tags()
		var data = alldata.get(tag_name,{})
		var keys = data.keys()
		if keys.size() >=1:
			return keys
		return []
	
	func __get_mods_and_tags_from_tag(tag_name: String) -> Dictionary:
		var alldata = __get_tags()
		var data = alldata.get(tag_name,{})
		var ex_data = {}
		var keys = data.keys()
		if keys.size() >=1:
			for mod in keys:
				match tag_name:
					"TAG_ADDS_EQUIPMENT","TAG_ADDS_EVENTS","TAG_ADDS_GAMEPLAY_MECHANICS","TAG_ADDS_SHIPS":
						var k = data.get(mod,[])
						var num = k.size()
						if num >= 1:
							var equip = []
							for lang in k:
								equip.append(lang)
							ex_data[mod] = equip
					"TAG_HANDLE_EXTRA_CREW":
						var k = data.get(mod,24)
						if k >= 25:
							ex_data[mod] = k
					_:
						var k = data.get(mod,false)
						ex_data[mod] = k
		return ex_data
	
	func __get_manifest_section(section: String, mod_id: String = "") -> Dictionary:
		var mod_data = {}
		if not cached_mod_list.empty():
			mod_data = cached_mod_list["mods"]
		else:
			mod_data = __get_mod_data()["mods"]
		var mode = "all"
		var return_data = {}
		if mod_id != "":
			mode = "specific"
		match mode:
			"all":
				for mod in mod_data:
					var manifest = mod_data[mod]["manifest"]["manifest_data"]
					if section in manifest.keys():
						return_data[mod] = manifest[section]
					
			"specific":
				for mod in mod_data:
					if mod_id in __get_mod_ids():
						var manifest = mod_data[mod]["manifest"]["manifest_data"]
						if "mod_information" in manifest.keys():
							if mod_id in manifest["mod_information"]["id"]:
								if section in manifest.keys():
									return_data = manifest[section]
		
		return return_data
	
	func __get_mod_ids() -> Array:
		var mod_data = {}
		if not cached_mod_list.empty():
			mod_data = cached_mod_list["mods"]
		else:
			mod_data = __get_mod_data()["mods"]
		var returning = []
		for mod in mod_data:
			var data = mod_data[mod]["manifest"]["manifest_data"]
			if "mod_information" in data.keys():
				var minfo = data["mod_information"]["id"]
				returning.append(minfo)
		
		return returning
	
	func __get_manifest_entry(section: String, entry: String, mod_id: String = ""):
		var mod_data = {}
		if not cached_mod_list.empty():
			mod_data = cached_mod_list["mods"]
		else:
			mod_data = __get_mod_data()["mods"]
		var mode = "all"
		var return_data = {}
		if mod_id != "":
			mode = "specific"
		match mode:
			"all":
				for mod in mod_data:
					var manifest = mod_data[mod]["manifest"]["manifest_data"]
					if section in manifest.keys():
						return_data[mod] = manifest[section]
					
			"specific":
				for mod in mod_data:
					if mod_id in __get_mod_ids():
						var manifest = mod_data[mod]["manifest"]["manifest_data"]
						if "mod_information" in manifest.keys():
							if mod_id in manifest["mod_information"]["id"]:
								if section in manifest.keys():
									return_data = manifest[section]
		
		var sec = return_data
		
		var nmode = "all"
		if mod_id != "":
			nmode = "specific"
		match nmode:
			"all":
				var dict = {}
				for mod in sec:
					var id = mod_data[mod]["manifest"]["manifest_data"]["mod_information"]["id"]
					if entry in sec[mod].keys():
						var e = sec[mod][entry]#["value"]
						dict.merge({id:e})
				return dict
			"specific":
				if entry in sec:
					return sec[entry]
		return {}
	
	func __check_complementary():
		var mods = {}
		if not cached_mod_list.empty():
			mods = cached_mod_list["mods"]
		else:
			mods = __get_mod_data()["mods"]
		var tags = __get_manifest_entry("manifest_definitions","complementary_mod_ids")
		var complimentaries = {}
		for mod in tags:
			var keys = tags[mod]
			if keys.size() >= 1:
				var items = []
				for item in keys:
					if item in mods:
						items.append(item)
				if items.size() >= 1:
					complimentaries.merge({mod:items})
		return complimentaries
	
	func __check_mod_complementary(mod_id):
		var mods = {}
		if not cached_mod_list.empty():
			mods = cached_mod_list["mods"]
		else:
			mods = __get_mod_data()["mods"]
		var tags = __get_manifest_entry("manifest_definitions","complementary_mod_ids",mod_id)
		var complimentaries = []
		for mod in tags:
			if mod in mods:
				complimentaries.append(mod)
		return complimentaries
	
	func __check_dependancies():
		var mods = __get_mod_ids()
		var tags = __get_manifest_entry("manifest_definitions","dependancy_mod_ids")
		var complimentaries = {}
		for mod in tags:
			var keys = tags[mod]
			if keys.size() >= 1:
				var items = []
				for item in keys:
					if item in mods:
						pass
					else:
						items.append(item)
				if items.size() >= 1:
					complimentaries.merge({mod:items})
		return complimentaries
	
	func __check_mod_dependancies(mod_id):
		var mods = __get_mod_ids()
		var tags = __get_manifest_entry("manifest_definitions","dependancy_mod_ids",mod_id)
		var complimentaries = []
		for mod in tags:
			if mod in mods:
				pass
			else:
				complimentaries.append(mod)
		return complimentaries
	
	func __check_conflicts():
		var mods = __get_mod_ids()
		var tags = __get_manifest_entry("manifest_definitions","conflicting_mod_ids")
		var complimentaries = {}
		for mod in tags:
			var keys = tags[mod]
			if keys.size() >= 1:
				var items = []
				for item in keys:
					if item in mods:
						items.append(item)
				if items.size() >= 1:
					complimentaries.merge({mod:items})
		return complimentaries
	
	func __check_mod_conflicts(mod_id):
		var mods = __get_mod_ids()
		var tags = __get_manifest_entry("manifest_definitions","conflicting_mod_ids",mod_id)
		var complimentaries = []
		for mod in tags:
			if mod in mods:
				complimentaries.append(mod)
		return complimentaries
	
	func __parse_tags(tag_data) -> Dictionary:
		var tag_dict = {}
		for entry in tag_data:
			var type = typeof(tag_data[entry])
			if type != TYPE_DICTIONARY:
				return tag_dict
			var tag_type = tag_data[entry].get("type","NULL_TYPE")
			tag_type = tag_type.to_lower()
			match tag_type:
				"boolean","bool":
					var val = bool(tag_data[entry].get("value"))
					tag_dict.merge({entry:val})
				"string","str":
					var val = str(tag_data[entry].get("value"))
					tag_dict.merge({entry:val})
				"integer","int":
					var val = int(tag_data[entry].get("value"))
					tag_dict.merge({entry:val})
				"array","arr":
					var val = Array(tag_data[entry].get("value"))
					tag_dict.merge({entry:val})
				_:
					var val = tag_data[entry].get("value")
					tag_dict.merge({entry:val})
		return tag_dict
	
	func __have_mods_updated(folder = "user://cache/.Mod_Menu_2_Cache/changelogs/",last_seen_file = "mods_from_last_launch.json") -> Dictionary:
		if not folder.ends_with("/"):
			folder = folder + "/"
		if last_seen_file.begins_with("/"):
			last_seen_file.lstrip("/")
		var all_mods = __get_mod_data()["mods"]
		FolderAccess.__check_folder_exists(folder)
		if not file.file_exists(folder + last_seen_file):
			file.open(folder + last_seen_file,File.WRITE)
			file.store_string("{}")
			file.close()
		var mods = {}
		for mod in all_mods:
			var data = all_mods[mod]
			if data["manifest"]["has_manifest"] and data["manifest"]["manifest_version"] >= 2.0:
				var manifest = data["manifest"]["manifest_data"]
				var info = manifest["mod_information"]
				var version = manifest["version"]
				mods[info["id"]] = {"name":info["name"],"version":{"major":version["version_major"],"minor":version["version_minor"],"bugfix":version["version_bugfix"]},"path":data["node"].get_script().get_path(),"changelog":manifest["manifest_definitions"]["changelog_path"]}
		var last = {}
		if file.file_exists(folder + last_seen_file):
			file.open(folder + last_seen_file,File.READ)
			last = JSON.parse(file.get_as_text()).result
			file.close()
		var changes = {}
		for mod in mods:
			var has_changed = false
			var data = mods[mod]
			if mod in last:
				if data["version"]["major"] != last[mod]["version"]["major"]:
					has_changed = true
				if data["version"]["minor"] != last[mod]["version"]["minor"]:
					has_changed = true
				if data["version"]["bugfix"] != last[mod]["version"]["bugfix"]:
					has_changed = true
			else:
				has_changed = true
			if has_changed:
				changes.merge({mod:data})
		pass
		
		return changes
	
	func __get_mod_versions(store = false,folder = "user://cache/.Mod_Menu_2_Cache/changelogs/",last_seen_file = "mods_from_last_launch.json",this_seen_file = "mods_from_this_launch.json") -> Dictionary:
		var mods = {}
		var all_mods = {}
		if not cached_mod_list.empty():
			all_mods = cached_mod_list["mods"]
		else:
			all_mods = __get_mod_data()["mods"]
		for mod in all_mods:
			var data = all_mods[mod]
			if data["manifest"]["has_manifest"] and data["manifest"]["manifest_version"] >= 2.0:
				var manifest = data["manifest"]["manifest_data"]
				var info = manifest["mod_information"]
				var version = manifest["version"]
				mods[info["id"]] = {"name":info["name"],"version":{"major":version["version_major"],"minor":version["version_minor"],"bugfix":version["version_bugfix"]}}
		if store:
			if not folder.ends_with("/"):
				folder = folder + "/"
			if last_seen_file.begins_with("/"):
				last_seen_file.lstrip("/")
			FolderAccess.__check_folder_exists(folder)
			if file.file_exists(folder + this_seen_file):
				file.open(folder + this_seen_file,File.READ)
				var lastData = JSON.parse(file.get_as_text()).result
				file.close()
				file.open(folder + last_seen_file,File.WRITE)
				file.store_string(JSON.print(lastData))
				file.close()
			file.open(folder + this_seen_file,File.WRITE)
			file.store_string(JSON.print(mods))
			file.close()
		return mods
	
	func __parse_changelogs(file_path):
		var c = ConfigFile.new()
		var changelog = {}
		c.load(file_path)
		var versions = c.get_sections()
		var spacing = "  "
		for version in versions:
			changelog.merge({version:[]})
			var keys = c.get_section_keys(version)
			var current_key = 1
			while current_key > 0:
				var key = str(current_key)
				if key in keys:
					var entry = c.get_value(version,key)
					changelog[version].append(entry)
					var current_subkey = 1
					while current_subkey > 0:
						var subkey = key + "." + str(current_subkey)
						if subkey in keys:
							var entry2 = c.get_value(version,subkey)
							entry2 = spacing + entry2
							changelog[version].append(entry2)
							var current_subkey2 = 1
							while current_subkey2 > 0:
								var subkey2 = subkey + "." + str(current_subkey2)
								if subkey2 in keys:
									var entry3 = c.get_value(version,subkey2)
									entry3 = spacing + spacing + entry3
									changelog[version].append(entry3)
									var current_subkey3 = 1
									while current_subkey3 > 0:
										var subkey3 = subkey2 + "." + str(current_subkey3)
										if subkey3 in keys:
											var entry4 = c.get_value(version,subkey3)
											entry4 = spacing + spacing + spacing + entry4
											changelog[version].append(entry4)
											current_subkey3 += 1
										else:
											current_subkey3 = 0
									current_subkey2 += 1
								else:
									current_subkey2 = 0
							current_subkey += 1
						else:
							current_subkey = 0
						
						pass
					
					current_key += 1
				else:
					current_key = 0
			
			pass
		return changelog
	

class _NodeAccess:
	var scripts = [
		
	]
	
	var FolderAccess
	func _init(f):
		FolderAccess = f
	
	func __get_all_children(node, strip_supplied_node_from_array = false, return_only_paths = false, use_relative_paths = false):
		var children = getAllChildren(node)
		if strip_supplied_node_from_array:
			children = strip_node(node, children)
		if return_only_paths:
			children = returnPaths(children, use_relative_paths, node)
		return children

	func getAllChildren(in_node,arr:=[]):
		arr.push_back(in_node)
		for child in in_node.get_children():
			arr = getAllChildren(child,arr)
		return arr

	func strip_node(in_node, arr):
		var paths = []
		for m in arr:
			var selfPath = in_node.get_path()
			var modify = str(m.get_path()).split(selfPath)
			if modify[1] != "":
				paths.append(m)
		return paths

	func returnPaths(arr, relative, in_node):
		var parentPath = str(in_node.get_path())
		var paths = []
		for m in arr:
			var path = m.get_path()
			paths.append(path)
		if relative:
			var rel = []
			for i in paths:
				var ps = str(i).split(parentPath)[1]
				var tsu = str(ps).lstrip("/")
				rel.append(tsu)
			paths = rel
		return paths
	
	func __claim_child_ownership(node: Node):
		var children = node.get_children()
		for child in children:
			setOwnership(child, node)

	func setOwnership(current_node: Node,set_owner_node: Node):
		current_node.set_owner(set_owner_node)
		if current_node.get_child_count() >= 1:
			var children = current_node.get_children()
			for child in children:
				if not __is_instanced_from_scene(child.get_parent()):
					setOwnership(child, set_owner_node)

	func __is_instanced_from_scene(p_node):
		if not p_node.filename.empty():
			return true
		return false
	
	func __dynamic_crew_expander(folder_path: String = "user://cache/.HevLib_Cache/dynamic_crew_expander/", max_crew:int = 24) -> String:
		FolderAccess.__check_folder_exists(folder_path)
		var log_header = "TSCN Writer for dynamic crew handler: "
		
		var line_to_test = "DIALOG_DERELICT_SWITCH_CREW"
		
		var base = 24
		
		var static_line_1 = "[gd_scene load_steps=3 format=2]"
		var static_line_3 = "[ext_resource path=\"res://comms/conversation/subtrees/DIALOG_DERELICT_RANDOM.tscn\" type=\"PackedScene\" id=1]"
		var static_line_4 = "[ext_resource path=\"res://comms/ConversationPlayer.gd\" type=\"Script\" id=2]"
		var static_line_6 = "[node name=\"DIALOG_DERELICT_RANDOM_1\" instance=ExtResource( 1 )]"

		var dynamic_line_1 = "[node name=\"DIALOG_DERELICT_SWITCH_CREW|%s\" type=\"Node\" parent=\".\" index=\"%s\"]"
		var dynamic_line_2 = "script = ExtResource( 2 )"
		var dynamic_line_3 = "myLine = false"
		var dynamic_line_4 = "faceless = true"
		var dynamic_line_5 = "importChildren = NodePath(\"../DIALOG_DERELICT_GO_AND_BRING_IT\")"
		var dynamic_line_6 = "agenda = \"CREW/%s\""
		var dynamic_line_7 = "agendaNotSame = true"
		
		
		var test = load("res://comms/conversation/subtrees/DIALOG_DERELICT_RANDOM.tscn").instance()
		var children = test.get_children()
		var names = []
		for child in children:
			names.append(child.name)
		var maximum = 0
		for line in names:
			if line.begins_with(line_to_test):
				var spl = line.split("|")
				if int(spl[1]) > maximum:
					maximum = int(spl[1])
		var tester = maximum + 1
		if tester > base:
			base = tester
		
		
		if max_crew <= base:
			Debug.l(log_header + "desired expansion to [%s] is less than or equal to the currently expanded number of [%s]" % [max_crew,base])
			return ""
		else:
			var header = static_line_1 + "\n\n" + static_line_3 + "\n" + static_line_4 + "\n\n" + static_line_6 + "\n\n"
			
			var compacted_string = header
			
			while max_crew > base:
				
				var compact = dynamic_line_1 % [base,base + 4] + "\n" + dynamic_line_2 + "\n" + dynamic_line_3 + "\n" + dynamic_line_4 + "\n" + dynamic_line_5 + "\n" + dynamic_line_6 % base + "\n" + dynamic_line_7 + "\n\n"
				
				compacted_string = compacted_string + compact
				
				base += 1
			if not folder_path.ends_with("/"):
				folder_path = folder_path + "/"
			var save_file_path = folder_path + "dynamic_crew_x%s.tscn" % base
			FolderAccess.__check_folder_exists(folder_path)
			var file = File.new()
			file.open(save_file_path,File.WRITE)
			file.store_string(compacted_string)
			file.close()
			
			return save_file_path
	
	func __convert_var_from_string(string : String, folder : String = "user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/file_caches"):
		if folder.ends_with("/"):
			pass
		else:
			folder = folder + "/"
		FolderAccess.__check_folder_exists(folder)
		var header = "extends Node\n\nconst VARIABLE = "
		var file = File.new()
		file.open(folder + "conversion.gd",File.WRITE)
		file.store_string(header + string)
		file.close()
		var script = load(folder + "conversion.gd")
		var variable = script.VARIABLE
		return variable
	
	func __remove_scripts(node):
		node.set_script(null)
		for obj in node.get_children():
			__remove_scripts(obj)
	
	
	
	
	

class _RingInfo:
	var scripts = [
		
	]
	
	const pixelToKm = 10000
	const map = preload("res://ring/ring-map.png")
	const veins = preload("res://ring/ring-veins.png")
	
	func __get_pixel_at(pos: Vector2) -> Color:
		var image = map.get_data()
		var size = image.get_size()
		var x = int(clamp(floor(pos.x / pixelToKm), 0, size.x - 1))
		var sy = int(size.y)
		var y = ((int(floor(pos.y / pixelToKm)) %sy) + sy) %sy
		var x1 = int(clamp(x + 1, 0, size.x - 1))
		var y1 = (y + 1) %int(size.y)
		
		if x <= 0:
			return Color(0, 0, 0, 0)
		
		image.lock()
		var p00 = image.get_pixel(x, y)
		var p10 = image.get_pixel(x1, y)
		var p11 = image.get_pixel(x1, y1)
		var p01 = image.get_pixel(x, y1)
		image.unlock()
		
		var cx = (pos.x - floor(pos.x / pixelToKm) * pixelToKm) / pixelToKm
		var cy = (pos.y - floor(pos.y / pixelToKm) * pixelToKm) / pixelToKm

		var pu = (p00 * (1 - cx) + p10 * (cx))
		var pd = (p01 * (1 - cx) + p11 * (cx))
		
		var pixel = pu * (1 - cy) + pd * (cy)
		return pixel
	
	func __get_vein_pixel_at(pos: Vector2) -> Color:
		var veinImage = veins.get_data()
		var veinSize = veinImage.get_size()
		var x = posmod(pos.x, veinSize.x)
		var y = posmod(pos.y, veinSize.y)
		var x1 = posmod(pos.x + 1, veinSize.x)
		var y1 = posmod(pos.y + 1, veinSize.y)
		
		veinImage.lock()
		var p00 = veinImage.get_pixel(x, y)
		var p10 = veinImage.get_pixel(x1, y)
		var p11 = veinImage.get_pixel(x1, y1)
		var p01 = veinImage.get_pixel(x, y1)
		veinImage.unlock()
		
		var cx = fposmod(pos.x, 1)
		var cy = fposmod(pos.y, 1)

		var pu = lerp(p00, p10, cx)
		var pd = lerp(p01, p11, cx)
		
		var pixel = lerp(pu, pd, cy)
		return pixel
	
	func __get_vein_at(pos: Vector2) -> String:
		var p1 = __get_vein_pixel_at(pos / 1861.0)
		var p2 = __get_vein_pixel_at(pos / - 2531.0)
		
		var values = [p1.r, p1.g, p1.b, p1.a, p2.r, p2.b, p2.g, p2.a]
			
		var total = 0
		for n in range(CurrentGame.traceMinerals.size()):
			var tm = CurrentGame.traceMinerals[n]
			values[n] = pow(values[n] / pow(CurrentGame.mineralPrices.get(tm, 1), 0.2), 4)
			total += values[n]
			
		var rnd = randf() * total
		var nr = 0
		for n in values:
			rnd -= n
			if rnd < 0:
				return CurrentGame.traceMinerals[nr]
			nr += 1
		
		return CurrentGame.traceMinerals[0]
	
	func get_chaos_at(pos):
		return __get_pixel_at(pos).r
	
	func get_raw_density_at(pos):
		return __get_pixel_at(pos).b
	

class _TimeAccess:
	var scripts = [
		
	]
	
	func __compare_dates(date, compare_to_this_date):
		var isDifferent = false
		var difference = "newer"
		var splitOne = date.split("T")
		var splitTwo = compare_to_this_date.split("T")
		var dateOne = splitOne[0].split("-")
		var dateTwo = splitTwo[0].split("-")
		var timeOne = splitOne[1].split(":")
		var timeTwo = splitTwo[1].split(":")
		var concatOne = [dateOne[0],dateOne[1],dateOne[2],timeOne[0],timeOne[1],timeOne[2]]
		var concatTwo = [dateTwo[0],dateTwo[1],dateTwo[2],timeTwo[0],timeTwo[1],timeTwo[2]]
		var index = 0
		while index < 6:
			var compare1 = concatOne[index]
			var compare2 = concatTwo[index]
			if compare1 > compare2:
				isDifferent = true
				difference = "newer"
			if compare1 < compare2:
				isDifferent = true
				difference = "older"
			if compare1 == compare2:
				isDifferent = false
				difference = "equal"
			
			if isDifferent:
				return difference
			index += 1
		if index >= 6:
			return "equal"
	
	func __get_time_in_seconds(datetime_dict : Dictionary):
		var time : int = 0
		time += (datetime_dict.get("second",0))
		time += (datetime_dict.get("minute",0) * 60)
		time += (datetime_dict.get("hour",0) * 60 * 60)
		time += (datetime_dict.get("day",0) * 60 * 60 * 24)
		time += (datetime_dict.get("month",0) * 60 * 60 * 24 * 30)
		time += (datetime_dict.get("year",0) * 60 * 60 * 24 * 30 * 12)
		
		
		return time
	

class _Translations:
	var scripts = [
		
	]
	
	var ConfigDriver
	func _init(c):
		ConfigDriver = c
	
	func __updateTL(path:String, delim:String = ",", fullLogging:bool = true):
		var fileName = path.split("/")[path.split("/").size() - 1]
		var folderName = path.split(fileName)[0]
		Debug.l("Adding translations from [%s] in [%s]" % [fileName, folderName])
		var tlFile:File = File.new()
		tlFile.open(path, File.READ)
		var translations := []
		var translationCount = 0
		var csvLine := tlFile.get_line().split(delim)
		if fullLogging:
			Debug.l("Adding translations as: %s" % csvLine)
		for i in range(1, csvLine.size()):
			var translationObject := Translation.new()
			translationObject.locale = csvLine[i]
			translations.append(translationObject)
		while not tlFile.eof_reached():
			csvLine = tlFile.get_csv_line(delim)
			var size = csvLine.size()
			if size > 1:
				if size > 2:
					var i = 0
					while i < size:
						if csvLine[i].ends_with("\\") and i < size:
							csvLine[i] = csvLine[i].rstrip("\\") + delim + csvLine[i + 1]
							csvLine.remove(i + 1)
							size -= 1
						i += 1
				var translationID := csvLine[0]
				for i in range(1, size):
					translations[i - 1].add_message(translationID, csvLine[i].c_unescape())
				if fullLogging:
					Debug.l("Added translation: %s" % csvLine)
				translationCount += 1
		tlFile.close()
		for translationObject in translations:
			TranslationServer.add_translation(translationObject)
		Debug.l("%s Translations Updated from @ [%s]" % [translationCount, fileName])
	
	func __updateTL_from_dictionary(path:Dictionary, fullLogging:bool = true):
		Debug.l("Adding translations from dictionary")
		var translations := []
		var translationCount = 0
		if fullLogging:
			Debug.l("Adding translations as: %s" % str(path.hash()))
		if "file" in path.keys():
			var file_paths = path["file"]
			for file in file_paths:
				var delim = file_paths[file]
				match typeof(delim):
					TYPE_STRING:
						var dict = __translation_file_to_dictionary(file,delim)
						__updateTL_from_dictionary(dict,fullLogging)
					TYPE_DICTIONARY:
						var string = delim.get("string","")
						var mod = delim.get("mod","")
						var section = delim.get("section","")
						var setting = delim.get("setting","")
						var invert = delim.get("invert",false)
						var val = ConfigDriver.__get_value(mod,section,setting)
						var do = true
						if typeof(val) == TYPE_BOOL:
							do = val
						if invert:
							do = !do
						if do and string != "":
							var dict = __translation_file_to_dictionary(file,string)
							__updateTL_from_dictionary(dict,fullLogging)
						
			path.erase("file")
		for lang in path.keys():
			var translationObject := Translation.new()
			translationObject.locale = lang
			var translation_dict = path.get(lang)
			var tKeys = translation_dict.keys()
			for key in tKeys:
				var data = translation_dict.get(key)
				match typeof(data):
					TYPE_STRING:
						translationObject.add_message(key,data.c_unescape())
						if fullLogging:
							Debug.l("Added translation: %s" % key)
					TYPE_DICTIONARY:
						var string = data.get("string","")
						var mod = data.get("mod","")
						var section = data.get("section","")
						var setting = data.get("setting","")
						var invert = data.get("invert",false)
						var val = ConfigDriver.__get_value(mod,section,setting)
						var do = true
						if typeof(val) == TYPE_BOOL:
							do = val
						if invert:
							do = !do
						if do and string != "":
							translationObject.add_message(key,string.c_unescape())
						if fullLogging:
							Debug.l("Added translation: %s" % key)
						pass
			translationCount += 1
			
			translations.append(translationObject)
		for translationObject in translations:
			TranslationServer.add_translation(translationObject)
		Debug.l("%s Translations Updated" % [translationCount])
	
	func __fetch_all_translation_objects(index) -> Array:
		var translations = []
		while index >= 1:
			var obj = instance_from_id(index)
			index -= 1
			if obj == null:
				continue
			var data = obj.get_class()
			if not data == "Translation":
				continue
			translations.append(obj) # for future, see if obj.self works to get the node instead of a reference
		return translations
	
	func __translation_file_to_dictionary(path : String, delimiter : String = "|") -> Dictionary:
		var log_header = "HevLib Translations: "
	#	Debug.l(log_header + "__translation_file_to_dictionary started for file at [%s] using CSV delimiter as [%s]" % [path, delimiter])
		var exists = Directory.new().file_exists(path)
		if not exists:
	#		Debug.l(log_header + "file at [%s] does not exist, returning empty dictionary" % path)
			return {}
		var dictionary = {}
		var file = File.new()
		file.open(path,File.READ)
		var lines = file.get_as_text(true).split("\n")
		file.close()
		
		var lang_data = lines[0]
		var language_lines = lang_data.split(delimiter)
		if not language_lines[0] == "locale":
	#		Debug.l(log_header + "improper localization header for [%s], exiting with empty dictionary" % path)
			return {}
		if language_lines.size() <= 1:
	#		Debug.l(log_header + "no languages specified at [%s], exiting with empty dictionary" % path)
			return {}
		var languages = []
		var lsize = language_lines.size()
		var lindex = 1
		while lindex < lsize:
			languages.append(language_lines[lindex])
			lindex += 1
		
		for lang in languages:
			var smdc = {lang:{}}
			dictionary.merge(smdc)
		var translation_count = 0
		var size = lines.size()
		var index = 1
		while index < size:
			var line = lines[index]
			if line == "":
				index += 1
				continue
			var line_split = line.split(delimiter)
			var split_size = line_split.size() - 1
			if split_size + 1 == 1:
				index += 1
				continue
			if split_size < languages.size():
				index += 1
				continue
			var translation_string = line_split[0]
			var tlindex = 0
			while tlindex < languages.size():
				var lang = languages[tlindex]
				dictionary[lang].merge({translation_string:line_split[tlindex + 1]})
				tlindex += 1
			index += 1
			translation_count += 1
	#	Debug.l(log_header + "fetched translations from [%s], which contains [%s] languages and [%s] translations" % [path,languages.size(),translation_count])
		return dictionary
	
	

class _WebTranslate:
	var scripts = [
		
	]
	
	var FolderAccess
	func _init(f):
		FolderAccess = f
	
	func __webtranslate(URL: String, fallback: Array = [], file_check: String = ""):
		Debug.l("HevLib WebTranslate: Fetching translations from %s" % URL)
		var HevLib = preload("res://HevLib/webtranslate/FetchGithubData.tscn").instance()
		var pms = Debug.get_node("/root")
		var tstamp = Time.get_datetime_string_from_system()
		var date = str(tstamp.split("T")[0])
		var time = str(tstamp.split("T")[1])
		var tSpl = time.split(":")
		var timeConcat = tSpl[0] + "-" + tSpl[1] + "-" + tSpl[2]
		var timestamp = "~" + date + "~" + timeConcat
		var nodes = pms.get_children()
		var names = []
		for node in nodes:
			var name = node.name
			if name.begins_with("FetchGithubData"):
				names.append(name)
		var nSize = names.size()
		
		
		Debug.l("HevLib WebTranslate: attaching node @ FetchGithubData%s~%s" % [timestamp,str(nSize)])
		HevLib.name = "FetchGithubData" + timestamp + "~" + str(nSize)
		HevLib.URLFullStopReformat = URL
		HevLib.fallbackFiles = fallback
		
		HevLib.file_check = file_check
		
		pms.call_deferred("add_child",HevLib)
	
	func __webtranslate_reset(URL: String) -> bool:
		var urlSplit = str(URL).split("github.com/")[1]
		var dataSplit = urlSplit.split("/")
		var user = dataSplit[0]
		var repo = dataSplit[1]
		var folderConcat = user + "~_~" + repo
		var folderToDelete = "user://cache/.HevLib_Cache/WebTranslate/" + folderConcat
		Debug.l("HevLib WebTranslate: deleting cache folder @ %s" % folderToDelete)
		var did = FolderAccess.__recursive_delete(folderToDelete)
		if did:
			return true
		else:
			return false
	
	func __webtranslate_reset_by_file_check(file_check: String) -> bool:
		var did = false
		var folder_to_delete = ""
		var cache = "user://cache/.HevLib_Cache/WebTranslate/"
		var dir = Directory.new()
		var files = FolderAccess.__fetch_folder_files(cache, true, true)
		for file in files:
			if not file.ends_with("/"):
				continue
			var cFiles = FolderAccess.__fetch_folder_files(file, false, true)
			for f in cFiles:
				if not f.ends_with(".file_check_cache"):
					continue
				var fo = File.new()
				fo.open(f,File.READ)
				var txt = fo.get_as_text()
				fo.close()
				if txt == file_check:
					folder_to_delete = file
				else:
					continue
		if not folder_to_delete == "":
			did = FolderAccess.__recursive_delete(folder_to_delete)
		return did
	
	func __webtranslate_timed(URL: String, MINUTES_DELAY: int, fallback: Array = [], file_check: String = ""):
		Debug.l("HevLib WebTranslate: function 'webtranslate_timed' initiated, starting constant translation of [%s] with a delay of [%s] minutes" % [URL,MINUTES_DELAY])
		var variableNode = ModLoader.get_tree().get_root().get_node("/root/HevLib~Variables")
		var handleNode = preload("res://HevLib/webtranslate/WebtranslateTimerHandler.tscn").instance()
		handleNode.name = URL + Time.get_time_string_from_system()
		handleNode.URL = URL
		handleNode.MINUTES = MINUTES_DELAY
		handleNode.fallback = fallback
		handleNode.file_check = file_check
		variableNode.add_child(handleNode)
	
	
	
	
	
	
	

class _Zip:
	var scripts = [
		
	]
	func __get_zip_content(path, stripFolder = false, lowerCase = false):
		var listOfNames = []
		var g = gdunzip.new()
		g.load(path)
		var fileList = gdunzip.files
		for m in fileList.keys():
			if stripFolder:
				var delim = m.split("/")[0] + "/"
				var s = m.split(delim)
				m = s[1]
			if lowerCase:
				m = m.to_lower()
			listOfNames.append(m)
		var dFiles = ""
		for m in listOfNames:
			if dFiles == "":
				dFiles = m
			else:
				dFiles = dFiles + ", " + m
		return listOfNames
	func __fetch_file_from_zip(path, cacheDir, desiredFiles):
		var dFiles = ""
		for m in desiredFiles:
			if dFiles == "":
				dFiles = m
			else:
				dFiles = dFiles + ", " + m
		var listOfNames = []
		var uncompressed = {}
		var zip = path.split("/")
		var splitSize = zip.size()
		var zipName = zip[splitSize - 1]
		var g = gdunzip.new()
		g.load(path)
		var fileList = g.files
		for m in fileList.keys():
			listOfNames.append(m)
		for f in listOfNames:
			var string = cacheDir + f
			if string.ends_with("/"):
				var dir = Directory.new()
				dir.make_dir_recursive(string)
		var modFolder = listOfNames[0]
		var savedFiles = []
		for d in desiredFiles:
			for F in listOfNames:
				var M = str(F).split(str(F).split("/")[0] + "/")[1]
				if str(M).to_lower() == str(d).to_lower():
					var fileToFetch = modFolder + d
					var saveDir = cacheDir + fileToFetch
					var data = g.uncompress(F).get_string_from_utf8()
					if data:
						var file = File.new()
						file.open(saveDir, File.WRITE)
						file.store_string(data)
						file.close()
						savedFiles.append(saveDir)
					else:
						savedFiles.append("")
		var mFiles = ""
		for m in savedFiles:
			if mFiles == "":
				mFiles = m
			else:
				mFiles = mFiles + ", " + m
		return savedFiles











