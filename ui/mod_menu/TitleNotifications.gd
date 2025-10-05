extends Button
const ManifestV2 = preload("res://HevLib/pointers/ManifestV2.gd")
var file = File.new()
var update_store = "user://cache/.Mod_Menu_2_Cache/updates/needs_updates.json"
func _ready():
	check()
	$Timer.start()
	visible = false
var visibility = false
func check():
	file.open(update_store,File.READ)
	var update_data = JSON.parse(file.get_as_text()).result
	file.close()
	var height = 50
	if update_data.keys().size() == 0:
		$NotificationBox/VBoxContainer/Updates.visible = false
	else:
		visibility = true
		height += 50
		$NotificationBox/VBoxContainer/Updates.visible = true
		$NotificationBox/VBoxContainer/Updates/Label.text = TranslationServer.translate("HEVLIB_UPDATE_COUNT") % update_data.keys().size()
	var conflicts = ManifestV2.__check_conflicts()
	var dependancies = ManifestV2.__check_dependancies()
	if conflicts.keys().size() == 0:
		$NotificationBox/VBoxContainer/Conflicts.visible = false
	else:
		visibility = true
		height += 50
		$NotificationBox/VBoxContainer/Conflicts.visible = true
		$NotificationBox/VBoxContainer/Conflicts/Label.text = TranslationServer.translate("HEVLIB_CONFLICT_COUNT") % conflicts.keys().size()
	if dependancies.keys().size() == 0:
		$NotificationBox/VBoxContainer/Dependancies.visible = false
	else:
		visibility = true
		height += 50
		$NotificationBox/VBoxContainer/Dependancies.visible = true
		$NotificationBox/VBoxContainer/Dependancies/Label.text = TranslationServer.translate("HEVLIB_DEPENDANCY_COUNT") % dependancies.keys().size()
	$NotificationBox.rect_size.y = height
	$NotificationBox.rect_position.y = -height

func _process(delta):
#	if mouse_focus:
#		focused = true
#	elif key_focus:
#		focused = true
#	else:
#		focused = false
#	if focused:
#		$NotificationBox.visible = true
	if mouse_focus or key_focus:
		$NotificationBox.visible = true
	else:
		$NotificationBox.visible = false
	visible = visibility

func _timeout():
	check()
var focused = false
var key_focus = false
var mouse_focus = false


func _focus_entered():
	key_focus = true


func _focus_exited():
	key_focus = false


func _mouse_entered():
	mouse_focus = true


func _mouse_exited():
	mouse_focus = false
