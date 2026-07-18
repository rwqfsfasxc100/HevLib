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
