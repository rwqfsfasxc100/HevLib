extends Node

var zone = ""
var ring = null
var busy = false

var defaultOdditiesEvery = 450
var defaultTestSpecificStoryElement = ""

func _ready():
	var timer = load("res://HevLib/scenes/timer/Timer.tscn").instance()
	timer.name = "Timer"
	add_child(timer)

func _process(delta):
	var ship = CurrentGame.getPlayerShip()
	if not ship == null:
		zone = ship.zone
	else:
		zone = ""
	
	
func spawn_event(event):
	if zone == "rings" and not busy:
		ring = get_node("/root/Game/TheRing")
		defaultOdditiesEvery = ring.odditiesEvery
		defaultTestSpecificStoryElement = ring.testSpecificStoryElement
		ring.odditiesEvery = 0.08
		ring.testSpecificStoryElement = event
		startEventTimerNode()
	
func startEventTimerNode():
	busy = true
	var timer = get_child(0)
	timer.start_timer(0.09, true)
	

func onTimerComplete():
	
	ring.testSpecificStoryElement = defaultTestSpecificStoryElement
	ring.odditiesEvery = defaultOdditiesEvery
	busy = false
