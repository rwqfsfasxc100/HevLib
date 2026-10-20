extends "res://Screensaver.gd"

var ctr:float = 0.0

var count:bool = false

func _init():
	var helperScript:Node = load("res://HevLib/scripts/ScreensaverHelper.gd").new()
	helperScript.parent = self
	add_child(helperScript)

func get_inputevent(event:InputEvent):
	if event is InputEventKey and event.scancode == KEY_ESCAPE:
		count = event.pressed
	get_tree().set_input_as_handled()

func _process(delta):
	if count:
		ctr += delta
		if ctr >= 1.0:
			get_tree().quit()
	else:
		ctr = 0
