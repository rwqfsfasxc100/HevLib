extends Popup

var update_store = "user://cache/.Mod_Menu_2_Cache/updates/needs_updates.json"

var offset = Vector2(100,75)

onready var container = $base/VBoxContainer/ScrollContainer/LabelContainer

var file = File.new()

const ManifestV2 = preload("res://HevLib/pointers/ManifestV2.gd")
const ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")
const update_container = preload("res://HevLib/ui/mod_menu/updates/ModUpdateContainer.tscn")
var has_updated_store = "user://cache/.Mod_Menu_2_Cache/updates/has_updated.txt"

export var restart_dialog_path = NodePath("")
onready var restart_dialog = get_node(restart_dialog_path)

func _about_to_show():
	for child in container.get_children():
		Tool.remove(child)
	
	file.open(update_store,File.READ)
	var update_data = JSON.parse(file.get_as_text()).result
	file.close()
	
	var currently_ignored = ConfigDriver.__get_value("ModMenu2","datastore","ignored_updates")
	if currently_ignored == null:
		currently_ignored = {}
	for u in update_data:
		if u in currently_ignored:
			if currently_ignored[u] == str(update_data[u]["new_version"][0]) + "." + str(update_data[u]["new_version"][1]) + "." + str(update_data[u]["new_version"][2]):
				update_data.erase(u)
			else:
				currently_ignored.erase(u)
	
	for mod in update_data:
		var c = update_container.instance()
		var md = update_data[mod]
		var info = ManifestV2.__get_mod_by_id(mod)
		var display_name = md["display"]
		var old_version = md["version"]
		var new_version = md["new_version"]
		c.get_node("ModInfo/Label").text = display_name
		c.mod_id = mod
		c.mod_name = md["name"]
		c.current_version = str(old_version[0]) + "." + str(old_version[1]) + "." + str(old_version[2])
		c.new_version = str(new_version[0]) + "." + str(new_version[1]) + "." + str(new_version[2])
		container.add_child(c)
	
	lastFocus = get_focus_owner()
	_on_resize()
	
	

func _visibility_changed():
	_on_resize()

func show_menu():
	popup()

func _ready():
	restart_dialog.add_button("HEVLIB_EXIT_INSTEAD",false,"exit_instead")
	restart_dialog.connect("confirmed",self,"confirmed")
	restart_dialog.connect("custom_action",self,"custom_action")
	

func cancel():
	file.open(has_updated_store,File.READ)
	var has = file.get_as_text()
	file.close()
	if has == "true":
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

func _on_resize():
	var size = Settings.getViewportSize()
	rect_size = size
	$ColorRect.rect_size = size
	$base.rect_min_size = size - offset
	$base.rect_position = offset/2
	


func _update_all_pressed():
	pass # Replace with function body.


func _confirmed():
	OS.set_restart_on_exit(true,OS.get_cmdline_args())


func _custom_action(action):
	match action:
		"exit_instead":
			OS.kill(OS.get_process_id())
