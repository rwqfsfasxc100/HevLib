extends ScrollContainer

onready var ring = get_node("/root/Game/TheRing")
onready var pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")
var all_events = {}
#const ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")
#func _process(delta):
#	get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().selected_events = all_events
onready var list = $VBoxContainer
onready var enableAllButton = get_node_or_null(NodePath("../HBoxContainer/EnableAll"))
onready var disableAllButton = get_node_or_null(NodePath("../HBoxContainer/DisableAll"))
func _ready():
	enableAllButton.connect("pressed",self,"enableAll")
	disableAllButton.connect("pressed",self,"disableAll")
	
#	var de = ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_EVENTS","disabled_events")
#	if de == null:
#		
	var disabled_events = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_EVENTS","disabled_events")
	if disabled_events == null:
		pointers.ConfigDriver.__store_value("HevLib","HEVLIB_CONFIG_SECTION_EVENTS","disabled_events",[])
		disabled_events = []
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
		list.add_child(btn)

func enableAll():
	for c in list.get_children():
		c.pressed = true
	pointers.ConfigDriver.__store_value("HevLib","HEVLIB_CONFIG_SECTION_EVENTS","disabled_events",[])
func disableAll():
	var arr = []
	for c in list.get_children():
		c.pressed = false
		arr.append(c.event)
	pointers.ConfigDriver.__store_value("HevLib","HEVLIB_CONFIG_SECTION_EVENTS","disabled_events",arr)
