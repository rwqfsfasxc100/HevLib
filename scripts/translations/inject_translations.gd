extends Node

static func inject_translations(translation_data: Dictionary, iterations: int = 100000):
	var Translations = preload("res://HevLib/pointers/Translations.gd")
	var objects = Translations.__fetch_all_translation_objects(iterations)
	var disengaged_translations = [] # check to see if modifying the original object and reinjecting it works
	for tsl in objects:
		var count = tsl.get_message_count()
		var locale = tsl.get_locale()
		if not locale in translation_data.keys():
			continue
		var messages = tsl.get_message_list()
		var translations = []
		for item in messages:
			translations.append(tsl.get_message(item))
		var wanted = translation_data[locale]
		var desired_keys = wanted.keys()
		for key in desired_keys:
			if key in messages and not tsl in disengaged_translations:
				disengaged_translations.append(tsl)
				TranslationServer.remove_translation(tsl)
				var dict = {locale:{key:wanted.get(key)}}
				
				
				var message = dict[locale].get(key)
				tsl.erase_message(key)
				tsl.add_message(key,message)
				TranslationServer.add_translation(tsl)
				
				
#				var did = TranslationServer.translate(key)
#
#
#				Translations.__updateTL_drom_dictionary(dict)
#
#
#
#
#	for item in disengaged_translations:
#		var V2 := Translation.new()
#		var D = item.get_message_list()
#		for key in D:
#			var msg = item.get_message(key)
#			V2.add_message(key,msg)
#		TranslationServer.add_translation(V2)
#	pass
