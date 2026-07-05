extends Popup

var pointers = ModLoader._savedObjects[0]

export var modmenu = NodePath("")
onready var mod_menu = get_node(modmenu)
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
	mod_menu.show_restart_menu()

var lastFocus = null
func refocus():
	if lastFocus and lastFocus.has_method("grab_focus"):
		lastFocus.grab_focus()
	else:
		Debug.l("I have no focus to fall back to!")
