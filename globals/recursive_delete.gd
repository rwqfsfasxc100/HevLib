extends Node

static func recursive_delete(path: String) -> bool:
	var dTest = Directory.new()
	if not dTest.open(path) == OK:
		return false
	var Globals = preload("res://HevLib/Functions.gd").new()
	if not path.ends_with("/"):
		path = path + "/"
	var filesForDeletion = []
	var foldersForDeletion = []
	var pms = Globals.__fetch_folder_files(path, true, true)
	for entry in pms:
		if str(entry).ends_with("/"):
			foldersForDeletion.append(entry)
		else:
			filesForDeletion.append(entry)
	for f in filesForDeletion:
		var splitFiles = str(f).split("/")[str(f).split("/").size()-1]
		var dir = Directory.new()
		dir.open(path)
		dir.remove(splitFiles)
	for folder in foldersForDeletion:
		Globals.__recursive_delete(folder)
	var dm = Directory.new()
	dm.open(path)
	dm.remove(path)
	return true
