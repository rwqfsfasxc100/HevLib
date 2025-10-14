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
const MOD_IS_LIBRARY = true
# Path of the mod folder, automatically generated on runtime
var modPath:String = get_script().resource_path.get_base_dir() + "/"
# Required var for the replaceScene() func to work
var _savedObjects := []

#Initializes the configuration variable. Used by loadSettings.

# Initialize the mod
# This function is executed before the majority of the game is loaded
# Only the Tool and Debug AutoLoads are available
# Script and scene replacements should be done here, before the originals are loaded

var upgrades_path = "user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/upgrades/Upgrades.tscn"
var weaponslot_path = "user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/weapon_slot/WeaponSlot.tscn"
var aux_path = "user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/power/AuxSlot.tscn"

var asteroid_path = "user://cache/.HevLib_Cache/Minerals/AsteroidSpawner.gd"
var currentgame_path = "user://cache/.HevLib_Cache/Minerals/CurrentGame.gd"
var thering_path = "user://cache/.HevLib_Cache/Minerals/TheRing.gd"
var ringscene_path = "user://cache/.HevLib_Cache/Minerals/TheRing.tscn"

var Equipment = preload("res://HevLib/pointers/Equipment.gd")
var ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")
func _init(modLoader = ModLoader):
	l("Initializing Equipment Driver")
	
	installScriptExtension("../scene_replacements/DLClist.gd")
	replaceScene("../scene_replacements/DLClist.tscn","res://tools/DLClist.tscn")
	
	
	
	var minerals = preload("res://HevLib/scenes/minerals/make_mineral_scripting.gd")
	minerals.make_mineral_scripting(false)
	
	var asteroids = ResourceLoader.load(asteroid_path)
	asteroids.new()
	asteroids.take_over_path("res://AsteroidSpawner.gd")
	_savedObjects.append(asteroids)
	
	var cg = ResourceLoader.load(currentgame_path)
	cg.new()
	cg.take_over_path("res://CurrentGame.gd")
	_savedObjects.append(cg)
	
	
	
	
	# Adds in_hevlib_menu to the CurrentGame script and preventing controls while it's true
	installScriptExtension("../../events/controls/CurrentGame.gd")
	installScriptExtension("../../events/controls/ship-ctrl.gd")
	
#	installScriptExtension("check.gd")
	installScriptExtension("../scene_replacements/blanks/MPU.gd")
	installScriptExtension("../scene_replacements/blanks/Hud.gd")
	installScriptExtension("../scene_replacements/ship-ctrl.gd")
	
	installScriptExtension("ThrusterSlot.gd")
	installScriptExtension("UpgradeGroup.gd")
	installScriptExtension("hardpoints/EquipmentItemTemplate.gd")
	
	installScriptExtension("../weaponslot/weapon_slot_handler.gd")
	
	installScriptExtension("ShipModificationDriver/InternalStorageMod.gd")
	installScriptExtension("ShipModificationDriver/AddNodes.gd")
	
	installScriptExtension("../better_title_screen/SaveSlotButton.gd")
	replaceScene("../better_title_screen/TitleScreen.tscn","res://TitleScreen.tscn")
	
#	Equipment.__make_upgrades_scene(false)
#	var ws = load(weaponslot_path)
#	ws.take_over_path("res://weapons/WeaponSlot.tscn")
#	_savedObjects.append(ws)
	
func _ready():
	l("Readying")
	ConfigDriver.__load_configs()
	
	
	var ring = preload("res://HevLib/scenes/minerals/make_ring_modifications.gd")
	ring.make_ring_modifications()
	
	var tr = ResourceLoader.load(thering_path)
	tr.new()
	tr.take_over_path("res://TheRing.gd")
	_savedObjects.append(tr)
	var f = File.new()
	f.open(ringscene_path,File.WRITE)
	f.store_string("[gd_scene load_steps=3 format=2]\n\n[ext_resource path=\"%s\" type=\"Script\" id=1]\n[ext_resource path=\"res://story/TheRing.tscn\" type=\"PackedScene\" id=2]\n\n[node name=\"TheRing\" instance=ExtResource( 2 )]\nscript = ExtResource( 1 )\n" % thering_path)
	f.close()
	var rs := load(ringscene_path)
	rs.take_over_path("res://story/TheRing.tscn")
	_savedObjects.append(rs)
	
	
	
	Equipment.__make_upgrades_scene(true)
	var upgrades = load(upgrades_path)
	upgrades.take_over_path("res://enceladus/Upgrades.tscn")
	_savedObjects.append(upgrades)
	
#	var aux = load(aux_path)
#	aux.take_over_path("res://ships/modules/AuxSlot.tscn")
#	_savedObjects.append(aux)
	
	var ws = load(weaponslot_path)
	ws.take_over_path("res://weapons/WeaponSlot.tscn")
	_savedObjects.append(ws)
	
	replaceScene("Upgrades.tscn", "res://enceladus/Upgrades.tscn")
#	replaceScene("Enceladus.tscn","res://enceladus/Enceladus.tscn")
#	installScriptExtension("../scene_replacements/Shipyard.gd")

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
