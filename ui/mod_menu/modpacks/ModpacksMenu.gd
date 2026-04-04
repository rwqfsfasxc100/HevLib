extends Popup

onready var pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")

export var restart_dialog_path = NodePath("")
onready var restart_dialog = get_node(restart_dialog_path)
var offset = Vector2(600,500)

func _about_to_show():
	lastFocus = get_focus_owner()

func show_menu():
	popup_centered()

func cancel():
	$AnimateAppear.play("hider")
var file = File.new()
var has_updated_store = "user://cache/.Mod_Menu_2_Cache/updates/has_updated.txt"
func hider():
	file.open(has_updated_store,File.READ)
	var has = file.get_as_text()
	file.close()
	if has == "1":
		hide()
		restart_dialog.popup_centered()
	else:
		hide()
		refocus()

var lastFocus = null
func refocus():
	if lastFocus and lastFocus.has_method("grab_focus"):
		lastFocus.grab_focus()
	else:
		Debug.l("I have no focus to fall back to!")
