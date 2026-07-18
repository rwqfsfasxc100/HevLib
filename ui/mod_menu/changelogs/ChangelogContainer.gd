extends VBoxContainer

var clearing = false

func parse(path:String,current_page:int,page_size:int,LEFT:Button,RIGHT:Button,refs:Array):
	var pointers = ModLoader._savedObjects[0]
	var header_label = load("res://HevLib/ui/mod_menu/changelogs/labels/version_label.tscn")
	var entry_label = load("res://HevLib/ui/mod_menu/changelogs/labels/changelog_entry.tscn")
	
	var data:Dictionary = pointers.ManifestV2.__parse_changelogs(path)
	
	var size = data.size()
	var offset = (current_page * page_size)
	var max_pages = int(ceil(float(size)/float(page_size))) - 1
	var keys = data.keys()
	LEFT.disabled = current_page < 1
	RIGHT.disabled = current_page > max_pages - 1
	for iv in range(clamp(size - offset,0,page_size)):
		var config = keys[iv + offset]
		var lines = data[config]
		var header = header_label.instance()
		header.text = config
		if not clearing:
			refs.append(header)
			add_child(header)
		for l in lines:
			var label = entry_label.instance()
			var tex = TranslationServer.translate(l)
			label.text = tex
			if not clearing:
				refs.append(label)
				add_child(label)
			yield(CurrentGame.get_tree(),"idle_frame")
		yield(CurrentGame.get_tree(),"idle_frame")
