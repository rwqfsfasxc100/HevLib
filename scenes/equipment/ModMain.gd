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

var cache_dir = "user://cache/.HevLib_Cache"

var checksum = "user://cache/.HevLib_Cache/checksums"

var f = File.new()
var d = Directory.new()
var correct = d.file_exists("res://HevLib/pointers.gd")
var pointers = null

func _init(modLoader : ModLoader = ModLoader):
	if correct:
		pointers = load("res://HevLib/pointers.gd").new()
		pointers.name = "HevLib~Pointers"
		if modLoader._savedObjects:
			var new_objects = [pointers]
			for i in modLoader._savedObjects:
				new_objects.append(i)
			modLoader._savedObjects = new_objects
		else:
			modLoader._savedObjects.append(pointers)
		l("Initializing Equipment Driver")
		pointers.FolderAccess.__recursive_delete("user://cache/.HevLib_Cache/")
		var variables_folder = "user://cache/.HevLib_Cache/Variable_Fetch/"
		d.make_dir_recursive(variables_folder)
		pointers.equipment_modmain = self
		pointers.FileAccess.__load_precached_mods()
		
#		testing(pointers)
		
		match_mod_path_to_zip()
		var scv = pointers.FolderAccess.__fetch_folder_files(variables_folder,false,true)
		for s in scv:
			d.remove(s)
		var fstr_old = "user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/file_caches"
		if d.dir_exists(fstr_old):
			pointers.FolderAccess.__recursive_delete(fstr_old)
		pointers.ConfigDriver.__load_configs()
		pointers.Translations.__inject_translations()
		
		installScriptExtension("../notification_driver/CurrentGame.gd")
		if pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DRIVERS","multiple_minerals_per_chunk"):
			installScriptExtension("../minerals/multiminerals/mineral.gd")
			installScriptExtension("../minerals/multiminerals/MineralProcessingUnit.gd")
			installScriptExtension("../minerals/multiminerals/AsteroidSpawner.gd")
		
		
		# Bind button display modifications
		installScriptExtension("../keymapping/bind_displays/AnalogAxisDisplay.gd")
		installScriptExtension("../keymapping/bind_displays/GamepadKeybindDisplay.gd")
		installScriptExtension("../keymapping/bind_displays/KeybindDisplay.gd")
		installScriptExtension("../keymapping/bind_displays/MousebindDisplay.gd")
		
		
		installScriptExtension("../../ui/ExtensionPopup.gd")
		installScriptExtension("../scene_replacements/DLClist.gd")
		replaceScene("../scene_replacements/DLClist.tscn","res://tools/DLClist.tscn")

		installScriptExtension("../better_title_screen/CurrentlyPlaying.gd")
		
		installScriptExtension("../minerals/AstrogatorPanel.gd")
		installScriptExtension("../minerals/OMS.gd")
		installScriptExtension("../minerals/CargoScanner.gd")
		installScriptExtension("../minerals/ProcessedCargoManifest.gd")
		
		pointers.Scripting.make_mineral_scripting()

		replaceScene("../../events/chaos_map/RingTelescopeView.tscn","res://hud/components/RingTelescopeView.tscn")
		# Adds in_hevlib_menu to the CurrentGame script and preventing controls while it's true
		installScriptExtension("../../events/controls/CurrentGame.gd")
		installScriptExtension("../../events/controls/ship-ctrl.gd")
		installScriptExtension("../../scripts/Namer.gd")

		installScriptExtension("ThrusterSlot.gd")
		installScriptExtension("SystemShipUpgradeUI.gd")
		installScriptExtension("UpgradeGroup.gd")
		installScriptExtension("hardpoints/EquipmentItemTemplate.gd")

		installScriptExtension("../weaponslot/weapon_slot_handler.gd")

		installScriptExtension("ShipModificationDriver/AddNodes.gd")
		installScriptExtension("ShipModificationDriver/InternalStorageMod.gd")

		installScriptExtension("../better_title_screen/SaveSlotButton.gd")
		
		var for_reload = pointers.ManifestV2.__load_modlets(false)
		for old_path in for_reload:
			pointers.DataFormat.__reload_scene(old_path)
	else:
		Debug.l("Folder structure not correct, exiting HevLib load")
	
func _ready():
	if correct:
		l("Readying")
		
		pointers.Scripting.make_ring_modifications()
		
		pointers.Equipment.__make_upgrades_scene()
		
		installScriptExtension("../minerals/Summary.gd")
		
		replaceScene("Upgrades.tscn", "res://enceladus/Upgrades.tscn")

		replaceScene("../minerals/multiminerals/AsteroidField.tscn","res://AsteroidField.tscn")
		
		var for_reload = pointers.ManifestV2.__load_modlets(true)
		for old_path in for_reload:
			pointers.DataFormat.__reload_scene(old_path)
		l("Ready")
	else:
		Debug.l("HevLib Equipment Driver onready process cannot be carried out")
func installScriptExtension(path:String):
	var childPath:String = str(modPath + path)
	var childScript:Script = load(childPath)

	childScript.new()

	var parentScript:Script = childScript.get_base_script()
	var parentPath:String = parentScript.resource_path

	l("Installing script extension: %s <- %s" % [parentPath, childPath])

	childScript.take_over_path(parentPath)
	_savedObjects.append(childScript)
func installScriptExtensionFromSource(source_code:String):
	var out = GDScript.new()
	out.set_source_code(source_code)
	out.reload()
	
	var parentScript:Script = out.get_base_script()
	var parentPath:String = parentScript.resource_path
	l("Installing script extension from source to: %s" % [parentPath])
	out.take_over_path(parentPath)
	_savedObjects.append(out)


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
func replaceSceneLiteral(newPath:String, oldPath:String):
	l("Updating scene literal: %s" % newPath)

	var scene := load(newPath)
	if scene and scene.can_instance():
		scene.take_over_path(oldPath)
		_savedObjects.append(scene)
		l("Finished updating literal: %s" % oldPath)

# Func to print messages to the logs
func l(msg:String, title:String = MOD_NAME, version:String = MOD_VERSION):
	var line = "%s V%s" % [title, version]
	pointers.l(msg,line)

func match_mod_path_to_zip():
	var _modZipFiles = []
	var zipModMainCache = {}
	var gameInstallDirectory = OS.get_executable_path().get_base_dir()
	if OS.get_name() == "OSX":
		gameInstallDirectory = gameInstallDirectory.get_base_dir().get_base_dir().get_base_dir()
	var modPathPrefix = gameInstallDirectory.plus_file("mods")
	var gd = load("res://HevLib/scripts/vendor/gdunzip.gd")
	var dir = Directory.new()
	if dir.open(modPathPrefix) != OK:
		return ""
	if dir.list_dir_begin() != OK:
		return ""

	while true:
		var fileName = dir.get_next()
		if fileName == "":
			break
		if dir.current_is_dir():
			continue
		var modFSPath = modPathPrefix.plus_file(fileName)
		var modGlobalPath = ProjectSettings.globalize_path(modFSPath)
		if pointers.DataFormat.__file_exists(modFSPath):
			_modZipFiles.append(modFSPath)
	dir.list_dir_end()
	var modFiles = []
	var mods = pointers.ManifestV2.__get_mod_data()["mods"]
	for mod in mods:
		modFiles.append(mod.to_lower())
	for modFSPath in _modZipFiles:
		var gdunzip = gd.new()
		gdunzip.load(modFSPath)
		for modEntryPath in gdunzip.files:
			var modEntryName = modEntryPath.get_file().to_lower()
			var modGlobalPath = "res://" + modEntryPath
			if modGlobalPath.to_lower() in modFiles:
				var zipName = modFSPath.split("/")[modFSPath.split("/").size() - 1]
				zipModMainCache[modGlobalPath] = modFSPath
	pointers.ManifestV2.zip_ref_store = zipModMainCache
	


func testing(pointers):
#	var time = (OS.get_unix_time_from_datetime({"day": 16, "hour": 11, "minute": 50, "month": 9, "second": 0, "year": 2273})) / (168.0 * 3600.0)
#	var t2 = time - floor(time)
#	var t3 = abs((t2*7) - 7)
#	var v : Array = PoolStringArray()
#	var can : Script = load("res://AymursEquipmentSuite/ModMain.gd").can_instance()
#	var can : Script = load("res://HevLib/ModMain.gd")
#	var prop = can.can_instance()
	
	
	breakpoint
