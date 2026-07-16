extends OptionButton

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

onready var ring = get_node("/root/Game/TheRing")

var eventNames = {0:"none"}
var justEvents = []
var cnode = ""

var defaultOdditiesEvery = 450
var defaultTestSpecificStoryElement = ""

var busy = false

var focusObject

var use_legacy = false
var use_inject = false

var clear_related_poi = true
var clear_in_cargo = false

func _on_SpawnNow_pressed():
	var ev = cnode
	Debug.l("EventDriver: forcing spawn of %s; parameters: legacy [%s]" % [ev,str(use_legacy)])
	if ev == "none" or ev == "":
		ev = justEvents[randi() % justEvents.size()]
		Debug.l("EventDriver: random event, selecting %s" % ev)
	var params = {}
	if use_legacy:
		params["legacy"] = true
	if use_inject:
		params["spawn_now"] = true
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
var pointers = ModLoader._savedObjects[0]


func _on_ClearEvent_pressed():
	
	pointers.Events.__clear_event(cnode,ring,clear_related_poi,clear_in_cargo)

onready var legacy_button = get_node_or_null(NodePath("../Toggles/Legacy"))
onready var inject_button = get_node_or_null(NodePath("../Toggles/Inject"))
func _toggle_legacy(how):
	use_legacy = how
	if how:
		inject_button.pressed = false
		use_inject = false


func _on_Inject_toggled(how):
	use_inject = how
	if how:
		legacy_button.pressed = false
		use_legacy = false


func _on_ClearPOI_toggled(how):
	clear_related_poi = how


func _on_ClearInCargo_toggled(how):
	clear_in_cargo = how
