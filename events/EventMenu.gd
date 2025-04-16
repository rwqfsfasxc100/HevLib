extends CanvasLayer

func _ready():
	visible = false
	var vpRect = get_node("/root").size
	var screenWidth = vpRect.x
	var screenHeight = vpRect.y
	var margins = get_node("NoMargins")
	var mX = margins.rect_size.x
	var mY = margins.rect_size.y
	var offsetX = (screenWidth/2 - mX/2)
	var offsetY = (screenHeight/2 - mY/2)
	margins.rect_position = Vector2(offsetX,offsetY)
	
	
	

func _input(event):
	if event.is_action_pressed("open_debug_event_menu"):
		visible = not visible
