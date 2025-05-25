extends Node

# Set mod priority if you want it to load before/after other mods
# Mods are loaded from lowest to highest priority, default is 0
const MOD_PRIORITY = -INF
# Name of the mod, used for writing to the logs
const MOD_NAME = "HevLib Library Equipment Driver Module"
const MOD_VERSION = "1.0.0"
const MOD_VERSION_MAJOR = 1
const MOD_VERSION_MINOR = 0
const MOD_VERSION_BUGFIX = 0
const MOD_VERSION_METADATA = ""
const MOD_IS_LIBRARY = false
# Path of the mod folder, automatically generated on runtime
var modPath:String = get_script().resource_path.get_base_dir() + "/"
# Required var for the replaceScene() func to work
var _savedObjects := []

#Initializes the configuration variable. Used by loadSettings.

# Initialize the mod
# This function is executed before the majority of the game is loaded
# Only the Tool and Debug AutoLoads are available
# Script and scene replacements should be done here, before the originals are loaded
func _init(modLoader = ModLoader):
	l("Initializing Equipment Driver")
	
	installScriptExtension("UpgradeGroup.gd")
	installScriptExtension("hardpoints/EquipmentItemTemplate.gd")
	
func _ready():
	l("Readying")
	replaceScene("Upgrades.tscn", "res://enceladus/Upgrades.tscn")
	l("Ready")
	
func installScriptExtension(path:String):
	var childPath:String = str(modPath + path)
	var childScript:Script = ResourceLoader.load(childPath)

	childScript.new()

	var parentScript:Script = childScript.get_base_script()
	var parentPath:String = parentScript.resource_path

	l("Installing script extension: %s <- %s" % [parentPath, childPath])

	childScript.take_over_path(parentPath)


# Helper function to replace scenes
# Can either be passed a single path, or two paths
# With a single path, it will replace the vanilla scene in the same relative position
func replaceScene(newPath:String, oldPath:String = ""):
	l("Updating scene: %s" % newPath)

	if oldPath.empty():
		oldPath = str("res://" + newPath)

	newPath = str(modPath + newPath)

	var scene := load(newPath)
	scene.take_over_path(oldPath)
	_savedObjects.append(scene)
	l("Finished updating: %s" % oldPath)

# Func to print messages to the logs
func l(msg:String, title:String = MOD_NAME, version:String = MOD_VERSION):
	Debug.l("[%s V%s]: %s" % [title, version, msg])
