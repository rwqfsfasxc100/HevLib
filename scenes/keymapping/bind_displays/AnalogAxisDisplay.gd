extends "res://hud/components/AnalogAxisDisplay.gd"

export var display_direction = false

var raw = ""

var icon_path = "res://HevLib/ui/themes/icons/joy_map.stex"

func _enter_tree():
	key = abs(key)
	if display_direction:
		var sp = get_node("Sprite")
		var stream = StreamTexture.new()
		stream.load_path = icon_path
		sp.texture = stream
		sp.hframes = 20
		var axisDirection = sign(key)
		if raw.begins_with("-"):
			axisDirection = -1
		if axisDirection < 0:
			key += 10
		key *= 2
