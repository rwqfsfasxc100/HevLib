extends Node

static func get_mods_from_tag(tag_name: String) -> Array:
	var ManifestV2 = preload("res://HevLib/pointers/ManifestV2.gd")
	var alldata = ManifestV2.__get_tags()
	var data = alldata.get(tag_name,{})
	var keys = data.keys()
	if keys.size() >=1:
		return keys
	return []
