extends Node

# This script can be copied into any mod and loaded to check for HevLib, or any other mod desired
# Upon being loaded, it will automatically run and perform the check for the desired mod
# Run the script by instancing it as such:
# var mod_check = load("res://path/to/script/hevlib_check.gd").new() 
# If the variable crash_if_not_found is set to false, the result of the query can be found by fetching the mod_exists variable from the variable
# var mod_exists = mod_check.mod_exists


# The mod name used by the dialogue box text when the mod does not exist
var mod_name : String = "HevLib"

# The minimum and maximum versions of the mod that would be considered valid. 
# Anything below the min and anything above the max will cause a failed query
# mod.manifest must be standardized to at least manifest version 2 to be treated as a valid version source
# If no manifest exists, or the manifest version is either below 2 or is not stated, versioning in the ModMain.gd script requires the following int variables: MOD_VERSION_MAJOR, MOD_VERSION_MINOR, and MOD_VERSION_BUGFIX
# If neither the manifest or mod main have proper versioning, the check automatically fails
var min_version_major : int = 1
var min_version_minor : int = 0
var min_version_bugfix : int = 0

var max_version_major : int = INF
var max_version_minor : int = 6
var max_version_bugfix : int = 9



var show_dialogue_box : bool = true

var crash_if_not_found : bool = true

var modmain_res_path : String = "res://HevLib/ModMain.gd"

var custom_message_string : String = ""












var mod_exists : bool = false












func _ready():
	pass
