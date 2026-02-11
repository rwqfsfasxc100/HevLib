extends Node

var developer_hint = {
	"__get_drivers":[
		"Fetches driver information and collects it based on mod",
		"Returns an array, ordered by mod & priority",
		"get_ids -> (optional) an array of strings containing specific mod ids to return. If left blank, lists all mods regardless of manifest existence or not. Defaults to []"
	],
	"__compare_driver_dictionaries":[
		"Sorting algorithm used to determine order priority of drivers",
		"Equivalent to sorting algorithm used in ModLoader.gd"
	]
}

const FolderAccess = preload("res://HevLib/pointers/FolderAccess.gd")
const FileAccess = preload("res://HevLib/pointers/FileAccess.gd")
const MV2 = preload("res://HevLib/pointers/ManifestV2.gd")
const DataFormat = preload("res://HevLib/pointers/DataFormat.gd")

const gd = preload("res://HevLib/scripts/driver_management/get_drivers.gd")
static func __get_drivers(get_ids : Array = []) -> Array:
	var s = gd.get_drivers(get_ids,FolderAccess,FileAccess,MV2,DataFormat)
	return s

const cdd = preload("res://HevLib/scripts/driver_management/compare_driver_dictionaries.gd")
static func __compare_driver_dictionaries(a,b) -> bool:
	return cdd.compare_driver_dictionaries(a,b)
