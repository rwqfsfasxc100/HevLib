extends Node

# An example function that can be used to check whether HevLib is installed
# Returns true if the library is loaded, otherwise returns false
static func __hevlib_check() -> bool:
	var mod = "res://HevLib/ModMain.gd"
	var dir = Directory.new()
	var does = dir.file_exists(mod)
	if does:
		Debug.l("HevLib is installed")
		return true
	else:
		Debug.l("HevLib is not installed")
		return false
