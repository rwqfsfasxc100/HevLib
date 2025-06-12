extends "res://Settings.gd"

# You may want to change many of the variable names to provide a unique identifier
# Make sure anything read by the ModMain is consistent with this file or they will not work
# These are default config values
# Any value not set in the config file will generate the missing values exactly as these are
var HevLib = {
	"equipment":{
		"do_sort_equipment_by_price":true,
	},
	"events":{
		"disabled_events":[  ],
		"write_events":true,
	},
	"debug":{
		"input_debugger":false,
		"ring_position_data_debugger":false,
		"ring_position_accurate_events":false,
	},
	"input":{
		"open_debug_event_menu":[  ],
		"debugger":[ "F10" ],
		"toggle_debug_menus":[ "F9" ],
	}, 
}

# The config file name. Make sure you set something unique
# Config is set to the cfg folder to make it easy to find
var ConfigPath = "user://cfg/HevLib.cfg"
var CfgFile = ConfigFile.new()

func _ready():
	var dir = Directory.new()
	dir.make_dir("user://cfg")
	load_HevLib_FromFile()
	save_HevLib_ToFile()


func save_HevLib_ToFile():
	for section in HevLib:
		for key in HevLib[section]:
			CfgFile.set_value(section, key, HevLib[section][key])
	CfgFile.save(ConfigPath)


func load_HevLib_FromFile():
	var error = CfgFile.load(ConfigPath)
	if error != OK:
		Debug.l("HevLib Config File: Error loading settings %s" % error)
		return 
	for section in HevLib:
		for key in HevLib[section]:
			HevLib[section][key] = CfgFile.get_value(section, key, HevLib[section][key])
	loadKeymapsFromConfig()

# Keybind setting handlers
func loadKeymapsFromConfig():
	for action_name in HevLib.input:
		var addAction = true
		for m in InputMap.get_actions():
			if m == action_name:
				addAction = false
		if addAction:
			InputMap.add_action(action_name)
		for key in HevLib.input[action_name]:
			var event = InputEventKey.new()
			event.scancode = OS.find_scancode_from_string(key)
			InputMap.action_add_event(action_name, event)
	emit_signal("controlSchemeChaged")
	
	var actions = InputMap.get_action_list("debugger")
	var keys = []
	for a in actions:
		var scancode = char(a.scancode)
		keys.append(scancode)
	
