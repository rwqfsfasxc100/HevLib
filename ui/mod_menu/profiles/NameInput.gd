extends Popup

var set_mode = ""

onready var box = $PanelContainer/VBoxContainer/PanelContainer/LineEdit

func save_data():
	var txt = box.text
	box.text = ""
	if txt == "" or txt == old:
		return
	match set_mode:
		"add":
			get_parent().add_profile(txt)
		"rename":
			get_parent().rename_profile(txt)
	cancel()

func set_show(mode):
	var title = $PanelContainer/VBoxContainer/Label
	set_mode = mode
	match mode:
		"add":
			title.text = "HEVLIB_PROFILENAME_ADD"
		"rename":
			title.text = "HEVLIB_PROFILENAME_RENAME"
	

func _about_to_show():
	lastFocus = get_focus_owner()
var old = ""
func show_menu(mode = "add"):
	old = get_parent().display[get_parent().profile_selections.selected]
	set_show(mode)
	popup_centered()

func cancel():
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
