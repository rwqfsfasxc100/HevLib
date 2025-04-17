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
	var ver = "unknown"
	if not json == null:
		releasesContent = json
	if releasesContent:
		for line in releasesContent.split("\n"):
			if line.begins_with("const MOD_VERSION = "):
				ver = line.split("\"")[1]
				
		
		get_parent().compared_version = ver
		get_parent().handleVersionCheck()
