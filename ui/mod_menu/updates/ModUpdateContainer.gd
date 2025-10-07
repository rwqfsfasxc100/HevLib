extends HBoxContainer

export var mod_id = ""




func _Ignore_pressed():
	$Popups/IgnorePopup.popup_centered()


func _Update_pressed():
	$Popups/UpdatePopup.popup_centered()
