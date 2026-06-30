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
	],
	"__copy_file":[
		"Copies (and overrides) a file to a folder, and can account for globalized and Windows paths",
		"file -> string for the path to the file, can be global or local path",
		"folder -> string for the path to the folder, can be global or local path"
	],
	"__get_folder_structure":[
		"Recursive equivalent to __fetch_folder_files",
		"folder -> absolute path to the folder desired. Can be literal, res://, or user://",
		"store_file_content -> (optional) bool to decide whether to store a stringified version of each file's content"
	]
}

const pointers = preload("res://HevLib/pointers.gd")

static func __check_folder_exists(folder: String, status_array: bool = false) -> bool:
	return pointers.new().FolderAccess.__check_folder_exists(folder,status_array)
static func __recursive_delete(path: String):
	return pointers.new().FolderAccess.__recursive_delete(path)
static func __get_first_file(folder: String) -> String:
	return pointers.new().FolderAccess.__get_first_file(folder)
static func __fetch_folder_files(folder: String, showFolders: bool = false, returnFullPath: bool = false,globalizePath: bool = false) -> Array:
	return pointers.new().FolderAccess.__fetch_folder_files(folder,showFolders,returnFullPath,globalizePath)

static func __copy_file(file, folder):
	pointers.new().FileAccess.__copy_file(file,folder)
static func __get_folder_structure(folder,store_file_content = false):
	return pointers.new().FolderAccess.__get_folder_structure(folder,store_file_content)

static func __get_modmain_files() -> Array:
	return pointers.new().ManifestV2.__get_modmain_files()
