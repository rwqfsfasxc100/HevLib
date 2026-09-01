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

const MOD_PRIORITY = -INF

const MOD_NAME = "HevLib Library Equipment Driver Module"
const MOD_VERSION = "1.0.0"
const MOD_VERSION_MAJOR = 1
const MOD_VERSION_MINOR = 0
const MOD_VERSION_BUGFIX = 0
const MOD_VERSION_METADATA = ""
const MOD_IS_LIBRARY = true

var modPath:String = get_script().resource_path.get_base_dir() + "/"

var _savedObjects := []

var cache_dir:String = "user://cache/.HevLib_Cache"

var file:File = File.new()
var directory:Directory = Directory.new()
var pointerDir:String = modPath.get_base_dir().get_base_dir().get_base_dir() + "/pointers.gd"
var correct:bool = ResourceLoader.exists(pointerDir)
var pointers = null

func _init(modLoader : ModLoader = ModLoader):
	if not correct:
		Debug.l("Folder structure not correct, exiting HevLib load")
		return
	pointers = load(pointerDir).new(pointerDir,self)
	pointers.name = "HevLib~Pointers"
	if modLoader._savedObjects:
		var new_objects = [pointers]
		var firstItemCheck = modLoader._savedObjects[0]
		if "resource_path" in firstItemCheck:
			var RP=firstItemCheck.resource_path
			if RP=="res://HevLib/pointers.gd"or RP==pointerDir:OS.alert("HevLib is double-loaded. Please remove any extra zip files and restart the game.")
		for i in modLoader._savedObjects:new_objects.append(i)
		modLoader._savedObjects=new_objects
	else:modLoader._savedObjects.append(pointers)
	l("Initializing Equipment Driver")
	pointers.FolderAccess.__recursive_delete("user://cache/.HevLib_Cache/")
	var variables_folder = "user://cache/.HevLib_Cache/Variable_Fetch/"
	directory.make_dir_recursive(variables_folder)
	pointers.FileAccess.__load_precached_mods()
	
#	testing()
	
	var scv = pointers.FolderAccess.__fetch_folder_files(variables_folder,false,true)
	for s in scv:
		directory.remove(s)
	var fstr_old = "user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/file_caches"
	if directory.dir_exists(fstr_old):
		pointers.FolderAccess.__recursive_delete(fstr_old)
	pointers.ConfigDriver.__load_configs()
	pointers.Translations.__inject_translations()
	
	installScriptExtension("../notification_driver/CurrentGame.gd")
	if pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DRIVERS","multiple_minerals_per_chunk"):
		installScriptExtension("../minerals/multiminerals/mineral.gd")
		installScriptExtension("../minerals/multiminerals/MineralProcessingUnit.gd")
		installScriptExtension("../minerals/multiminerals/AsteroidSpawner.gd")
	
	# Bind button display modifications
	installScriptExtension("../keymapping/bind_displays/AnalogAxisDisplay.gd")
	installScriptExtension("../keymapping/bind_displays/GamepadKeybindDisplay.gd")
	installScriptExtension("../keymapping/bind_displays/KeybindDisplay.gd")
	installScriptExtension("../keymapping/bind_displays/MousebindDisplay.gd")
	installScriptExtension("../../scripts/SteamWebAPI.gd")
	
	
	installScriptExtension("../../ui/ExtensionPopup.gd")
	installScriptExtension("../scene_replacements/DLClist.gd")
	replaceScene("../scene_replacements/DLClist.tscn","res://tools/DLClist.tscn")

	installScriptExtension("../better_title_screen/CurrentlyPlaying.gd")
	
	installScriptExtension("../minerals/AstrogatorPanel.gd")
	installScriptExtension("../minerals/OMS.gd")
	installScriptExtension("../minerals/CargoScanner.gd")
	installScriptExtension("../minerals/ProcessedCargoManifest.gd")
	
	pointers.Scripting.make_mineral_scripting()

	replaceScene("../../events/chaos_map/RingTelescopeView.tscn","res://hud/components/RingTelescopeView.tscn")
	installScriptExtension("../../events/controls/CurrentGame.gd")
	installScriptExtension("../../events/controls/ship-ctrl.gd")
	installScriptExtension("../../events/controls/camera.gd")
	
	installScriptExtension("../research/Enceladus.gd")
	
	installScriptExtension("../../scripts/Namer.gd")

	installScriptExtension("ThrusterSlot.gd")
	installScriptExtension("SystemShipUpgradeUI.gd")
	installScriptExtension("SystemBuyUI.gd")
	installScriptExtension("UpgradeGroup.gd")
	installScriptExtension("hardpoints/EquipmentItemTemplate.gd")

	installScriptExtension("../weaponslot/weapon_slot_handler.gd")

	installScriptExtension("ShipModificationDriver/AddNodes.gd")
	installScriptExtension("ShipModificationDriver/InternalStorageMod.gd")

	installScriptExtension("../better_title_screen/SaveSlotButton.gd")
	
	for old_path in pointers.ManifestV2.__load_modlets(false):
		pointers.DataFormat.__reload_scene(old_path)
var libid = "hev.LIBRARY"
func _ready():
	if not correct:
		Debug.l("HevLib Equipment Driver onready process cannot be carried out")
		return
	l("Readying")
	
	initiate_mod_update_fetch()
	
	pointers.Scripting.make_ring_modifications()
	
	pointers.Equipment.__make_upgrades_scene()
	
	installScriptExtension("../minerals/Summary.gd")
	
	replaceScene("Upgrades.tscn", "res://enceladus/Upgrades.tscn")

	replaceScene("../minerals/multiminerals/AsteroidField.tscn","res://AsteroidField.tscn")
	
	for old_path in pointers.ManifestV2.__load_modlets(true):
		pointers.DataFormat.__reload_scene(old_path)
	l("Ready")

# Mod update checking
signal updates_fetched
var update_store = "user://cache/.Mod_Menu_2_Cache/updates/needs_updates.json"
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
		var updates = {}
		for ID in p:
			if ID in ids:
				var fetchData=p[ID]
				var modData=pointers.ManifestV2.__get_mod_by_id(ID)
				var current_version=modData["version_data"]
				var doUpdate=false
				var newVer=[fetchData["major"],fetchData["minor"],fetchData["bugfix"]]
				var ctr = 0
				while(not doUpdate)and(ctr < 3):
					match ctr:
						0:
							if newVer[0] > current_version["version_major"]:doUpdate = true
							elif newVer[0] < current_version["version_major"]:ctr = 5
						1:
							if newVer[1] > current_version["version_minor"]:doUpdate = true
							elif newVer[1] < current_version["version_minor"]:ctr = 5
						2:
							if newVer[2] > current_version["version_bugfix"]:doUpdate = true
							elif newVer[2] < current_version["version_bugfix"]:ctr = 5
					ctr += 1
				if doUpdate:
					var file_name = fetchData.get("file_name","file.zip")
					var fetchURL = "https://github.com/rwqfsfasxc100/dv_update_database/raw/refs/heads/main/zip_store/%s/%d.%d.%d/%s" % [ID,newVer[0],newVer[1],newVer[2],file_name]
					var mod_name = modData.get("name","")
					updates[ID] = {"name":mod_name,"id":ID,"version":[current_version["version_major"],current_version["version_minor"],current_version["version_bugfix"]],"new_version":newVer,"github":fetchURL,"file_name":file_name,"display":mod_name + " (" + ID + ")"}
		var dont = false
		if libid in p:
			var curr = pointers.ManifestV2.__get_mod_by_id(libid)["version_data"]
			var major = p[libid].major
			var minor = p[libid].minor
			var bugfix = p[libid].bugfix
			var cm = curr.version_major
			var cn = curr.version_minor
			var cb = curr.version_bugfix
			if major>cm:
				if minor>cn:dont=true
				elif bugfix>cb+2:dont=true
			elif minor>cn:if bugfix>cb+5:dont=true
			elif bugfix>cb+10:dont=true
		if dont:
			pointers.DataFormat.__exit(false,"cannot collect version specific data. Is HevLib out of date?","pointers.SafeMode",20.0)
		file.open(update_store,File.WRITE)
		file.store_string(JSON.print(updates))
		file.close()
		emit_signal("updates_fetched")
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

func installScriptExtension(path:String):
	var childPath:String = str(modPath + path)
	var childScript:Script = load(childPath)

	childScript.new()

	var parentScript:Script = childScript.get_base_script()
	var parentPath:String = parentScript.resource_path

	l("Installing script extension: %s <- %s" % [parentPath, childPath])

	childScript.take_over_path(parentPath)
	_savedObjects.append(childScript)

func installScriptExtensionFromSource(source_code:String):
	var out = GDScript.new()
	out.set_source_code(source_code)
	out.reload()
	var parentScript:Script = out.get_base_script()
	var parentPath:String = parentScript.resource_path
	l("Installing script extension from [Source Code -> %s]" % parentPath)
	out.take_over_path(parentPath)
	_savedObjects.append(out)

func installScriptExtensionFromScript(out:Script):
	var parentScript:Script = out.get_base_script()
	var parentPath:String = parentScript.resource_path
	l("Installing script extension from [%s -> %s]" % [str(out),parentPath])
	out.take_over_path(parentPath)
	_savedObjects.append(out)

func installScriptOverrideFromSource(source_code:String,original_path:String):
	var out = GDScript.new()
	out.set_source_code(source_code)
	out.reload()
	l("Installing script override from [Source Code -> %s]" % original_path)
	out.take_over_path(original_path)
	_savedObjects.append(out)

func installScriptOverrideFromScript(out:Script,original_path:String):
	l("Installing script override from [%s -> %s]" % [str(out),original_path])
	out.take_over_path(original_path)
	_savedObjects.append(out)


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
func replaceSceneLiteral(newPath:String, oldPath:String):
	l("Updating scene literal: %s" % newPath)

	var scene := load(newPath)
	if scene and scene.can_instance():
		scene.take_over_path(oldPath)
		_savedObjects.append(scene)
		l("Finished updating literal: %s" % oldPath)

# Func to print messages to the logs
func l(msg:String, title:String = MOD_NAME, version:String = MOD_VERSION):
	var line = "%s V%s" % [title, version]
	pointers.l(msg,line)

func testing():
	file.open("C:/Program Files (x86)/Steam/steamapps/common/dV Rings of Saturn/mods/HevLib.zip",File.READ)
	var buffer = file.get_buffer(file.get_len())
	file.close()
	var files = pointers.Zip.__get_zip_central_directory_from_buffer(buffer)
	
	
	
	
	breakpoint
