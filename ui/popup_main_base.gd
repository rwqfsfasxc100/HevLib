extends Popup

export var datastring = ""

var size = Vector2(1280,720)

func _pressed():
	popup_centered()

func _process(delta):
	
	var iterate_node = self
	var ind = 0
	while ind == 0:
		var iterated_node = iterate_node.get_parent()
		if iterated_node.get_class() == "CanvasLayer":
			ind = 1
		else:
			iterate_node = iterate_node.get_parent()
	var vpRect = iterate_node.rect_size
	size = vpRect
	var screenWidth = vpRect.x
	var screenHeight = vpRect.y
	margin_right = screenWidth
	var windowed = Settings.cfg["display"]["windowed"]
	var fullscreen = Settings.cfg["display"]["fullscreen"]
	if OS.get_name() == "Windows" and windowed == false and fullscreen == false:
		margin_bottom = screenHeight - 1
	else:
		margin_bottom = screenHeight
	margin_left = 0
	margin_top = 0
