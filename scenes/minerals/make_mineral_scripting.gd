extends Node

static func make_mineral_scripting(is_onready = false):
	
	var FILE_PATHS = [
		"user://cache/.HevLib_Cache/Minerals/mineral_cache.json",
		"user://cache/.HevLib_Cache/Minerals/AsteroidSpawner.gd",
		"user://cache/.HevLib_Cache/Minerals/CurrentGame.gd",
		"user://cache/.HevLib_Cache/Minerals/TheRing.gd",
	]
	
	var FolderAccess = preload("res://HevLib/pointers/FolderAccess.gd")
	for file in FILE_PATHS:
		FolderAccess.__check_folder_exists(file.split(file.split("/")[file.split("/").size() - 1])[0])
	
	var mineral_cache_file = FILE_PATHS[0]
	var asteroid_spawner_script = FILE_PATHS[1]
	var current_game_script = FILE_PATHS[2]
	var the_ring_script = FILE_PATHS[3]
	
	var DataFormat = preload("res://HevLib/pointers/DataFormat.gd")
	if is_onready:
		
		var version = DataFormat.__get_vanilla_version()
		var text = "HevLib Mineral Manager: observed game version of %s"  % str(version)
		Debug.l(text)
	
	
	var folders = FolderAccess.__fetch_folder_files("res://", true, true)
	
	
	
	
	
	var running_in_debugged = false
	var debugged_defined_mods = []
	var onready_mod_paths = []
	var onready_mod_folders = []
	
	# Use when not loading from ready
	if not is_onready:
		var p = load("res://ModLoader.gd")
		var ps = p.get_script_constant_map()
		for item in ps:
			if item == "is_debugged":
				running_in_debugged = true
				var pf = File.new()
#				if pf.file_exists("res://ModLoader.gd"):
#					l("Can see ModLoader.gd")
#				else:
#					l("Cannot see ModLoader.tscn")
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
	
	
	# Use when running on ready
	if is_onready:
		var mods = ModLoader.get_children()
		for mod in mods:
			var path = mod.get_script().get_path()
			onready_mod_paths.append(path)
			var split = path.split("/")
			onready_mod_folders.append(split[2])
	
	var f = File.new()
	
	
	f.open(mineral_cache_file,File.WRITE)
	f.store_string("[]")
	f.close()
	
	for folder in folders:
		var semi_root = folder.split("/")[2]
		if semi_root.begins_with("."):
			continue
					
		if folder.ends_with("/"):
			var mods_to_avoid = []
			if not is_onready:
				if running_in_debugged:
					for mod in debugged_defined_mods:
						var home = mod.split("/")[2]
						if home == semi_root:
							mods_to_avoid.append(home)
			var folder_2 = FolderAccess.__fetch_folder_files(folder, true, true)
			for check in folder_2:
				if not is_onready:
					if semi_root in mods_to_avoid:
						continue
				else:
					if not semi_root in onready_mod_folders:
						continue
				if check.ends_with("HEVLIB_MINERAL_DRIVER_TAGS/"): # MINERALDRIVER FILES
					var files = FolderAccess.__fetch_folder_files(check, false, true)
					var mod = check.hash()
					var mineral_dict = []
					for file in files:
						var last_bit = file.split("/")[file.split("/").size() - 1]
						match last_bit:
							"ADD_MINERALS.gd":
								var data = load(check + last_bit)
								var constants = data.get_script_constant_map()
								for item in constants:
									var equipment = data.get(item).duplicate(true)
									mineral_dict.append(equipment)
					
					f.open(mineral_cache_file,File.READ_WRITE)
					var md = JSON.parse(f.get_as_text(true)).result
					md.append_array(mineral_dict)
					f.store_string(JSON.print(md))
					f.close()
					
	
	
	
