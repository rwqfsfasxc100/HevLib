extends "res://tools/DLClist.gd"

var pointers = ModLoader._savedObjects[0]

func _ready():
	grow_horizontal = Control.GROW_DIRECTION_BEGIN
	if get_child_count() >= 1:
		var p = hl_dlc_make_label("HEVLIB_DLCLIST_DLC_HEADER")
		add_child(p)
		move_child(p,0)
		
		add_child(hl_dlc_make_label("HEVLIB_DLCLIST_MODS_HEADER"))
		
	var mods = pointers.ManifestV2.__get_mod_data()["mods"]
	var labels = []
	var names = []
	var show_always_display_libraries_in_dlclist = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DRIVERS","show_always_display_libraries_in_dlclist")
	var show_all_libraries_in_dlclist = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DRIVERS","show_all_libraries_in_dlclist")
	var dlc_mod_list_sort_order = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DRIVERS","dlc_mod_list_sort_order")
	for mod in mods:
		var data = mods[mod]
		if not data["library_information"]["is_library"]:
			labels.append(hl_dlc_make_label(data["name"]))
			names.append(data["name"])
		elif data["library_information"]["always_display"] and show_always_display_libraries_in_dlclist:
			labels.append(hl_dlc_make_label(data["name"]))
			names.append(data["name"])
		elif show_all_libraries_in_dlclist:
			labels.append(hl_dlc_make_label(data["name"]))
			names.append(data["name"])
	match dlc_mod_list_sort_order:
		"alphabetical_ascending":
			descending = true
			labels.sort_custom(self,"hl_dlc_sort_alphabetical")
		"alphabetical_descending":
			descending = false
			labels.sort_custom(self,"hl_dlc_sort_alphabetical")
		"length_ascending":
			descending = true
			labels.sort_custom(self,"hl_dlc_sort_length")
		"length_descending":
			descending = false
			labels.sort_custom(self,"hl_dlc_sort_length")
		_:
			descending = false
	for label in labels:
		add_child(label)



func hl_dlc_make_label(text):
	
	var l = Label.new()
	l.text = text
	l.align = Label.ALIGN_RIGHT
	
	
	return l

var descending:bool = false

func hl_dlc_sort_alphabetical(a, b, index = 0) -> bool: 
	if index >= a.text.length() or index >= b.text.length():
		return descending
	if a.text[index] < b.text[index]: 
		return !descending
	elif a.text[index] == b.text[index]:
		index += 1
		hl_dlc_sort_alphabetical(a,b,index)
	return descending

func hl_dlc_sort_length(a,b) -> bool:
	if a.text.length() > b.text.length():
		return descending
	if a.text.length() < b.text.length(): 
		return !descending
	elif a.text.length() == b.text.length():
		return hl_dlc_sort_alphabetical(a,b,0)
	return descending
