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

const Globals = preload("res://HevLib/Functions.gd")

const cfe = preload("res://HevLib/globals/check_folder_exists.gd")
static func __check_folder_exists(folder: String, status_array: bool = false) -> bool:
	var s = cfe.check_folder_exists(folder, status_array)
	return s
const rd = preload("res://HevLib/globals/recursive_delete.gd")
static func __recursive_delete(path: String):
	Debug.l("HevLib: function 'recursive_delete' started on @%s" % path)
	var s = rd.recursive_delete(path,Globals.new())
	return s
const gff = preload("res://HevLib/globals/get_first_file.gd")
static func __get_first_file(folder: String) -> String:
	var s = gff.get_first_file(folder,Globals.new())
	return s
const fff = preload("res://HevLib/globals/fetch_folder_files.gd")
static func __fetch_folder_files(folder: String, showFolders: bool = false, returnFullPath: bool = false,globalizePath: bool = false) -> Array:
	var s = fff.fetch_folder_files(folder, showFolders, returnFullPath,globalizePath)
	return s

static func __copy_file(file, folder):
	var prepfile = ProjectSettings.localize_path(file)
#	var current_mods = FolderAccess.__fetch_folder_files(folder)
	var fn = prepfile.split("/")[prepfile.split("/").size() - 1]
	
	var dir = Directory.new()
	dir.copy(prepfile,folder + "/" + fn)
const gfs = preload("res://HevLib/scripts/get_folder_structure.gd")
static func __get_folder_structure(folder,store_file_content = false):
#	var s = gfs.get_folder_structure(folder,store_file_content,FolderAccess)
#	return s
	var file = File.new()
	var folder_structure = {}
	var files = __fetch_folder_files(folder,true,false)
	for object in files:
		if object.ends_with("/"):
			var data = __get_folder_structure(folder+object,store_file_content)
			folder_structure.merge({object:data})
		else:
			var fd = "FILE"
			if store_file_content:
				file.open(folder + object,File.READ)
				fd = file.get_as_text(true)
				file.close()
			folder_structure.merge({object:fd})
	return folder_structure

static func __get_modmain_files() -> Array:
	var structure = __get_folder_structure("res://")
	var dvs = siftFolderStructure(structure)
	return dvs


static func siftFolderStructure(structure:Dictionary,path:String = "res://"):
	var out = []
	for i in structure:
		if i.ends_with("/"):
			out.append_array(siftFolderStructure(structure[i],path + i))
		else:
			var f = i.to_lower()
			if f.begins_with("modmain") and f.ends_with(".gd"):
				out.append(path + i)
	return out

