extends "res://CurrentGame.gd"

var in_hevlib_menu = false setget set_in_menu

signal eventDriverVisibilityChanged(how)

func set_in_menu(how:bool):
	in_hevlib_menu = how
	emit_signal("eventDriverVisibilityChanged",how)
