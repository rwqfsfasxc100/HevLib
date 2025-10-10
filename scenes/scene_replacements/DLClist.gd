extends "res://tools/DLClist.gd"

var ManifestV2 = preload("res://HevLib/pointers/ManifestV2.gd")

func _ready():
	grow_horizontal = Control.GROW_DIRECTION_BEGIN
	if get_child_count() >= 1:
		var p = make_label("HEVLIB_DLCLIST_DLC_HEADER")
		add_child(p)
		move_child(p,0)
		
		add_child(make_label("HEVLIB_DLCLIST_MODS_HEADER"))
		
		pass
	var mods = ManifestV2.__get_mod_data()["mods"]
	for mod in mods:
		var data = mods[mod]
		if not data["library_information"]["is_library"]:
			add_child(make_label(data["name"]))



func make_label(text):
	
	var l = Label.new()
	l.text = text
	l.align = Label.ALIGN_RIGHT
	
	
	return l
