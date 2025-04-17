extends Node

static func webtranslate(URL: String, fallback: Array = []):
	Debug.l("HevLib WebTranslate: Fetching translations from %s" % URL)
	var HevLib = preload("res://HevLib/webtranslate/FetchGithubData.tscn").instance()
	var pms = Debug.get_node("/root")
	var tstamp = Time.get_datetime_string_from_system()
	var date = str(tstamp.split("T")[0])
	var time = str(tstamp.split("T")[1])
	var tSpl = time.split(":")
	var timeConcat = tSpl[0] + "-" + tSpl[1] + "-" + tSpl[2]
	var timestamp = "~" + date + "~" + timeConcat
	var nodes = pms.get_children()
	var names = []
	for node in nodes:
		var name = node.name
		if name.begins_with("FetchGithubData"):
			names.append(name)
	var nSize = names.size()
	
	
	Debug.l("HevLib WebTranslate: attaching node @ FetchGithubData%s~%s" % [timestamp,str(nSize)])
	HevLib.name = "FetchGithubData" + timestamp + "~" + str(nSize)
	HevLib.URLFullStopReformat = URL
	HevLib.fallbackFiles = fallback
	pms.call_deferred("add_child",HevLib)
	
