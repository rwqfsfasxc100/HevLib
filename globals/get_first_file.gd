extends Node

static func get_first_file(folder):
	Debug.l("HevLib: function 'get_first_file' instanced looking for the first file from %s" % folder)
	var firstFile
	var Globals = preload("res://HevLib/Functions.gd").new()
	var fileNo = 0
	var fileList = Globals.__fetch_folder_files(folder)
	for file in fileList:
		if fileNo == 0:
			firstFile = file
			fileNo = 1
	Debug.l("HevLib: get_first_file returning as %s" % firstFile)
	if firstFile == null:
		return false
	else:
		return firstFile
