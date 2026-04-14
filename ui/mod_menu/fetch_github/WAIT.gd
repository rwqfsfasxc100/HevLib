extends Popup

func _ready():
	connect("about_to_show",self,"_about_to_show")
	
func _about_to_show():
	lastFocus = get_focus_owner()
	$PanelContainer/Button.grab_focus()

func show_menu():
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
