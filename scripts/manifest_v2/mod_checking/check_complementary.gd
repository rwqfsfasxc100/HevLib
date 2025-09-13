extends Node

static func check_complementary():
	var ManifestV2 = preload("res://HevLib/pointers/ManifestV2.gd")
	var mods = ManifestV2.__get_mod_ids()
	var tags = ManifestV2.__get_manifest_entry("manifest_definitions","complimentary_mod_ids")
	var complimentaries = {}
	for mod in tags:
		var keys = tags[mod]
		if keys.size() >= 1:
			var items = []
			for item in keys:
				if item in mods:
					items.append(item)
			complimentaries.merge({mod:items})
	return complimentaries
	
