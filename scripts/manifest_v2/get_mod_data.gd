extends Node

static func get_mod_data(format_to_manifest_version:bool,print_json:bool,FolderAccess = null,DataFormat = null) -> Dictionary:
#	var mods = ModLoader.get_children()
	var ManifestV2 = load("res://HevLib/pointers/ManifestV2.gd")
	
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
				manifest_data = ManifestV2.__parse_file_as_manifest(folder_path + file, true)
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
	if print_json:
		var psj = JSON.print(returnValues, "\t")
		return psj
	else:
		return returnValues
