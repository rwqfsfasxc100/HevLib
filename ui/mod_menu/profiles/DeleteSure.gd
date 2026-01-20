extends Popup

func delete():
	get_parent().delete_profile()
	cancel()

func _about_to_show():
	
	lastFocus = get_focus_owner()

func show_menu():
	popup_centered()

func cancel():
	$AnimateAppear.play("hider")

func hider():
	hide()
	refocus()
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
