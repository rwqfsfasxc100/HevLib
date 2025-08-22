extends Node

static func load_configs(cfg_filename : String = "Mod_Configurations" + ".cfg"):
	var ManifestV2 = preload("res://HevLib/pointers/ManifestV2.gd")
	var data = ManifestV2.__get_mod_data()
	var mod_entries = data["mods"]
	var configs = {}
	for mod in mod_entries:
		var manifest = mod_entries[mod]["manifest"]
		var has_manifest = manifest["has_manifest"]
		if has_manifest:
			var mod_name = mod_entries[mod]["name"]
			var manifest_version = manifest["manifest_version"]
			if manifest_version >= 2.1:
				var cfg = manifest["manifest_data"]["configs"]
				if not cfg.hash() == {}.hash():
					configs.merge({mod_name:cfg})
	
	breakpoint
	
