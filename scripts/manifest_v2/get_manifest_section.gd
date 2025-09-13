extends Node

static func get_manifest_section(section: String, mod_id: String = "") -> Dictionary:
	var ManifestV2 = preload("res://HevLib/pointers/ManifestV2.gd")
	var mod_data = ManifestV2.__get_mod_data(true)["mods"]
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
				if mod_id in ManifestV2.__get_mod_ids():
					var manifest = mod_data[mod]["manifest"]["manifest_data"]
					if "mod_information" in manifest.keys():
						if mod_id in manifest["mod_information"]["id"]:
							if section in manifest.keys():
								return_data = manifest[section]
	
	return return_data
