extends Node


var ring = null
var busy = false

var defaultOdditiesEvery = 450
var defaultTestSpecificStoryElement = ""

func _ready():
	var timer = load("res://HevLib/scenes/timer/Timer.tscn").instance()
	timer.name = "Timer"
	add_child(timer)
var focusObject
func spawn_event(event,thering: Node):
	ring = thering
	focusObject = CurrentGame.getPlayerShip()
	if focusObject.zone == "rings":
		
		var event_node = ring.get_node_or_null(event)
		if event_node and event_node.has_method("makeAt"):
			var pos = getPos()
			var oddity = event_node.makeAt(pos)
			if oddity is Array:
				for o in oddity:
					if not event in ring.group:
						ring.group[event] = []
					ring.group[event].append(o)
					ring.all_oddities.append(o)
					ring.requestOdditySpawn(o)
			else:
				if not event in ring.group:
					ring.group[event] = []
				ring.group[event].append(oddity)
				ring.all_oddities.append(oddity)
				ring.requestOdditySpawn(oddity)
		
		
		
#		defaultOdditiesEvery = ring.odditiesEvery
#		defaultTestSpecificStoryElement = ring.testSpecificStoryElement
#		ring.odditiesEvery = 0.08
#		ring.testSpecificStoryElement = event
#		startEventTimerNode()


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
		




func startEventTimerNode():
	busy = true
	var timer = get_child(0)
	timer.start_timer(0.09, true)
	

func onTimerComplete():
	
	ring.testSpecificStoryElement = defaultTestSpecificStoryElement
	ring.odditiesEvery = defaultOdditiesEvery
	busy = false
