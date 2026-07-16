extends Node

const MOD_PRIORITY = INF
const MOD_NAME = "HevLib"
const MOD_VERSION_MAJOR = 1
const MOD_VERSION_MINOR = 15
const MOD_VERSION_BUGFIX = 8
const MOD_VERSION_METADATA = ""
const MOD_IS_LIBRARY = true
const LIBRARY_HIDDEN_BY_DEFAULT = false
var modPath:String = get_script().resource_path.get_base_dir() + "/"
var _savedObjects := []

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

var enable_research = false

var pointers

var file = File.new()
var correct = ResourceLoader.exists("res://HevLib/pointers.gd")
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
		replaceScene("scenes/scene_replacements/TheRing.tscn", "res://story/TheRing.tscn")
		replaceScene("scenes/notification_driver/Notifications.tscn","res://achievement/Notifications.tscn")
		installScriptExtension("scripts/transit_tips/TransitTip.gd")
		var self_path = self.get_script().get_path()
		var self_directory = self_path.split(self_path.split("/")[self_path.split("/").size() - 1])[0]
		var self_check = load(self_directory + "self_check.tscn").instance()
		add_child(self_check)
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
		
		initiate_mod_update_fetch()
#		network_send()
		
		
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
		var file = File.new()
		
		# Fix this later and update the HevLib class once documentation is finished.
#		file.open("user://cache/.HevLib_Cache/library_documentation.json", File.WRITE)
#		var functionality = pointers.HevLib.__get_library_functionality(true)
#		file.store_string(functionality)
#		file.close()
		
		var cache_folder = "user://cache/.HevLib_Cache/Equipment_Driver/"
		replaceScene("scenes/crew_extensions/base_expansion_x24.tscn","res://comms/conversation/subtrees/DIALOG_DERELICT_RANDOM.tscn")
#		var CRoot = get_tree().get_root()
		
		installScriptExtension("scenes/research/overhead_handle/Enceladus.gd")
		installScriptExtension("scenes/research/overhead_handle/AsteroidSpawner.gd")
		var nNode = load("res://HevLib/scenes/research/overhead_handle/ResearchOverheadHandle.tscn").instance()
		CRoot.call_deferred("add_child",nNode)
		var scene = load("res://HevLib/scenes/better_title_screen/TitleScreen.tscn")
		
		pointers.ManifestV2.__get_mod_versions(true)
		var ncrew = pointers.ManifestV2.__get_manifest_entry("tags","TAG_HANDLE_EXTRA_CREW")
		var count = 24
		for mod in ncrew:
			var data = ncrew[mod]
			if data > count:
				count = data
		var crew = pointers.NodeAccess.__dynamic_crew_expander("user://cache/.HevLib_Cache/",count)
		
		if enable_research:
			replaceScene("scenes/research/Enceladus.tscn","res://enceladus/Enceladus.tscn")
		
		
#		var gameFiles = pointers.FolderAccess.__get_folder_structure("res://",false)
#		file.open("user://cache/.HevLib_Cache/filesys.json",File.WRITE)
#		if gameFiles.size() == 0:
		if OS.has_feature("editor") and not file.file_exists("res://VersionLabel.tscn"):
			printerr("FAILED TO FETCH FILE SYSTEM")
			l("ERROR! FAILED TO FETCH FILE SYSTEM")
#		var sys = JSON.print(gameFiles,"\t")
#		file.store_string(sys)
#		file.close()
#
		
#		var PointerNode = ResourceLoader.load("res://HevLib/pointers.gd","",true).new()
#		var PointerNode = Node.new()
#		PointerNode.set_script(load("res://HevLib/pointers.gd").new())
#		PointerNode.name = "HevLib~Pointers"
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

func initiate_mod_update_fetch():
	var http = HTTPRequest.new()
	http.connect("request_completed",self,"updatelist_return",[http])
	http.timeout = 20
	add_child(http)
	http.request("https://raw.githubusercontent.com/rwqfsfasxc100/dv_update_database/refs/heads/main/manifest_path_store.json")

func updatelist_return(result, response_code,headers,body,mh):
	if result == 0 and response_code == 200:
		var p = JSON.parse(body.get_string_from_utf8()).result
		var ids = pointers.ManifestV2.__get_mod_ids()
		for ID in p:
			if ID in ids:
				var fetchData = p[ID]
				var modData = pointers.ManifestV2.__get_mod_by_id(ID)
				var current_version = modData["version_data"]
				var doUpdate = false
				var newVer = [fetchData["major"],fetchData["minor"],fetchData["bugfix"]]
				if newVer[0] > current_version["version_major"]:
					doUpdate = true
				elif newVer[1] > current_version["version_minor"]:
					doUpdate = true
				elif newVer[2] > current_version["version_bugfix"]:
					doUpdate = true
				if doUpdate:
					var file_name = fetchData.get("file_name","file.zip")
					var fetchURL = "https://github.com/rwqfsfasxc100/dv_update_database/raw/refs/heads/main/zip_store/%s/%d.%d.%d/%s" % [ID,newVer[0],newVer[1],newVer[2],file_name]
					var mod_name = modData.get("name","")
					file.open(update_store,File.READ_WRITE)
					var updates = JSON.parse(file.get_as_text()).result
					updates.merge({ID:{"name":mod_name,"id":ID,"version":[current_version["version_major"],current_version["version_minor"],current_version["version_bugfix"]],"new_version":newVer,"github":fetchURL,"file_name":file_name,"display":mod_name + " (" + ID + ")"}})
					file.store_string(JSON.print(updates))
					file.close()
		if not OS.has_feature("editor") or pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","always_send_new_mods"):
			var md = pointers.ManifestV2.__get_mod_data()["mods"]
			var api_url = "https://publicactiontrigger.azurewebsites.net/api/dispatches/rwqfsfasxc100/dv_update_database"
			for mod in md:
				var mod_data = md[mod]
				if mod_data["manifest"]["has_manifest"]:
					var manifest = mod_data["manifest"]["manifest_data"]
					if "mod_information" in manifest:
						var mid = manifest["mod_information"].get("id","")
						if mid and not mid in p:
							var mURL = ""
							var gURL = ""
							if "manifest_definitions" in manifest:
								mURL = manifest["manifest_definitions"].get("manifest_url","")
							if "links" in manifest:
								if "HEVLIB_GITHUB" in manifest["links"]:
									gURL = manifest["links"]["HEVLIB_GITHUB"].get("URL","")
							if mURL and gURL:
								var pld = {
									"id":mid,
									"manifest_url":mURL,
									"github_url":gURL
								}
								var payload = {"event_type":"add_mod_entry","client_payload":{"data":JSON.print(pld)}}
								var tHTTP = HTTPRequest.new()
								add_child(tHTTP)
								tHTTP.request(api_url,[],true,HTTPClient.METHOD_POST,JSON.print(payload))
								Tool.deferCallInPhysics(Tool,"remove",[tHTTP])
	Tool.deferCallInPhysics(Tool,"remove",[mh])

func network_send():
	var md = pointers.ManifestV2.__get_mod_data()["mods"]
	for item in md:
		var data = md[item]["manifest"]
		if data["has_manifest"]:
			var url = data["manifest_data"]["manifest_definitions"]["manifest_url"]
			if url != "":
				var http = HTTPRequest.new()
				var pm = md[item]
				file.open(url_store,File.READ_WRITE)
				var current = JSON.parse(file.get_as_text()).result
				current.append([pm["name"],pm["manifest"]["manifest_data"]["mod_information"]["id"],pm["version_data"]["version_major"],pm["version_data"]["version_minor"],pm["version_data"]["version_bugfix"]])
				file.store_string(JSON.print(current))
				file.close()
				var mh = str(hash(item))
				http.name = mh
				http.connect("request_completed",self,"network_return",[mh])
				add_child(http)
				http.timeout = 20
				http.request(url)
				update_urls.append(pm["manifest"]["manifest_data"]["mod_information"]["id"])

func network_return(result, response_code,headers,body,mh):
	if result == 0 and response_code == 200:
		var p = body.get_string_from_utf8()
		var path = "user://cache/.Mod_Menu_2_Cache/updates/manifest_cache/network_manifest_%s.cfg"
		var path2 = "user://cache/.Mod_Menu_2_Cache/updates/network_manifest.json"
		var id = 0
		for i in body:
			id += i
		file.open(path % id,File.WRITE)
		file.store_string(p)
		file.close()
		file.open(url_store,File.READ)
		var current = JSON.parse(file.get_as_text(true)).result
		file.close()
		var manifest = pointers.ManifestV2.__parse_file_as_manifest(path % id,true)
		
		for item in current:
			if item[1] in update_urls:
				var nv1 = manifest["version"]["version_major"]
				var nv2 = manifest["version"]["version_minor"]
				var nv3 = manifest["version"]["version_bugfix"]
				var does = pointers.DataFormat.__compare_versions(item[2],item[3],item[4],nv1,nv2,nv3)
				if not does and item[1] == manifest["mod_information"]["id"]:
					file.open(update_store,File.READ_WRITE)
					var updates = JSON.parse(file.get_as_text()).result
					updates.merge({item[1]:{"name":item[0],"id":item[1],"version":[item[2],item[3],item[4]],"new_version":[nv1,nv2,nv3],"github":manifest["links"].get("HEVLIB_GITHUB",{"URL":""}).get("URL",""),"nexus":manifest["links"].get("HEVLIB_NEXUS",{"URL":""}).get("URL",""),"display":item[0] + " (" + item[1] + ")"}})
					file.store_string(JSON.print(updates))
					file.close()
	Tool.deferCallInPhysics(Tool,"remove",[get_node(mh)])

func _notification(what):
	if what == NOTIFICATION_CRASH:
		file.open("user://cache/.HevLib_Cache/currently_installed_mods.json", File.WRITE)
		file.store_string(pointers.ManifestV2.__get_mod_data(true))
		file.close()
