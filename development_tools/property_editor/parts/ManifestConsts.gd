extends Node

const property_nodes = {
	"null":preload("res://HevLib/development_tools/property_editor/property_containers/null.tscn"),
	"bool":preload("res://HevLib/development_tools/property_editor/property_containers/bool.tscn"),
	"int":preload("res://HevLib/development_tools/property_editor/property_containers/int.tscn"),
	"float":preload("res://HevLib/development_tools/property_editor/property_containers/float.tscn"),
	"string":preload("res://HevLib/development_tools/property_editor/property_containers/string.tscn"),
	"Vector2":preload("res://HevLib/development_tools/property_editor/property_containers/vec2.tscn"),
	"Vector3":preload("res://HevLib/development_tools/property_editor/property_containers/vec3.tscn"),
	"Rect2":preload("res://HevLib/development_tools/property_editor/property_containers/rect2.tscn"),
	"Transform2D":preload("res://HevLib/development_tools/property_editor/property_containers/transform2d.tscn"),
	"Color":preload("res://HevLib/development_tools/property_editor/property_containers/color.tscn"),
	"Dictionary":preload("res://HevLib/development_tools/property_editor/property_containers/dict.tscn"),
	"Array":preload("res://HevLib/development_tools/property_editor/property_containers/array.tscn"),
	"PoolByteArray":preload("res://HevLib/development_tools/property_editor/property_containers/poolbytearray.tscn"),
	"PoolIntArray":preload("res://HevLib/development_tools/property_editor/property_containers/poolintarray.tscn"),
	"PoolRealArray":preload("res://HevLib/development_tools/property_editor/property_containers/poolrealarray.tscn"),
	"PoolStringArray":preload("res://HevLib/development_tools/property_editor/property_containers/poolstringarray.tscn"),
	"PoolVector2Array":preload("res://HevLib/development_tools/property_editor/property_containers/poolvector2array.tscn"),
	"PoolVector3Array":preload("res://HevLib/development_tools/property_editor/property_containers/poolvector3array.tscn"),
	"PoolColorArray":preload("res://HevLib/development_tools/property_editor/property_containers/poolcolorarray.tscn"),
}
const supported_property_types = [
	"null",
	"bool",
	"int",
	"float",
	"string",
	"Vector2",
	"Rect2",
	"Vector3",
	"Transform2D",
	"Color",
	"Dictionary",
	"Array",
	"PoolByteArray",
	"PoolIntArray",
	"PoolRealArray",
	"PoolStringArray",
	"PoolVector2Array",
	"PoolVector3Array",
	"PoolColorArray",
]
const BUILTIN_TAGS = {
	"TAG_ALLOW_ACHIEVEMENTS":["bool",false,"Whether the mod would permit achievements.\nNot currently functional in-game."],
	"TAG_QOL":["bool",false,"Whether the mod adds QOL features."],
	"TAG_OVERHAUL":["bool",false,"Whether the mod overhauls a part or parts of the game."],
	"TAG_VISUAL":["bool",false,"Whether the mod makes visual adjustments."],
	"TAG_FUN":["bool",false,"Whether the mod is more fun than serious."],
	"TAG_UI":["bool",false,"Whether the mod adds UI elements."],
	"TAG_ADDS_SHIPS":["Array",[],"Names of ships that the mod adds.\nCan use translation strings."],
	"TAG_ADDS_EQUIPMENT":["Array",[],"Names of equipment that the mod adds.\nCan use translation strings."],
	"TAG_ADDS_GAMEPLAY_MECHANICS":["Array",[],"Names of gameplay mechanics that the mod adds.\nCan use translation strings."],
	"TAG_ADDS_EVENTS":["Array",[],"Names of events that the mod adds.\nCan use translation strings."],
	"TAG_HANDLE_EXTRA_CREW":["int",24,"For ships with very large numbers of crew, prevents derelict dialogue\nbeing broken if the crew count exceeds what the dialogue can handle.\n\nHevLib automatically sets this to 24, so only does anything above that."],
#	"TAG_USING_HEVLIB_RESEARCH":["array",[],""],
}
const property_assignment = {
	TYPE_NIL:"null",
	TYPE_BOOL:"bool",
	TYPE_INT:"int",
	TYPE_REAL:"float",
	TYPE_STRING:"string",
	TYPE_VECTOR2:"Vector2",
	TYPE_RECT2:"Rect2",
	TYPE_VECTOR3:"Vector3",
	TYPE_TRANSFORM2D:"Transform2D",
	TYPE_COLOR:"Color",
	TYPE_DICTIONARY:"Dictionary",
	TYPE_ARRAY:"Array",
	TYPE_RAW_ARRAY:"PoolByteArray",
	TYPE_INT_ARRAY:"PoolIntArray",
	TYPE_REAL_ARRAY:"PoolRealArray",
	TYPE_STRING_ARRAY:"PoolStringArray",
	TYPE_VECTOR2_ARRAY:"PoolVector2Array",
	TYPE_VECTOR3_ARRAY:"PoolVector3Array",
	TYPE_COLOR_ARRAY:"PoolColorArray",
}
const defaults_for_property_type = {
	"null":null,
	"bool":false,
	"int":0,
	"float":0.0,
	"string":"",
	"Vector2":Vector2.ZERO,
	"Rect2":Rect2(),
	"Vector3":Vector3.ZERO,
	"Transform2D":Transform2D(),
	"Color":Color.black,
	"Dictionary":{},
	"Array":[],
	"PoolByteArray":PoolByteArray(),
	"PoolIntArray":PoolIntArray(),
	"PoolRealArray":PoolRealArray(),
	"PoolStringArray":PoolStringArray(),
	"PoolVector2Array":PoolVector2Array(),
	"PoolVector3Array":PoolVector3Array(),
	"PoolColorArray":PoolColorArray(),
}




const CONFIG_NAMES = [
	"bool",
	"int",
	"float",
	"string",
	"optionbutton",
	"input",
	"action"
]

const CONFIG_NODES = {
	"bool":preload("res://HevLib/development_tools/property_editor/modules/manifests/inputboxes/config_parts/bool.tscn"),
	"int":preload("res://HevLib/development_tools/property_editor/modules/manifests/inputboxes/config_parts/int.tscn"),
	"float":preload("res://HevLib/development_tools/property_editor/modules/manifests/inputboxes/config_parts/float.tscn"),
	"string":preload("res://HevLib/development_tools/property_editor/modules/manifests/inputboxes/config_parts/string.tscn"),
	"optionbutton":preload("res://HevLib/development_tools/property_editor/modules/manifests/inputboxes/config_parts/optionbutton.tscn"),
	"input":preload("res://HevLib/development_tools/property_editor/modules/manifests/inputboxes/config_parts/input.tscn"),
	"action":preload("res://HevLib/development_tools/property_editor/modules/manifests/inputboxes/config_parts/action.tscn"),
}

const CONFIG_TYPES = {
	"action":{							# Acceptable types: action
		"name":"ACTION_MISSING_NAME",	# Display name of the config
		"description":"",				# Description for the config, used as a tooltip
		"requires_bools":[],			# Boolean configs that must be true for the config to be available. Each string formatted like 'ModName/Section/Entry', e.g. "VelocityPlus/VP_ENCELADUS/enable_achievements". Use ConfigDriver.__truncate_to_setting_entry to help format.
		"invert_bool_requirement":false,# Invert the requires_bools output to have all of them negative to permit this config. 
		"script_path":"",				# Filepath for the script that the action button uses
		"button_label":"",				# String that the action button displays. Can be a translation string.
		"method":"_pressed",			# Method that the button script would be connected to.
	},
	"bool":{							# Acceptable types: bool, boolean
		"name":"BOOL_MISSING_NAME",		# Display name of the config
		"description":"",				# Description for the config, used as a tooltip
		"requires_bools":[],			# Boolean configs that must be true for the config to be available. Each string formatted like 'ModName/Section/Entry', e.g. "VelocityPlus/VP_ENCELADUS/enable_achievements". Use ConfigDriver.__truncate_to_setting_entry to help format.
		"invert_bool_requirement":false,# Invert the requires_bools output to have all of them negative to permit this config. 
		"default":false,				# The default value for the config.
		"require_restart":false,		# Whether changing this option requires the game to be restarted and prompts the user that it does.
	},
	"input":{							# Accepatable types: input
		"name":"INPUT_MISSING_NAME",	# Display name of the config
		"description":"",				# Description for the config, used as a tooltip
		"requires_bools":[],			# Boolean configs that must be true for the config to be available. Each string formatted like 'ModName/Section/Entry', e.g. "VelocityPlus/VP_ENCELADUS/enable_achievements". Use ConfigDriver.__truncate_to_setting_entry to help format.
		"invert_bool_requirement":false,# Invert the requires_bools output to have all of them negative to permit this config. 
		"default":[],					# The default value for the config.
		"always_binds":[],				# Keys that will always be available for this config, and not used.
	},
	"int":{								# Accepatable types: int, integer
		"name":"INTFLOAT_MISSING_NAME",	# Display name of the config
		"description":"",				# Description for the config, used as a tooltip
		"requires_bools":[],			# Boolean configs that must be true for the config to be available. Each string formatted like 'ModName/Section/Entry', e.g. "VelocityPlus/VP_ENCELADUS/enable_achievements". Use ConfigDriver.__truncate_to_setting_entry to help format.
		"invert_bool_requirement":false,# Invert the requires_bools output to have all of them negative to permit this config. 
		"default":10,					# The default value for the config.
		"style":"slider",				# The style of the value display. Accepts slider and spinbox
		"min":0,						# The minimum value of the display.
		"max":10,						# The maximum value of the display.
		"step":1,						# How much the value is changed by every tick up or down
		"require_restart":false,		# Whether changing this option requires the game to be restarted and prompts the user that it does.
	},
	"float":{							# Accepatable types: float, real
		"name":"INTFLOAT_MISSING_NAME",	# Display name of the config
		"description":"",				# Description for the config, used as a tooltip
		"requires_bools":[],			# Boolean configs that must be true for the config to be available. Each string formatted like 'ModName/Section/Entry', e.g. "VelocityPlus/VP_ENCELADUS/enable_achievements". Use ConfigDriver.__truncate_to_setting_entry to help format.
		"invert_bool_requirement":false,# Invert the requires_bools output to have all of them negative to permit this config. 
		"default":10.0,					# The default value for the config.
		"style":"slider",				# The style of the value display. Accepts slider and spinbox
		"min":0.0,						# The minimum value of the display.
		"max":10.0,						# The maximum value of the display.
		"step":1.0,						# How much the value is changed by every tick up or down
		"require_restart":false,		# Whether changing this option requires the game to be restarted and prompts the user that it does.
	},
	"string":{							# Acceptable types: string, str
		"name":"STRING_MISSING_NAME",	# Display name of the config
		"description":"",				# Description for the config, used as a tooltip
		"requires_bools":[],			# Boolean configs that must be true for the config to be available. Each string formatted like 'ModName/Section/Entry', e.g. "VelocityPlus/VP_ENCELADUS/enable_achievements". Use ConfigDriver.__truncate_to_setting_entry to help format.
		"invert_bool_requirement":false,# Invert the requires_bools output to have all of them negative to permit this config. 
		"default":"",					# The default value for the config.
		"max_length":0,					# The maximum amount of characters allowed in the box
		"secret":false,					# Whether the text should be hidden
		"clear_button":false,			# Whether a button to clear the text should be displayed
		"placeholder":"HEVLIB_CONFIG_LINEEDIT_PLACEHOLDER",# Placeholder text used when there is nothing in the string.
		"require_restart":false,		# Whether changing this option requires the game to be restarted and prompts the user that it does.
	},
	"optionbutton":{					# Acceptable types: option, optionbutton, option_button
		"name":"OPTION_MISSING_NAME",	# Display name of the config
		"description":"",				# Description for the config, used as a tooltip
		"requires_bools":[],			# Boolean configs that must be true for the config to be available. Each string formatted like 'ModName/Section/Entry', e.g. "VelocityPlus/VP_ENCELADUS/enable_achievements". Use ConfigDriver.__truncate_to_setting_entry to help format.
		"invert_bool_requirement":false,# Invert the requires_bools output to have all of them negative to permit this config. 
		"default":"",					# The default value for the config.
		"options":[],					# The names for the options to display
		"store_method":"int",			# Whether the index of the selected option or the name of the selected option is stored.
		"require_restart":false,		# Whether changing this option requires the game to be restarted and prompts the user that it does.
	}
}

