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

var ship_driver_path = "user://cache/.HevLib_Cache/ShipDriver/"

var checksum = "user://cache/.HevLib_Cache/checksums"

var f = File.new()
var d = Directory.new()
var correct = d.file_exists("res://HevLib/pointers.gd")
var pointers = null

func _init(modLoader : ModLoader = ModLoader):
	if correct:
		l("Initializing Equipment Driver")
		var variables_folder = "user://cache/.HevLib_Cache/Variable_Fetch/"
		d.make_dir_recursive(variables_folder)
		if not d.dir_exists(deviceinfostore):
			d.make_dir_recursive(deviceinfostore)
		f.open(deviceinfocache,File.WRITE)
		f.store_string("")
		f.close()
		pointers = load("res://HevLib/pointers.gd").new()
		if modLoader._savedObjects:
			var new_objects = [pointers]
			for i in modLoader._savedObjects:
				new_objects.append(i)
			modLoader._savedObjects = new_objects
		else:
			modLoader._savedObjects.append(pointers)
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
		var injector = load("res://HevLib/scripts/translations/inject_translations.gd")
		injector.inject_translations(pointers)
		
		d.make_dir_recursive(ship_driver_path)
		var ml = MainLoop.new()
		ml.set_script(load("res://HevLib/scripts/crash_handler.gd"))
		_savedObjects.append(ml)
		
		
		
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
		var minerals = load("res://HevLib/scenes/minerals/make_mineral_scripting.gd")
		minerals.make_mineral_scripting(pointers)

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
		storeLogCache()
	else:
		l("Folder structure not correct, exiting HevLib load")
	
func _ready():
	if correct:
		l("Readying")
		
		
		var ring = load("res://HevLib/scenes/minerals/make_ring_modifications.gd")
		ring.make_ring_modifications(pointers)
		
		
		
#		var tr = ResourceLoader.load(thering_path)
#		tr.new()
#		tr.take_over_path("res://TheRing.gd")
#		_savedObjects.append(tr)
		f.open(ringscene_path,File.WRITE)
		f.store_string("[gd_scene load_steps=3 format=2]\n\n[ext_resource path=\"%s\" type=\"Script\" id=1]\n[ext_resource path=\"res://story/TheRing.tscn\" type=\"PackedScene\" id=2]\n\n[node name=\"TheRing\" instance=ExtResource( 2 )]\nscript = ExtResource( 1 )\n" % ["res://TheRing.gd"])#thering_path)
		f.close()
		var rs := load(ringscene_path)
		rs.take_over_path("res://story/TheRing.tscn")
		_savedObjects.append(rs)
		
		
		
		pointers.Equipment.__make_upgrades_scene()
		var upgrades = load(upgrades_path)
		upgrades.take_over_path("res://enceladus/Upgrades.tscn")
		_savedObjects.append(upgrades)
		
		var slot_limits = load(slot_limits_path)
		slot_limits.take_over_path("res://enceladus/Upgrades.tscn")
		_savedObjects.append(slot_limits)
		
#		var aux = load(aux_path)
#		aux.take_over_path("res://ships/modules/AuxSlot.tscn")
#		_savedObjects.append(aux)

#		var ws = load(weaponslot_path)
#		ws.take_over_path("res://weapons/WeaponSlot.tscn")
#		_savedObjects.append(ws)
		
		installScriptExtension("../minerals/Summary.gd")
#		replaceScene("../minerals/DiveSummary.tscn","res://enceladus/DiveSummary.tscn")
		
		replaceScene("Upgrades.tscn", "res://enceladus/Upgrades.tscn")
#		replaceScene("Enceladus.tscn","res://enceladus/Enceladus.tscn")
#		installScriptExtension("../scene_replacements/Shipyard.gd")

		replaceScene("../minerals/multiminerals/AsteroidField.tscn","res://AsteroidField.tscn")
		
		var for_reload = pointers.ManifestV2.__load_modlets(true)
		for old_path in for_reload:
			pointers.DataFormat.__reload_scene(old_path)
		l("Ready")
		storeLogCache()
	else:
		l("HevLib Equipment Driver onready process cannot be carried out")
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
	scene.take_over_path(oldPath)
	_savedObjects.append(scene)
	l("Finished updating literal: %s" % oldPath)

# Func to print messages to the logs
var logCache = ""
func l(msg:String, title:String = MOD_NAME, version:String = MOD_VERSION):
	var line = "[%s V%s]: %s" % [title, version, msg]
	Debug.l(line)
	logCache += line + "\n"

var deviceinfostore:String = "user://cache/.Mod_Menu_2_Cache/EssentialsLogCache/"
var deviceinfocache:String = deviceinfostore + "DeviceInfoCache"

func storeLogCache():
	f.open(deviceinfocache,File.READ)
	var ov = f.get_as_text(true)
	f.close()
	ov += logCache
	f.open(deviceinfocache,File.WRITE)
	f.store_string(ov)
	f.close()
	logCache = ""

func match_mod_path_to_zip():
	var zip_ref_store = "user://cache/.HevLib_Cache/zip_ref_store.json"
	f.open(zip_ref_store,File.WRITE)
	f.store_string("{}")
	f.close()
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
	f.open(zip_ref_store,File.WRITE)
	f.store_string(JSON.print(zipModMainCache))
	f.close()
	


func testing(pointers):
#	var time = (OS.get_unix_time_from_datetime({"day": 16, "hour": 11, "minute": 50, "month": 9, "second": 0, "year": 2273})) / (168.0 * 3600.0)
#	var t2 = time - floor(time)
#	var t3 = abs((t2*7) - 7)
#	var v : Array = PoolStringArray([])
	
	
	pass
