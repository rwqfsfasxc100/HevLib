extends Node

# Set mod priority if you want it to load before/after other mods
# Mods are loaded from lowest to highest priority, default is 0
const MOD_PRIORITY = INF
# Name of the mod, used for writing to the logs
const MOD_NAME = "HevLib"
const MOD_VERSION = "1.3.6"
# Path of the mod folder, automatically generated on runtime
var modPath:String = get_script().resource_path.get_base_dir() + "/"
# Required var for the replaceScene() func to work
var _savedObjects := []

var modConfig = {}
#Initializes the configuration variable. Used by loadSettings.

# Initialize the mod
# This function is executed before the majority of the game is loaded
# Only the Tool and Debug AutoLoads are available
# Script and scene replacements should be done here, before the originals are loaded
func _init(modLoader = ModLoader):
	l("Initializing DLC")
	
# Modify Settings.gd first so we can load config and DLC
	loadDLC() # preloads DLC as things may break if this isn't done
	loadSettings()
	
	
	
	
	
var Globals = preload("res://HevLib/Functions.gd").new()
# Do stuff on ready
# At this point all AutoLoads are available and the game is loaded
func _ready():
	l("Readying")
	var WebTranslate = preload("res://HevLib/pointers/WebTranslate.gd")
	WebTranslate.__webtranslate("https://github.com/rwqfsfasxc100/HevLib",[[modPath + "i18n/en.txt", "|"]])
	replaceScene("scenes/scene_replacements/MouseLayer.tscn", "res://menu/MouseLayer.tscn")
	
	# Test button scene that i use for testing these functions
	if ModLoader.is_debugged:
		replaceScene("scenes/scene_replacements/TitleScreen.tscn", "res://TitleScreen.tscn")
	
	
	var NodeNew = Node.new()
	NodeNew.set_script(load("res://HevLib/Variables.gd"))
	NodeNew.name = "HevLib~Variables"
	var Gamespace_Canvas = load("res://HevLib/ui/core_scenes/_HevLib_Gamespace_Canvas.tscn").instance()
	var mouse = load("res://HevLib/scenes/scene_replacements/MouseLayer.tscn").instance()
	var CRoot = get_tree().get_root()
	CRoot.call_deferred("add_child",NodeNew)
	CRoot.call_deferred("add_child",Gamespace_Canvas)
	CRoot.call_deferred("add_child",mouse)
	loadTranslationsFromCache()
	
	replaceScene("scenes/scene_replacements/Game.tscn", "res://Game.tscn")
	l("Ready")
	

func loadTranslationsFromCache():
	var WebTranslateCache = "user://cache/.HevLib_Cache/WebTranslate/"
	Globals.__check_folder_exists(WebTranslateCache)
	var cacheContent = Globals.__fetch_folder_files(WebTranslateCache, true)
	for folder in cacheContent:
		var folderPath = WebTranslateCache + folder
		var files = Globals.__fetch_folder_files(folderPath)
		for file in files:
			var filePath = str(folderPath + file)
			var ffile = str(file)
			var dm = ffile.split("--")[1]
			var dm5 = str(dm).split("[")[1]
			var dm6 = str(dm5).split("]")[0]
			var vm = [dm6]
			var dm2 = PoolByteArray(vm)
			var delim = dm2.get_string_from_utf8()
			updateTL(filePath,delim,false)

# Helper script to load translations using csv format
# `path` is the path to the transalation file
# `delim` is the symbol used to seperate the values
# `useRelativePath` setting it to false uses a `res://` relative path instead of relative to the file
# `fullLogging` setting it to false reduces the number of logs written to only display the number of translations made
# exampleexample usage: updateTL("i18n/translation.txt", "|")
func updateTL(path:String, delim:String = ",", useRelativePath:bool = true, fullLogging:bool = true):
	if useRelativePath:
		path = str(modPath + path)
	l("Adding translations from: %s" % path)
	var tlFile:File = File.new()
	tlFile.open(path, File.READ)

	var translations := []
	
	var translationCount = 0
	var csvLine := tlFile.get_line().split(delim)
	if fullLogging:
		l("Adding translations as: %s" % csvLine)
	for i in range(1, csvLine.size()):
		var translationObject := Translation.new()
		translationObject.locale = csvLine[i]
		translations.append(translationObject)

	while not tlFile.eof_reached():
		csvLine = tlFile.get_csv_line(delim)

		if csvLine.size() > 1:
			var translationID := csvLine[0]
			for i in range(1, csvLine.size()):
				translations[i - 1].add_message(translationID, csvLine[i].c_unescape())
			if fullLogging:
				l("Added translation: %s" % csvLine)
			translationCount += 1

	tlFile.close()

	for translationObject in translations:
		var pms = translationObject.get_message_list()
		var pmL = []
		for m in pms:
			var pt = translationObject.get_message(m)
			pmL.append([m,pt])
		var tr = TranslationServer.translate(pms[0])
		TranslationServer.add_translation(translationObject)
		var pms2 = translationObject.get_message_list()
		var tr2 = TranslationServer.translate(pms[0])
		
		
		
		pass
	l("%s Translations Updated" % translationCount)


# Helper function to extend scripts
# Loads the script you pass, checks what script is extended, and overrides it
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


# Instances Settings.gd, loads DLC, then frees the script.
func loadDLC():
	l("Preloading DLC as workaround")
	var DLCLoader:Settings = preload("res://Settings.gd").new()
	DLCLoader.loadDLC()
	DLCLoader.queue_free()
	l("Finished loading DLC")


# Func to print messages to the logs
func l(msg:String, title:String = MOD_NAME, version:String = MOD_VERSION):
	Debug.l("[%s V%s]: %s" % [title, version, msg])
	
	
# This function is a helper to provide any file configurations to your mod
# You may want to replace any "Example" text with your own identifier to make it unique
# Check the example Settings.gd file for how to setup that side of it
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
