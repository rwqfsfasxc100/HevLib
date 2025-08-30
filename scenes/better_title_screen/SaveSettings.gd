extends Popup

var save_slot_file = "user://savegame.dv"

var delete_color = Color(1,1,1,1)

var slot_available = true


func _process(delta):
	var screen = get_viewport().size
	
	var size = $NoMargins.rect_size
	
	var x = (screen.x - size.x)/2
	var y = (screen.y - size.y)/2
	var pos = Vector2(x,y)
#	breakpoint
	$NoMargins.rect_position = pos - self.rect_position

func cancel():
	hide()


func _about_to_show():
	
	$NoMargins/CenterContainer/TabHintContainer/TabsWithGamepadControl/HEVLIB_SAVE_OPTIONS/MarginContainer/MarginContainer/ScrollContainer/VBoxContainer/DELETE_SAVE.disabled = !slot_available
