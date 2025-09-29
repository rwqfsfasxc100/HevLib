extends Label


var count = 0

func _process(delta):
	var vc = 0
	var listbox = get_node("../../ModList/ScrollContainer/VBoxContainer")
	for node in listbox.get_children():
		if node.visible:
			vc += 1
	count = vc
	var txt = TranslationServer.translate("HEVLIB_MODMENU_MODS_VISIBLE")
	
	text = txt % int(count - 1)
