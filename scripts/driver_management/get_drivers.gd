extends Node

const FolderAccess = preload("res://HevLib/pointers/FolderAccess.gd")
const FileAccess = preload("res://HevLib/pointers/FileAccess.gd")
const MV2 = preload("res://HevLib/pointers/ManifestV2.gd")

static func get_drivers(get_ids):
	var DriverManagement = load("res://HevLib/pointers/DriverManagement.gd")
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
						var manifest = MV2.__parse_file_as_manifest(folder + manifest_path)
						id = manifest.get("mod_information",{}).get("id","")
					if id != "":
						this_mod_data.merge({"id":id})
					var mm_prio = 0
					var modmain = FileAccess.__get_file_content(folder + modmain_path)
					for line in modmain.split("\n"):
						var lsp = line.split("MOD_PRIORITY")
						if lsp.size() > 1:
							var lp = lsp[1].split("=")
							for vms in lp[1].split(" "):
								if vms != "":
									mm_prio = str2var(vms)
					if typeof(mm_prio) == TYPE_STRING:
						if mm_prio == "INF":
							mm_prio = INF
						elif mm_prio == "-INF":
							mm_prio = -INF
					this_mod_data.merge({"priority":mm_prio})
					
					
					if "HEVLIB_EQUIPMENT_DRIVER_TAGS/" in folderCheck:
						var driverFolder = folder + "HEVLIB_EQUIPMENT_DRIVER_TAGS/"
						for driver in FolderAccess.__fetch_folder_files(driverFolder):
							if driver in this_mod_data["drivers"]:
								pass
							else:
								this_mod_data["drivers"].merge({driver:{}})
							var dv = load(driverFolder + driver)
							var consts = dv.get_script_constant_map()
							for i in consts:
								this_mod_data["drivers"][driver].merge({i:consts[i]})
					if "HEVLIB_MENU/" in folderCheck:
						var driverFolder = folder + "HEVLIB_MENU/"
						for driver in FolderAccess.__fetch_folder_files(driverFolder):
							if driver in this_mod_data["drivers"]:
								pass
							else:
								this_mod_data["drivers"].merge({driver:{}})
							var dv = load(driverFolder + driver)
							var consts = dv.get_script_constant_map()
							for i in consts:
								this_mod_data["drivers"][driver].merge({i:consts[i]})
					if "HEVLIB_MINERAL_DRIVER_TAGS/" in folderCheck:
						var driverFolder = folder + "HEVLIB_MINERAL_DRIVER_TAGS/"
						for driver in FolderAccess.__fetch_folder_files(driverFolder):
							if driver in this_mod_data["drivers"]:
								pass
							else:
								this_mod_data["drivers"].merge({driver:{}})
							var dv = load(driverFolder + driver)
							var consts = dv.get_script_constant_map()
							for i in consts:
								this_mod_data["drivers"][driver].merge({i:consts[i]})
					if "HEVLIB_DRIVERS/" in folderCheck:
						var driverFolder = folder + "HEVLIB_DRIVERS/"
						for driver in FolderAccess.__fetch_folder_files(driverFolder):
							if driver in this_mod_data["drivers"]:
								pass
							else:
								this_mod_data["drivers"].merge({driver:{}})
							var dv = load(driverFolder + driver)
							var consts = dv.get_script_constant_map()
							for i in consts:
								this_mod_data["drivers"][driver].merge({i:consts[i]})
					this_mod_data.merge({"mod_directory":folder})
					if this_mod_data["drivers"].size() > 0:
						if (get_ids.size()) == 0 or (get_ids.size() > 0 and id in get_ids):
							mod_drivers.append(this_mod_data)
	else:
		var mods = MV2.__get_mod_data()["mods"]
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
			
			var mp = mod_data["node"].get_script().get_path()
			
			var folder = mp.split(mp.split("/")[mp.split("/").size() - 1])[0]
			var folderCheck = FolderAccess.__fetch_folder_files(folder,true)
			
			
			if "HEVLIB_EQUIPMENT_DRIVER_TAGS/" in folderCheck:
				var driverFolder = folder + "HEVLIB_EQUIPMENT_DRIVER_TAGS/"
				for driver in FolderAccess.__fetch_folder_files(driverFolder):
					if driver in this_mod_data["drivers"]:
						pass
					else:
						this_mod_data["drivers"].merge({driver:{}})
					var dv = load(driverFolder + driver)
					var consts = dv.get_script_constant_map()
					for i in consts:
						this_mod_data["drivers"][driver].merge({i:consts[i]})
			if "HEVLIB_MENU/" in folderCheck:
				var driverFolder = folder + "HEVLIB_MENU/"
				for driver in FolderAccess.__fetch_folder_files(driverFolder):
					if driver in this_mod_data["drivers"]:
						pass
					else:
						this_mod_data["drivers"].merge({driver:{}})
					var dv = load(driverFolder + driver)
					var consts = dv.get_script_constant_map()
					for i in consts:
						this_mod_data["drivers"][driver].merge({i:consts[i]})
			if "HEVLIB_MINERAL_DRIVER_TAGS/" in folderCheck:
				var driverFolder = folder + "HEVLIB_MINERAL_DRIVER_TAGS/"
				for driver in FolderAccess.__fetch_folder_files(driverFolder):
					if driver in this_mod_data["drivers"]:
						pass
					else:
						this_mod_data["drivers"].merge({driver:{}})
					var dv = load(driverFolder + driver)
					var consts = dv.get_script_constant_map()
					for i in consts:
						this_mod_data["drivers"][driver].merge({i:consts[i]})
			if "HEVLIB_DRIVERS/" in folderCheck:
				var driverFolder = folder + "HEVLIB_DRIVERS/"
				for driver in FolderAccess.__fetch_folder_files(driverFolder):
					if driver in this_mod_data["drivers"]:
						pass
					else:
						this_mod_data["drivers"].merge({driver:{}})
					var dv = load(driverFolder + driver)
					var consts = dv.get_script_constant_map()
					for i in consts:
						this_mod_data["drivers"][driver].merge({i:consts[i]})
			this_mod_data.merge({"mod_directory":folder})
			if this_mod_data["drivers"].size() > 0:
				if (get_ids.size()) == 0 or (get_ids.size() > 0 and id in get_ids):
					mod_drivers.append(this_mod_data)
	
	
	
	
	
	mod_drivers.sort_custom(DriverManagement,"__compare_driver_dictionaries")
	return mod_drivers
	


