extends Node

# [license]
# 3-Clause BSD NON-AI License
# 
# Copyright 2026 __hev (Benjamin Buckhurst)
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.
# 
# 4. The source code and the binary form, and any modifications made to them may not be used for the purpose of input data, the training of, or improvment of machine learning algorithms,
# including but not limited to artificial intelligence, natural language processing, or data mining. This condition applies to any derivatives,
# modifications, or updates based on the Software code. Any usage of the source code or the binary form in an AI-training dataset is considered a breach of this License.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# [/license]

var cacheExtension = ".hevlibucache"
var slatedForUpdateCacheFolder = "user://cache/.HevLib_Cache/updatecache/current_mod_caches/"
var githubDataCache = "user://cache/.HevLib_Cache/updatecache/github_cache/"
var persistUpdateCacheFolder = "user://cache/.HevLib_Cache/updatecache/persistent_mod_caches/"
var zipStore = "user://cache/.HevLib_Cache/updatecache/downloaded_zips/"
var zipCache = "user://cache/.HevLib_Cache/updatecache/zip_data_cache/"
var debugPrefix = "HevLib Github Release Fetcher: "


var childData = {}
var dataDictionary = {}
var updateMods = []

var pointers = ModLoader._savedObjects[0]

func handleZips():
	
	var zipList = pointers.FolderAccess.__fetch_folder_files(zipStore)
	for zip in zipList:
		var dataStore
		var zipCacheFilename = zip + cacheExtension
		var zipCacheStore = zipCache + zip + "/"
		pointers.FolderAccess.__check_folder_exists(zipCacheStore)
		var fetchedManifest = pointers.Zip.__fetch_file_from_zip(zipStore + zip, zipCacheStore, ["mod.manifest"])
		var manifestData = pointers.ManifestV1.__load_manifest_from_file(pointers.DataFormat.__array_to_string(fetchedManifest))["package"]
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
		file.open("user://cache/.HevLib_Cache/updatecache/mod.updates", File.WRITE)
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
