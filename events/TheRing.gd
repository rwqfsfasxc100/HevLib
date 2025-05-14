extends "res://TheRing.gd"

func _ready():
	image = map.get_data()
	size = image.get_size()
	
	veinImage = veins.get_data()
	veinSize = veinImage.get_size()
	
	var disabled_events = Settings.HevLib["events"]["disabled_events"]
	
	for kid in get_children():
		if kid.name in disabled_events:
			Debug.l("%s is in disabled events list, not adding to playlist" % kid.name)
		else:
			Debug.l("%s is not in disabled events list, adding to playlist" % kid.name)
			if kid.has_method("makeAt") and kid.has_method("canBeAt"):
				playlist.append(kid)
	if not Engine.is_editor_hint():
		CurrentGame.connect("inGameTimePassed", self, "_gameTimeProcess")
