extends Popup

var offset = Vector2(12,12)
var FolderAccess = preload("res://HevLib/pointers/FolderAccess.gd")
var cache_folder = "user://cache/.Mod_Menu_2_Cache/"
var filter_cache_file = "menu_filter_cache.json"
var file = File.new()
func _about_to_show():
	FolderAccess.__check_folder_exists(cache_folder)
	file.open(cache_folder + filter_cache_file,File.WRITE)
	file.store_string(JSON.print([]))
	file.close()
	var nodes = $FilterPopup/base/FilterContainer/VBoxContainer/ScrollContainer/VBoxContainer.get_children()
	for node in nodes:
		var c = node.get_node("CheckButton")
		c.pressed = true
	$base/PanelContainer/VBoxContainer/ModContainer/SPLIT/ModList.about_to_show()
	lastFocus = get_focus_owner()
	_on_resize()
	
func _unhandled_input(event):
	if visible and Input.is_action_just_pressed("ui_cancel"):
		if $WAIT.visible:
			Debug.l("Currently downloading a mod update for %s, not closing wait window.")
		elif $URLPopup.visible:
			$URLPopup.cancel()
		elif $FilterPopup.visible:
			$FilterPopup.cancel()
		elif $ModSettingsMenu.visible:
			$ModSettingsMenu.cancel()
		elif $ConflictMenu.visible:
			$ConflictMenu.hide()
		elif $DependancyMenu.visible:
			$DependancyMenu.hide()
		elif $UpdateDialog.visible:
			$UpdateDialog.hide()
		elif $ProfilesMenu.visible:
			$ProfilesMenu.hide()
		elif $MMChangelogMenu.visible:
			$MMChangelogMenu.hide()
		else:
			cancel()
		get_tree().set_input_as_handled()

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

onready var restart_menu = $MMRestartDialog

func _on_resize():
	var size = Settings.getViewportSize()
	rect_size = size
	$ColorRect.rect_min_size = size
	$ColorRect.rect_size = size
	$base.rect_min_size = size - offset
	$base.rect_size = size - offset
	$base.rect_position = offset/2
	
	
	var bn = $base/PanelContainer/VBoxContainer/ModContainer/SPLIT/ModList/ScrollContainer/VBoxContainer
	if bn:
		if bn.get_children().size() >= 1:
			var buttonnode = bn.get_child(0)
			var children = buttonnode.get_children()
			var names = []
			for child in children:
				names.append(child.name)
			if "ModButton" in names:
				buttonnode.get_node("ModButton").grab_focus()

func _visibility_changed():
	_on_resize()

