extends Button

export var url = ""

var has_pressed = false

onready var timer = $Timer

func _ready():
	timer.wait_time = 0.5
	timer.one_shot = true

func _pressed():
	if not has_pressed:
		OS.shell_open(url)
		has_pressed = true
		timer.start()
		


func _timeout():
	has_pressed = false
