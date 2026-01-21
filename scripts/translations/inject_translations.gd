extends Node

const DriverManagement = preload("res://HevLib/pointers/DriverManagement.gd")
const Translations = preload("res://HevLib/pointers/Translations.gd")

static func inject_translations():
	var data = translate()
	var p = ProjectSettings.get_setting("locale/translations")
	TranslationServer.clear()
	Translations.__updateTL_from_dictionary(data)
	var v = 0
	while v < 10000:
		v += 1
	for i in p:
		TranslationServer.add_translation(ResourceLoader.load(i,"",true))

static func translate():
	var drivers = DriverManagement.__get_drivers()
	var data = {}
	for mod in drivers:
		if "REPLACE_TRANSLATIONS.gd" in mod["drivers"]:
			var translations = mod["drivers"]["REPLACE_TRANSLATIONS.gd"].get("TRANSLATIONS",{})
			for language in translations:
				var lang = translations[language]
				if not language in data:
					data.merge({language:{}})
				for t in lang:
					var v = lang[t]
					data[language][t] = v
	return data
