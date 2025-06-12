extends Node

# An example function that can be used to check whether HevLib is installed
# Returns true if the library is loaded, otherwise returns false
static func __hevlib_check_with_version(version_array: Array = [1,0,0]) -> bool:
	var mod = "res://HevLib/ModMain.gd"
	var dir = Directory.new()
	var does = dir.file_exists(mod)
	if does:
		Debug.l("HevLib is installed")
		for item in ModLoader.get_children():
			var script = item.get_script()
			var path = script.get_path()
			if path == mod:
				var con = script.get_script_constant_map()
				var major = con.get("MOD_VERSION_MAJOR",1)
				var minor = con.get("MOD_VERSION_MINOR",1)
				var bugfix = con.get("MOD_VERSION_MBUGFIX",1)
				if version_array[0] > major:
					return false
				if version_array[1] > minor:
					return false
				if version_array[2] > bugfix:
					return false
		return true
	else:
		Debug.l("HevLib is not installed")
		return false
