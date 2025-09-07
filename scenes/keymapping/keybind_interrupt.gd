extends Node

var actionDict = {}

var actionTypes = []

var current_key_inputs = []
var current_key_data = {}

var is_active_window = true

var single_input_actions = {}

var deadzones = {}

var overrides = load("res://HevLib/scenes/keymapping/data/overrides.gd").get_script_constant_map()

func _ready():
	self.pause_mode = Node.PAUSE_MODE_PROCESS
	var actions = InputMap.get_actions()
	for action in actions:
		if action in overrides.actions_ignore:
			continue
		var act = InputMap.get_action_list(action)
		var deadzone = InputMap.action_get_deadzone(action)
		deadzones.merge({action:deadzone})
		for event in act:
			if event is InputEventKey:
					
				var key = ""
				var is_scancode = true
				var is_physical = true
				if event.scancode == 0:
					is_scancode = false
				if event.physical_scancode == 0:
					is_physical = false
				if is_scancode:
					key = OS.get_scancode_string(event.scancode)
				elif is_physical:
					key = OS.get_scancode_string(event.physical_scancode)
				if not key in single_input_actions.keys():
					single_input_actions.merge({key:[]})
				var current_binds = single_input_actions[key]
				if action in current_binds:
					pass
				else:
					single_input_actions[key].append(action)
			if event is InputEventJoypadMotion:
				var key = "JoyAxis" + str(event.axis)
				if not key in single_input_actions.keys():
					single_input_actions.merge({key:[]})
				var current_binds = single_input_actions[key]
				if action in current_binds:
					pass
				else:
					single_input_actions[key].append(action)
				
			if event is InputEventJoypadButton:
				var key = "JoyButton" + str(event.button_index)
				if not key in single_input_actions.keys():
					single_input_actions.merge({key:[]})
				var current_binds = single_input_actions[key]
				if action in current_binds:
					pass
				else:
					single_input_actions[key].append(action)
				
			if event is InputEventMouseButton:
				var key = "Mouse" + str(event.button_index)
				if not key in single_input_actions.keys():
					single_input_actions.merge({key:[]})
				var current_binds = single_input_actions[key]
				if action in current_binds:
					pass
				else:
					single_input_actions[key].append(action)
				
		
#		breakpoint
		actionDict.merge({action:act})
		for active in act:
			var ck = match_event_type(active)
			for item in ck:
				match item:
					"InputEvent","InputEventWithModifiers":
						pass
					_:
						if item in actionTypes:
							pass
						else:
							actionTypes.append(item)
			InputMap.action_erase_event(action, active)
#	breakpoint

func _physics_process(delta):
	is_active_window = OS.is_window_focused()
	if not is_active_window:
		for item in current_key_data:
			current_key_data[item]["pressed"] = false
		current_key_inputs = []

func _input(event):
	if InputEventAction in event:
		pass
	else:
		var is_key = false
		var is_joy_motion = false
		var is_joy_button = false
		var is_mouse_button = false
	#	var is_mouse_motion = false
	#	var is_mouse = false
		var index = 0
		
		if event is InputEventKey:
			is_key = true
			index += 1
		if event is InputEventJoypadMotion:
			is_joy_motion = true
			index += 1
		if event is InputEventJoypadButton:
			is_joy_button = true
			index += 1
		if event is InputEventMouseButton:
			is_mouse_button = true
			index += 1
	#	if event is InputEventMouse:
	#		is_mouse = true
	#		index += 1
	#	if event is InputEventMouseMotion:
	#		is_mouse_motion = true
		if index >= 1:
			if is_key:
				var key = ""
				var is_scancode = true
				var is_physical = true
				if event.scancode == 0:
					is_scancode = false
				if event.physical_scancode == 0:
					is_physical = false
				if is_scancode:
					key = OS.get_scancode_string(event.scancode)
				elif is_physical:
					key = OS.get_scancode_string(event.physical_scancode)
				if not key in current_key_data.keys():
					current_key_data.merge({key:{}})
				var pressed = event.pressed
				if pressed:
					if key in current_key_inputs:
						pass
					else:
						current_key_inputs.append(key)
				else:
					if key in current_key_inputs:
						var new_array = []
						for item in current_key_inputs:
							if item == key:
								pass
							else:
								new_array.append(item)
						current_key_inputs = new_array
				var echo = event.echo
				if key != "":
					current_key_data[key]["pressed"] = pressed
					current_key_data[key]["echo"] = echo
					current_key_data[key]["type"] = "InputEventKey"
			if is_mouse_button:
				var mouseString = "Mouse" + str(event.button_index)
				if not mouseString in current_key_data.keys():
					current_key_data.merge({mouseString:{}})
				var pressed = event.pressed
				if pressed:
					if mouseString in current_key_inputs:
						pass
					else:
						current_key_inputs.append(mouseString)
				else:
					if mouseString in current_key_inputs:
						var new_array = []
						for item in current_key_inputs:
							if item == mouseString:
								pass
							else:
								new_array.append(item)
						current_key_inputs = new_array
				var doubleclick = event.doubleclick
				current_key_data[mouseString]["pressed"] = pressed
				current_key_data[mouseString]["doubleclick"] = doubleclick
				current_key_data[mouseString]["type"] = "InputEventMouseButton"
			if is_joy_button:
				var joyButtonString = "JoyButton" + str(event.button_index)
				if not joyButtonString in current_key_data.keys():
					current_key_data.merge({joyButtonString:{}})
				var pressed = event.pressed
				if pressed:
					if joyButtonString in current_key_inputs:
						pass
					else:
						current_key_inputs.append(joyButtonString)
				else:
					if joyButtonString in current_key_inputs:
						var new_array = []
						for item in current_key_inputs:
							if item == joyButtonString:
								pass
							else:
								new_array.append(item)
						current_key_inputs = new_array
				current_key_data[joyButtonString]["pressed"] = pressed
				current_key_data[joyButtonString]["type"] = "InputEventJoypadButton"
			if is_joy_motion:
				var joyAxisString = "JoyAxis" + str(event.axis)
				if not joyAxisString in current_key_data.keys():
					current_key_data.merge({joyAxisString:{}})
				var axis = event.axis
				var axis_value = event.axis_value
				
				if abs(axis_value) >= 0.1:
					if joyAxisString in current_key_inputs:
						pass
					else:
						current_key_inputs.append(joyAxisString)
				else:
					if joyAxisString in current_key_inputs:
						var new_array = []
						for item in current_key_inputs:
							if item == joyAxisString:
								pass
							else:
								new_array.append(item)
						current_key_inputs = new_array
				
				current_key_data[joyAxisString]["axis"] = axis
				current_key_data[joyAxisString]["axis_value"] = axis_value
				current_key_data[joyAxisString]["type"] = "InputEventJoypadMotion"
				
	#		breakpoint
			for key in single_input_actions:
				var actions = single_input_actions[key]
				if key in current_key_data:
					for action in actions:
						var act = InputEventAction.new()
						var data = current_key_data[key]
						var pressed = false
						if data["type"] == "InputEventJoypadMotion":
							var deadzone = deadzones[action]
							if data["axis_value"] >= deadzone:
								pressed = true
						else:
							pressed = current_key_data[key]["pressed"]
						act.pressed = pressed
						act.action = action
						Input.parse_input_event(act)
		
		
		
	
	


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
