extends Node

static func sift_dictionary(dictionary, string_array):
	var DataFormat = preload("res://HevLib/pointers/DataFormat.gd")
	var returning_keys = []
	for key in dictionary:
		if key in string_array:
			returning_keys.append(key)
		var kdata = dictionary[key]
		if kdata in string_array:
			returning_keys.append(kdata)
		if typeof(kdata) == TYPE_DICTIONARY:
			returning_keys.append_array(DataFormat.__sift_dictionary(kdata,string_array))
	return returning_keys
