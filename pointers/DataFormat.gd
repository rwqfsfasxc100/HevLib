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
