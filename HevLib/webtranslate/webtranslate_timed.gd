extends Node

func webtranslate_timed(URL: String, MINUTES_DELAY: int):
	Debug.l("HevLib WebTranslate: function 'webtranslate_timed' initiated, starting constant translation of [%s] with a delay of [%s] minutes" % [URL,MINUTES_DELAY])
	var variableNode = ModLoader.get_tree().get_root().get_node("/root/HevLib~Variables")
	var handleNode = preload("res://HevLib/webtranslate/WebtranslateTimerHandler.tscn").instance()
	handleNode.name = URL + Time.get_time_string_from_system()
	handleNode.URL = URL
	handleNode.MINUTES = MINUTES_DELAY
	variableNode.add_child(handleNode)
