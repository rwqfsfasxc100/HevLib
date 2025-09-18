extends Popup

var offset = Vector2(12,12)

func _about_to_show():
	$base/PanelContainer/VBoxContainer/ModContainer/SPLIT/ModList.about_to_show()
	lastFocus = get_focus_owner()
	_on_resize()
	
func _unhandled_input(event):
	if visible and Input.is_action_just_pressed("ui_cancel"):
		cancel()
		get_tree().set_input_as_handled()

func show_menu():
	popup()

func cancel():
	hide()
	refocus()

var lastFocus = null
func refocus():
	if lastFocus and lastFocus.has_method("grab_focus"):
		lastFocus.grab_focus()
	else:
		Debug.l("I have no focus to fall back to!")

func _on_resize():
	var size = Settings.getViewportSize()
	$ColorRect.rect_size = size
	$base.rect_size = size - offset
	$base.rect_position = offset/2
	var buttonnode = $base/PanelContainer/VBoxContainer/ModContainer/SPLIT/ModList/ScrollContainer/VBoxContainer.get_child(0)
	var children = buttonnode.get_children()
	var names = []
	for child in children:
		names.append(child.name)
	if "ModButton" in names:
		buttonnode.get_node("ModButton").grab_focus()

func _visibility_changed():
	_on_resize()
