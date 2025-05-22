extends Node

var developer_hint = {
	"__check_folder_exists":[
		"Ensures the supplied folder exists",
		"If folder exists, returns true",
		"Otherwise, attempts to create it. If it succeeds, returns true, else returns false"
	],
	"__recursive_delete":[
		"Recursively deletes the provided folder",
		"Returns false if the folder doesn't load"
	],
	"__get_first_file":[
		"Supplies the first file in a folder",
		"If no files exists, returns false"
	],
	"__fetch_folder_files":[
		"Returns the file contents of a folder",
		" -> folder - path to the folder to check the contents of",
		" -> showFolders - whether to add folders into the array of files. each folder will end with a slash to identify",
		" -> returnFullPath - whether to return the full paths of the files and folders, rather the names"
	]
}

static func __check_folder_exists(folder: String, status_array: bool = false) -> bool:
	var f = load("res://HevLib/globals/check_folder_exists.gd")
	var s = f.check_folder_exists(folder, status_array)
	return s

static func __recursive_delete(path: String):
	Debug.l("HevLib: function 'recursive_delete' started on @%s" % path)
	var f = load("res://HevLib/globals/recursive_delete.gd")
	var s = f.recursive_delete(path)
	return s

static func __get_first_file(folder: String) -> String:
	var f = load("res://HevLib/globals/get_first_file.gd")
	var s = f.get_first_file(folder)
	return s

static func __fetch_folder_files(folder: String, showFolders: bool = false, returnFullPath: bool = false) -> Array:
	var f = load("res://HevLib/globals/fetch_folder_files.gd")
	var s = f.fetch_folder_files(folder, showFolders, returnFullPath)
	return s
