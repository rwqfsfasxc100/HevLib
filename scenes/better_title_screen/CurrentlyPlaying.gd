extends "res://menu/CurrentlyPlaying.gd"

func _ready():
	yield (get_tree(), "idle_frame")
	var mod_menu = get_tree().get_root().find_node("ModMenu", true, false)
	if mod_menu:
		mod_menu.connect("visibility_changed", self , "display")

var pointers = ModLoader._savedObjects[0]
func display():
	var mod_menu = get_tree().get_root().find_node("ModMenu", true, false)
	if mod_menu and mod_menu.visible:
		visible = false
		return
		
	if pointers.ConfigDriver.__get_value("HevLib", "HEVLIB_CONFIG_SECTION_DRIVERS", "show_currently_playing"):
		.display()
	else:
		visible = false
