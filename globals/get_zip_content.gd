extends Node

static func get_zip_content(path, stripFolder = false, lowerCase = false):
	Debug.l("HevLib: function 'get_zip_content' instanced at %s. Stripping the root folder? [%s] Outputting lowercase? [%s]" % [path, stripFolder, lowerCase])
	var listOfNames = []
	var gdunzip = load("res://vendor/gdunzip.gd").new()
	gdunzip.load(path)
	var fileList = gdunzip.files
	for m in fileList.keys():
		if stripFolder:
			var delim = m.split("/")[0] + "/"
			var s = m.split(delim)
			m = s[1]
		if lowerCase:
			m = m.to_lower()
		listOfNames.append(m)
	var dFiles = ""
	for m in listOfNames:
		if dFiles == "":
			dFiles = m
		else:
			dFiles = dFiles + ", " + m
	Debug.l("HevLib: get_zip_content returning as %s" % dFiles)
	return listOfNames
