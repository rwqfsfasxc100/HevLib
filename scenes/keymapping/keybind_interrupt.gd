extends Node

var actionDict = {}

var inputDebug = false
#
#func _ready():
#	if inputDebug:
#		var actions = InputMap.get_actions()
#		var bActionDict = {}
#		for action in actions:
#			var act = InputMap.get_action_list(action)
#			actionDict.merge({action:act})
#			for active in act:
#				InputMap.action_erase_event(action, active)
			

var currentKeyEvents = ""
onready var InputDebugPanel = get_parent().get_node("_HevLib_Gamespace_Canvas/MarginContainer/DebugPanel/ScrollContainer/MarginContainer/VBoxContainer/InputDebug")
	
func _ready():
	InputDebugPanel.visible = inputDebug

func _process(delta):
	inputDebug = Settings.HevLib["debug"]["input_debugger"]
	var siblingCount = get_parent().get_child_count()
	get_parent().move_child(self, siblingCount)
	InputDebugPanel.text = str(currentKeyEvents)
	InputDebugPanel.visible = inputDebug
		

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
	if inputDebug:
		if Input.is_action_just_pressed("toggle_debug_menus"):
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
			currentKeyEvents = "Device: " + str(eventDevice) + "\nJoyCon Buttons: [ButtonIndex: " + str(joyButtonIndex) + ", Pressure: " + str(joyButtonPressure) + "],\n\tJoypadMotion: [Axis: " + str(joyAxis) + ", AxisValue: " + str(joyAxisValue) + "]\nKey: " + str(key) + "\nMouse Generic: [ButtonMask: " + str(mouseButtonMask) + ", Position: " + str(mousePosition) + ", GlobalPosition: " + str(mouseGlobalPosition) + "],\n\tMouseButtons: [Factor: " + str(mouseFactor) + ", ButtonIndex: " + str(mouseButtonIndex) + ", Canceled: " + str(mouseCanceled) + ", DoubleClick: " + str(mouseDoubleClick) + "],\n\tMouseMotion: [Tilt: " + str(mouseTilt) + ", Pressure: " + str(mousePressure) + ", PenInverted: " + str(mousePenInverted) + ", Relative: " + str(mouseRelative) + ", Speed: " + str(mouseSpeed) + "]\nModifiers: [Alt: " + str(modifierAlt) + ", Shift: " + str(modifierShift) + ", Control: " + str(modifierControl) + ", Meta: " + str(modifierMeta) + ", Command: " + str(modifierCommand) + "]"

			
			
			
			
	#		if "InputEventKey" in eventType:
	#			var scancode = null
	##			scancode = OS.keyboard_get_scancode_from_physical(event.scancode)
	##			if scancode == null:
	#			scancode = OS.keyboard_get_scancode_from_physical(event.physical_scancode)
	#			var label = OS.get_scancode_string(scancode) + " (" + str(scancode) + ")"
	#			var pressed = event.pressed
	#			if pressed and not label in currentKeyEvents:
	#				currentKeyEvents.append(label)
	#			if not pressed and label in currentKeyEvents:
	#				var repl = []
	#				for it in currentKeyEvents:
	#					if not it == label:
	#						repl.append(it)
	#				currentKeyEvents = repl
	#		get_viewport().set_input_as_handled()
		

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
	
	
	
