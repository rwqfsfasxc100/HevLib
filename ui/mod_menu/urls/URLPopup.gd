extends Popup


var filter_offset = Vector2(200,200)


func _visibility_changed():
	_on_resize()

var lastFocus = null
func refocus():
	if lastFocus and lastFocus.has_method("grab_focus"):
		lastFocus.grab_focus()
	else:
		Debug.l("I have no focus to fall back to!")


func _unhandled_input(event):
	if visible and Input.is_action_just_pressed("ui_cancel"):
		cancel()
		get_tree().set_input_as_handled()

func _on_resize():
	var size = Settings.getViewportSize()
	rect_size = size
	$ColorRect.rect_size = size
#	rect_position = filter_offset/2
	$base.rect_size = size - filter_offset
	$base.rect_position = filter_offset/2

func show_menu():
	popup()
#	$base/URLContainer.show()

func cancel():
	hide()
	refocus()


func _about_to_show():
	lastFocus = get_focus_owner()
	var container = $base/URLContainer/VBoxContainer/ScrollContainer/VBoxContainer
	
	_on_resize()
