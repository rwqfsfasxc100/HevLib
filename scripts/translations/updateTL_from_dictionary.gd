extends Node

static func updateTL_from_dictionary(path:Dictionary, delim:String = ",", fullLogging:bool = true):
	
	Debug.l("Adding translations from dictionary")
	var translations := []
	var translationCount = 0
	if fullLogging:
		Debug.l("Adding translations as: %s" % str(path.hash()))
	for lang in path.keys():
		var translationObject := Translation.new()
		translationObject.locale = lang
		var translation_dict = path.get(lang)
		var tKeys = translation_dict.keys()
		for key in tKeys:
			var data = translation_dict.get(key)
			translationObject.add_message(key,data.c_unescape())
			if fullLogging:
				Debug.l("Added translation: %s" % key)
		translationCount += 1
		
		translations.append(translationObject)
	for translationObject in translations:
		TranslationServer.add_translation(translationObject)
	Debug.l("%s Translations Updated" % [translationCount])
