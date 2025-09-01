extends ScrollContainer

onready var ring = get_node("/root/Game/TheRing")

var all_events = {}

func _process(delta):
	get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().selected_events = all_events

func _ready():
	var disabled_events = Settings.HevLib["events"]["disabled_events"]
	var event_names = []
	for item in ring.get_children():
		event_names.append(item.name)
	var events = event_names
	for evnt in events:
		var does = true
		if evnt in disabled_events:
			does = false
		var edict = {evnt:does}
		all_events.merge(edict)
	var selector_button = load("res://HevLib/events/EventSelector.tscn")
	for event in all_events:
		var btn = selector_button.instance()
		if event in disabled_events:
			btn.pressed = false
		btn.text = event
		btn.name = event
		btn.event = event
		$VBoxContainer.add_child(btn)
