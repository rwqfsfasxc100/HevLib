extends Node

static func fetch_file_from_zip(path, cacheDir, desiredFiles):
	var dFiles = ""
	for m in desiredFiles:
		if dFiles == "":
			dFiles = m
		else:
			dFiles = dFiles + ", " + m
	Debug.l("HevLib: function 'fetch_file_from_zip' instanced for %s in %s, looking for %s" % [path,cacheDir,dFiles])
	var listOfNames = []
	var uncompressed = {}
	var zip = path.split("/")
	var splitSize = zip.size()
	var zipName = zip[splitSize - 1]
	var gdunzip = load("res://vendor/gdunzip.gd").new()
	gdunzip.load(path)
	var fileList = gdunzip.files
	for m in fileList.keys():
		listOfNames.append(m)
	for f in listOfNames:
		var string = cacheDir + f
		if string.ends_with("/"):
			var dir = Directory.new()
			dir.make_dir_recursive(string)
	var modFolder = listOfNames[0]
	var savedFiles = []
	for d in desiredFiles:
		for F in listOfNames:
			var M = str(F).split(str(F).split("/")[0] + "/")[1]
			if str(M).to_lower() == str(d).to_lower():
				var fileToFetch = modFolder + d
				var saveDir = cacheDir + fileToFetch
				var data = gdunzip.uncompress(F).get_string_from_utf8()
				if data:
					var file = File.new()
					file.open(saveDir, File.WRITE)
					file.store_string(data)
					file.close()
					savedFiles.append(saveDir)
				else:
					savedFiles.append("")
	var mFiles = ""
	for m in savedFiles:
		if mFiles == "":
			mFiles = m
		else:
			mFiles = mFiles + ", " + m
	Debug.l("HevLib: fetch_file_from_zip returning as %s" % mFiles)
	return savedFiles
	
