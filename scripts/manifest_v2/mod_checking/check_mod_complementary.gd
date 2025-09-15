extends Node

static func check_mod_complementary(mod_id):
	var ManifestV2 = preload("res://HevLib/pointers/ManifestV2.gd")
	var mods = ManifestV2.__get_mod_ids()
	var tags = ManifestV2.__get_manifest_entry("manifest_definitions","complementary_mod_ids",mod_id)
	var complimentaries = []
	for mod in tags:
		if mod in mods:
			complimentaries.append(mod)
	return complimentaries
