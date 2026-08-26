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
# 4. The source code and the binary form, and any modifications made to them may not be used for the purpose of input data, reference code snippets and/or files, OR used in the training of, or improvement of machine learning algorithms,
# including but not limited to artificial intelligence, natural language processing, or data mining. This condition applies to any derivatives,
# modifications, or updates based on the Software code. Any usage of the source code or the binary form may not be present in any form as data fed, inputted, or provided to an AI, or present in any AI-training dataset is considered a breach of this License.
# 
# 5. Any projects deriving work from this project MUST include a copy of this license and all other license and/or copyright agreements posed within other source material,
# all of which must be followed to its entirety. Failure to follow these licenses prohibit all modification and redistribution of the material until all licensing has been reinstated.
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

const MOD_PRIORITY = INF
const MOD_NAME = "HevLib"
const MOD_VERSION_MAJOR = 1
const MOD_VERSION_MINOR = 15
const MOD_VERSION_BUGFIX = 44
const MOD_VERSION_METADATA = ""
const MOD_IS_LIBRARY = true
const LIBRARY_HIDDEN_BY_DEFAULT = false
var modPath:String = get_script().resource_path.get_base_dir() + "/"
var _savedObjects := []
var pointers
var file = File.new()
var pointerDir:String = modPath + "pointers.gd"
var correct = ResourceLoader.exists(pointerDir)
var HevLibModMain = true
func _init(modLoader = ModLoader):
	if correct:
		pointers = modLoader._savedObjects[0]
		l("Initializing HevLib")
		l("Initializing DLC")
		loadDLC()
		
		installScriptExtension("scenes/ship_driver/Shipyard.gd")
		installScriptExtension("scenes/ship_driver/CurrentGame.gd")
		installScriptExtension("scenes/ship_driver/TheRing.gd")
		
		
		
		installScriptExtension("events/TheRing.gd")
		installScriptExtension("events/custom_events/TheRing.gd")
		replaceScene("scenes/scene_replacements/TheRing.tscn", "res://story/TheRing.tscn")
		replaceScene("scenes/notification_driver/Notifications.tscn","res://achievement/Notifications.tscn")
		installScriptExtension("scripts/transit_tips/TransitTip.gd")
	else:
		Debug.l("Folder structure not correct, exiting HevLib load")
	
	
	

var update_urls = PoolStringArray()
var url_store = "user://cache/.Mod_Menu_2_Cache/updates/url_refs.json"
var update_store = "user://cache/.Mod_Menu_2_Cache/updates/needs_updates.json"
var has_updated_store = "user://cache/.Mod_Menu_2_Cache/updates/has_updated.txt"

var dependancies_store = "user://cache/.Mod_Menu_2_Cache/dependancies/dependancies.json"
var conflicts_store = "user://cache/.Mod_Menu_2_Cache/conflicts/conflicts.json"
var complementary_store = "user://cache/.Mod_Menu_2_Cache/complementary/complementary.json"

var weaponslot_cache = "user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/weapon_slot/ship_data"

var event_log_file = "user://cache/.HevLib_Cache/Event_Driver/event_log.json"
var active_events_file = "user://cache/.HevLib_Cache/Event_Driver/active_events.txt"
var latest_event_file = "user://cache/.HevLib_Cache/Event_Driver/latest_event.txt"

var releases_cache = "user://cache/.Mod_Menu_2_Cache/github_list/releases_cache.json"
var modlet_toggle_restart_path = "user://cache/.Mod_Menu_2_Cache/updates/modlet_restart_requests.json"

func _ready():
	if correct:
		l("Readying")
		var p = ProjectSettings.get_setting("locale/translations")
		for i in p:
			var translation = ResourceLoader.load(i,"",true)
			TranslationServer.add_translation(translation)
		
		pointers.FolderAccess.__check_folder_exists("user://cache/.Mod_Menu_2_Cache/updates/manifest_cache/")
		pointers.FolderAccess.__check_folder_exists("user://cache/.Mod_Menu_2_Cache/updates/zip_cache/")
		pointers.FolderAccess.__check_folder_exists("user://cache/.Mod_Menu_2_Cache/dependancies/")
		pointers.FolderAccess.__check_folder_exists("user://cache/.Mod_Menu_2_Cache/conflicts/")
		pointers.FolderAccess.__check_folder_exists("user://cache/.Mod_Menu_2_Cache/complementary/")
		pointers.FolderAccess.__check_folder_exists("user://cache/.Mod_Menu_2_Cache/github_list/icon_cache/")
		pointers.FolderAccess.__check_folder_exists("user://cache/.Mod_Menu_2_Cache/github_list/downloaded_zips/")
		pointers.FolderAccess.__check_folder_exists("user://cache/.HevLib_Cache/Event_Driver/")
		var zips = pointers.FolderAccess.__fetch_folder_files("user://cache/.Mod_Menu_2_Cache/updates/zip_cache/",true,true)
		var zips2 = pointers.FolderAccess.__fetch_folder_files("user://cache/.Mod_Menu_2_Cache/github_list/downloaded_zips/",true,true)
		var manifests = pointers.FolderAccess.__fetch_folder_files("user://cache/.Mod_Menu_2_Cache/updates/manifest_cache/",true,true)
		var d = Directory.new()
		for f in zips:
			d.remove(f)
		for f in zips2:
			d.remove(f)
		for f in manifests:
			d.remove(f)
		if d.dir_exists(weaponslot_cache):
			pointers.FolderAccess.__recursive_delete(weaponslot_cache)
		if file.file_exists(releases_cache):
			var age = OS.get_unix_time() - file.get_modified_time(releases_cache)
			if age > 3600:
				file.open(releases_cache,File.WRITE)
				file.store_string("{}")
				file.close()
				Debug.l("Releases cache older than an hour (%s minutes old), clearing" % [floor(age/60)])
			else:
				Debug.l("Releases cache too new (%s minutes old), not clearing" % [floor(age/60)])
		file.open(url_store,File.WRITE)
		file.store_string("[]")
		file.close()
		file.open(has_updated_store,File.WRITE)
		file.store_string("0")
		file.close()
		file.open(update_store,File.WRITE)
		file.store_string("{}")
		file.close()
		file.open(event_log_file,File.WRITE)
		file.store_string("{}")
		file.close()
		file.open(active_events_file,File.WRITE)
		file.store_string("")
		file.close()
		file.open(latest_event_file,File.WRITE)
		file.store_string("")
		file.close()
		file.open(modlet_toggle_restart_path,File.WRITE)
		file.store_string("[]")
		file.close()
		if OS.has_feature("editor"):
			replaceScene("ui/mod_menu/editor_titlescreen/TitleScreen.tscn","res://TitleScreen.tscn")
		replaceScene("scenes/better_title_screen/TitleScreen.tscn","res://TitleScreen.tscn")
		
		
		
		var conflicts = pointers.ManifestV2.__check_conflicts()
		var dependancies = pointers.ManifestV2.__check_dependancies()
		var complementary = pointers.ManifestV2.__check_complementary()
		
		file.open(conflicts_store,File.WRITE)
		file.store_string(JSON.print(conflicts))
		file.close()
		file.open(dependancies_store,File.WRITE)
		file.store_string(JSON.print(dependancies))
		file.close()
		file.open(complementary_store,File.WRITE)
		file.store_string(JSON.print(complementary))
		file.close()
		
		var CRoot = get_tree().get_root()
		
		replaceScene("scenes/scene_replacements/Game.tscn", "res://Game.tscn")
		var dir = Directory.new()
		dir.make_dir_recursive("user://cache/.HevLib_Cache/")
		
		# Fix this later and update the HevLib class once documentation is finished.
#		file.open("user://cache/.HevLib_Cache/library_documentation.json", File.WRITE)
#		var functionality = pointers.HevLib.__get_library_functionality(true)
#		file.store_string(functionality)
#		file.close()
		
		replaceScene("scenes/crew_extensions/base_expansion_x24.tscn","res://comms/conversation/subtrees/DIALOG_DERELICT_RANDOM.tscn")
		
		installScriptExtension("scenes/research/overhead_handle/Enceladus.gd")
		installScriptExtension("scenes/research/overhead_handle/AsteroidSpawner.gd")
		var nNode = load("res://HevLib/scenes/research/overhead_handle/ResearchOverheadHandle.tscn").instance()
		CRoot.call_deferred("add_child",nNode)
		
		pointers.ManifestV2.__get_mod_versions(true)
		var ncrew = pointers.ManifestV2.__get_manifest_entry("tags","TAG_HANDLE_EXTRA_CREW")
		var count = 24
		for mod in ncrew:
			var data = ncrew[mod]
			if data > count:
				count = data
		pointers.NodeAccess.__dynamic_crew_expander("user://cache/.HevLib_Cache/",count)
		
		if OS.has_feature("editor") and not file.file_exists("res://VersionLabel.tscn"):
			printerr("FAILED TO FETCH FILE SYSTEM")
			l("ERROR! FAILED TO FETCH FILE SYSTEM")
		CRoot.call_deferred("add_child",pointers)
		
#		var console = ResourceLoader.load("res://HevLib/logging/Console.tscn").instance()
#		CRoot.call_deferred("add_child",console)
#		pointers.free()
		l("Ready")
	else:
		Debug.l("HevLib onready process cannot be carried out")
	
func installScriptExtension(path:String):
	var childPath:String = str(modPath + path)
	var childScript:Script = load(childPath)
	childScript.new()
	var parentScript:Script = childScript.get_base_script()
	var parentPath:String = parentScript.resource_path
	l("Installing script extension: %s <- %s" % [parentPath, childPath])
	childScript.take_over_path(parentPath)
	_savedObjects.append(childScript)
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
func l(msg:String, title:String = MOD_NAME, version:String = str(MOD_VERSION_MAJOR) + "." + str(MOD_VERSION_MINOR) + "." + str(MOD_VERSION_BUGFIX)):
	if not MOD_VERSION_METADATA == "":
		version = version + "-" + MOD_VERSION_METADATA
	var line = "%s V%s" % [title, version]
	pointers.l(msg,line)

func _notification(what):
	if what == NOTIFICATION_CRASH:
		file.open("user://cache/.HevLib_Cache/currently_installed_mods.json", File.WRITE)
		file.store_string(pointers.ManifestV2.__get_mod_data(true))
		file.close()
