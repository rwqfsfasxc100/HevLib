extends Node

static func get_tags() -> Dictionary:
	var mods = ModLoader.get_children()
	var FolderAccess = load("res://HevLib/pointers/FolderAccess.gd")
	var ManifestV2 = load("res://HevLib/pointers/ManifestV2.gd")
	
	var tag_dict = {}
	
	for mod in mods:
		var constants = mod.get_script().get_script_constant_map()
		var script_path = mod.get_script().get_path()
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
