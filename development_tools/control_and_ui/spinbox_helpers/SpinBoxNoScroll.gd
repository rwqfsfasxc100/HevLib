extends SpinBox

var scroll:LineEdit

func _ready():
	scroll = get_line_edit()
	scroll.focus_mode = FOCUS_CLICK

func _gui_input(event):
	if scroll.has_focus():
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_WHEEL_UP or event.button_index == BUTTON_WHEEL_DOWN:
				scroll.release_focus()
#				accept_event()
