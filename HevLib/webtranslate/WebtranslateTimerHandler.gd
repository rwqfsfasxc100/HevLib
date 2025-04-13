extends Node

var Globals = preload("res://HevLib/Functions.gd").new()

export var URL = ""
export var MINUTES = 30


func _ready():
	var timer = preload("res://HevLib/Scenes/timer/Timer.tscn").instance()
	add_child(timer)
	get_child(0).start_timer(MINUTES)
	Globals.__webtranslate(URL)


func onTimerComplete():
	
	Debug.l("HevLib WebTranslate: restarting translation loop for [%s], with delay of [%s]" % [URL, MINUTES])
	Globals.__webtranslate(URL)
	get_child(0).start_timer(MINUTES)
	
