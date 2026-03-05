extends Node

var actionDict = {}

var actionTypes = []

var current_key_inputs = []
var current_joy_strength = {}

var is_active_window = true

var single_input_actions = {}

var deadzones = {}

var key_codes = load("res://HevLib/scenes/keymapping/data/key_events.gd").get_script_constant_map()

onready var vanilla_binds = Settings.cfg.input
onready var key_events = key_codes["KEYS"]
onready var mouse_button_events = key_codes["MOUSEBUTTONS"]
onready var joy_button_events = key_codes["JOYBUTTONS"]
onready var joy_axis_events = key_codes["JOYAXES"]
onready var adjustments = key_codes["ADJUSTMENT"]

var overrides = load("res://HevLib/scenes/keymapping/data/overrides.gd").get_script_constant_map()
onready var pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")


onready var compiler = preload("res://HevLib/scenes/keymapping/compile_keymap.gd").new(pointers)

var INPUT_DRIVER_ACTIVE = true

const ALLOW_KEYBIND_MODIFICATIONS = false

var old_actions = []

var keybind_folder = "user://cache/.HevLib_Cache/Keybinds/"
var vanilla_binds_file = "user://cfg/Vanilla_Binds.cfg"

var file = File.new()

var input_handle = null

# NEEDS TO COMBINE BOTH COMPILATION AND DETECTION METHODS
# DECIDE WHICH TO USE BASED ON WHETHER THE CONTROL IS INDIVIDUAL OR CONTINUOUS

# BEFOREHAND, TRY RELEASING ACTION AS WELL AS SETTING AS HANDLED - AND IT WORKS!

func _ready():
	pointers.FolderAccess.__check_folder_exists(keybind_folder)
	self.pause_mode = Node.PAUSE_MODE_PROCESS
	self.process_priority = -32768
	INPUT_DRIVER_ACTIVE = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","use_input_virtualization")
	if ALLOW_KEYBIND_MODIFICATIONS and INPUT_DRIVER_ACTIVE:
		var actions = InputMap.get_actions()
		var sortedAv = pointers.Keymapping.__get_built_in_action_list()
		var vb = pointers.FileAccess.__config_parse(vanilla_binds_file)
		file.open(keybind_folder + "defined_control_configs.json",File.READ)
		var mb = JSON.parse(file.get_as_text()).result
		
		
		var ignore_builtin = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","input_virtualization_ignore_builtin")
		
#		print(str(actions),"\n\n",str(pointers.Keymapping.__get_vanilla_action_list()))
		for action in actions:
#			if ignore_builtin and action in sortedAv:
#				continue
			var act = InputMap.get_action_list(action)
			for active in act:
				InputMap.action_erase_event(action, active)
			if action in vb:
				pointers.Keymapping.__create_input_event(action,vb[action]["inputs"],vb[action]["opts"])
			if action in mb:
				pointers.Keymapping.__create_input_event(action,mb[action]["controls"],mb[action]["opts"])
		compile()
		pointers.ConfigDriver.__establish_connection("compile",self,"input")
		
#		var v = InputEventKey.new()
#		v.scancode = OS.find_scancode_from_string("F10")
#		InputMap.action_add_event("debugger",v)
		

func compile():
	var active_script = compiler.compile_keymap()
	file.open(keybind_folder + "handle_input.gd",File.WRITE)
	file.store_string(active_script)
	file.close()
	input_handle = null
	
	input_handle = ResourceLoader.load(keybind_folder + "handle_input.gd","",true).new(pointers)
	

func _physics_process(delta):
	if ALLOW_KEYBIND_MODIFICATIONS and INPUT_DRIVER_ACTIVE:
		is_active_window = OS.is_window_focused()
		if not is_active_window:
			current_key_inputs.clear()
			bit_index = 0
			scancode_order.clear()

func _input(event):
	if ALLOW_KEYBIND_MODIFICATIONS and INPUT_DRIVER_ACTIVE:
#		event.set_script(load("res://HevLib/scenes/keymapping/data/inject.gd"))
		if handle_raw_inputs(event):
#			event.checker = true
#			get_tree().set_input_as_handled()
			Debug.l("Current Index: " + str(current_key_inputs))
			input_handle.handle_input(current_key_inputs, event)
		
#		if ("W" in current_key_inputs):
#			if "Shift" in current_key_inputs:
#				Input.action_press("autopilot_up")
#				if Input.is_action_pressed("ship_forward"):
#					Input.action_release("ship_forward")
#			else:
#				Input.action_press("ship_forward")
#				if Input.is_action_pressed("autopilot_up"):
#					Input.action_release("autopilot_up")
#		else:
#			if Input.is_action_pressed("ship_forward"):
#				Input.action_release("ship_forward")
#			if Input.is_action_pressed("autopilot_up"):
#				Input.action_release("autopilot_up")
		
		
#		var t1 = OS.get_ticks_usec()
#		bit_index = bit_index | 12
#		var a = bit_index
#		bit_index = bit_index | 16
#		var b = bit_index
#		var s = bit_index & 12 == 12
#		var h = bit_index & 14 == 14
#		bit_index = bit_index | 14
#		var b2 = bit_index
#		var h2 = bit_index & 14 == 14
#
#		bit_index = bit_index ^ 12
#		var c = bit_index
#		bit_index = bit_index ^ 16
#		var d = bit_index
#		var t2 = OS.get_ticks_usec()
#		var time = t2-t1
		
		
		

var bit_index = 0
var scancode_order = PoolIntArray([])

func handle_raw_inputs(event):
	var m = false
	if event is InputEventKey:
		m = true
		var scancode = 0
		if event.scancode != 0:
			scancode = event.scancode
		elif event.physical_scancode != 0:
			scancode = event.physical_scancode
		if !event.echo:
			if event.pressed and not scancode in current_key_inputs:
				current_key_inputs.append(scancode)
				bit_index = bit_index | scancode
			elif scancode in current_key_inputs:
				current_key_inputs.erase(scancode)
				bit_index = bit_index ^ scancode
	
	if event is InputEventMouseButton:
		m = true
		var scancode = event.button_index + adjustments["MOUSEBUTTONS"]
		if event.pressed and not scancode in current_key_inputs:
			current_key_inputs.append(scancode)
			bit_index = bit_index | scancode
		elif scancode in current_key_inputs:
			current_key_inputs.erase(scancode)
			bit_index = bit_index ^ scancode
	
	
	if event is InputEventJoypadMotion:
		m = true
		var av = event.axis_value
		var scancode = event.axis + adjustments["JOYAXES"]
		var offset = adjustments["JOYAXES"]
		var strength = stepify(av,0.05)
		if abs(strength) > 0.095 and (not scancode in current_key_inputs or (scancode in current_joy_strength and current_joy_strength[scancode] != strength)):
			if not scancode in current_key_inputs:
				current_key_inputs.append(scancode)
				bit_index = bit_index | scancode
			current_joy_strength[scancode] = strength
		elif scancode in current_key_inputs:
			current_key_inputs.erase(scancode)
			current_joy_strength.erase(scancode)
			bit_index = bit_index ^ scancode
	
	if event is InputEventJoypadButton:
		m = true
		var scancode = event.button_index + adjustments["JOYBUTTONS"]
		if event.pressed and not scancode in current_key_inputs:
			current_key_inputs.append(scancode)
			bit_index = bit_index | scancode
		elif scancode in current_key_inputs:
			current_key_inputs.erase(scancode)
			bit_index = bit_index ^ scancode
	
	return m

func get_event_str(event):
	var string = ""
	if event is InputEventKey:
		if event.scancode != 0:
			string = OS.get_scancode_string(event.scancode)
		elif event.physical_scancode != 0:
			string = OS.get_scancode_string(event.physical_scancode)
	if event is InputEventMouseButton:
		string = "Mouse " + str(event.button_index)
	
	if event is InputEventJoypadMotion:
		var av = event.axis_value
		var sv = sign(av)
		string = "JoyAxis " + str(event.axis * sv)
	
	if event is InputEventJoypadButton:
		string = "JoyButton " + str(event.button_index)
	return string

func handle_string_inputs(event):
	var t1 = OS.get_ticks_usec()
	if event is InputEventKey:
		var string = ""
		if event.scancode != 0:
			string = OS.get_scancode_string(event.scancode)
		elif event.physical_scancode != 0:
			string = OS.get_scancode_string(event.physical_scancode)
		if !event.echo:
			if event.pressed and not string in current_key_inputs:
				current_key_inputs.append(string)
			elif string in current_key_inputs:
				current_key_inputs.erase(string)
	
	if event is InputEventMouseButton:
		var string = "Mouse " + str(event.button_index)
		if event.pressed and not string in current_key_inputs:
			current_key_inputs.append(string)
		elif string in current_key_inputs:
			current_key_inputs.erase(string)
	
	
	if event is InputEventJoypadMotion:
		var av = event.axis_value
		var sv = sign(av)
		var string = "JoyAxis " + str(event.axis * sv)
		var strength = stepify(av * sv,0.05)
		if strength > 0.095 and (not string in current_key_inputs or (string in current_joy_strength and current_joy_strength[string] != strength)):
			current_key_inputs.append(string)
			current_joy_strength[string] = strength
		elif string in current_key_inputs:
			current_key_inputs.erase(string)
			current_joy_strength.erase(string)
	
	if event is InputEventJoypadButton:
		var string = "JoyButton " + str(event.button_index)
		if event.pressed and not string in current_key_inputs:
			current_key_inputs.append(string)
		elif string in current_key_inputs:
			current_key_inputs.erase(string)
	
	var t2 = OS.get_ticks_usec()
	var diff = t2-t1
	
	Debug.l(str(current_key_inputs) + " in " + str(diff))

