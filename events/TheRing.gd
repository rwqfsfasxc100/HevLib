extends "res://TheRing.gd"

var event_names = []

func _ready():
	image = map.get_data()
	size = image.get_size()
	
	veinImage = veins.get_data()
	veinSize = veinImage.get_size()
	
	var disabled_events = Settings.HevLib["events"]["disabled_events"]
	
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
