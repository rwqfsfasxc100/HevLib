extends Node

static func get_mod_data(format_to_manifest_version:bool,print_json:bool) -> Dictionary:
	var mods = ModLoader.get_children()
	var FolderAccess = preload("res://HevLib/pointers/FolderAccess.gd")
	var ManifestV2 = preload("res://HevLib/pointers/ManifestV2.gd")
	var mod_dictionary = {}
	var manifest_count = 0
	var library_count = 0
	var non_library_count = 0
	# FUTURE ME: FIX THIS TO USE PARSE TAGS
	var stat_tags = {
				"adds_equipment":[],
				"adds_events":[],
				"adds_gameplay_mechanics":[],
				"adds_ships":[],
				"allow_achievements":0,
				"fun":0,
				"handle_extra_crew":24,
				"is_library_mod":0,
				"library_hidden_by_default":0,
				"overhaul":0,
				"quality_of_life":0,
				"uses_hevlib_research":0,
				"visual":0,
				"language":{"en":0},
				"user_interface":0
				}
	for mod in mods:
		var constants = mod.get_script().get_script_constant_map()
		var script_path = mod.get_script().get_path()
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
				manifest_count += 1
				manifest_data = ManifestV2.__parse_file_as_manifest(folder_path + file, true)
				mod_name = manifest_data["mod_information"].get("name",mod_name)
				legacy_mod_version = manifest_data["version"].get("version_string",legacy_mod_version)
				mod_version_major = manifest_data["version"].get("version_major",mod_version_major)
				mod_version_minor = manifest_data["version"].get("version_minor",mod_version_minor)
				mod_version_bugfix = manifest_data["version"].get("version_bugfix",mod_version_bugfix)
				mod_version_metadata = manifest_data["version"].get("version_metadata",mod_version_metadata)
				mod_is_library = manifest_data["tags"].get("is_library_mod",false)
				hide_library = manifest_data["tags"].get("library_hidden_by_default",true)
				manifest_version = manifest_data["manifest_definitions"].get("manifest_version",1)
				
				var equipment = manifest_data["tags"].get("adds_equipment",[])
				for item in equipment:
					if not item in stat_tags["adds_equipment"]:
						stat_tags["adds_equipment"].append(item)
				
				var events = manifest_data["tags"].get("adds_events",[])
				for item in events:
					if not item in stat_tags["adds_events"]:
						stat_tags["adds_events"].append(item)
				
				var gameplay = manifest_data["tags"].get("adds_gameplay_mechanics",[])
				for item in gameplay:
					if not item in stat_tags["adds_gameplay_mechanics"]:
						stat_tags["adds_gameplay_mechanics"].append(item)
				
				var ships = manifest_data["tags"].get("adds_ships",[])
				for item in ships:
					if not item in stat_tags["adds_ships"]:
						stat_tags["adds_ships"].append(item)
				
				var allow_achievements = manifest_data["tags"].get("allow_achievements",false)
				if allow_achievements:
					stat_tags["allow_achievements"] += 1
				
				var fun = manifest_data["tags"].get("fun",false)
				if fun:
					stat_tags["allow_achievements"] += 1
				
				var handle_extra_crew = manifest_data["tags"].get("handle_extra_crew",24)
				if handle_extra_crew > stat_tags["handle_extra_crew"]:
					stat_tags["handle_extra_crew"] = handle_extra_crew
				
				var is_library_mod = manifest_data["tags"].get("is_library_mod",false)
				if is_library_mod:
					stat_tags["is_library_mod"] += 1
					library_count += 1
					var library_hidden_by_default = manifest_data["tags"].get("library_hidden_by_default",false)
					if library_hidden_by_default:
						stat_tags["library_hidden_by_default"] += 1
				
				var overhaul = manifest_data["tags"].get("overhaul",false)
				if overhaul:
					stat_tags["overhaul"] += 1
				
				var quality_of_life = manifest_data["tags"].get("quality_of_life",false)
				if quality_of_life:
					stat_tags["quality_of_life"] += 1
				
				var uses_hevlib_research = manifest_data["tags"].get("uses_hevlib_research",false)
				if uses_hevlib_research:
					stat_tags["uses_hevlib_research"] += 1
				
				var visual = manifest_data["tags"].get("visual",false)
				if visual:
					stat_tags["visual"] += 1
				
				var user_interface = manifest_data["tags"].get("user_interface",false)
				if user_interface:
					stat_tags["user_interface"] += 1
				
				var language = manifest_data["tags"].get("language",["en"])
				for lang in language:
					if lang in stat_tags["language"].keys():
						stat_tags["language"][lang] += 1
					else:
						stat_tags["language"].merge({lang:1})
					
					
				
			if file.to_lower().begins_with("icon") and file.to_lower().ends_with(".stex"):
				has_icon_file = true
				icon_path = folder_path + file
		var icon_dict = {"has_icon_file":has_icon_file,"icon_path":icon_path}
		var manifestEntry = {"has_manifest":has_mod_manifest,"manifest_version":manifest_version,"manifest_data":manifest_data}
		var mod_version_array = [mod_version_major,mod_version_minor,mod_version_bugfix]
		var mod_version_string = str(mod_version_major) + "." + str(mod_version_minor) + "." + str(mod_version_bugfix)
#		if mod_is_library:
#			library_count += 1
#		else:
#			non_library_count += 1
		if not str(mod_version_metadata) == "":
			mod_version_array.append(mod_version_metadata)
			mod_version_string = mod_version_string + "-" + str(mod_version_metadata)
		var version_dictionary = {"version_major":mod_version_major,"version_minor":mod_version_minor,"version_bugfix":mod_version_bugfix,"version_metadata":mod_version_metadata,"full_version_array":mod_version_array,"full_version_string":mod_version_string,"legacy_mod_version":legacy_mod_version}
		var mod_entry = {str(script_path):{"name":mod_name,"priority":mod_priority,"version_data":version_dictionary,"mod_icon":icon_dict,"library_information":{"is_a_library":mod_is_library,"keep_library_hidden":hide_library},"node":mod,"manifest":manifestEntry}}
		mod_dictionary.merge(mod_entry)
	var stat_count = {"total_mod_count":mods.size(),"mods_using_manifests":manifest_count,"mods":non_library_count,"libraries":library_count}
#	breakpoint
	var statistics = {"counts":stat_count,"tags":stat_tags}
	var returnValues = {"mods":mod_dictionary,"statistics":statistics}
	if print_json:
		var psj = JSON.print(returnValues, "\t")
		return psj
	else:
		return returnValues
