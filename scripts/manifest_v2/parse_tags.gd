extends Node

static func parse_tags(tag_data) -> Dictionary:
	var tag_dict = {}
	for entry in tag_data:
		var type = typeof(tag_data[entry])
		if type != TYPE_DICTIONARY:
			return tag_dict
		var tag_type = tag_data[entry].get("type","NULL_TYPE")
		tag_type = tag_type.to_lower()
		match tag_type:
			"boolean","bool":
				var val = bool(tag_data[entry].get("value"))
				tag_dict.merge({entry:val})
			"string","str":
				var val = str(tag_data[entry].get("value"))
				tag_dict.merge({entry:val})
			"integer","int":
				var val = int(tag_data[entry].get("value"))
				tag_dict.merge({entry:val})
			"array","arr":
				var val = Array(tag_data[entry].get("value"))
				tag_dict.merge({entry:val})
			_:
				var val = tag_data[entry].get("value")
				tag_dict.merge({entry:val})
	return tag_dict
