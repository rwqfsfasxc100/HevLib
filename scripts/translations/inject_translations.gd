extends Node

#const DriverManagement = preload("res://HevLib/pointers/DriverManagement.gd")
#const Translations = preload("res://HevLib/pointers/Translations.gd")
#const ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")

static func inject_translations(pointers):
	var file = File.new()
	var p = ProjectSettings.get_setting("locale/translations")
	TranslationServer.clear()
	var drivers = pointers.DriverManagement.__get_drivers()
	var data = {}
	var ml_check_data = {}
	for mod in drivers:
		if "REPLACE_TRANSLATIONS.gd" in mod["drivers"]:
			var translations = mod["drivers"]["REPLACE_TRANSLATIONS.gd"].get("TRANSLATIONS",{})
			var master_locale = null
			if "master_locale" in translations:
				master_locale = translations["master_locale"]
				translations.erase("master_locale")
			for language in translations:
				var check_ml = false
				var lang = translations[language]
				var mlt = null
				if not language in data:
					data.merge({language:{}})
				if master_locale and language != master_locale:
					ml_check_data[language] = {"needs_updating":[],"needs_updating_size":0,"not_in_master":[],"not_in_master_size":0,"missing_translations":[],"missing_translations_size":0}
					check_ml = true
					mlt = translations[master_locale]
					if lang.size() < mlt.size():
						for tv in mlt:
							if not tv in lang:
								ml_check_data[language]["missing_translations"].append(tv)
								ml_check_data[language]["missing_translations_size"] += 1
				for t in lang:
					var v = lang[t]
					if check_ml and "version_hash" in v:
						if t in mlt:
							var c = mlt[t]
							if typeof(c) == TYPE_DICTIONARY and "string" in c:
								if hash(c.string) != v.version_hash:
									ml_check_data[language]["needs_updating"].append(t)
									ml_check_data[language]["needs_updating_size"] += 1
						else:
							ml_check_data[language]["not_in_master"].append(t)
							ml_check_data[language]["not_in_master_size"] += 1
					data[language][t] = v
	if "file" in data:
		var dv = data["file"].duplicate(true)
		data.erase("file")
		for t in dv:
			var delim = dv[t]
			match typeof(delim):
				TYPE_STRING:
					var dict = pointers.Translations.__translation_file_to_dictionary(t,delim)
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
					var val = pointers.ConfigDriver.__get_value(mod,section,setting)
					var do = true
					if typeof(val) == TYPE_BOOL:
						do = val
					if invert:
						do = !do
					if do and string != "":
						var dict = pointers.Translations.__translation_file_to_dictionary(t,string)
						for lp in dict:
							if not lp in data:
								data[lp] = {}
							for translation in dict[lp]:
								data[lp].merge({translation:dict[lp][translation]},true)
	var date = Time.get_date_dict_from_system()
	if date.month == 4 and date.day == 1:
		data["en"].merge({"H2O": "C2H6O"},true)
	
	file.open("user://cache/.HevLib_Cache/translation_check_data.json",File.WRITE)
	file.store_string(JSON.print(ml_check_data,"\t"))
	file.close()
	pointers.Translations.__updateTL_from_dictionary(data.duplicate(true))
	
	
