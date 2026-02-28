extends Node

var actionDict = {}

var actionTypes = []

var current_key_inputs = {}
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
onready var pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")
#var FolderAccess = preload("res://HevLib/pointers/FolderAccess.gd")

var INPUT_DRIVER_ACTIVE = true

const ALLOW_KEYBIND_MODIFICATIONS = false

var old_actions = []

var keybind_folder = "user://cache/.HevLib_Cache/Keybinds/"

var file = File.new()

func _ready():
	pointers.FolderAccess.__check_folder_exists(keybind_folder)
	INPUT_DRIVER_ACTIVE = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","use_input_virtualization")
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
					var key = "JoyAxis " + str(event.axis)
					if not key in single_input_actions.keys():
						single_input_actions.merge({key:[]})
					var current_binds = single_input_actions[key]
					if action in current_binds:
						pass
					else:
						single_input_actions[key].append(action)
					
				if event is InputEventJoypadButton:
					var key = "JoyButton " + str(event.button_index)
					if not key in single_input_actions.keys():
						single_input_actions.merge({key:[]})
					var current_binds = single_input_actions[key]
					if action in current_binds:
						pass
					else:
						single_input_actions[key].append(action)
					
				if event is InputEventMouseButton:
					var key = "Mouse " + str(event.button_index)
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
				var ck = pointers.Keymapping.__match_event_type(active)
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
	
	var v = InputEventKey.new()
	v.scancode = OS.find_scancode_from_string("F10")
	InputMap.action_add_event("debugger", v)

func _physics_process(delta):
	if ALLOW_KEYBIND_MODIFICATIONS and INPUT_DRIVER_ACTIVE:
		is_active_window = OS.is_window_focused()
		if not is_active_window:
			for item in current_key_data:
				current_key_data[item]["pressed"] = false
			current_key_inputs.clear()

func _input(event):
	if ALLOW_KEYBIND_MODIFICATIONS and INPUT_DRIVER_ACTIVE:
		handle_raw_inputs(event)
		if ("W" in current_key_inputs):
			if "Shift" in current_key_inputs:
				Input.action_press("autopilot_up")
				if Input.is_action_pressed("ship_forward"):
					Input.action_release("ship_forward")
			else:
				Input.action_press("ship_forward")
				if Input.is_action_pressed("autopilot_up"):
					Input.action_release("autopilot_up")
		else:
			if Input.is_action_pressed("ship_forward"):
				Input.action_release("ship_forward")
			if Input.is_action_pressed("autopilot_up"):
				Input.action_release("autopilot_up")
		
		
		
		




func handle_raw_inputs(event):
	var t1 = OS.get_ticks_usec()
	if event is InputEventKey:
		var string = ""
		if event.scancode != 0:
			string = OS.get_scancode_string(event.scancode)
		elif event.physical_scancode != 0:
			string = OS.get_scancode_string(event.physical_scancode)
		if !event.echo:
			if event.pressed and not string in current_key_inputs:
				current_key_inputs[string] = 1.0
			elif string in current_key_inputs:
				current_key_inputs.erase(string)
	
	if event is InputEventMouseButton:
		var string = "Mouse " + str(event.button_index)
		if event.pressed and not string in current_key_inputs:
			current_key_inputs[string] = 1.0
		elif string in current_key_inputs:
			current_key_inputs.erase(string)
	
	
	if event is InputEventJoypadMotion:
		var av = event.axis_value
		var sv = sign(av)
		var string = "JoyAxis " + str(event.axis * sv)
		var strength = stepify(av * sv,0.05)
		if strength > 0.095 and (not string in current_key_inputs or (string in current_key_inputs and current_key_inputs[string] != strength)):
			current_key_inputs[string] = strength
		elif string in current_key_inputs:
			current_key_inputs.erase(string)
	
	if event is InputEventJoypadButton:
		var string = "JoyButton " + str(event.button_index)
		if event.pressed and not string in current_key_inputs:
			current_key_inputs[string] = 1.0
		elif string in current_key_inputs:
			current_key_inputs.erase(string)
	
	var t2 = OS.get_ticks_usec()
	var diff = t2-t1
	
	Debug.l(str(current_key_inputs) + " in " + str(diff))
