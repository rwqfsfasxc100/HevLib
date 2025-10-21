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

var focusObject

func _on_SpawnNow_pressed():
	if busy == false:
		if cnode == "none" or cnode == "":
			cnode = ""
			ring.testSpecificStoryElement = cnode
			ring.odditiesEvery = 0.1
			startEventTimerNode()
		else:
			Events.__spawn_event(cnode,ring)
				

var spawnDirectionScale = 0.75
var odditySpawnRadiusMin = 24000
var odditySpawnRadiusMinCutscene = 6000
var odditySpawnRadiusMax = 38000
var odditySpawnRadiusSafemax = 80000
var odditySpawnFailures = 0
var odditySpawnRadiusSafemaxSteps = 40

func getPos():
	if Tool.claim(focusObject):
		var cutscene = ("cutscene" in focusObject and focusObject.cutscene) and ("fastTravelDirection" in focusObject and focusObject.fastTravelDirection < 0)
		var focusPoint = focusObject.global_position
		var randomVector = Vector2(rand_range( - 1, 1), rand_range( - 1, 1)).normalized()
		var directionVector = focusObject.linear_velocity.normalized() * spawnDirectionScale
		var dirvec = (randomVector + directionVector).normalized()
		if dirvec.length() < 0.9:
			dirvec = randomVector
		var oddityFocusOffset = dirvec * rand_range(odditySpawnRadiusMin if not cutscene else odditySpawnRadiusMinCutscene, lerp(odditySpawnRadiusMax, odditySpawnRadiusSafemax, clamp(float(odditySpawnFailures) / float(odditySpawnRadiusSafemaxSteps), 0, 1)))
		
		var oddityPoint = focusPoint + oddityFocusOffset
		Tool.release(focusObject)
		return CurrentGame.globalCoords(oddityPoint)
		

func _ready():
	focusObject = CurrentGame.getPlayerShip()
	if not ring == null:
		defaultTestSpecificStoryElement = ring.testSpecificStoryElement
		defaultOdditiesEvery = ring.odditiesEvery
		var value = defaultOdditiesEvery
		
		get_parent().get_node("HBoxContainer/Timer").text = "%s s" % value
		
		
		addEvents()
var event_objects = {}
func addEvents():
	
	var events = ring.get_children()
	var indx = 1
	for evnt in events:
		var ename = evnt.name
		eventNames.merge({indx:ename})
		event_objects.merge({ename:evnt})
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

const Events = preload("res://HevLib/pointers/Events.gd")
func _on_ClearEvent_pressed():
	
	Events.__clear_event(cnode,ring)
