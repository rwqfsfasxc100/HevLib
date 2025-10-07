extends Popup

var update_store = "user://cache/.Mod_Menu_2_Cache/updates/needs_updates.json"

var offset = Vector2(100,75)

onready var container = $base/VBoxContainer/LabelContainer

var file = File.new()

const ManifestV2 = preload("res://HevLib/pointers/ManifestV2.gd")

func _about_to_show():
	for child in container.get_children():
		Tool.remove(child)
	
	file.open(update_store,File.READ)
	var update_data = JSON.parse(file.get_as_text()).result
	file.close()
	
	for mod in update_data:
		var md = update_data[mod]
		var info = ManifestV2.__get_mod_by_id(mod)
		var display_name = md["display"]
		var old_version = md["version"]
		var new_version = md["new_version"]
		breakpoint
	
	lastFocus = get_focus_owner()
	_on_resize()

func _visibility_changed():
	_on_resize()

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
	rect_size = size
	$ColorRect.rect_size = size
	$base.rect_min_size = size - offset
	$base.rect_position = offset/2
	


func _update_all_pressed():
	pass # Replace with function body.
