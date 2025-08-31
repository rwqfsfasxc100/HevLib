extends Node

static func get_mod_by_id(id:String, case_sensitive: bool = true) -> Dictionary:
	var ManifestV2 = preload("res://HevLib/pointers/ManifestV2.gd")
	var data = ManifestV2.__get_mod_data(true)
	var mods = data["mods"]
	for mod in mods:
		var ID = ""
		var moddata = mods.get(mod)
		var manifest = moddata["manifest"]["manifest_data"]
		var keys = manifest.keys()
		if keys.size() > 0:
			if "mod_information" in keys:
				ID = manifest["mod_information"].get("id","")
		var matches = false
		if case_sensitive:
			if id.to_upper() == ID.to_upper():
				matches = true
		else:
			if id == ID:
				matches = true
		if matches:
			return moddata
	return {}
