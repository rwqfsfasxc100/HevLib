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
		"Compares two sets of versions. If the first one is newer, returns true, otherwise returns false",
		"First three int inputs are the major, minor and bugfix for the first version",
		"Second three int inputs are the major, minor and bugfix for the second version",
	]
}


static func __array_to_string(arr: Array) -> String:
	var f = load("res://HevLib/globals/array_to_string.gd").new()
	var s = f.array_to_string(arr)
	return s

static func __format_for_large_numbers(num: int) -> String:
	var f = load("res://HevLib/globals/format_for_large_numbers.gd")
	var s = f.format_for_large_numbers(num)
	return s

static func __compare_with_byte_array(input_string: String, comparison_string: String) -> bool:
	var f = load("res://HevLib/scripts/compare_with_byte_array.gd")
	var s = f.compare_with_byte_array(input_string, comparison_string)
	return s

static func __rotate_point(point: Vector2, angle: float, degrees:bool = true) -> Vector2:
	var f = load("res://HevLib/scripts/rotate_point.gd")
	var s = f.rotate_point(point, angle, degrees)
	return s

static func __get_vanilla_version(get_from_files: bool = false) -> Array:
	var f = load("res://HevLib/scripts/get_vanilla_version.gd")
	var s = f.get_vanilla_version(get_from_files)
	return s

static func __sift_dictionary(dictionary: Dictionary,search_keys: Array) -> Array:
	var f = load("res://HevLib/scripts/sift_dictionary.gd")
	var s = f.sift_dictionary(dictionary,search_keys)
	return s

static func __convert_arr_to_vec2arr(array: Array) -> PoolVector2Array:
	var f = load("res://HevLib/scripts/convert_arr_to_vec2arr.gd")
	var s = f.convert_arr_to_vec2arr(array)
	return s

static func __compare_versions(primary_major : int,primary_minor : int,primary_bugfix : int, compare_major : int, compare_minor : int, compare_bugfix : int) -> bool:
	var f = load("res://HevLib/scripts/compare_versions.gd")
	var s = f.compare_versions(primary_major ,primary_minor ,primary_bugfix , compare_major , compare_minor , compare_bugfix )
	return s
