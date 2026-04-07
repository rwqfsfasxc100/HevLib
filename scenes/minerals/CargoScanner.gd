extends "res://hud/CargoScanner.gd"

var pointers

func _enter_tree():
	pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	pointers.ConfigDriver.__establish_connection("updateValues",self)
	updateValues()

func updateValues():
	if pointers:
		cargo_limit = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_EQUIPMENT","cargo_scanner_mineral_display_limit")

var cargo_limit = 15

func compare(a,b):
	return smooth[a] > smooth[b]
	pass

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

func clear_non_minerals(arr):
	if "" in arr:
		arr.erase("")
	if "cargo_space" in arr:
		arr.erase("cargo_space")
	if "_" in arr:
		arr.erase("_")
	if "SHIP" in arr:
		arr.erase("SHIP")
	if "CARGO_EQUIPMENT" in arr:
		arr.erase("CARGO_EQUIPMENT")
	return arr
