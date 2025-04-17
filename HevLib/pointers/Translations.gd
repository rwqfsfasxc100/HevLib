extends Node

var developer_hint = {
	"__updateTL": [
		"Updates translations from a file in CSV format",
		" -> path - path to the file to fetch translations from",
		" -> delim - the delimiter used for the CSV",
		" -> fullLogging - whether to be verbose and state every translation made, or to display only the number of updated translations"
	]
}

static func __updateTL(path:String, delim:String = ",", fullLogging:bool = true):
	var HevLib = load("res://HevLib/pointers/ModInit.gd").new()
	Debug.l("Adding translations from: %s" % path)
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

		if csvLine.size() > 1:
			var translationID := csvLine[0]
			for i in range(1, csvLine.size()):
				translations[i - 1].add_message(translationID, csvLine[i].c_unescape())
			if fullLogging:
				Debug.l("Added translation: %s" % csvLine)
			translationCount += 1

	tlFile.close()

	for translationObject in translations:
		var pms = translationObject.get_message_list()
		var pmL = []
		for m in pms:
			var pt = translationObject.get_message(m)
			pmL.append([m,pt])
		var tr = TranslationServer.translate(pms[0])
		TranslationServer.add_translation(translationObject)
		var pms2 = translationObject.get_message_list()
		var tr2 = TranslationServer.translate(pms[0])
		
		
		
		pass
	Debug.l("%s Translations Updated" % translationCount)
	
