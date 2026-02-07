extends Node

static func recursive_delete(path: String,Globals = null) -> bool:
	var dTest = Directory.new()
	if not dTest.open(path) == OK:
		return false
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
		recursive_delete(folder,Globals)
	var dm = Directory.new()
	dm.open(path)
	dm.remove(path)
	return true
