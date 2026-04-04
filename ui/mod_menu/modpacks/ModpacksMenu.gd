extends Popup

onready var pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")


var offset = Vector2(600,500)

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
