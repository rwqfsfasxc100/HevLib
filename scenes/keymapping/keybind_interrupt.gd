extends Node

const ALLOW_KEYBIND_MODIFICATIONS = ! true
var INPUT_DRIVER_ACTIVE = true

var current_key_inputs = []
var current_joy_strength = {}

var is_active_window = true

onready var vanilla_binds = Settings.cfg.input
onready var adjustments = load("res://HevLib/scenes/keymapping/data/key_adjustments.gd").ADJUSTMENT.duplicate(true)

onready var pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")


onready var compiler = preload("res://HevLib/scenes/keymapping/compile_keymap.gd").new(pointers)

var keybind_folder = "user://cache/.HevLib_Cache/Keybinds/"
var vanilla_binds_file = "user://cfg/Vanilla_Binds.cfg"

var file = File.new()

var input_handle = null

func _ready():
	pointers.FolderAccess.__check_folder_exists(keybind_folder)
	self.pause_mode = Node.PAUSE_MODE_PROCESS
	self.process_priority = -INF
	INPUT_DRIVER_ACTIVE = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","input_virtualization")
	self.set_process_input(ALLOW_KEYBIND_MODIFICATIONS and INPUT_DRIVER_ACTIVE)
	if ALLOW_KEYBIND_MODIFICATIONS and INPUT_DRIVER_ACTIVE:
		var actions = InputMap.get_actions()
		var sortedAv = pointers.Keymapping.__get_built_in_action_list()
		var vb = pointers.ConfigDriver.__config_parse(vanilla_binds_file)
		file.open(keybind_folder + "defined_control_configs.json",File.READ)
		var mb = JSON.parse(file.get_as_text()).result
		
		
		var ignore_builtin = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","input_virtualization_ignore_builtin")
		
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
		
func compile():
	var active_script = compiler.compile_keymap()
	input_handle = null
	var gd = pointers.DataFormat.__compile_to_script_object(active_script)
	input_handle = gd

func _physics_process(delta):
	if ALLOW_KEYBIND_MODIFICATIONS and INPUT_DRIVER_ACTIVE:
		is_active_window = OS.is_window_focused()
		if not is_active_window:
			current_key_inputs.clear()
			bit_index = 0

func _input(event):
	if handle_raw_inputs(event):
		Debug.l("Current Index: " + str(current_key_inputs))
		input_handle.handle_input(current_key_inputs, event)

var bit_index = 0

func handle_raw_inputs(event):
	var m = false
	if event is InputEventKey:
		m = true
		if !event.echo:
			var scancode = 0
			if event.scancode != 0:
				scancode = event.scancode
			elif event.physical_scancode != 0:
				scancode = event.physical_scancode
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
