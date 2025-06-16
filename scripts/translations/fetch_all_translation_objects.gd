extends Node

static func fetch_all_translation_objects(index) -> Array:
	var translations = []
	while index >= 1:
		var obj = instance_from_id(index)
		index -= 1
		if obj == null:
			continue
		var data = obj.get_class()
		if not data == "Translation":
			continue
		translations.append(obj)
	return translations
