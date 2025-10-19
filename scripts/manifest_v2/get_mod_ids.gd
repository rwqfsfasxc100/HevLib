extends Node

static func get_mod_ids() -> Array:
	var ManifestV2 = load("res://HevLib/pointers/ManifestV2.gd")
	var mod_data = ManifestV2.__get_mod_data(true)["mods"]
	var returning = []
	for mod in mod_data:
		var data = mod_data[mod]["manifest"]["manifest_data"]
		if "mod_information" in data.keys():
			var minfo = data["mod_information"]["id"]
			returning.append(minfo)
	
	return returning
