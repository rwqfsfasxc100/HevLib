extends OptionButton

onready var ring = get_node("/root/Game/TheRing")

var eventNames = {0:"none"}
var justEvents = []
var cnode = ""

var defaultOdditiesEvery = 450
var defaultTestSpecificStoryElement = ""

var busy = false

var focusObject

var use_legacy = false

func _on_SpawnNow_pressed():
	var ev = cnode
	Debug.l("EventDriver: forcing spawn of %s; parameters: legacy [%s]" % [ev,str(use_legacy)])
	if ev == "none" or ev == "":
		ev = justEvents[randi() % justEvents.size()]
		Debug.l("EventDriver: random event, selecting %s" % ev)
	var params = {}
	if use_legacy:
		params["legacy"] = true
	pointers.Events.__spawn_event(ev,ring,params)

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
		get_parent().get_node("HSlider").value = value
		
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
onready var pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")
#const Events = preload("res://HevLib/pointers/Events.gd")
func _on_ClearEvent_pressed():
	
	pointers.Events.__clear_event(cnode,ring)


func _toggle_legacy(how):
	use_legacy = how
