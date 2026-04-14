extends "res://hud/CargoScanner.gd"

var HevLib_pointers

func _enter_tree():
	HevLib_pointers = CurrentGame.get_tree().get_root().get_node_or_null("HevLib~Pointers")
	HevLib_pointers.ConfigDriver.__establish_connection("updateValues",self)
	updateValues()

func updateValues():
	if HevLib_pointers:
		cargo_limit = HevLib_pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_EQUIPMENT","cargo_scanner_mineral_display_limit")

var cargo_limit = 15

func compare(a,b):
	return smooth[a] > smooth[b]

func smoothValue(dict, s):
	.smoothValue(dict,s)
	var sms = smooth.size()
	if sms > 10:
		var top = clear_non_minerals(smooth.keys())
		sms = top.size()
		top.sort_custom(self,"compare")
		if sms > cargo_limit:
			for a in range(sms - cargo_limit):
				smooth.erase(top[a + cargo_limit])
	return smooth

func clear_non_minerals(arr: Array):
	arr.erase("")
	arr.erase("cargo_space")
	arr.erase("_")
	arr.erase("SHIP")
	arr.erase("CARGO_EQUIPMENT")
	return arr
