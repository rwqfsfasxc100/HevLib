extends Node

static func get_mod_data(print_json) -> Dictionary:
	var mods = ModLoader.get_children()
	var FolderAccess = preload("res://HevLib/pointers/FolderAccess.gd")
	var FileAccess = preload("res://HevLib/pointers/FileAccess.gd")
	var mod_dictionary = {}
	for mod in mods:
		var constants = mod.get_script().get_script_constant_map()
		var script_path = mod.get_script().get_path()
		var folder_path = script_path.split(script_path.split("/")[script_path.split("/").size() - 1])[0]
		var mod_priority = constants.get("MOD_PRIORITY",0)
		var mod_name = constants.get("MOD_NAME",script_path.split("/")[2])
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
		for file in content:
			if file.to_lower() == "mod.manifest":
				has_mod_manifest = true
				var cfg = FileAccess.__config_parse(folder_path + file)
				if "package" in cfg.keys():
					mod_name = cfg["package"].get("name",mod_name)
					legacy_mod_version = cfg["package"].get("version",legacy_mod_version)
					mod_version_major = cfg["package"].get("version_major",mod_version_major)
					mod_version_minor = cfg["package"].get("version_minor",mod_version_minor)
					mod_version_bugfix = cfg["package"].get("version_bugfix",mod_version_bugfix)
					mod_version_metadata = cfg["package"].get("version_metadata",mod_version_metadata)
				if "manifest_definitions" in cfg.keys():
					manifest_version = cfg["manifest_definitions"].get("manifest_version",manifest_version)
				manifest_data = cfg
		
		var manifestEntry = {"has_manifest":has_mod_manifest,"manifest_data":manifest_data}
		var mod_version_array = [mod_version_major,mod_version_minor,mod_version_bugfix]
		var mod_version_string = str(mod_version_major) + "." + str(mod_version_minor) + "." + str(mod_version_bugfix)
		if not str(mod_version_metadata) == "":
			mod_version_array.append(mod_version_metadata)
			mod_version_string = mod_version_string + "-" + str(mod_version_metadata)
		var version_dictionary = {"version_major":mod_version_major,"version_minor":mod_version_minor,"version_bugfix":mod_version_bugfix,"version_metadata":mod_version_metadata,"full_version_array":mod_version_array,"full_version_string":mod_version_string,"legacy_mod_version":legacy_mod_version}
		var mod_entry = {str(script_path):{"name":mod_name,"priority":mod_priority,"version_data":version_dictionary,"library_information":{"is_a_library":mod_is_library,"keep_library_hidden":hide_library},"node":mod,"manifest":manifestEntry}}
		mod_dictionary.merge(mod_entry)
	var statistics = {"installed_mod_count":mods.size()}
	var returnValues = {"mods":mod_dictionary,"statistics":statistics}
	if print_json:
		var psj = JSON.print(returnValues, "\t")
		return psj
	else:
		return returnValues
