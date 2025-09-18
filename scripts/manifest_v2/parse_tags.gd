extends Node

static func parse_tags(tag_data) -> Dictionary:
	var tag_dict = {}
	for entry in tag_data:
		var type = typeof(tag_data[entry])
		if type != TYPE_DICTIONARY:
			return tag_dict
		var tag_type = tag_data[entry].get("type")
		match tag_type:
			"boolean","bool":
				var val = tag_data[entry].get("value")
				tag_dict.merge({entry:val})
	return tag_dict
