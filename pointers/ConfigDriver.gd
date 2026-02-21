extends Node

const config_name = "Mod_Configurations"

var developer_hint = {
	"__config_parse":[
		"Parses a config file as a dictionary",
		"file -> string containing the file path to the config",
		"File must be formatted to ini standards, e.g. through using the ConfigFile module"
	],
	"__store_config":[
		"Stores a config formatted through a dictionary",
		"id -> string containing the config's identification.",
		"cfg_filename -> (optional) string for the filename for the config file stored in the user://cfg/ folder. Defaults to Mod_Configurations.cfg",
		"To associate a config with a mod, set the id to use the mod's name in the mod.manifest file."
	],
	"__get_config":[
		"Retrieves a specific config formatted through a dictionary.",
		"id -> string containing the config's identification.",
		"cfg_filename -> (optional) string for the filename for the config file stored in the user://cfg/ folder. Defaults to Mod_Configurations.cfg",
		"To fetch a config associated with a mod, set the id to use the mod's name in the mod.manifest file.",
		"If no respective configuration exists, returns an empty dictionary"
	],
	"__store_value":[
		"Stores an entry into the configuration",
		"id -> string containing the config's identification",
		"section -> string containing the config section",
		"key -> string containing the entry within the section",
		"value -> the desired value of the key. Can be any variable type",
		"cfg_filename -> (optional) string for the filename for the config file stored in the user://cfg/ folder. Defaults to Mod_Configurations.cfg",
		"To assign a config entry to be associated with a mod, set the id to use the mod's name in the mod.manifest file.",
	],
	"__get_value":[
		"Fetches an entry from the configuration file",
		"id -> string containing the config's identification",
		"section -> string containing the config section",
		"key -> string containing the entry within the section",
		"cfg_filename -> (optional) string for the filename for the config file stored in the user://cfg/ folder. Defaults to Mod_Configurations.cfg",
		"To fetch a config entry associated with a mod, set the id to use the mod's name in the mod.manifest file.",
		"If no respective entry, section, or configuration exists, returns null"
	],
	"__load_configs":[
		"Initializes a configuration file at the given location",
		"Will automatically assign default configurations to any missing entries or sections in the config",
		"Must be run on ready as mod data won't be available before then",
		"cfg_filename -> (optional) string for the filename for the config file stored in the user://cfg/ folder. Defaults to Mod_Configurations.cfg",
	],
	"__set_button_focus":[
		"Internal function used for the focusing of buttons"
	],
	"__load_inputs_from_string_array":[
		"Adds inputs for an input action from an array of input keys",
		"key -> string used as the input action to register the input events for",
		"strings -> array of strings for the input events to use. Mouse inputs are prefixed with 'Mouse %s', joy axis inputs are prefixed with 'JoyAxis %s', and joy button inputs are prefixed with 'JoyButton %s'"
	]
}

const DataFormat = preload("res://HevLib/pointers/DataFormat.gd")
const ManifestV2 = preload("res://HevLib/pointers/ManifestV2.gd")
const FolderAccess = preload("res://HevLib/pointers/FolderAccess.gd")

const cfp = preload("res://HevLib/scripts/configs/config_parse.gd")
static func __config_parse(file: String) -> Dictionary:
	var s = cfp.config_parse(file)
	return s
const sc = preload("res://HevLib/scripts/configs/store_config.gd")
static func __store_config(id: String, configuration: Dictionary, cfg_filename : String = config_name + ".cfg"):
	sc.store_config(configuration,id,cfg_filename,DataFormat)
const sv = preload("res://HevLib/scripts/configs/store_value.gd")
static func __store_value(id: String, section: String, key: String, value, cfg_filename : String = config_name + ".cfg"):
	sv.store_value(id, section, key, value,cfg_filename)
const gc = preload("res://HevLib/scripts/configs/get_config.gd")
static func __get_config(id: String, cfg_filename : String = config_name + ".cfg") -> Dictionary:
	var s = gc.get_config(id,cfg_filename)
	return s
const gv = preload("res://HevLib/scripts/configs/get_value.gd")
static func __get_value(id: String, section: String, key: String, cfg_filename : String = config_name + ".cfg"):
	var s = gv.get_value(id, section, key, cfg_filename,DataFormat)
	return s
const lc = preload("res://HevLib/scripts/configs/load_configs.gd")
static func __load_configs(cfg_filename : String = config_name + ".cfg"):
	lc.load_configs(cfg_filename,ManifestV2,FolderAccess)
const sbf = preload("res://HevLib/scripts/configs/set_button_focus.gd")
static func __set_button_focus(button,check_button):
	sbf.set_button_focus(button,check_button)

static func __load_inputs_from_string_array(key:String, strings: Array):
	for i in strings:
		if i.begins_with("Mouse "):
			var event = InputEventMouseButton.new()
			event.button_index = int(i.split("Mouse ")[1])
			if not InputMap.action_has_event(key,event):
				Debug.l("ConfigDriver: Adding input event [%s] for [%s]" % [i,key])
				InputMap.action_add_event(key, event)
			else:
				Debug.l("ConfigDriver: Input event [%s] for [%s] already exists, skipping" % [i,key])
		if i.begins_with("JoyButton "):
			var event = InputEventJoypadButton.new()
			event.button_index = int(i.split("JoyButton ")[1])
			if not InputMap.action_has_event(key,event):
				Debug.l("ConfigDriver: Adding input event [%s] for [%s]" % [i,key])
				InputMap.action_add_event(key, event)
			else:
				Debug.l("ConfigDriver: Input event [%s] for [%s] already exists, skipping" % [i,key])
		if i.begins_with("JoyAxis "):
			var event = InputEventJoypadMotion.new()
			event.axis = abs(int(i.split("JoyAxis ")[1]))
			if i.split("JoyAxis ")[1].begins_with("-"):
				event.axis_value = -1.0
			else:
				event.axis_value = 1.0
			if not InputMap.action_has_event(key,event):
				Debug.l("ConfigDriver: Adding input event [%s] for [%s]" % [i,key])
				InputMap.action_add_event(key, event)
			else:
				Debug.l("ConfigDriver: Input event [%s] for [%s] already exists, skipping" % [i,key])
			
		else:
			var event = InputEventKey.new()
			event.scancode = OS.find_scancode_from_string(i)
			if not InputMap.action_has_event(key,event):
				Debug.l("ConfigDriver: Adding input event [%s] for [%s]" % [i,key])
				InputMap.action_add_event(key, event)
			else:
				Debug.l("ConfigDriver: Input event [%s] for [%s] already exists, skipping" % [i,key])


#	Config types - this explains formatting for config types for manifests
#	
#	BOOL:
#	{
#	"name":"" - string used to provide a name for the entry
#	"description":"" - string used to provide the description tooltip
#	"type":"bool" - string used to define type, in this case a bool. can be bool or boolean, not case sensitive
#	"default":true - bool used for default value. false if absent
#	"requires_bools":[] - array of strings for bool settings used to enable this option. as long as there is one valid entry that's true, this option will be enabled. formatted like "Mod/section/entry" (e.g. HevLib/equipment/do_sort_equipment_by_price)
#	"invert_bool_requirement":false - bool used to decide that this option will instead be enabled until there is one true setting in the array
#	}
#	
#	
