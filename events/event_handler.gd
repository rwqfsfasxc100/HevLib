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

const default_parameter_dict = {}
func spawn_event(event,thering: Node,parameters : Dictionary = {}):
	if thering == null:
		Debug.l("No ring object specified, returning")
		return
	ring = thering
	focusObject = CurrentGame.getPlayerShip()
	if focusObject.zone == "rings":
		var tree = ring.get_tree()
		var event_node = ring.get_node_or_null(event)
		if event_node and event_node.has_method("canBeAt") and event_node.has_method("makeAt"):
			var pos = getPos(parameters)
			event_node.canBeAt(pos)
			var oddity = event_node.makeAt(pos)
			if oddity and ring.has_method("request_event"):
				ring.request_event(oddity, event)
		
		
		
#		defaultOdditiesEvery = ring.odditiesEvery
#		defaultTestSpecificStoryElement = ring.testSpecificStoryElement
#		ring.odditiesEvery = 0.08
#		ring.testSpecificStoryElement = event
#		startEventTimerNode()




func getPos(params : Dictionary):
	
	var x_direction = clamp(params.get("x_direction",rand_range( - 1, 1)),-1,1)
	var y_direction = clamp(params.get("y_direction",rand_range( - 1, 1)),-1,1)
	
	var spawnDirectionScale = params.get("spawn_direction_scale",0.75)
	var odditySpawnRadiusMin = params.get("oddity_spawn_radius_min",24000)
	var odditySpawnRadiusMinCutscene = params.get("oddity_spawn_radius_min_cutscene",6000)
	var odditySpawnRadiusMax = params.get("oddity_spawn_radius_max",38000)
	var odditySpawnRadiusSafemax = params.get("oddity_spawn_radius_safe_max",80000)
	var odditySpawnFailures = params.get("oddity_spawn_failures",0)
	var odditySpawnRadiusSafemaxSteps = params.get("oddity_spawn_radius_safe_max_steps",40)
	
	if Tool.claim(focusObject):
		
		var cutscene = ("cutscene" in focusObject and focusObject.cutscene) and ("fastTravelDirection" in focusObject and focusObject.fastTravelDirection < 0)
		var focusPoint = focusObject.global_position
		var randomVector = Vector2(x_direction,y_direction).normalized()
		var directionVector = focusObject.linear_velocity.normalized() * spawnDirectionScale
		var dirvec = (randomVector + directionVector).normalized()
		if dirvec.length() < 0.9:
			dirvec = randomVector
		var oRangeMin = odditySpawnRadiusMin if not cutscene else odditySpawnRadiusMinCutscene
		var failBasedMax = clamp(float(odditySpawnFailures) / float(odditySpawnRadiusSafemaxSteps), 0, 1)
		var oRangeMax = lerp(odditySpawnRadiusMax, odditySpawnRadiusSafemax, failBasedMax)
		var oddityFocusOffset = dirvec * rand_range(oRangeMin, oRangeMax)
		
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
