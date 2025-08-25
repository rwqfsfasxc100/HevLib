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

static func __translation_file_to_dictionary(path: String) -> Dictionary:
	var f = load("res://HevLib/scripts/translations/translation_file_to_dictionary.gd")
	var s = f.inject_translations(path)
	return s
