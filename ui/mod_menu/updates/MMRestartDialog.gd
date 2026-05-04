extends Popup

func restart_cancel():
	hide()

var can_restart = true

func show():
	popup_centered()
	if can_restart:
		$PanelContainer/VBoxContainer/HBoxContainer/Restart/Button.grab_focus()
		$PanelContainer/VBoxContainer/HBoxContainer/Exit/Button.hint_tooltip = ""
		$PanelContainer/VBoxContainer/HBoxContainer/Restart/Button.hint_tooltip = ""
	else:
		$PanelContainer/VBoxContainer/HBoxContainer/Cancel/Button.grab_focus()
		$PanelContainer/VBoxContainer/HBoxContainer/Exit/Button.hint_tooltip = "HEVLIB_MODMENU_CANNOT_RESTART"
		$PanelContainer/VBoxContainer/HBoxContainer/Restart/Button.hint_tooltip = "HEVLIB_MODMENU_CANNOT_RESTART"

func let_restart(how):
	can_restart = how
	$PanelContainer/VBoxContainer/HBoxContainer/Restart/Button.disabled = !how
	$PanelContainer/VBoxContainer/HBoxContainer/Exit/Button.disabled = !how

func _restart():
	var path = OS.get_executable_path()
	var args = OS.get_cmdline_args()
	var pid = OS.execute(path, args, false)
	OS.kill(OS.get_process_id())

func _exit():
	OS.kill(OS.get_process_id())

func _input(event):
	if is_visible_in_tree() and Input.is_action_just_pressed("ui_cancel"):
		hide()
		CurrentGame.get_tree().set_input_as_handled()
