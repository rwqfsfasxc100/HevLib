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
	if correct:
		pointers = load(pointerDir).new()
		pointers.equipment_modmain = self
		pointers.name = "HevLib~Pointers"
		if modLoader._savedObjects:
			var new_objects = [pointers]
			for i in modLoader._savedObjects:
				new_objects.append(i)
			modLoader._savedObjects = new_objects
		else:
			modLoader._savedObjects.append(pointers)
		l("Initializing Equipment Driver")
		pointers.FolderAccess.__recursive_delete("user://cache/.HevLib_Cache/")
		var variables_folder = "user://cache/.HevLib_Cache/Variable_Fetch/"
		directory.make_dir_recursive(variables_folder)
		pointers.FileAccess.__load_precached_mods()
		
#		testing()
		
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
		# Adds in_hevlib_menu to the CurrentGame script and preventing controls while it's true
		installScriptExtension("../../events/controls/CurrentGame.gd")
		installScriptExtension("../../events/controls/ship-ctrl.gd")
		installScriptExtension("../../events/controls/camera.gd")
		
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
	else:
		Debug.l("Folder structure not correct, exiting HevLib load")
	
func _ready():
	if correct:
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
	else:
		Debug.l("HevLib Equipment Driver onready process cannot be carried out")

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
					updates[ID] = {"name":mod_name,"id":ID,"version":[current_version["version_major"],current_version["version_minor"],current_version["version_bugfix"]],"new_version":newVer,"github":fetchURL,"file_name":file_name,"display":mod_name + " (" + ID + ")"}
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
	l("Installing script extension from source to: %s" % [parentPath])
	out.take_over_path(parentPath)
	_savedObjects.append(out)
func installScriptExtensionFromScript(out:Script):
	var parentScript:Script = out.get_base_script()
	var parentPath:String = parentScript.resource_path
	l("Installing script extension from source to: %s" % [parentPath])
	out.take_over_path(parentPath)
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
#	var shadow_tool = load("res://HevLib/development_tools/helper_scripts/ScriptShadowCreationTool.gd").new()
#	var time = (OS.get_unix_time_from_datetime({"day": 16, "hour": 11, "minute": 50, "month": 9, "second": 0, "year": 2273})) / (168.0 * 3600.0)
#	var t2 = time - floor(time)
#	var t3 = abs((t2*7) - 7)
#	var v : Array = PoolStringArray()
#	var can : Script = load("res://AymursEquipmentSuite/ModMain.gd").can_instance()
#	var can : Script = load("res://HevLib/ModMain.gd")
#	var prop = can.can_instance()
#	var spath = "res://asteroids/asteroid.gd"
#	var out = shadow_tool.__make_shadow_of_script(spath,[],[],[])
#	yield(pointers.Zip.__load_pck("C:\\Program Files (x86)\\Steam\\steamapps\\common\\dV Rings of Saturn\\Delta-V.pck",true,true,100),"completed")
#	var F = pointers.Zip.Files
	
	breakpoint

