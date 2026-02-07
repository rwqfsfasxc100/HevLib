extends Node

static func updateTL_from_dictionary(path:Dictionary, fullLogging:bool = true,ConfigDriver = null):
	var Translations = load("res://HevLib/pointers/Translations.gd")
	Debug.l("Adding translations from dictionary")
	var translations := []
	var translationCount = 0
	if fullLogging:
		Debug.l("Adding translations as: %s" % str(path.hash()))
	if "file" in path.keys():
		var file_paths = path["file"]
		for file in file_paths:
			var delim = file_paths[file]
			match typeof(delim):
				TYPE_STRING:
					var dict = Translations.__translation_file_to_dictionary(file,delim)
					Translations.__updateTL_from_dictionary(dict,fullLogging)
				TYPE_DICTIONARY:
					var string = delim.get("string","")
					var mod = delim.get("mod","")
					var section = delim.get("section","")
					var setting = delim.get("setting","")
					var invert = delim.get("invert",false)
					var val = ConfigDriver.__get_value(mod,section,setting)
					var do = true
					if typeof(val) == TYPE_BOOL:
						do = val
					if invert:
						do = !do
					if do and string != "":
						var dict = Translations.__translation_file_to_dictionary(file,string)
						Translations.__updateTL_from_dictionary(dict,fullLogging)
					
		path.erase("file")
	for lang in path.keys():
		var translationObject := Translation.new()
		translationObject.locale = lang
		var translation_dict = path.get(lang)
		var tKeys = translation_dict.keys()
		for key in tKeys:
			var data = translation_dict.get(key)
			match typeof(data):
				TYPE_STRING:
					translationObject.add_message(key,data.c_unescape())
					if fullLogging:
						Debug.l("Added translation: %s" % key)
				TYPE_DICTIONARY:
					var string = data.get("string","")
					var mod = data.get("mod","")
					var section = data.get("section","")
					var setting = data.get("setting","")
					var invert = data.get("invert",false)
					var val = ConfigDriver.__get_value(mod,section,setting)
					var do = true
					if typeof(val) == TYPE_BOOL:
						do = val
					if invert:
						do = !do
					if do and string != "":
						translationObject.add_message(key,string.c_unescape())
					if fullLogging:
						Debug.l("Added translation: %s" % key)
					pass
		translationCount += 1
		
		translations.append(translationObject)
	for translationObject in translations:
		TranslationServer.add_translation(translationObject)
	Debug.l("%s Translations Updated" % [translationCount])
