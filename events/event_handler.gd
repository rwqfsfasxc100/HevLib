# [license]
# 3-Clause BSD NON-AI License
# 
# Copyright 2026 __hev (Benjamin Buckhurst)
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.
# 
# 4. The source code and the binary form, and any modifications made to them may not be used for the purpose of input data, the training of, or improvment of machine learning algorithms,
# including but not limited to artificial intelligence, natural language processing, or data mining. This condition applies to any derivatives,
# modifications, or updates based on the Software code. Any usage of the source code or the binary form in an AI-training dataset is considered a breach of this License.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# [/license]

var ring = null
var busy = false

var defaultOdditiesEvery = 450
var defaultTestSpecificStoryElement = ""

var focusObject
const default_parameter_dict = {}
func spawn_event(event : String,thering : Node,parameters : Dictionary = {}):
	if not busy:
		busy = true
		if thering == null:
			Debug.l("EventDriver: No ring object specified, returning")
			return
		ring = thering
		if parameters.get("legacy",false):
			var counter = ring.oddityCounter
			ring.oddityCounter = 0x0FFFFFFF
			ring.testSpecificStoryElement = event
			yield(ring.get_tree().create_timer(0.1),"timeout")
			ring.testSpecificStoryElement = ""
			ring.oddityCounter = counter
		elif parameters.get("inject",false):
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
						Debug.n("HevLib EventDriver: injecting oddity %s" % event)
		else:
			focusObject = CurrentGame.getPlayerShip()
			if focusObject.zone == "rings":
				var tree = ring.get_tree()
				var event_node = ring.get_node_or_null(event)
				if event_node and event_node.has_method("canBeAt") and event_node.has_method("makeAt"):
					var pos = getPos(parameters)
					event_node.canBeAt(pos)
					var oddity = event_node.makeAt(pos)
					
					var randomOddityKey = ""
					if oddity:
#						if ring.has_method("oddity_spawning"):
#							ring.oddity_spawning(event, oddity)
						ring.addNearbyOddity(event, oddity, pos)
						if oddity is Array:
							for o in oddity:
								o.connect("tree_entered", ring, "forcedOddityConfirmed", [randomOddityKey])
						else:
							oddity.connect("tree_entered", ring, "forcedOddityConfirmed", [randomOddityKey])
						ring.unspawnedOddities[randomOddityKey] = oddity
						ring.unspawnedOdditiesLocation[randomOddityKey] = pos
						Debug.n("HevLib EventDriver: force spawning oddity %s" % event)
		busy = false
		

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
		var failBasedMax = clamp(float(odditySpawnFailures) / float(odditySpawnRadiusSafemaxSteps), 0, 1)
		var oRangeMax = lerp(odditySpawnRadiusMax, odditySpawnRadiusSafemax, failBasedMax)
		var oddityFocusOffset = dirvec * rand_range(odditySpawnRadiusMin if not cutscene else odditySpawnRadiusMinCutscene, lerp(odditySpawnRadiusMax, odditySpawnRadiusSafemax, clamp(float(odditySpawnFailures) / float(odditySpawnRadiusSafemaxSteps), 0, 1)))
		
		var oddityPoint = focusPoint + oddityFocusOffset
		Tool.release(focusObject)
		return CurrentGame.globalCoords(oddityPoint)
		



func _ready():
	var timer = load("res://HevLib/scenes/timer/Timer.tscn").instance()
	timer.name = "Timer"
	add_child(timer)

func startEventTimerNode():
	busy = true
	var timer = get_child(0)
	timer.start_timer(0.09, true)
	

func onTimerComplete():
	
	ring.testSpecificStoryElement = defaultTestSpecificStoryElement
	ring.odditiesEvery = defaultOdditiesEvery
	busy = false
