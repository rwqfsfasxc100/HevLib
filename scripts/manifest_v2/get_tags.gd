extends Node

static func get_tags(FolderAccess = null,DataFormat = null) -> Dictionary:
#	var mods = ModLoader.get_children()
	var ManifestV2 = load("res://HevLib/pointers/ManifestV2.gd")
	
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
		
		var ps = DataFormat.get_script_constant_map_without_load("res://ModLoader.gd")
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
		
		
		
		var folders = FolderAccess.fetch_folder_files("res://", true, true)
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
				var folderCheck = FolderAccess.fetch_folder_files(folder,true)
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
					var constants = DataFormat.get_script_constant_map_without_load(mv)
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
				var manifest_data = ManifestV2.__parse_file_as_manifest(folder_path + file, true)
				var mod_id = manifest_data["mod_information"]["id"]
				var manifest_version = manifest_data["manifest_definitions"]["manifest_version"]
				if mod_id:
					if manifest_version >= 2.1:
						var tag_data = manifest_data["tags"]
						var p = ManifestV2.__parse_tags(tag_data)
						for entry in p:
							if not entry in tag_dict:
								tag_dict.merge({entry:{}})
							tag_dict[entry].merge({mod_id:p[entry]})
	return tag_dict
