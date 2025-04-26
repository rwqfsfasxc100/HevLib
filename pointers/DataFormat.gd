extends Node

var developer_hint = {
	"__array_to_string":[
		"Concatenates all parts of an array into a string",
		"Returns a string in the form of array[0] + array[1] + ... + array[n] etc."
	],
	"__format_for_large_numbers":[
		"Formats numbers into a human-readable form, separated with a comma"
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
