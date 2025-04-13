extends Node

static func fetch_folder_files(folder, showFolders, returnFullPath):
	Debug.l("HevLib: function 'fetch_folder_files' instanced in %s, with folders included? [%s]" % [folder, showFolders])
	var fileList = []
	var dir = Directory.new()
	dir.open(folder)
	var dirName = dir.get_current_dir()
	dir.list_dir_begin(true)
	while true:
		var fileName = dir.get_next()
		var capture = true
		if fileName.ends_with("/"):
			capture = false
		if fileName == "." or fileName == "..":
			capture = false
		if capture:
			dirName = dir.get_current_dir()
			Debug.l(fileName)
			if fileName == "":
				break
			if dir.current_is_dir() and not showFolders:
				continue
			elif dir.current_is_dir() and showFolders:
				fileName = fileName + "/"
			if returnFullPath:
				fileName = folder + fileName
			fileList.append(fileName)
	
	
	
#	m = m.split(m.split("/")[0] + "/")[1].to_lower()
	var dFiles = ""
	for m in fileList:
		if dFiles == "":
			dFiles = m
		else:
			dFiles = dFiles + ", " + m
	Debug.l("HevLib: fetch_folder_files returning as %s" % dFiles)
	return fileList
