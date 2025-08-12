extends Node

static func get_mod_data_from_files(script_path:String, format_to_manifest_version: bool = false) -> Dictionary:
	var FolderAccess = preload("res://HevLib/pointers/FolderAccess.gd")
	var ManifestV2 = preload("res://HevLib/pointers/ManifestV2.gd")
	var FileAccess = preload("res://HevLib/pointers/FileAccess.gd")
	var constants = load(script_path).get_script_constant_map()
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
			manifest_data = ManifestV2.__parse_file_as_manifest(folder_path + file, true)
			mod_name = manifest_data["package"].get("name",mod_name)
			legacy_mod_version = manifest_data["package"].get("version",legacy_mod_version)
			mod_version_major = manifest_data["package"].get("version_major",mod_version_major)
			mod_version_minor = manifest_data["package"].get("version_minor",mod_version_minor)
			mod_version_bugfix = manifest_data["package"].get("version_bugfix",mod_version_bugfix)
			mod_version_metadata = manifest_data["package"].get("version_metadata",mod_version_metadata)
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
	var mod_entry = {str(script_path):{"name":mod_name,"priority":mod_priority,"version_data":version_dictionary,"mod_icon":icon_dict,"library_information":{"is_a_library":mod_is_library,"keep_library_hidden":hide_library},"manifest":manifestEntry}}
	return(mod_entry)
