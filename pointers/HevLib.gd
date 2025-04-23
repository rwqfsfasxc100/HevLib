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
	var f = load("res://HevLib/globals/get_lib_variables.gd").new()
	var s = f.get_lib_variables()
	return s

static func __get_lib_pointers(return_as_full_path: bool = false) -> Array:
	var Globals = preload("res://HevLib/Functions.gd").new()
	var path = "res://HevLib/pointers/"
	var files = Globals.__fetch_folder_files(path)
	if return_as_full_path:
		var compileArray = []
		for f in files:
			compileArray.append(path + f)
		return compileArray
	else:
		return files

static func __get_pointer_functions(pointer: String, return_JSON: bool = false) -> Dictionary:
	var path = "res://HevLib/pointers/"
	var pSplit = pointer.split("/")
	var actualPointer = path + pSplit[pSplit.size() - 1]
	var pointerLoad = load(actualPointer).new()
	var pFuncs = pointerLoad.get_method_list()
	var methods = {}
	for pFunc in pFuncs:
		var pFuncName = pFunc.name
		if pFuncName.begins_with("__"):
			var data = pointerLoad.get_property_list()
			var devHint = {}
			for item in data:
				if item.get("name") == "developer_hint":
					devHint = pointerLoad.developer_hint
			var desc = devHint.get(pFuncName, [TranslationServer.translate("HEVLIB_MISSING_DOCUMENTATION_1"),TranslationServer.translate("HEVLIB_MISSING_DOCUMENTATION_2")])
			methods.merge({pFuncName:desc})
	var psj = JSON.print(methods, "\t")
	if return_JSON:
		return psj
	else:
		return methods


static func __get_library_functionality(return_JSON: bool = false) -> Dictionary:
	var Globals = preload("res://HevLib/Functions.gd").new()
	var path = "res://HevLib/pointers/"
	var functions = {}
	var files = Globals.__fetch_folder_files(path)
	for pointer in files:
		var pSplit = pointer.split("/")
		var actualPointer = path + pSplit[pSplit.size() - 1]
		var pointerLoad = load(actualPointer).new()
		var pFuncs = pointerLoad.get_method_list()
		var methods = {}
		for pFunc in pFuncs:
			var pFuncName = pFunc.name
			if pFuncName.begins_with("__"):
				var data = pointerLoad.get_property_list()
				var devHint = {}
				for item in data:
					if item.get("name") == "developer_hint":
						devHint = pointerLoad.developer_hint
				var desc = devHint.get(pFuncName, [TranslationServer.translate("HEVLIB_MISSING_DOCUMENTATION_1"),TranslationServer.translate("HEVLIB_MISSING_DOCUMENTATION_2")])
				methods.merge({pFuncName:desc})
		var concat = {pointer:methods}
		functions.merge(concat)
	var psj = JSON.print(functions, "\t")
	if return_JSON:
		return psj
	else:
		return functions
