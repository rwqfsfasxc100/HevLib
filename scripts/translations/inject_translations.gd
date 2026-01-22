extends Node

const DriverManagement = preload("res://HevLib/pointers/DriverManagement.gd")
const Translations = preload("res://HevLib/pointers/Translations.gd")
const ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")

static func inject_translations():
	var p = ProjectSettings.get_setting("locale/translations")
	TranslationServer.clear()
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
	if "file" in data:
		var dv = data["file"].duplicate(true)
		data.erase("file")
		for t in dv:
			var delim = dv[t]
			match typeof(delim):
				TYPE_STRING:
					var dict = Translations.__translation_file_to_dictionary(t,delim)
					for lp in dict:
						if not lp in data:
							data[lp] = {}
						for translation in dict[lp]:
							data[lp].merge({translation:dict[lp][translation]},true)
							pass
					pass
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
						var dict = Translations.__translation_file_to_dictionary(t,string)
						for lp in dict:
							if not lp in data:
								data[lp] = {}
							for translation in dict[lp]:
								data[lp].merge({translation:dict[lp][translation]},true)
	Translations.__updateTL_from_dictionary(data.duplicate(true))
	
	
