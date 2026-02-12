extends "res://menu/CurrentlyPlaying.gd"

#const ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")

func display():
	var pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	if pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DRIVERS","show_currently_playing"):
		.display()
	else:
		visible = false
