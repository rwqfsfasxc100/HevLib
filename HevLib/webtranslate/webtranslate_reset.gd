extends Node

static func webtranslate_reset(URL):
	var Globals = preload("res://HevLib/Functions.gd").new()
	var urlSplit = str(URL).split("github.com/")[1]
	var dataSplit = urlSplit.split("/")
	var user = dataSplit[0]
	var repo = dataSplit[1]
	var folderConcat = user + "~_~" + repo
	var folderToDelete = "user://cache/.HevLib_Cache/WebTranslate/" + folderConcat
	Debug.l("HevLib WebTranslate: deleting cache folder @ %s" % folderToDelete)
	var did = Globals.__recursive_delete(folderToDelete)
	if did:
		return true
	else:
		return false
