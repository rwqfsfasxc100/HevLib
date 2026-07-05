extends Node

var developer_hint = {
	"__get_lib_variables":[
		"Returns HevLib variables",
		"Has to be done on ready, as it relies upon the Autoloads having finished loading",
		"Some variables may take longer to load as they are fetched from the internet"
	],
	"__get_lib_pointers":[
		"Returns HevLib function files as an array.",
		"Using the optional return_as_full_path boolean will return each pointer's path rather than just the filename"
	],
	"__get_pointer_functions":[
		"Returns a dictionary of the pointer's functions",
		"Each key is the function name, with the respective array being notes on how the function is used",
		"Optional 'return_JSON' boolean returns a JSON-formatted string instead of a dictionary"
	],
	"__get_library_functionality":[
		"Returns a dictionary containing info on the entire library",
		" -> Top level of keys are the pointer names",
		" -> Child keys are equivalent to using __get_pointer_functions() on the respective pointers",
		"Optional 'return_JSON' boolean returns a JSON-formatted string instead of a dictionary"
	]
}

static func __get_lib_variables() -> Object:
	return preload("res://HevLib/pointers.gd").new().HevLib.__get_lib_variables()

static func __get_lib_pointers(return_as_full_path: bool = false) -> Array:
	return preload("res://HevLib/pointers.gd").new().HevLib.__get_lib_pointers(return_as_full_path)

static func __get_pointer_functions(pointer: String, return_JSON: bool = false) -> Dictionary:
	return preload("res://HevLib/pointers.gd").new().HevLib.__get_pointer_functions(pointer,return_JSON)


static func __get_library_functionality(return_JSON: bool = false) -> Dictionary:
	return preload("res://HevLib/pointers.gd").new().HevLib.__get_library_functionality(return_JSON)
