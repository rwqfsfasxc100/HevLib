extends "res://tools/DLClist.gd"

var pointers
#var ManifestV2 = preload("res://HevLib/pointers/ManifestV2.gd")
#var ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")
func _ready():
	grow_horizontal = Control.GROW_DIRECTION_BEGIN
	if get_child_count() >= 1:
		var p = make_label("HEVLIB_DLCLIST_DLC_HEADER")
		add_child(p)
		move_child(p,0)
		
		add_child(make_label("HEVLIB_DLCLIST_MODS_HEADER"))
		
		pass
	pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	if pointers == null:
		yield(get_tree(),"idle_frame")
		pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	var mods = pointers.ManifestV2.__get_mod_data()["mods"]
	var labels = []
	var names = []
	for mod in mods:
		var data = mods[mod]
		if not data["library_information"]["is_library"]:
			labels.append(make_label(data["name"]))
			names.append(data["name"])
		elif data["library_information"]["always_display"] and pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DRIVERS","show_always_display_libraries_in_dlclist"):
			labels.append(make_label(data["name"]))
			names.append(data["name"])
		elif pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DRIVERS","show_all_libraries_in_dlclist"):
			labels.append(make_label(data["name"]))
			names.append(data["name"])
	match pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DRIVERS","dlc_mod_list_sort_order"):
		"alphabetical_ascending":
			descending = true
			labels.sort_custom(self,"sort_alphabetical")
		"alphabetical_descending":
			descending = false
			labels.sort_custom(self,"sort_alphabetical")
		"length_ascending":
			descending = true
			labels.sort_custom(self,"sort_length")
		"length_descending":
			descending = false
			labels.sort_custom(self,"sort_length")
		_:
			descending = false
	for label in labels:
		add_child(label)



func make_label(text):
	
	var l = Label.new()
	l.text = text
	l.align = Label.ALIGN_RIGHT
	
	
	return l

var descending:bool = false

func sort_alphabetical(a, b, index = 0) -> bool: 
	if index >= a.text.length() or index >= b.text.length():
		return descending
	if a.text[index] < b.text[index]: 
		return !descending
	elif a.text[index] == b.text[index]:
		index += 1
		sort_alphabetical(a,b,index)
	return descending

func sort_length(a,b) -> bool:
	if a.text.length() > b.text.length():
		return descending
	if a.text.length() < b.text.length(): 
		return !descending
	elif a.text.length() == b.text.length():
		return sort_alphabetical(a,b,0)
	return descending
