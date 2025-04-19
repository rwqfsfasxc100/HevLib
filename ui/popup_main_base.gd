extends Popup

export var datastring = ""

func _pressed():
	popup_centered()

func _ready():
	var vpRect = get_viewport_rect().size
	var screenWidth = vpRect.x
	var screenHeight = vpRect.y
	
	margin_right = screenWidth
	if OS.get_name() == "Windows":
		margin_bottom = screenHeight - 1
	else:
		margin_bottom = screenHeight
	margin_left = 0
	margin_top = 0
