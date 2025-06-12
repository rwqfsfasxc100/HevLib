extends "res://TheRing.gd"

var event_names = []

var FolderAccess = preload("res://HevLib/pointers/FolderAccess.gd")

var cache_folder = "user://cache/.HevLib_Cache/"

func _ready():
	image = map.get_data()
	size = image.get_size()
	
	veinImage = veins.get_data()
	veinSize = veinImage.get_size()
	
	var disabled_events = Settings.HevLib["events"]["disabled_events"]
	var write_events = Settings.HevLib["events"]["write_events"]
	
	for kid in get_children():
		var kidName = kid.name
		event_names.append(kidName)
		if kidName in disabled_events:
			Debug.l("%s is in disabled events list, not adding to playlist" % kidName)
		else:
			Debug.l("%s is not in disabled events list, adding to playlist" % kidName)
			if kid.has_method("makeAt") and kid.has_method("canBeAt"):
				playlist.append(kid)
	if not Engine.is_editor_hint():
		CurrentGame.connect("inGameTimePassed", self, "_gameTimeProcess")
	if write_events:
		var string = ""
		for event in event_names:
			if string == "":
				string = event
			else:
				string = string + "\n" + event
		FolderAccess.__check_folder_exists(cache_folder)
		var file = File.new()
		file.open(cache_folder + "current_events.txt",File.WRITE)
		file.store_string(string)
		file.close()
