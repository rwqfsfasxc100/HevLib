extends Node

var developer_hint = {
	"__updateTL": [
		"Updates translations from a file in CSV format",
		" -> path - path to the file to fetch translations from",
		" -> delim - (optional) string, the delimiter used for the CSV. Defaults to \",\"",
		" -> fullLogging - (optional) whether to be verbose and state every translation made, or to display only the number of updated translations. Defaults to true"
	],
	"__updateTL_drom_dictionary":[
		"Updates translations from a dictionary formatted as a translationDictionary.",
		"Use __translation_file_to_dictionary() to convert conventional CSV translation files to dictionary to provide info on how the formatting is done",
		"dictionary -> the dictionary where translations will be sourced",
		"fullLogging -> (optional) whether to use more verbose logging. Defaults to true"
	],
	"__fetch_all_translation_objects":[
		"Returns an array of all translation objects within the selected PID range",
		"number_of_objects_to_iterate_through -> (optional) integer for the maximum number of PIDs to iterate through. Defaults to 100000"
	],
	"__inject_translations":[
		"Attempts to override loaded translations with a translation dictionary",
		"translation_data -> dictionary containing the translation data, formatted to translation dictionary standards",
		"number_of_objects_to_iterate_through -> (optional) integer for the maximum number of PIDs to iterate through for overriding. Defaults to 100000"
	],
	"__translation_file_to_dictionary":[
		"Converts a CSV formatted translation file to a translation dictionary",
		"path -> string to the translation file's location",
		"delimiter -> (optional) string containing the character to split the CSV line by. Defaults to '|"
	]
}

static func __updateTL(path:String, delim:String = ",", fullLogging:bool = true):
	var f = load("res://HevLib/scripts/translations/updateTL.gd")
	f.updateTL(path, delim, fullLogging)

static func __updateTL_drom_dictionary(dictionary:Dictionary, fullLogging:bool = true):
	var f = load("res://HevLib/scripts/translations/updateTL_from_dictionary.gd")
	f.updateTL_from_dictionary(dictionary, fullLogging)

static func __fetch_all_translation_objects(number_of_objects_to_iterate_through: int = 100000) -> Array:
	var f = load("res://HevLib/scripts/translations/fetch_all_translation_objects.gd")
	var s = f.fetch_all_translation_objects(number_of_objects_to_iterate_through)
	return s

static func __inject_translations(translation_data: Dictionary,number_of_objects_to_iterate_through: int = 100000) -> Array:
	var f = load("res://HevLib/scripts/translations/inject_translations.gd")
	var s = f.inject_translations(translation_data,number_of_objects_to_iterate_through)
	return s

static func __translation_file_to_dictionary(path: String, delimiter : String = "|") -> Dictionary:
	var f = load("res://HevLib/scripts/translations/translation_file_to_dictionary.gd")
	var s = f.translation_file_to_dictionary(path,delimiter)
	return s
