extends "res://hud/CargoScanner.gd"

var HevLib_pointers

func _enter_tree():
	HevLib_pointers = ModLoader._savedObjects[0]
	HevLib_pointers.ConfigDriver.__establish_connection("hl_cargo_limiter_uv",self)
	hl_cargo_limiter_uv()

func hl_cargo_limiter_uv():
	if HevLib_pointers:
		cargo_limit = HevLib_pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_EQUIPMENT","cargo_scanner_mineral_display_limit")

var cargo_limit = 15

func hl_cs_compare_for_order(a,b):
	return smooth[a] > smooth[b]

func smoothValue(dict, s):
	.smoothValue(dict,s)
	var sms = smooth.size()
	if sms > 10:
		var top = hl_cs_clear_non_minerals(smooth.keys())
		sms = top.size()
		top.sort_custom(self,"hl_cs_compare_for_order")
		if sms > cargo_limit:
			for a in range(sms - cargo_limit):
				smooth.erase(top[a + cargo_limit])
	return smooth

func hl_cs_clear_non_minerals(arr: Array):
	arr.erase("")
	arr.erase("cargo_space")
	arr.erase("_")
	arr.erase("SHIP")
	arr.erase("CARGO_EQUIPMENT")
	return arr
