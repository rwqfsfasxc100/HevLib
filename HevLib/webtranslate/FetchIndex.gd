extends HTTPRequest

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
		Debug.l("HevLib WebTranslate: index data found: %s" % releasesContent)
		get_parent().index_handler(releasesContent)
	
	
