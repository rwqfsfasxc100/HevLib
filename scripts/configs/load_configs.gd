extends Node

static func load_configs():
	var ManifestV2 = preload("res://HevLib/pointers/ManifestV2.gd")
	var data = ManifestV2.__get_mod_data()
	var mod_entries = data["mods"]
	for mod in mod_entries:
		var has_manifest = mod_entries[mod]["manifest"]["has_manifest"]
		if has_manifest:
			var manifest_version = mod_entries[mod]["manifest"]["manifest_version"]
			breakpoint
	
	breakpoint
	
