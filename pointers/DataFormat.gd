extends Node

var developer_hint = {
	"__array_to_string":[
		"Concatenates all parts of an array into a string",
		"Returns a string in the form of array[0] + array[1] + ... + array[n] etc."
	],
	"__format_for_large_numbers":[
		"Formats numbers into a human-readable form, separated with a comma"
	],
	"__compare_with_byte_array":[
		"Compared two strings bitwise to make a more efficient check",
		"input_string -> the first string to compare",
		"comparison_string -> the second string to compare",
		"returns a boolean whether the scripts match"
	],
	"__rotate_point":[
		"Rotates a Vector2 point around the origin",
		"point -> Vector2 point to be rotated (this is set as angle 0)",
		"angle -> float to set as the desired rotation",
		"degrees -> (optional) whether to have the angle treated as degrees rather than radians. Defaults to true"
	],
	"__sift_dictionary":[
		"Searches for any matches in keys or values within a dictionary",
		"dictionary -> the dictionary to search through",
		"search_keys -> array of keys and values to look for. Can contain any type, will return any match.",
		"Returns an array of the values matched from within the search_keys array"
	],
	"__convert_arr_to_vec2arr":[
		"Returns a PoolVector2Array from an array of integers and floats",
		"array -> Array used as the input integers/floats. Must have an even size and contain only ints or floats"
	],
	"__get_vanilla_version":[
		"Gets the vanilla game version",
		"get_from_files -> (optional) bool deciding whether to get the version from the files. Generally slower than it being disabled, however is the only way to get it before the onready phase. Only works in debug builds due to bytecode compiled data"
	],
	"__compare_versions":[
		"Compares two sets of versions. If the first one is equal to or newer, returns true, otherwise returns false",
		"First three int inputs are the major, minor and bugfix for the first version",
		"Second three int inputs are the major, minor and bugfix for the second version",
	],
	"__sift_ship_config":[
		"Ship config specific equivalent to __sift_dictionary",
		"Allows you to remove specific keys from the top level of the dictionary, useful for getting rid of specific config entries that may sour the data",
		"dictionary -> the dictionary to search through",
		"search_keys -> array of keys and values to look for. Can contain any type, will return any match.",
		"cfgs_to_ignore -> (optional) array used to remove keys from the top level of the dictionary",
		"Returns an array of the values matched from within the search_keys array in config format with the system appended to the end, e.g. weaponSlot.main.type.SYSTEM_EMD14"
	]
}

const ats = preload("res://HevLib/globals/array_to_string.gd")
static func __array_to_string(arr: Array) -> String:
	var s = ats.array_to_string(arr)
	return s
const ffln = preload("res://HevLib/globals/format_for_large_numbers.gd")
static func __format_for_large_numbers(num: int) -> String:
	var s = ffln.format_for_large_numbers(num)
	return s
const cwba = preload("res://HevLib/scripts/compare_with_byte_array.gd")
static func __compare_with_byte_array(input_string: String, comparison_string: String) -> bool:
	var s = cwba.compare_with_byte_array(input_string, comparison_string)
	return s
const rp = preload("res://HevLib/scripts/rotate_point.gd")
static func __rotate_point(point: Vector2, angle: float, degrees:bool = true) -> Vector2:
	var s = rp.rotate_point(point, angle, degrees)
	return s
const gvv = preload("res://HevLib/scripts/get_vanilla_version.gd")
static func __get_vanilla_version(get_from_files: bool = false) -> Array:
	var s = gvv.get_vanilla_version(get_from_files)
	return s
const sd = preload("res://HevLib/scripts/sift_dictionary.gd")
static func __sift_dictionary(dictionary: Dictionary,search_keys: Array) -> Array:
	var s = sd.sift_dictionary(dictionary,search_keys)
	return s
const catv = preload("res://HevLib/scripts/convert_arr_to_vec2arr.gd")
static func __convert_arr_to_vec2arr(array: Array) -> PoolVector2Array:
	var s = catv.convert_arr_to_vec2arr(array)
	return s
const cv = preload("res://HevLib/scripts/compare_versions.gd")
static func __compare_versions(primary_major : int,primary_minor : int,primary_bugfix : int, compare_major : int, compare_minor : int, compare_bugfix : int) -> bool:
	var s = cv.compare_versions(primary_major ,primary_minor ,primary_bugfix , compare_major , compare_minor , compare_bugfix )
	return s
const ssc = preload("res://HevLib/scripts/sift_ship_config.gd")
static func __sift_ship_config(dictionary: Dictionary,search_keys: Array, cfgs_to_ignore:Array) -> Array:
	var s = ssc.sift_ship_config(dictionary,search_keys,cfgs_to_ignore)
	return s
