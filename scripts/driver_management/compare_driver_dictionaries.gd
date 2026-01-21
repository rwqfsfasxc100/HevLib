extends Node

static func compare_driver_dictionaries(a, b):
	var aPrio = a.get("priority",0)
	var bPrio = b.get("priority",0)
	if aPrio != bPrio:
		return aPrio < bPrio

	
	var aPath = a.get("mod_directory")
	var bPath = b.get("mod_directory")
	if aPath != bPath:
		return aPath < bPath

	return false
