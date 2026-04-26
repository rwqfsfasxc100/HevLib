extends Popup


func _ready():
	connect("about_to_show",self,"_about_to_show")
	connect("visibility_changed",self,"_on_resize")
	get_tree().get_root().connect("size_changed", self, "_on_resize")







export var restart_dialog_path = NodePath("")
onready var restart_dialog = get_node(restart_dialog_path)
var file = File.new()
var has_updated_store = "user://cache/.Mod_Menu_2_Cache/updates/has_updated.txt"



func _about_to_show():
	lastFocus = get_focus_owner()
	$base/VBoxContainer/Content/ListGithubMods.select_first_mod()

func show_menu():
#	get_parent().hide()
	popup()

func cancel():
	$AnimateAppear.play("hider")
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
#	get_parent().show_menu()

var lastFocus = null
func refocus():
	if lastFocus and lastFocus.has_method("grab_focus"):
		lastFocus.grab_focus()
	else:
		Debug.l("I have no focus to fall back to!")

export var offset = Vector2(12,12)

func _on_resize():
	var size = Settings.getViewportSize()
	rect_size = size
	$ColorRect.rect_min_size = size
	$ColorRect.rect_size = size
	$base.rect_min_size = size - offset
	$base.rect_size = size - offset
	$base.rect_position = offset/2
	yield(CurrentGame.get_tree(),"idle_frame")
#	$base/VBoxContainer/Content/Info/INFO/ScrollContainer.rect_size = $base/VBoxContainer/Content/Info/INFO.rect_size
