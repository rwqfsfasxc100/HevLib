extends MarginContainer



func _resized():
	var size = get_parent().rect_size
	rect_size = size


func _visibility_changed():
	_resized()
