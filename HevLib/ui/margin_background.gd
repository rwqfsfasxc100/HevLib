extends MarginContainer

func _process(delta):
	var vpRect = get_viewport_rect().size
	var screenWidth = vpRect.x
	var screenHeight = vpRect.y
	var panelWidth = Settings.maxScreenScale.x - 2
	var panelHeight = Settings.maxScreenScale.y - 2
	if OS.get_name() == "Windows":
		screenHeight -= 1
	margin_right = screenWidth
	margin_bottom = screenHeight
	margin_left = 0
	margin_top = 0
