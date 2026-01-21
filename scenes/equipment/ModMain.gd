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
#var exhaust_cache_path = "user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/power/Exhaust_Cache"

var upgrades_path = "user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/upgrades/Upgrades.tscn"
var weaponslot_path = "user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/weapon_slot/WeaponSlot.tscn"
var aux_path = "user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/power/AuxSlot.tscn"
var slot_limits_path = "user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/upgrades/Slot_Limits.tscn"

var asteroid_path = "user://cache/.HevLib_Cache/Minerals/AsteroidSpawner.gd"
var currentgame_path = "user://cache/.HevLib_Cache/Minerals/CurrentGame.gd"
var thering_path = "user://cache/.HevLib_Cache/Minerals/TheRing.gd"
var ringscene_path = "user://cache/.HevLib_Cache/Minerals/TheRing.tscn"

var Equipment = preload("res://HevLib/pointers/Equipment.gd")
var ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")
var ManifestV2 = preload("res://HevLib/pointers/ManifestV2.gd")
#var DriverManagement = preload("res://HevLib/pointers/DriverManagement.gd")


func _init(modLoader = ModLoader):
	l("Initializing Equipment Driver")
	
	var injector = load("res://HevLib/scripts/translations/inject_translations.gd")
	injector.inject_translations()
	
	var FolderAccess = load("res://HevLib/pointers/FolderAccess.gd")
	var d = Directory.new()
	if d.dir_exists("user://cache/.HevLib_Cache"):
		FolderAccess.__recursive_delete("user://cache/.HevLib_Cache")
	
	var ml = MainLoop.new()
	ml.set_script(load("res://HevLib/scripts/crash_handler.gd"))
	_savedObjects.append(ml)
	
	
	
	if ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DRIVERS","multiple_minerals_per_chunk"):
		installScriptExtension("../minerals/multiminerals/mineral.gd")
		installScriptExtension("../minerals/multiminerals/MineralProcessingUnit.gd")
		installScriptExtension("../minerals/multiminerals/AsteroidSpawner.gd")
	
	
	
	installScriptExtension("../../ui/ExtensionPopup.gd")
	installScriptExtension("../scene_replacements/DLClist.gd")
	replaceScene("../scene_replacements/DLClist.tscn","res://tools/DLClist.tscn")

	installScriptExtension("../better_title_screen/CurrentlyPlaying.gd")
	var minerals = load("res://HevLib/scenes/minerals/make_mineral_scripting.gd")
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
#	replaceScene("../better_title_screen/TitleScreen.tscn","res://TitleScreen.tscn")
	
#	Equipment.__make_upgrades_scene(false)
#	var ws = load(weaponslot_path)
#	ws.take_over_path("res://weapons/WeaponSlot.tscn")
#	_savedObjects.append(ws)
	
var f = File.new()
func _ready():
	l("Readying")
	
	ConfigDriver.__load_configs()
	var zip_ref_store = "user://cache/.HevLib_Cache/zip_ref_store.json"
	f.open(zip_ref_store,File.WRITE)
	f.store_string("{}")
	f.close()
	
	var modzips = {}
	for mod in ManifestV2.__get_mod_data()["mods"]:
		var zipinfo = match_mod_path_to_zip(mod)
		modzips.merge({mod:zipinfo})
	f.open(zip_ref_store,File.WRITE)
	f.store_string(JSON.print(modzips))
	f.close()
	
	var ring = preload("res://HevLib/scenes/minerals/make_ring_modifications.gd")
	ring.make_ring_modifications()
	
	var tr = ResourceLoader.load(thering_path)
	tr.new()
	tr.take_over_path("res://TheRing.gd")
	_savedObjects.append(tr)
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
	
	var slot_limits = load(slot_limits_path)
	slot_limits.take_over_path("res://enceladus/Upgrades.tscn")
	_savedObjects.append(slot_limits)
	
#	var aux = load(aux_path)
#	aux.take_over_path("res://ships/modules/AuxSlot.tscn")
#	_savedObjects.append(aux)
	
#	var ws = load(weaponslot_path)
#	ws.take_over_path("res://weapons/WeaponSlot.tscn")
#	_savedObjects.append(ws)
	
	replaceScene("Upgrades.tscn", "res://enceladus/Upgrades.tscn")
#	replaceScene("Enceladus.tscn","res://enceladus/Enceladus.tscn")
#	installScriptExtension("../scene_replacements/Shipyard.gd")

	replaceScene("../minerals/multiminerals/AsteroidField.tscn","res://AsteroidField.tscn")
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

func match_mod_path_to_zip(mod_main_path:String) -> String:
	var _modZipFiles = []
	var gameInstallDirectory = OS.get_executable_path().get_base_dir()
	if OS.get_name() == "OSX":
		gameInstallDirectory = gameInstallDirectory.get_base_dir().get_base_dir().get_base_dir()
	var modPathPrefix = gameInstallDirectory.plus_file("mods")
	var gd = load("res://HevLib/scripts/vendor/gdunzip.gd")
	var dir = Directory.new()
	if dir.open(modPathPrefix) != OK:
#		Debug.l("HevLib ManifestV2: Can't open mod folder %s." % modPathPrefix)
		return ""
	if dir.list_dir_begin() != OK:
#		Debug.l("HevLib ManifestV2: Can't read mod folder %s." % modPathPrefix)
		return ""

	while true:
		var fileName = dir.get_next()
		if fileName == "":
			break
		if dir.current_is_dir():
			continue
		var modFSPath = modPathPrefix.plus_file(fileName)
		var modGlobalPath = ProjectSettings.globalize_path(modFSPath)
		if not ProjectSettings.load_resource_pack(modGlobalPath, true):
#			Debug.l("HevLib ManifestV2: %s failed to add." % fileName)
			continue
		_modZipFiles.append(modFSPath)
#		Debug.l("HevLib ManifestV2: %s added." % fileName)
	dir.list_dir_end()
	
	var initScripts = []
#	Debug.l("HevLib ManifestV2: checking zips")
	for modFSPath in _modZipFiles:
		var gdunzip = gd.new()
		gdunzip.load(modFSPath)
		for modEntryPath in gdunzip.files:
			var modEntryName = modEntryPath.get_file().to_lower()
			if modEntryName.begins_with("modmain") and modEntryName.ends_with(".gd"):
				var modGlobalPath = "res://" + modEntryPath
				var zipName = modFSPath.split("/")[modFSPath.split("/").size() - 1]
				initScripts.append([modGlobalPath,zipName])
	for item in initScripts:
		if item[0] == mod_main_path:
#			Debug.l("HevLib ManifestV2: %s matches, returning as %s." % [item[0],item[1]])
			return item[1]
#	Debug.l("HevLib ManifestV2: no matches found, is the mod installed or run via the Godot editor?.")
	return ""
