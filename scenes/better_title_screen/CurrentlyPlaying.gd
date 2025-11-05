extends "res://menu/CurrentlyPlaying.gd"

const ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")

func display():
	if ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DRIVERS","show_currently_playing"):
		.display()
	else:
		visible = false
