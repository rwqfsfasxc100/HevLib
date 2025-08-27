extends "res://menu/TitleMenu.gd"

func _enter_tree():
	var Equipment = preload("res://HevLib/pointers/Equipment.gd")
	Equipment.__make_upgrades_scene()
	replaceScene("user://cache/.HevLib_Cache/upgrades/Upgrades.tscn","res://enceladus/Upgrades.tscn")
	replaceScene("res://HevLib/scenes/equipment/Enceladus.tscn","res://enceladus/Enceladus.tscn")
	Loader.prepare("res://enceladus/Enceladus.tscn")
func replaceScene(input, replace):
	var upgrades = load(input)
	upgrades.take_over_path(replace)
	
