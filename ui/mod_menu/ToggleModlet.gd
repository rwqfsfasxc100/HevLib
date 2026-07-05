extends CheckButton

var pointers = ModLoader._savedObjects[0]

var current_modlet = null
var current_modlet_path : String = ""

var can_toggle = false

var file = File.new()
var modlet_toggle_restart_path = "user://cache/.Mod_Menu_2_Cache/updates/modlet_restart_requests.json"
var updateCacheDir = "user://cache/.Mod_Menu_2_Cache/updates/has_updated.txt"

func _toggled(button_pressed):
	if can_toggle:
		var all_modlets = pointers.ManifestV2.__get_all_modlets(false)
		all_modlets[current_modlet_path] = button_pressed
		file.open(modlet_toggle_restart_path,File.READ)
		var restarting = JSON.parse(file.get_as_text()).result
		file.close()
		if not current_modlet_path in restarting:
			restarting.append(current_modlet_path)
		current_modlet.needs_restart_from_toggling = true
		file.open(modlet_toggle_restart_path,File.WRITE)
		file.store_string(JSON.print(restarting))
		file.close()
		file.open(updateCacheDir,File.WRITE)
		file.store_string("1")
		file.close()
		pointers.ConfigDriver.__store_value("HevLib","modlets","seen_modlets",all_modlets)
		yield(CurrentGame.get_tree(),"idle_frame")
		current_modlet.update()

func change_modlet_to(modlet,modlet_path:String):
	can_toggle = false
	current_modlet = modlet
	current_modlet_path = modlet_path
	if modlet and modlet_path:
		if modlet_path == "res://ModMenu2/Mod.manifest":
			disabled = true
			hint_tooltip = "HEVLIB_MODMENU_MODLET_TOGGLE_MM2FALLBACK"
		else:
			disabled = false
			hint_tooltip = "HEVLIB_MODMENU_MODLET_TOGGLE_TOOLTIP"
		var all_modlets = pointers.ManifestV2.__get_all_modlets(false)
		var enabled = all_modlets[modlet_path]
		pressed = enabled
		yield(CurrentGame.get_tree(),"physics_frame")
		can_toggle = true
