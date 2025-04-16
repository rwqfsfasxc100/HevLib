extends Node

var Globals = preload("res://ModMenu/Globals.gd").new()


var cacheExtension = ".modmenucache"
var slatedForUpdateCacheFolder = "user://cache/.Mod_Menu_Cache/updatecache/current_mod_caches/"
var githubDataCache = "user://cache/.Mod_Menu_Cache/updatecache/github_cache/"
var persistUpdateCacheFolder = "user://cache/.Mod_Menu_Cache/updatecache/persistent_mod_caches/"
var zipStore = "user://cache/.Mod_Menu_Cache/updatecache/downloaded_zips/"
var zipCache = "user://cache/.Mod_Menu_Cache/updatecache/zip_data_cache/"
var debugPrefix = "Mod Menu Update Checker: "


var childData = {}
var dataDictionary = {}
var updateMods = []

func handleZips():
	
	var zipList = Globals.__fetch_folder_files(zipStore)
	for zip in zipList:
		var dataStore
		var zipCacheFilename = zip + cacheExtension
		var zipCacheStore = zipCache + zip + "/"
		Globals.__check_folder_exists(zipCacheStore)
		var fetchedManifest = Globals.__fetch_file_from_zip(zipStore + zip, zipCacheStore, ["mod.manifest"])
		var manifestData = Globals.__load_manifest_from_file(Globals.__array_to_string(fetchedManifest))["package"]
		dataStore = {
			manifestData["id"]:
				[manifestData["name"], manifestData["version"],zip]
		}
		dataDictionary.merge(dataStore)
	var modDir = get_parent().get_parent().get_node("VBoxContainer")
	var childNodes = modDir.get_children()
	
	for child in childNodes:
		var childInfo = child.editor_description
		var childInfoSorted = {
			childInfo.split("\n")[15]:
				[childInfo.split("\n")[0],
				childInfo.split("\n")[1],
				childInfo.split("\n")[4]],
		}
		if not childInfo.split("\n")[15] == "MODMENU_ID_PLACEHOLDER":
			childData.merge(childInfoSorted)
	var installedMods = childData.keys()
	var downloadedZips = dataDictionary.keys()
	for mod in downloadedZips:
		for current in installedMods:
			if current == mod:
				compareVersions(current)
	if updateMods.size() >= 1:
		var updates = ""
		for n in updateMods:
			var secondaryData = dataDictionary[n]
			var updateData = n + "~||~" + secondaryData[0] + "~||~" + secondaryData[1] + "~||~" + secondaryData[2]
			if not updates == "":
				updates = updates + "\n"
			updates = updates + updateData
		
		var file = File.new()
		file.open("user://cache/.Mod_Menu_Cache/updatecache/mod.updates", File.WRITE)
		file.store_string(updates)
		file.close()
	




func compareVersions(mod):
	var versionFromCurrent = childData.get(mod)[2]
	var versionFromDownload = dataDictionary.get(mod)[1]
	var currentSplit = versionFromCurrent.split(".")
	var currentSplitSize = currentSplit.size()
	var downloadSplit = versionFromDownload.split(".")
	var downloadSplitSize = downloadSplit.size()
	if currentSplitSize == 1 and downloadSplitSize == 1:
		var c = compare(versionFromCurrent, versionFromDownload)
		if c:
			updateMods.append(mod)
	elif currentSplitSize == downloadSplitSize:
		var index = 0
		while index +1 <= currentSplitSize:
			var c = compare(currentSplit[index],downloadSplit[index])
			if c:
				updateMods.append(mod)
				break
			index += 1
	
	
	
func compare(current, download):
	if int(download) > int(current):
		return true
	else:
		return false
