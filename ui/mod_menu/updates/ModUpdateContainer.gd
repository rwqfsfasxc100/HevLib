extends HBoxContainer

var mod_id = ""
var mod_name = ""
var current_version = ""
var new_version = ""
var update_store = "user://cache/.Mod_Menu_2_Cache/updates/needs_updates.json"
var has_updated_store = "user://cache/.Mod_Menu_2_Cache/updates/has_updated.txt"
const ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")
var file = File.new()
onready var manager = get_parent().get_parent().get_parent().get_parent().get_parent()
func _ready():
	$Popups/IgnorePopup.dialog_text = TranslationServer.translate("HEVLIB_CONFIRMATION_DIALOGUE_IGNORE_MOD_UPDATE") % [mod_name,new_version]
	$Popups/UpdatePopup.dialog_text = TranslationServer.translate("HEVLIB_CONFIRMATION_DIALOGUE_UPDATE_MOD") % [mod_name,new_version]
	var gameInstallDirectory = OS.get_executable_path().get_base_dir()
	if OS.get_name() == "OSX":
		gameInstallDirectory = gameInstallDirectory.get_base_dir().get_base_dir().get_base_dir()
	modPathPrefix = gameInstallDirectory.plus_file("mods")

func _Ignore_pressed():
	$Popups/IgnorePopup.popup_centered()


func _Update_pressed():
	$Popups/UpdatePopup.popup_centered()

var display_wait_popup = true

func _ignore_confirmed():
	var currently_ignored = ConfigDriver.__get_value("ModMenu2","datastore","ignored_updates")
	if currently_ignored == null:
		ConfigDriver.__store_value("ModMenu2","datastore","ignored_updates",{})
	currently_ignored = ConfigDriver.__get_value("ModMenu2","datastore","ignored_updates")
	currently_ignored[mod_id] = new_version
	ConfigDriver.__store_value("ModMenu2","datastore","ignored_updates",currently_ignored)
	repos()
	Tool.remove(self)
var zip_folder = "user://cache/.Mod_Menu_2_Cache/updates/zip_cache/"
const Github = preload("res://HevLib/pointers/Github.gd")
func _update_confirmed():
	file.open(update_store,File.READ)
	var data = JSON.parse(file.get_as_text()).result
	file.close()
	var github = data[mod_id]["github"]
	var nexus = data[mod_id]["nexus"]
	if github:
		if github.ends_with("/"):
			github.rstrip("/")
		if not github.ends_with("/releases"):
			github = github + "/releases"
		Github.__get_github_release(github,zip_folder,self,true,"zip")
	elif nexus:
		if nexus.ends_with("/"):
			nexus.rstrip("/")
		OS.shell_open(nexus + "?tab=files")
	if display_wait_popup:
		$Popups/WAIT.popup_centered()
var modPathPrefix = ""
const FileAccess = preload("res://HevLib/pointers/FileAccess.gd")
func _downloaded_zip(file, filepath):
	$Popups/WAIT.hide()
	var fi = File.new()
	fi.open(update_store,File.READ)
	var data = JSON.parse(fi.get_as_text()).result
	fi.close()
	
	if mod_id in data:
		data.erase(mod_id)
	fi.open(update_store,File.WRITE)
	fi.store_string(JSON.print(data))
	fi.close()
	fi.open(has_updated_store,File.WRITE)
	fi.store_string("true")
	fi.close()
	repos()
	FileAccess.__copy_file(filepath,modPathPrefix)
	manager.move_to_next_mod()
	Tool.remove(self)


func repos():
	var mods = get_parent().get_child_count()
	var pos = get_position_in_parent()
	if mods >= 2:
		if pos != 0:
			get_parent().get_child(0).get_node("Buttons/Ignore").grab_focus()
		else:
			get_parent().get_child(1).get_node("Buttons/Ignore").grab_focus()
	else:
		get_parent().get_parent().get_parent().get_node("ButtonContainer/Cancel/Button").grab_focus()
		get_parent().get_parent().get_parent().get_node("ButtonContainer/UpdateAll/Button").disabled = true
		get_parent().get_parent().get_parent().get_node("ButtonContainer/UpdateAll/Button").modulate = Color(0.7,0.7,0.7,1)
		get_parent().get_parent().get_parent().get_node("ButtonContainer/IgnoreAll/Button").disabled = true
		get_parent().get_parent().get_parent().get_node("ButtonContainer/IgnoreAll/Button").modulate = Color(0.7,0.7,0.7,1)
