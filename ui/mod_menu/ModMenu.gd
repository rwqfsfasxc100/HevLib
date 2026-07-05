extends Popup
var pointers = ModLoader._savedObjects[0]
var offset = Vector2(12,12)

var cache_folder : String = "user://cache/.Mod_Menu_2_Cache/"
var filter_cache_file : String = "menu_filter_cache.json"
var file : File = File.new()
func _about_to_show():
	pointers.FolderAccess.__check_folder_exists(cache_folder)
	file.open(cache_folder + filter_cache_file,File.WRITE)
	file.store_string("[]")
	file.close()
	var nodes : Array = $FilterPopup/base/FilterContainer/VBoxContainer/ScrollContainer/VBoxContainer.get_children()
	for node in nodes:
		var c = node.get_node("CheckButton")
		c.pressed = true
	$base/PanelContainer/VBoxContainer/ModContainer/SPLIT/ModList.about_to_show()
	lastFocus = get_focus_owner()
	_on_resize()
	$base/PanelContainer/VBoxContainer/ModContainer/SPLIT/ModList.hide_mods()
	
func _unhandled_input(event):
	if visible and Input.is_action_just_pressed("ui_cancel"):
		if $WAIT.visible:
			Debug.l("Currently downloading a mod update, not closing wait window.")
		elif $ModpacksMenu/WAIT.visible:
			Debug.l("Currently downloading a mod, not closing wait window.")
		elif $FetchGithub/WAIT.visible:
			Debug.l("Currently downloading a mod, not closing wait window.")
		
		
		elif $MMRestartDialog.visible:
			$MMRestartDialog.hide()
		
		elif $ModpacksMenu/OpenPack.visible:
			$ModpacksMenu/OpenPack.hide()
		elif $ModpacksMenu/SavePack.visible:
			$ModpacksMenu/SavePack.hide()
		
		
		elif $FetchGithub.visible:
			$FetchGithub.cancel()
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
			$ProfilesMenu.cancel()
		elif $MMChangelogMenu.visible:
			$MMChangelogMenu.cancel()
		elif $ModpacksMenu.visible:
			$ModpacksMenu.cancel()
		else:
			cancel()
		get_tree().set_input_as_handled()

func show_menu():
	popup()

func cancel():
	$AnimateAppear.play("hider")

onready var restart_menu : Node = $MMRestartDialog
var has_updated_store : String = "user://cache/.Mod_Menu_2_Cache/updates/has_updated.txt"

func show_restart_menu():
	var valid = true
	var ps = CurrentGame.getPlayerShip()
	if ps and ps.zone == "rings":
		valid = false
	restart_menu.let_restart(valid)
	file.open(has_updated_store,File.READ)
	var has : String = file.get_as_text()
	file.close()
	if has == "1":
		restart_menu.show()
		return true
	return false

func hider():
	if restart_menu.can_restart:
		if not show_restart_menu():
			hide()
			refocus()
		else:
			hide()
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
	var size: Vector2 = Settings.getViewportSize()
	rect_size = size
	$ColorRect.rect_min_size = size
	$ColorRect.rect_size = size
	$base.rect_min_size = size - offset
	$base.rect_size = size - offset
	$base.rect_position = offset/2
	
	
	var bn : Node = $base/PanelContainer/VBoxContainer/ModContainer/SPLIT/ModList/ScrollContainer/VBoxContainer
	if bn:
		if bn.get_children().size() >= 1:
			var buttonnode : Node = bn.get_child(0)
			var children : Array = buttonnode.get_children()
			var names : Array = []
			for child in children:
				names.append(child.name)
			if "ModButton" in names:
				buttonnode.get_node("ModButton").grab_focus()

func _ready():
	get_tree().get_root().connect("size_changed", self, "_on_resize")

func _visibility_changed():
	_on_resize()

