extends Node

onready var pointers = ModLoader._savedObjects[0]

export var URL = ""
export var MINUTES = 30
export var fallback = []
export var file_check = ""

func _ready():
	var timer = preload("res://HevLib/scenes/timer/Timer.tscn").instance()
	add_child(timer)
	get_child(0).start_timer(MINUTES)
	pointers.WebTranslate.__webtranslate(URL, fallback, file_check)


func onTimerComplete():
	
	Debug.l("HevLib WebTranslate: restarting translation loop for [%s], with delay of [%s]" % [URL, MINUTES])
	pointers.WebTranslate.__webtranslate(URL, fallback)
	get_child(0).start_timer(MINUTES)
	
