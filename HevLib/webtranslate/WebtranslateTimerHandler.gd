extends Node

var Globals = preload("res://HevLib/Functions.gd").new()

export var URL = ""
export var MINUTES = 30
export var fallback = []

func _ready():
	var timer = preload("res://HevLib/Scenes/timer/Timer.tscn").instance()
	add_child(timer)
	get_child(0).start_timer(MINUTES)
	Globals.__webtranslate(URL, fallback)


func onTimerComplete():
	
	Debug.l("HevLib WebTranslate: restarting translation loop for [%s], with delay of [%s]" % [URL, MINUTES])
	Globals.__webtranslate(URL, fallback)
	get_child(0).start_timer(MINUTES)
	
