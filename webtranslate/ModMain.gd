extends Node

# Set mod priority if you want it to load before/after other mods
# Mods are loaded from lowest to highest priority, default is 0
const MOD_PRIORITY = INF
# Name of the mod, used for writing to the logs
const MOD_NAME = "HevLib Library WebTranslate Module"
const MOD_VERSION = "1.0.0"
const MOD_VERSION_MAJOR = 1
const MOD_VERSION_MINOR = 0
const MOD_VERSION_BUGFIX = 0
const MOD_VERSION_METADATA = ""
const MOD_IS_LIBRARY = true
func _init(modLoader = ModLoader):
	l("Initializing WebTranslate")
var modPath:String = get_script().resource_path.get_base_dir() + "/"
func _ready():
	l("Readying")
	
	var WebTranslate = preload("res://HevLib/pointers/WebTranslate.gd")
	WebTranslate.__webtranslate("https://github.com/rwqfsfasxc100/HevLib",[[modPath + "i18n/en.txt", "|"]])
	
	loadTranslationsFromCache()
	
	l("Ready")
	
func loadTranslationsFromCache():
	var FolderAccess = preload("res://HevLib/pointers/FolderAccess.gd").new()
	var WebTranslateCache = "user://cache/.HevLib_Cache/WebTranslate/"
	FolderAccess.__check_folder_exists(WebTranslateCache)
	var cacheContent = FolderAccess.__fetch_folder_files(WebTranslateCache, true)
	for folder in cacheContent:
		var folderPath = WebTranslateCache + folder
		var files = FolderAccess.__fetch_folder_files(folderPath)
		for file in files:
			var filePath = str(folderPath + file)
			var ffile = str(file)
			var dm = ffile.split("--")[1]
			var does = true
			if str(dm).ends_with("]"):
				does = false
			if does:
				var vm = dm.split("-~-")
				var mv = PoolByteArray()
				for itm in vm:
					mv.append(int(itm))
				var delim = mv.get_string_from_utf8()
				updateTL(filePath,delim,false,false)
			else:
				var dir = Directory.new()
				dir.remove(filePath)
# Helper script to load translations using csv format
# `path` is the path to the transalation file
# `delim` is the symbol used to seperate the values
# `useRelativePath` setting it to false uses a `res://` relative path instead of relative to the file
# `fullLogging` setting it to false reduces the number of logs written to only display the number of translations made
# example usage: updateTL("i18n/translation.txt", "|")
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
		TranslationServer.add_translation(translationObject)
	l("%s Translations Updated" % translationCount)


# Func to print messages to the logs
func l(msg:String, title:String = MOD_NAME, version:String = MOD_VERSION):
	Debug.l("[%s V%s]: %s" % [title, version, msg])
