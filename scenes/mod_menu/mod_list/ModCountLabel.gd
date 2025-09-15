extends Label

func _process(delta):
	var count = 0
	var listbox = get_node("../../ModList/ScrollContainer/VBoxContainer")
	for node in listbox.get_children():
		if node.visible:
			count += 1
	var txt = TranslationServer.translate("HEVLIB_MODMENU_MODS_VISIBLE")
	
	text = txt % count - 1
