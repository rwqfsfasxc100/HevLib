extends ScrollContainer

onready var ring = get_node("/root/Game/TheRing")

var all_events = {}

func _ready():
	
	var events = ring.get_children()
	for evnt in events:
		var ename = evnt.name
		var edict = {ename:true}
		all_events.merge(edict)
	var selector_button = load("res://HevLib/events/EventSelector.tscn")
	for event in all_events:
		var btn = selector_button.instance()
		btn.text = event
		btn.name = event
		btn.event = event
		$VBoxContainer.add_child(btn)
