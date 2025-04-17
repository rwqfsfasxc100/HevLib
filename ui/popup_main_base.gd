extends Popup

export var datastring := {}

func _process(delta):
	
	var vpRect = get_viewport_rect().size
	var screenWidth = vpRect.x
	var screenHeight = vpRect.y
	
	margin_right = screenWidth - 2
	if OS.get_name() == "Windows":
		margin_bottom = screenHeight - 3
	else:
		margin_bottom = screenHeight - 2
	margin_left = 0
	margin_top = 0


func _pressed():
	popup_centered()
