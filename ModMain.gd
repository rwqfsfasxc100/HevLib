extends Node

const MOD_PRIORITY = INF
const MOD_NAME = "HevLib"
const MOD_VERSION = "1.5.11"
const MOD_VERSION_MAJOR = 1
const MOD_VERSION_MINOR = 5
const MOD_VERSION_BUGFIX = 11
const MOD_VERSION_METADATA = ""
const MOD_IS_LIBRARY = true
var modPath:String = get_script().resource_path.get_base_dir() + "/"
var _savedObjects := []
var modConfig = {}
var HevLibModMain = true
func _init(modLoader = ModLoader):
	l("Initializing DLC")
	loadDLC()
	loadSettings()
	installScriptExtension("events/TheRing.gd")
func _ready():
	l("Readying")
#	replaceScene("scenes/scene_replacements/MouseLayer.tscn", "res://menu/MouseLayer.tscn")
	if ModLoader.is_debugged:
		replaceScene("scenes/scene_replacements/TitleScreen.tscn", "res://TitleScreen.tscn")
#	var mouse = load("res://HevLib/scenes/scene_replacements/MouseLayer.tscn").instance()
	var CRoot = get_tree().get_root()
#	CRoot.call_deferred("add_child",mouse)
	replaceScene("scenes/scene_replacements/TheRing.tscn", "res://story/TheRing.tscn")
	replaceScene("scenes/scene_replacements/Game.tscn", "res://Game.tscn")
	var dir = Directory.new()
	dir.make_dir_recursive("user://cache/.HevLib_Cache/")
	var file = File.new()
	file.open("user://cache/.HevLib_Cache/library_documentation.json", File.WRITE)
	file.store_string(load("res://HevLib/pointers/HevLib.gd").__get_library_functionality(true))
	file.close()
	l("Ready")
func installScriptExtension(path:String):
	var childPath:String = str(modPath + path)
	var childScript:Script = ResourceLoader.load(childPath)
	childScript.new()
	var parentScript:Script = childScript.get_base_script()
	var parentPath:String = parentScript.resource_path
	l("Installing script extension: %s <- %s" % [parentPath, childPath])
	childScript.take_over_path(parentPath)
func replaceScene(newPath:String, oldPath:String = ""):
	l("Updating scene: %s" % newPath)
	if oldPath.empty():
		oldPath = str("res://" + newPath)
	newPath = str(modPath + newPath)
	var scene := load(newPath)
	scene.take_over_path(oldPath)
	_savedObjects.append(scene)
	l("Finished updating: %s" % oldPath)
func loadDLC():
	l("Preloading DLC as workaround")
	var DLCLoader:Settings = preload("res://Settings.gd").new()
	DLCLoader.loadDLC()
	DLCLoader.queue_free()
	l("Finished loading DLC")
func l(msg:String, title:String = MOD_NAME, version:String = MOD_VERSION):
	Debug.l("[%s V%s]: %s" % [title, version, msg])
func loadSettings():
	installScriptExtension("Settings.gd")
	l(MOD_NAME + ": Loading mod settings")
	var settings = load("res://Settings.gd").new()
	settings.load_HevLib_FromFile()
	settings.save_HevLib_ToFile()
	modConfig = settings.HevLib
	l(MOD_NAME + ": Current settings: %s" % modConfig)
	settings.queue_free()
	l(MOD_NAME + ": Finished loading settings")
