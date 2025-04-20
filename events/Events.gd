extends OptionButton

onready var ring = get_node("/root/Game/TheRing")

var eventNames = {0:"none"}
var justEvents = []
var cnode = ""

var defaultOdditiesEvery = 450
var defaultTestSpecificStoryElement = ""

var busy = false

var sliderOdditiesEvery = 450
var sliderValue = 0

func _on_SpawnNow_pressed():
	if busy == false:
		if cnode == "none":
			cnode = ""
		ring.testSpecificStoryElement = cnode
		ring.odditiesEvery = 0.1
		startEventTimerNode()
	
func _ready():
	if not ring == null:
		defaultTestSpecificStoryElement = ring.testSpecificStoryElement
		defaultOdditiesEvery = ring.odditiesEvery
		var value = defaultOdditiesEvery
		
		get_parent().get_node("HBoxContainer/Timer").text = "%s s" % value
		
		
		addEvents()
	
func addEvents():
	
	var events = ring.get_children()
	var indx = 1
	for evnt in events:
		var ename = evnt.name
		eventNames.merge({indx:ename})
		justEvents.append(ename)
		indx += 1
	for event in eventNames:
		var evnt = eventNames.get(event)
		add_item(evnt)
	
	


func _on_HSlider_value_changed(value):
	defaultOdditiesEvery = value
	ring.odditiesEvery = value
	get_parent().get_node("HBoxContainer/Timer").text = "%s s" % value


func _on_Events_item_selected(index):
	for event in eventNames:
		if event == index:
			cnode = eventNames.get(index)
	
	
func startEventTimerNode():
	busy = true
	var timer = $Timer
	timer.start()
	

func _timer_complete():
	
	ring.testSpecificStoryElement = defaultTestSpecificStoryElement
	ring.odditiesEvery = defaultOdditiesEvery
	busy = false
