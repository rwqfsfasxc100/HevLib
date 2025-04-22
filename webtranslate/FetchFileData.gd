extends HTTPRequest

var Globals = preload("res://HevLib/Functions.gd").new()

var HevLibCache = "user://cache/.HevLib_Cache"
var cacheExtension = ".hev"

var Translations = preload("res://HevLib/pointers/Translations.gd").new()

func _ready():
	connect("request_completed",self,"_on_request_complete")
	
	
func _on_request_complete(result, response_code, headers, body):
	if not result == 0:
		get_parent().on_timeout()
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
		var utf8 = delim.to_utf8()
		var utfc = ""
		for ut in utf8:
			var chars = utf8.size()
			if utfc == "":
				utfc = str(ut)
			else:
				utfc = utfc + "-~-" + str(ut)
		Globals.__check_folder_exists(HevLibCache + "/WebTranslate/" + nameContent[0])
		var file = File.new()
		var fileName = HevLibCache + "/WebTranslate/" + nameContent[0] + "/" + nameContent[1] + cacheExtension + "--" + utfc
		file.open(fileName,File.WRITE)
		file.store_string(releasesContent)
		file.close()
		
		Translations.__updateTL(fileName,delim)
		
	get_parent().fetchTranslations()


