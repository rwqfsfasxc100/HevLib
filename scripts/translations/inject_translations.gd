extends Node

static func inject_translations(translation_data: Dictionary, iterations: int = 100000):
	var Translations = preload("res://HevLib/pointers/Translations.gd")
	var objects = Translations.__fetch_all_translation_objects(iterations)
	for tsl in objects:
		var count = tsl.get_message_count()
		var locale = tsl.get_locale()
		if not locale in translation_data.keys():
			continue
		var messages = tsl.get_message_list()
		var translations = []
		for item in messages:
			translations.append(tsl.get_message(item))
		pass
	
	pass
