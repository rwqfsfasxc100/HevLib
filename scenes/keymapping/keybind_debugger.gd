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

extends Node

var currentKeyEvents = ""
onready var InputDebugPanel = get_parent().get_parent().get_node("_HevLib_Gamespace_Canvas/MarginContainer/DebugPanel/ScrollContainer/MarginContainer/VBoxContainer/InputDebug")
onready var InputEventDebugPanel = get_parent().get_parent().get_node("_HevLib_Gamespace_Canvas/MarginContainer/DebugPanel/ScrollContainer/MarginContainer/VBoxContainer/inputEventDebug")

var actionDict = {}
var key_actions = []

var action_dict = {}

var inputDebug = false
var inputEventDebug = false

func _ready():
	var actions = InputMap.get_actions()
	var bActionDict = {}
	for action in actions:
		var act = InputMap.get_action_list(action)
		actionDict.merge({action:act})
	InputDebugPanel.visible = inputDebug
	InputEventDebugPanel.visible = inputEventDebug
	key_actions = InputMap.get_actions()
	for action in key_actions:
		action_dict.merge({action:false})


var pressed = false
var eventDevice = 0
var joyButtonIndex = 0
var joyButtonPressure = 0
var joyAxis = 0
var joyAxisValue = 0
var key = ""
var mouseButtonMask = 0
var mousePosition = Vector2(0,0)
var mouseGlobalPosition = Vector2(0,0)
var mouseTilt = Vector2(0,0)
var mousePressure = 0
var mousePenInverted = false
var mouseRelative = Vector2(0,0)
var mouseSpeed = Vector2(0,0)
var mouseFactor = 0
var mouseButtonIndex = 0
var mouseCanceled = false
var mouseDoubleClick = false
var modifierAlt = false
var modifierShift = false
var modifierControl = false
var modifierMeta = false
var modifierCommand = false

func _input(event):
	
	if inputEventDebug:
		ieDebug()
	if inputDebug:
		iDebug(event)
var pointers = ModLoader._savedObjects[0]

var count = 0
func _physics_process(delta):
	count += 1
	if count % 10 == 0:
		count = 0
		inputDebug = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","input_debugger")
		inputEventDebug = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","input_event_debugger")
		var siblingCount = get_parent().get_parent().get_child_count()
		get_parent().get_parent().move_child(get_parent(), siblingCount)
#		get_parent().get_parent().move_child(pointers, siblingCount - 1)
		InputDebugPanel.text = str(currentKeyEvents)
		InputDebugPanel.visible = inputDebug
		InputEventDebugPanel.text = JSON.print(action_dict,"\t")
		InputEventDebugPanel.visible = inputEventDebug



func match_event_type(event):
	var eventType = []
	if event is InputEvent:
		eventType.append("InputEvent")
	if event is InputEventAction:
		eventType.append("InputEventAction")
	if event is InputEventGesture:
		eventType.append("InputEventGesture")
	if event is InputEventJoypadButton:
		eventType.append("InputEventJoypadButton")
	if event is InputEventJoypadMotion:
		eventType.append("InputEventJoypadMotion")
	if event is InputEventKey:
		eventType.append("InputEventKey")
	if event is InputEventMIDI:
		eventType.append("InputEventMIDI")
	if event is InputEventMagnifyGesture:
		eventType.append("InputEventMagnifyGesture")
	if event is InputEventMouse:
		eventType.append("InputEventMouse")
	if event is InputEventMouseButton:
		eventType.append("InputEventMouseButton")
	if event is InputEventMouseMotion:
		eventType.append("InputEventMouseMotion")
	if event is InputEventPanGesture:
		eventType.append("InputEventPanGesture")
	if event is InputEventScreenDrag:
		eventType.append("InputEventScreenDrag")
	if event is InputEventScreenTouch:
		eventType.append("InputEventTouch")
	if event is InputEventWithModifiers:
		eventType.append("InputEventWithModifiers")
	if eventType == null:
		return false
	else:
		return eventType
	
func ieDebug():
	if Input.is_action_pressed("toggle_debug_menus"):
		InputEventDebugPanel.visible = !InputEventDebugPanel.visible
	for evnt in action_dict:
			if Input.is_action_pressed(evnt):
				action_dict[evnt] = true
			else:
				action_dict[evnt] = false

func iDebug(event):
	if Input.is_action_pressed("toggle_debug_menus"):
		InputDebugPanel.visible = !InputDebugPanel.visible
	if not event is InputEventAction:
		var eventAction
		for item in actionDict:
			var does = Input.is_action_pressed(item)
			if does:
				eventAction = item
		var eventTypes = match_event_type(event)
		for eventType in eventTypes:
			if eventType == "InputEvent":
				eventDevice = event.device
			if eventType == "InputEventAction":
				pass
			if eventType == "InputEventGesture":
				pass
			if eventType == "InputEventJoypadButton":
				joyButtonIndex = event.button_index
				joyButtonPressure = event.pressure
			if eventType == "InputEventJoypadMotion":
				joyAxis = event.axis
				joyAxisValue = event.axis_value
			if eventType == "InputEventKey":
				key = OS.get_scancode_string(event.physical_scancode)
			if eventType == "InputEventMIDI":
				pass
			if eventType == "InputEventMagnifyGesture":
				pass
			if eventType == "InputEventMouse":
				mouseButtonMask = event.button_mask
				mousePosition = event.position
				mouseGlobalPosition = event.global_position
			if eventType == "InputEventMouseButton":
				mouseFactor = event.factor
				mouseButtonIndex = event.button_index
				mouseCanceled = event.canceled
				mouseDoubleClick = event.doubleclick
			if eventType == "InputEventMouseMotion":
				mouseTilt = event.tilt
				mousePressure = event.pressure
				mousePenInverted = event.pen_inverted
				mouseRelative = event.relative
				mouseSpeed = event.speed
			if eventType == "InputEventPanGesture":
				pass
			if eventType == "InputEventScreenDrag":
				pass
			if eventType == "InputEventScreenTouch":
				pass
			if eventType == "InputEventWithModifiers":
				modifierAlt = event.alt
				modifierShift = event.shift
				modifierControl = event.control
				modifierMeta = event.meta
				modifierCommand = event.command
		currentKeyEvents = "Device: " + str(eventDevice) + "\nJoyCon Buttons: [ButtonIndex: " + str(joyButtonIndex) + ", Pressure: " + str(joyButtonPressure) + "],\n\tJoypadMotion: [Axis: " + str(joyAxis) + ", AxisValue: " + str(joyAxisValue) + "]\nKey: " + str(key) + "\nMouse Generic: [ButtonMask: " + str(mouseButtonMask) + ", Position: " + str(mousePosition) + ", GlobalPosition: " + str(mouseGlobalPosition) + "],\n\tMouseButtons: [Factor: " + str(mouseFactor) + ", ButtonIndex: " + str(mouseButtonIndex) + ", Canceled: " + str(mouseCanceled) + ", DoubleClick: " + str(mouseDoubleClick) + "],\n\tMouseMotion: [Tilt: " + str(mouseTilt) + ", Pressure: " + str(mousePressure) + ", PenInverted: " + str(mousePenInverted) + ", Relative: " + str(mouseRelative) + ", Speed: " + str(mouseSpeed) + "]\nModifiers: [Alt: " + str(modifierAlt) + ", Shift: " + str(modifierShift) + ", Control: " + str(modifierControl) + ", Meta: " + str(modifierMeta) + ", Command: " + str(modifierCommand) + "]\nAll Inputs: " + str(get_parent().current_key_inputs)
		
		

