extends Node

# This script can be copied into any mod and loaded to check for HevLib, or any other mod desired
# Upon being loaded, it will automatically run and perform the check for the desired mod
# Run the script by instancing it as such:
# var mod_check = load("res://path/to/script/hevlib_check.gd").new() 
# If the variable crash_if_not_found is set to false, the result of the query can be found by fetching the mod_exists variable from the variable
# var mod_exists = mod_check.mod_exists


# The display mod name used by the dialogue box text and for logging
var mod_name : String = "HevLib"

# The minimum and maximum versions of the mod that would be considered valid. 
# Anything below the min and anything above the max will cause a failed query
# mod.manifest must be standardized to at least manifest version 2 to be treated as a valid version source
# If no manifest exists, or the manifest version is either below 2 or is not stated, versioning in the ModMain.gd script requires the following int variables: MOD_VERSION_MAJOR, MOD_VERSION_MINOR, and MOD_VERSION_BUGFIX
# If neither the manifest or mod main have proper versioning, the check automatically fails
# Setting INF for the max major version and -INF for the min major version will act as standard operators and mean that no maximum or no minimum is set respectively
# 
var min_version_major : int = 1
var min_version_minor : int = 0
var min_version_bugfix : int = 0

var max_version_major : int = INF
var max_version_minor : int = 6
var max_version_bugfix : int = 9

var check_mod_version : bool = true

# Whether to display a confirmation dialogue box to say that the mod is missing
# Will use a default message and mod name if the custom_message_string variable is left blank as ""
var show_dialogue_box : bool = true

# If true, the game will close after either the dialogue box is closed, or if show_dialogue_box is false, immediately after the query fails
# If no dialogue box is used, there will be extra logging performed to make sure that the issue is made very clear.
var crash_if_not_found : bool = true

# The file path to the mod main file. The file structure is equivalent to the file structure of the zip file.
var modmain_res_path : String = "res://HevLib/ModMain.gd"

# A custom message that can be used for the dialogue box if enabled.
# Can be both raw text or a translation string, however do make sure that the translation is loaded before this script runs
# This will not use the mod_name string for display, so please make sure to include it in the string
var custom_message_string : String = ""







# Variable used to decide the query. Can be fetched if set to not close the game
var mod_exists : bool












func _ready():
	pass
