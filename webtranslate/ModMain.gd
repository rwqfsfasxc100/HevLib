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
	updateTL("res://HevLib/i18n/en.txt","|",false,false)
	updateTL("res://HevLib/i18n/en_transit_tips.txt","|",false,false)
	updateTL("res://HevLib/i18n/uk_UA.txt","|",false,false)
var modPath:String = get_script().resource_path.get_base_dir() + "/"
func _ready():
	l("Readying")
	
	# var WebTranslate = preload("res://HevLib/pointers/WebTranslate.gd")
	# WebTranslate.__webtranslate("https://github.com/rwqfsfasxc100/HevLib",[[modPath + "i18n/en.txt", "|"]], "res://HevLib/webtranslate/ModMain.gd")
	
#	loadTranslationsFromCache()
	
	l("Ready")

var cache_extension = ".file_check_cache"

func loadTranslationsFromCache():
	var accepted = false
	var FolderAccess = load("res://HevLib/pointers/FolderAccess.gd").new()
	var WebTranslateCache = "user://cache/.HevLib_Cache/WebTranslate/"
	FolderAccess.__check_folder_exists(WebTranslateCache)
	var cacheContent = FolderAccess.__fetch_folder_files(WebTranslateCache, true)
	for folder in cacheContent:
		var folderPath = WebTranslateCache + folder
		var files = FolderAccess.__fetch_folder_files(folderPath)
		var cache_location_exists = false
		for file in files:
			var filePath = str(folderPath + file)
			var ffile = str(file)
			if ffile.ends_with(cache_extension):
				cache_location_exists = true
				var f = File.new()
				f.open(filePath,File.READ)
				var txt = f.get_as_text()
				f.close()
				var dir = Directory.new()
				var does = dir.file_exists(txt)
				if does:
					Debug.l("WebTranslate: available translations from cache at %s" % ffile)
					accepted = true
				
			else:
				continue
		if not cache_location_exists:
			FolderAccess.__recursive_delete(folderPath)
		if accepted:
			for file in files:
				var filePath = str(folderPath + file)
				var ffile = str(file)
				if ffile.ends_with(cache_extension):
					continue
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
	var err = tlFile.open(path, File.READ)
	
	if err != OK:
		return
	
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
		var size = csvLine.size()
		if size > 1:
			if size > 2:
				var i = 0
				while i < size:
					if csvLine[i].ends_with("\\") and i < size:
						csvLine[i] = csvLine[i] + delim + csvLine[i + 1]
						csvLine.remove(i + 1)
						size -= 1
					i += 1
			var translationID := csvLine[0]
			for i in range(1, size):
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
