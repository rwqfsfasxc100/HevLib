extends Popup

export var update_menu_path = NodePath("")
onready var update_menu = get_node(update_menu_path)

var update_store = "user://cache/.Mod_Menu_2_Cache/updates/needs_updates.json"

var file = File.new()
const ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")
func _ready():
	file.open(update_store,File.READ)
	var updates = JSON.parse(file.get_as_text()).result
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
		$Timer.start()
	

func show_menu():
	
	popup_centered()

func cancel():
	hide()
#	refocus()

var lastFocus = null
func refocus():
	if lastFocus and lastFocus.has_method("grab_focus"):
		lastFocus.grab_focus()
	else:
		Debug.l("I have no focus to fall back to!")


func _about_to_show():
	
	lastFocus = get_focus_owner()


func _confirmed():
	update_menu.popup()
	cancel()
	update_menu.lastFocus = lastFocus
