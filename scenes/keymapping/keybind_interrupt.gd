extends Node

var actionDict = {}

var actionTypes = []

var current_key_inputs = []
var current_key_data = {}

var is_active_window = true

var single_input_actions = {}

var deadzones = {}

var key_codes = load("res://HevLib/scenes/keymapping/data/key_events.gd").get_script_constant_map()

onready var vanilla_binds = Settings.cfg.input
onready var key_events = key_codes["KEYS"]
onready var mouse_button_events = key_codes["MOUSEBUTTONS"]
onready var joy_button_events = key_codes["JOYBUTTONS"]
onready var joy_axis_events = key_codes["JOYAXES"]

var overrides = load("res://HevLib/scenes/keymapping/data/overrides.gd").get_script_constant_map()

var FolderAccess = preload("res://HevLib/pointers/FolderAccess.gd")

var INPUT_DRIVER_ACTIVE = false

const ALLOW_KEYBIND_MODIFICATIONS = false

var old_actions = []

var keybind_folder = "user://cache/.HevLib_Cache/Keybinds/"

var key_file = keybind_folder + "keys.txt"
var mouse_file = keybind_folder + "mousebuttons.txt"
var joybutton_file = keybind_folder + "joybuttons.txt"
var joyaxis_file = keybind_folder + "joyaxes.txt"

var file = File.new()

const ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")


func _ready():
	FolderAccess.__check_folder_exists(keybind_folder)
	file.open(key_file,File.WRITE)
	file.store_string("[]")
	file.close()
	file.open(mouse_file,File.WRITE)
	file.store_string("[]")
	file.close()
	file.open(joybutton_file,File.WRITE)
	file.store_string("[]")
	file.close()
	file.open(joyaxis_file,File.WRITE)
	file.store_string("[]")
	file.close()
	INPUT_DRIVER_ACTIVE = ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DRIVERS","use_input_virtualization")
	if ALLOW_KEYBIND_MODIFICATIONS and INPUT_DRIVER_ACTIVE:
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
	
	
	for action_name in key_events:
		var addAction = true
		for m in InputMap.get_actions():
			if m == action_name:
				addAction = false
		if addAction:
			InputMap.add_action(action_name)
		var code = key_events[action_name]
		var key = InputEventKey.new()
		key.scancode = code
		InputMap.action_add_event(action_name, key)
	
	for action_name in mouse_button_events:
		var addAction = true
		for m in InputMap.get_actions():
			if m == action_name:
				addAction = false
		if addAction:
			InputMap.add_action(action_name)
		var code = mouse_button_events[action_name]
		var key = InputEventMouseButton.new()
		key.button_index = code
		InputMap.action_add_event(action_name, key)
	
	for action_name in joy_axis_events:
		var addAction = true
		for m in InputMap.get_actions():
			if m == action_name:
				addAction = false
		if addAction:
			InputMap.add_action(action_name)
		var code = joy_axis_events[action_name]
		var key = InputEventJoypadMotion.new()
		key.axis = code
		InputMap.action_add_event(action_name, key)
	
	for action_name in joy_button_events:
		var addAction = true
		for m in InputMap.get_actions():
			if m == action_name:
				addAction = false
		if addAction:
			InputMap.add_action(action_name)
		var code = joy_button_events[action_name]
		var key = InputEventJoypadButton.new()
		key.button_index = code
		InputMap.action_add_event(action_name, key)
	
	
	
	
	
#	var ac = InputMap.get_actions()
#	breakpoint

func _physics_process(delta):
	if ALLOW_KEYBIND_MODIFICATIONS and INPUT_DRIVER_ACTIVE:
		is_active_window = OS.is_window_focused()
		if not is_active_window:
			for item in current_key_data:
				current_key_data[item]["pressed"] = false
			current_key_inputs = []

func _input(event):
	if ALLOW_KEYBIND_MODIFICATIONS and INPUT_DRIVER_ACTIVE:
		for action in key_events:
			var string = OS.get_scancode_string(key_events[action])
			var does = Input.is_action_just_pressed(action)
			if does:
				current_key_inputs.append(string)
			var neg = Input.is_action_just_released(action)
			if neg:
				if string in current_key_inputs:
					var replace = []
					for key in current_key_inputs:
						if key == string:
							pass
						else:
							replace.append(key)
					current_key_inputs = replace
		for action in mouse_button_events:
			var string = "Mouse " + str(mouse_button_events[action])
			var does = Input.is_action_just_pressed(action)
			if does:
				current_key_inputs.append(string)
			var neg = Input.is_action_just_released(action)
			if neg:
				if string in current_key_inputs:
					var replace = []
					for key in current_key_inputs:
						if key == string:
							pass
						else:
							replace.append(key)
					current_key_inputs = replace
		for action in joy_axis_events:
			var string = "JoyAxis " + str(joy_axis_events[action])
			var does = Input.is_action_just_pressed(action)
			if does:
				current_key_inputs.append(string)
			var neg = Input.is_action_just_released(action)
			if neg:
				if string in current_key_inputs:
					var replace = []
					for key in current_key_inputs:
						if key == string:
							pass
						else:
							replace.append(key)
					current_key_inputs = replace
		for action in joy_button_events:
			var string = "JoyButton " + str(joy_button_events[action])
			var does = Input.is_action_just_pressed(action)
			if does:
				current_key_inputs.append(string)
			var neg = Input.is_action_just_released(action)
			if neg:
				if string in current_key_inputs:
					var replace = []
					for key in current_key_inputs:
						if key == string:
							pass
						else:
							replace.append(key)
					current_key_inputs = replace
		
#		if current_key_inputs.size() >=1:
#			breakpoint
		
		handle_inputs()
		
		
		
		


func handle_inputs():
	for item in vanilla_binds:
		var keys = vanilla_binds[item]
		for key in keys:
			if key in current_key_inputs:
				parse_input(key,item)
	
	
	
	



func parse_input(key: String,input_event: String):
	var event
	var new_inputs = []
	var echo_inputs = []
	var depress_inputs = []
	
	for item in current_key_inputs:
		if item in old_actions:
			pass
		else:
			new_inputs.append(item)
	
	for item in old_actions:
		if item in current_key_inputs:
			if item in new_inputs:
				pass
			else:
				echo_inputs.append(item)
		else:
			depress_inputs.append(item)
	
	
	if key.begins_with("Mouse"):
		var id = key.split(" ")[1]
		event = InputEventMouseButton.new()
		event.button_index = id
		if key in old_actions:
			event.pressed = false
		else:
			event.pressed = true
	elif key.begins_with("JoyButton"):
		var id = key.split(" ")[1]
		event = InputEventJoypadButton.new()
		event.button_index = id
		if key in old_actions:
			event.pressed = false
		else:
			event.pressed = true
	elif key.begins_with("JoyAxis"):
		var id = key.split(" ")[1]
		event = InputEventJoypadMotion.new()
		event.axis = id
		if key in old_actions:
			event.axis_value = 0.0
		else:
			event.axis_value = 1.0
	else:
		event = InputEventKey.new()
		event.scancode = OS.find_scancode_from_string(key)
		if key in old_actions:
			event.pressed = false
		else:
			event.pressed = true
		if key in echo_inputs:
			event.echo = true
		else:
			event.echo = false
#	breakpoint
	
	Input.parse_input_event(event)
	
	
	
	
	old_actions = current_key_inputs







func register_input(event):
	var key_in_list = false
	var is_key = false
	var is_joy_motion = false
	var is_joy_button = false
	var is_mouse_button = false
#	var is_mouse_motion = false
#	var is_mouse = false
	var index = 0
	
	if event is InputEventKey:
		get_viewport().set_input_as_handled()
		is_key = true
		index += 1
	if event is InputEventJoypadMotion:
		get_viewport().set_input_as_handled()
		is_joy_motion = true
		index += 1
	if event is InputEventJoypadButton:
		get_viewport().set_input_as_handled()
		is_joy_button = true
		index += 1
	if event is InputEventMouseButton:
		get_viewport().set_input_as_handled()
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
			if key in single_input_actions:
				key_in_list = true
			if key != "":
				current_key_data[key]["pressed"] = pressed
				current_key_data[key]["scancode"] = event.scancode
				current_key_data[key]["echo"] = echo
				current_key_data[key]["type"] = "InputEventKey"
			file.open(key_file,File.READ_WRITE)
			var txt = JSON.parse(file.get_as_text(true)).result
			if not key in txt:
				txt.append(key)
			file.store_string(JSON.print(txt,"\t"))
			file.close()
		if is_mouse_button:
			var mouseString = "Mouse " + str(event.button_index)
			if not mouseString in current_key_data.keys():
				current_key_data.merge({mouseString:{}})
			var echo = current_key_data[mouseString].get("pressed",false)
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
			var factor = event.factor
			var canceled = event.canceled
			var doubleclick = event.doubleclick
			
			current_key_data[mouseString]["echo"] = echo
			current_key_data[mouseString]["button_index"] = event.button_index
			current_key_data[mouseString]["factor"] = factor
			current_key_data[mouseString]["canceled"] = canceled
			current_key_data[mouseString]["pressed"] = pressed
			current_key_data[mouseString]["doubleclick"] = doubleclick
			current_key_data[mouseString]["type"] = "InputEventMouseButton"
			file.open(mouse_file,File.READ_WRITE)
			var txt = JSON.parse(file.get_as_text(true)).result
			if not mouseString in txt:
				txt.append(mouseString)
			file.store_string(JSON.print(txt,"\t"))
			file.close()
			if mouseString in single_input_actions:
				key_in_list = true
		if is_joy_button:
			var joyButtonString = "JoyButton " + str(event.button_index)
			if not joyButtonString in current_key_data.keys():
				current_key_data.merge({joyButtonString:{}})
			var echo = current_key_data[joyButtonString].get("pressed",false)
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
			current_key_data[joyButtonString]["echo"] = echo
			current_key_data[joyButtonString]["pressed"] = pressed
			current_key_data[joyButtonString]["button_index"] = event.button_index
			current_key_data[joyButtonString]["type"] = "InputEventJoypadButton"
			if joyButtonString in single_input_actions:
				key_in_list = true
			file.open(joybutton_file,File.READ_WRITE)
			var txt = JSON.parse(file.get_as_text(true)).result
			if not joyButtonString in txt:
				txt.append(joyButtonString)
			file.store_string(JSON.print(txt,"\t"))
			file.close()
		if is_joy_motion:
			var joyAxisString = "JoyAxis " + str(event.axis)
			if not joyAxisString in current_key_data.keys():
				current_key_data.merge({joyAxisString:{}})
			var echo = current_key_data[joyAxisString].get("axis_value",0.0)
			var axis_value = event.axis_value
			var axis = event.axis
			if abs(axis_value) >= 0.1:
				if not joyAxisString in current_key_data.keys():
					current_key_data.merge({joyAxisString:{}})
			
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
			if abs(axis_value) >= 0.1:
				current_key_data[joyAxisString]["echo"] = echo
				current_key_data[joyAxisString]["axis"] = axis
				current_key_data[joyAxisString]["axis_value"] = axis_value
				current_key_data[joyAxisString]["type"] = "InputEventJoypadMotion"
				if joyAxisString in single_input_actions:
					key_in_list = true
				file.open(joyaxis_file,File.READ_WRITE)
				var txt = JSON.parse(file.get_as_text(true)).result
				if not joyAxisString in txt:
					txt.append(joyAxisString)
				file.store_string(JSON.print(txt,"\t"))
				file.close()
			else:
				if current_key_data.has(joyAxisString):
					current_key_data[joyAxisString]["axis_value"] = 0.0
	return key_in_list


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


#func _input(event):
#	if current_key_inputs.size() >= 1:
#		breakpoint
#	if ALLOW_KEYBIND_MODIFICATIONS and INPUT_DRIVER_ACTIVE:
#		var key_in_list = false
#		var c = true
#		var l = event.get_script()
#		if l != null:
#			var constants = l.get_script_constant_map()
#			if "hevlib_static" in constants:
#				var value = constants["hevlib_static"]
#				if value:
#					c = false
#
#		if c:
#				register_input(event)
#	#			breakpoint
#
#				pass
##				breakpoint
#				if key_in_list:
#					for key in single_input_actions:
#						var actions = single_input_actions[key]
#						if key in current_key_data:
#							for action in actions:
#								var data = current_key_data[key]
#								var type = data["type"]
#								match type:
#									"InputEventKey":
#										var act = InputEventKey.new()
#										act.pressed = data["pressed"]
#										act.scancode = data["scancode"]
#										act.echo = data["echo"]
#										act.set_script(load("res://HevLib/scenes/keymapping/data/inject.gd"))
#										Input.parse_input_event(act)
#									"InputEventMouseButton":
#										var act = InputEventMouseButton.new()
#										act.button_index = data["button_index"]
#										act.factor = data["factor"]
#										act.canceled = data["canceled"]
#										act.pressed = data["pressed"]
#										act.doubleclick = data["doubleclick"]
#										act.set_script(load("res://HevLib/scenes/keymapping/data/inject.gd"))
#										Input.parse_input_event(act)
#									"InputEventJoypadMotion":
#										var act = InputEventJoypadMotion.new()
#										act.axis = data["axis"]
#										act.axis_value = data["axis_value"]
#										act.set_script(load("res://HevLib/scenes/keymapping/data/inject.gd"))
#										Input.parse_input_event(act)
#									"InputEventJoypadButton":
#										var act = InputEventJoypadButton.new()
#										act.pressed = data["pressed"]
#										act.button_index = data["button_index"]
#										act.set_script(load("res://HevLib/scenes/keymapping/data/inject.gd"))
#										Input.parse_input_event(act)
				
			
			
		
