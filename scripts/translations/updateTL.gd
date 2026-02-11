extends Node

static func updateTL(path:String, delim:String = ",", fullLogging:bool = true):
	var fileName = path.split("/")[path.split("/").size() - 1]
	var folderName = path.split(fileName)[0]
	Debug.l("Adding translations from [%s] in [%s]" % [fileName, folderName])
	var tlFile:File = File.new()
	tlFile.open(path, File.READ)
	var translations := []
	var translationCount = 0
	var csvLine := tlFile.get_line().split(delim)
	if fullLogging:
		Debug.l("Adding translations as: %s" % csvLine)
	for i in range(1, csvLine.size()):
		var translationObject := Translation.new()
		translationObject.locale = csvLine[i]
		translations.append(translationObject)
	while not tlFile.eof_reached():
		csvLine = tlFile.get_csv_line(delim)
		var size = csvLine.size()
		if size > 1:
			if size > 2:
				var i = 0
				while i < size:
					if csvLine[i].ends_with("\\") and i < size:
						csvLine[i] = csvLine[i].rstrip("\\") + delim + csvLine[i + 1]
						csvLine.remove(i + 1)
						size -= 1
					i += 1
			var translationID := csvLine[0]
			for i in range(1, size):
				translations[i - 1].add_message(translationID, csvLine[i].c_unescape())
			if fullLogging:
				Debug.l("Added translation: %s" % csvLine)
			translationCount += 1
	tlFile.close()
	for translationObject in translations:
		TranslationServer.add_translation(translationObject)
	Debug.l("%s Translations Updated from @ [%s]" % [translationCount, fileName])
