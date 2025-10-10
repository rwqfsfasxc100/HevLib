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

var updating_all = false

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
	$Timer.start()

func _visibility_changed():
	_on_resize()

func show_menu():
	popup()
var updates = {}
func _ready():
	restart_dialog.get_node("PanelContainer/VBoxContainer/HBoxContainer/Restart/Button").connect("pressed",self,"_confirmed")
	restart_dialog.get_node("PanelContainer/VBoxContainer/HBoxContainer/Exit/Button").connect("pressed",self,"_custom_action")
	restart_dialog.get_node("PanelContainer/VBoxContainer/HBoxContainer/Cancel/Button").connect("pressed",self,"restart_cancel")
	notifications_button.connect("pressed",self,"notifications_pressed")
	

func _input(event):
	if is_visible_in_tree():
		if event.is_action_pressed("ui_cancel"):
			cancel()

func restart_cancel():
	restart_dialog.hide()

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
	

var mods_to_download = []

var update_all_count = 0
var update_all_current = 0

func _update_all_pressed():
	updating_all = true
	var mods = container.get_children()
	update_all_count = mods.size()
	for mod in mods:
		mods_to_download.append({"name":mod.mod_name,"id":mod.mod_id,"version":mod.new_version,"container":mod})
	move_to_next_mod()
	$WAIT.popup_centered()

func move_to_next_mod():
	if mods_to_download.size() >= 1:
		var current = mods_to_download.pop_front()
		update_all_current += 1
		$WAIT/PanelContainer/Button/Label.text = TranslationServer.translate("HEVLIB_WAIT_TO_UPDATE_ALL") % [update_all_current,update_all_count,current["name"],current["id"],current["version"]]
		current["container"].display_wait_popup = false
		current["container"]._update_confirmed()
		$WAIT/PanelContainer/Button.grab_focus()
	else:
		$WAIT.hide()

func _confirmed():
	OS.set_restart_on_exit(true,OS.get_cmdline_args())


func _custom_action():
	OS.kill(OS.get_process_id())


func _ignore_all_pressed():
	var mods = container.get_children()
	for mod in mods:
		mod._ignore_confirmed()


func _update_all_desired():
	$UpdatePopup.popup_centered()


func _ignore_all_desired():
	$IgnorePopup.popup_centered()

export var notifications_button_path = NodePath("")
onready var notifications_button = get_node(notifications_button_path)

func notifications_pressed():
	file.open(update_store,File.READ)
	updates = JSON.parse(file.get_as_text()).result
	file.close()
	
	var currently_ignored = ConfigDriver.__get_value("ModMenu2","datastore","ignored_updates")
	if currently_ignored == null:
		currently_ignored = {}
	for u in updates:
		if u in currently_ignored:
			if currently_ignored[u] == str(updates[u]["new_version"][0]) + "." + str(updates[u]["new_version"][1]) + "." + str(updates[u]["new_version"][2]):
				updates.erase(u)
			else:
				currently_ignored.erase(u)
	if updates.size() >= 1:
		popup()


func _timeout():
	if container.get_child_count() >= 1:
		container.get_child(0).get_node("Buttons/Ignore").grab_focus()
	else:
		$base/VBoxContainer/ButtonContainer/Cancel/Button.grab_focus()
