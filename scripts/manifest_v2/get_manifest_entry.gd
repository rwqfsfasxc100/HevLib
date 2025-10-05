extends Node

static func get_manifest_entry(section: String, entry: String, mod_id: String = ""):
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
	
	var sec = return_data
	
	
	
	var nmode = "all"
	if mod_id != "":
		nmode = "specific"
	match nmode:
		"all":
			var dict = {}
			for mod in sec:
				var id = mod_data[mod]["manifest"]["manifest_data"]["mod_information"]["id"]
				if entry in sec[mod].keys():
					var e = sec[mod][entry]#["value"]
					dict.merge({id:e})
			return dict
		"specific":
			if entry in sec:
				return sec[entry]
	return {}
