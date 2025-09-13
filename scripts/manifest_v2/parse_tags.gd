extends Node

static func parse_tags(tag_data) -> Dictionary:
	var tag_dict = {}
	for entry in tag_data:
		var type = typeof(tag_data[entry])
		match type:
			TYPE_BOOL:
				match entry:
					"library_hidden_by_default":
						var k = tag_data.get(entry,true)
						if not k:
							tag_dict.merge({entry:k})
					_:
						var k = tag_data.get(entry,false)
						if k:
							tag_dict.merge({entry:k})
			TYPE_ARRAY,TYPE_STRING_ARRAY:
				match entry:
					"language":
						var k = tag_data.get(entry,["en"])
						if k.size() >= 1:
							tag_dict.merge({entry:k})
					_:
						var k = tag_data.get(entry,[])
						if k.size() >= 1:
							tag_dict.merge({entry:k})
			TYPE_INT:
				match entry:
					"handle_extra_crew":
						var k = tag_data.get(entry,24)
						if k > 24:
							tag_dict.merge({entry:k})
					_:
						var k = tag_data.get(entry,0)
						if k > 0:
							tag_dict.merge({entry:k})
	return tag_dict
