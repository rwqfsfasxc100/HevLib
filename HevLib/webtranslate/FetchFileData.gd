extends HTTPRequest

var path = ""
var modPath = ""

var Globals = preload("res://HevLib/Functions.gd").new()

var HevLibCache = "user://cache/.HevLib_Cache"
var cacheExtension = ".hev"

func _ready():
	connect("request_completed",self,"_on_request_complete")
	
	
func _on_request_complete(result, response_code, headers, body):
	var json = body.get_string_from_utf8()
	var releasesContent
	var data
	if not json == null:
		releasesContent = json
	if releasesContent:
		var cFile = str(get_parent().currentFile)
		var CContent = str(cFile.split("https://raw.githubusercontent.com/")[1])
		var nameContent = CContent.split("/refs/heads/")
		var indexData = str(get_parent().indexData)
		var delim = ""
		var index = str(indexData.split("\n")[0])
		if index.begins_with("delimiter:"):
			delim = index.split("delimiter:")[1]
		else:
			delim = "|"
		var psmp = []
		for p in nameContent:
			var als = str(p).split("/")
			var pindex = 0
			var concatStr = ""
			while pindex <= als.size() - 1:
				if pindex == 0:
					concatStr = als[pindex]
				else:
					concatStr = concatStr + "~_~" + als[pindex]
				pindex += 1
			if concatStr != "":
				psmp.append(concatStr)
		if psmp != []:
			nameContent = psmp
		Globals.__check_folder_exists(HevLibCache + "/WebTranslate/" + nameContent[0])
		var file = File.new()
		var fileName = HevLibCache + "/WebTranslate/" + nameContent[0] + "/" + nameContent[1] + cacheExtension + "--" + str(delim.to_utf8())
		file.open(fileName,File.WRITE)
		file.store_string(releasesContent)
		file.close()
		
		updateTL(fileName,delim)
		
	get_parent().fetchTranslations()



func updateTL(path:String, delim:String = ","):
	path = str(modPath + path)
	Debug.l("Adding translations from: %s" % path)
	var tlFile:File = File.new()
	tlFile.open(path, File.READ)

	var translations := []

	var csvLine := tlFile.get_line().split(delim)
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
			Debug.l("Added translation: %s" % csvLine)

	tlFile.close()

	for translationObject in translations:
		TranslationServer.add_translation(translationObject)

	Debug.l("Translations Updated")
