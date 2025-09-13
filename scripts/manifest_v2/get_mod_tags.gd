extends Node

static func get_mod_tags(mod_id: String) -> Dictionary:
	
	var mods = ModLoader.get_children()
	var FolderAccess = preload("res://HevLib/pointers/FolderAccess.gd")
	var ManifestV2 = preload("res://HevLib/pointers/ManifestV2.gd")
	
	var tag_dict = {
				"adds_equipment":[],
				"adds_events":[],
				"adds_gameplay_mechanics":[],
				"adds_ships":[],
				"allow_achievements":false,
				"fun":false,
				"handle_extra_crew":24,
				"is_library_mod":false,
				"library_hidden_by_default":true,
				"overhaul":false,
				"quality_of_life":false,
				"uses_hevlib_research":false,
				"visual":{},
				"language":["en"]
			}
	
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
				var this_mod_id = manifest_data["mod_information"]["id"]
				if this_mod_id == mod_id:
					var manifest_version = manifest_data["manifest_definitions"]["manifest_version"]
					if manifest_version >= 2.1:
						var tag_data = manifest_data["tags"]
						for entry in tag_dict:
							match entry:
								"adds_equipment","adds_events","adds_gameplay_mechanics","adds_ships":
									var k = tag_data.get(entry,[])
									var num = k.size()
									if num >= 1:
										if k in tag_dict:
											pass
										else:
											tag_dict[entry].append(k)
								"handle_extra_crew":
									var k = tag_data.get(entry,24)
									if k > tag_dict[entry]:
										tag_dict[entry] = k
								"language":
									var k = tag_data.get(entry,["en"])
									if k.size() >= 1:
										for lang in k:
											if lang in tag_dict["language"]:
												pass
											else:
												tag_dict["language"].append(lang)
								_:
									var k = tag_data.get(entry,false)
									tag_dict[entry] = k
						return tag_dict
	return {}
