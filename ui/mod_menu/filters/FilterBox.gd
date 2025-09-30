extends HBoxContainer

#signal changed_tag(tag,change)
#
#func _ready():
#	connect("changed_tag",get_parent().get_parent().get_parent().get_parent(),"update_filters")



var cache_folder = "user://cache/.Mod_Menu_2_Cache/"
var filter_cache_file = "menu_filter_cache.json"
var file = File.new()


func _toggled(button_pressed):
	var toggle = self.name
	file.open(cache_folder + filter_cache_file,File.READ)
	var data = JSON.parse(file.get_as_text(true)).result
	file.close()
	if button_pressed:
		var replace = []
		for item in data:
			if item == toggle:
				pass
			else:
				replace.append(item)
		data = replace
	else:
		if toggle in data:
			pass
		else:
			data.append(toggle)
	file.open(cache_folder + filter_cache_file,File.WRITE)
	file.store_string(JSON.print(data))
	file.close()
