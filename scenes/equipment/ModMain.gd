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

var variables_folder:String = "user://cache/.HevLib_Cache/Variable_Fetch/"
var validation_check_path:String = "user://cache/.HevLib_Cache/SafeMode/recache_validation.json"

var file:File = File.new()
var directory:Directory = Directory.new()
var pointers_dir:String = modPath.get_base_dir().get_base_dir().get_base_dir() + "/pointers.gd"
var correct:bool = ResourceLoader.exists(pointers_dir)
var pointers = null

var do_safe_load:bool = true

func _init(modLoader : ModLoader = ModLoader):
	if not correct:
		Debug.l("Folder structure not correct, exiting HevLib load")
		return
	handle_pointer_cast_clearing(modLoader)
	pointers = load(pointers_dir).new(pointers_dir,self)
	pointers.name = "HevLib~Pointers"
	if modLoader._savedObjects:
		var new_objects = [pointers]
		var firstItemCheck = modLoader._savedObjects[0]
		if "resource_path" in firstItemCheck:
			var RP=firstItemCheck.resource_path
			if RP=="res://HevLib/pointers.gd"or RP==pointers_dir:OS.alert("HevLib is double-loaded. Please remove any extra zip files and restart the game.","Warning!")
		for i in modLoader._savedObjects:new_objects.append(i)
		modLoader._savedObjects=new_objects
	else:modLoader._savedObjects.append(pointers)
	l("Initializing Equipment Driver")
	pointers.FolderAccess.__recursive_delete(variables_folder)
	directory.make_dir_recursive(variables_folder)
	directory.make_dir_recursive(validation_check_path.get_base_dir())
	pointers.FileAccess.__load_precached_mods()
	
	pointers.ConfigDriver.__load_configs()
	do_safe_load = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DRIVERS","safe_modlet_loading")
	
#	testing()
	
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
	
	# Disabled for reworking later on 
	do_safe_load = false
	if not do_safe_load:
		for old_path in pointers.ManifestV2.__load_modlets(false,false):
			pointers.DataFormat.__reload_scene(old_path)
var libid = "hev.LIBRARY"
func _ready():
	if not correct:
		Debug.l("HevLib Equipment Driver onready process cannot be carried out")
		return
	l("Readying")
	
	# RPC
	installScriptExtension("../rpc/Crew.gd")
	installScriptExtension("../rpc/Dealer.gd")
	installScriptExtension("../rpc/DiveTarget.gd")
	installScriptExtension("../rpc/Enceladus.gd")
	installScriptExtension("../rpc/Game.gd")
	installScriptExtension("../rpc/Logs.gd")
	installScriptExtension("../rpc/MineralMarket.gd")
	installScriptExtension("../rpc/Music.gd")
	installScriptExtension("../rpc/PreFlightInspection.gd")
	installScriptExtension("../rpc/Repairs.gd")
	installScriptExtension("../rpc/Services.gd")
	installScriptExtension("../rpc/SimulationLayer.gd")
	installScriptExtension("../rpc/Summary.gd")
	installScriptExtension("../rpc/TitleMenu.gd")
	installScriptExtension("../rpc/Tuning.gd")
	installScriptExtension("../rpc/Upgrades.gd")
	replaceScene("../rpc/Music.tscn")
	
	initiate_mod_update_fetch()
	
	pointers.Scripting.make_ring_modifications()
	
	pointers.Equipment.__make_upgrades_scene()
	
	installScriptExtension("../minerals/Summary.gd")
	
	replaceScene("Upgrades.tscn", "res://enceladus/Upgrades.tscn")

	replaceScene("../minerals/multiminerals/AsteroidField.tscn","res://AsteroidField.tscn")
	if not do_safe_load:
		for old_path in pointers.ManifestV2.__load_modlets(true,false):
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
			var md = pointers.ManifestV2.__get_mod_data()
			var api_url = "https://publicactiontrigger.azurewebsites.net/api/dispatches/rwqfsfasxc100/dv_update_database"
			for mod in pointers.ManifestV2.__get_mod_list_keys():
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
								yield(get_tree().create_timer(150),"timeout")
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

func handle_pointer_cast_clearing(modLoader:ModLoader):
	var script_paths:PoolStringArray = PoolStringArray()
	for zip in modLoader._modZipFiles:
		file.open(zip,File.READ)
		var buffer:PoolByteArray = file.get_buffer(file.get_len())
		file.close()
		
		var buffer_len:int = buffer.size()
		if buffer_len < 22:
			continue
		# Fetch EOCD, including max potential comment size
		# More mem efficient than fetching entire buffer
		var search_start = max(buffer_len - 0x06054b50 - 65536, 0)
		var tail:PoolByteArray = buffer.subarray(0,buffer_len - search_start - 1)
		var eocd_pos:int = -1
		var i:int = tail.size() - 22
		while i > -1:
			if tail[i] == 0x50 and tail[i + 1] == 0x4b and tail[i + 2] == 0x05 and tail[i + 3] == 0x06:
				eocd_pos = i
				break
			i -= 1
		if eocd_pos < 0:
			continue
		var total_entries:int = (tail[eocd_pos + 10] | (tail[eocd_pos + 10 + 1] << 8))
		var current_offset:int = (tail[eocd_pos + 16] | (tail[eocd_pos + 16 + 1] << 8) | (tail[eocd_pos + 16 + 2] << 16) | (tail[eocd_pos + 16 + 3] << 24))
		for ctr in total_entries:
			var magic:int = (tail[current_offset] | (tail[current_offset + 1] << 8) | (tail[current_offset + 2] << 16) | (tail[current_offset + 3] << 24))
			var magicCheck:int = 0x02014b50
			if magic != magicCheck:
				break
			current_offset += 28 # magic num. && skip written version + required version + flag && compression method && skip time + date + CRC32 + comp_size + uncomp_size
			var name_len:int = (tail[current_offset] | (tail[current_offset + 1] << 8))
			var extra_len:int = (tail[current_offset + 2] | (tail[current_offset + 3] << 8))
			var comment_len:int = (tail[current_offset + 4] | (tail[current_offset + 5] << 8))
			current_offset += 18 # comment length && skip disk num. + internal attrib + external attrib. + local_offset
			var file_name:String = tail.subarray(current_offset,current_offset + name_len - 1).get_string_from_utf8()
			current_offset += name_len
			if extra_len > 0:
				current_offset += extra_len
			if comment_len > 0:
				current_offset += comment_len
			if file_name.get_extension() == "gd":
				script_paths.append(file_name)
	if script_paths:
		var dir:Directory = Directory.new()
		dir.make_dir_recursive("user://cache/.HevLib_Cache/Variable_Fetch/")
		var classes_to_clear:PoolStringArray = PoolStringArray(["HevLibPointers"])
		var driver_dirs = PoolStringArray([
			"HEVLIB_EQUIPMENT_DRIVER_TAGS",
			"HEVLIB_MENU",
			"HEVLIB_MINERAL_DRIVER_TAGS",
			"HEVLIB_DRIVERS",
		])
		for sc in script_paths:
			if sc.get_file() == "DEFINED_CLASS_NAMES.gd" and sc.split("/",false)[-2] in driver_dirs:
				for i in PoolStringArray(load(sc).get_script_constant_map().get("DEFINED_CLASS_NAMES",PoolStringArray())):
					if not i in classes_to_clear:
						classes_to_clear.append(i)
		var clearlist:String = "|".join(classes_to_clear)
		var regex:RegEx = RegEx.new()
#		regex.compile("\\b(?:var)\\s+\\w+\\K\\s*:\\s*(?!(?:%s)\\b)\\w+" % vanilla_classes)
		regex.compile("\\b(?:var)\\s+\\w+\\K\\s*:\\s*(?:%s)\\b" % clearlist)
		var replacements:Dictionary = {}
		for script in script_paths:
			file.open("res://" + script,File.READ)
			var text = file.get_as_text(true)
			file.close()
			var entries = regex.search_all(text)
			if entries:
				var cases:PoolStringArray = PoolStringArray()
				var ignoreChars:PoolStringArray = PoolStringArray(["\n","=",";"])
				for entry in entries:
					var endPos:int = entry.get_end()
					var appendage:String = ""
					while endPos < text.length():
						var c:String = text[endPos]
						if c in ignoreChars:
							break
						appendage += c
						endPos += 1
					for s in entry.strings:
						var sp = s + appendage
						if not sp in cases:
							cases.append(sp)
				for r in cases:
					text = text.replace(r,"")
				replacements[script] = text.to_utf8()
		if replacements:
			var datetime:Dictionary = Time.get_datetime_dict_from_system()
			var dos_time:int = (datetime.hour << 11) | (datetime.minute << 5) | int(datetime.second / 2.0)
			var dos_date:int = (int(max(datetime.year - 1980, 0)) << 9) | (datetime.month << 5) | datetime.day
			var dt1:int = dos_time & 0xFF
			var dt2:int = (dos_time & 0xFF00) >> 8
			var dt3:int = dos_date & 0xFF
			var dt4:int = (dos_date & 0xFF00) >> 8
			
			var buffer:PoolByteArray = PoolByteArray()
			var central_records:Array = Array()
			for entry_path in replacements:
				var data:PoolByteArray = replacements[entry_path]
				var offset:int = buffer.size()
				var uncompressed_size:int = data.size()
				var name_bytes:PoolByteArray = entry_path.to_utf8()
				var crc:int = __get_crc_32(data)
				var name_size:int = name_bytes.size()
				var uc1:int = uncompressed_size & 0xFF
				var uc2:int = (uncompressed_size & 0xFF00) >> 8
				var uc3:int = (uncompressed_size & 0xFF0000) >> 16
				var uc4:int = (uncompressed_size & 0xFF000000) >> 24
				buffer.resize(offset + 30)
				# Local entry magic number
				buffer[offset] = 80;buffer[offset + 1] = 75;buffer[offset + 2] = 3;buffer[offset + 3] = 4
				
				# Version to extract
				buffer[offset + 4] = 20;buffer[offset + 5] = 0
				
				# General purpose flag
				buffer[offset + 6] = 0;buffer[offset + 7] = 8
				
				# Compression (none)
				buffer[offset + 8] = 0;buffer[offset + 9] = 0
				
				# Time
				buffer[offset + 10] = dt1;buffer[offset + 11] = dt2
				
				# Date
				buffer[offset + 12] = dt3;buffer[offset + 13] = dt4
				
				# CRC32
				buffer[offset + 14] = crc & 0xFF;buffer[offset + 15] = (crc & 0xFF00) >> 8;buffer[offset + 16] = (crc & 0xFF0000) >> 16;buffer[offset + 17] = (crc & 0xFF000000) >> 24
				
				# Compressed size
				buffer[offset + 18] = uc1;buffer[offset + 19] = uc2;buffer[offset + 20] = uc3;buffer[offset + 21] = uc4
				
				# Uncompressed size
				buffer[offset + 22] = uc1;buffer[offset + 23] = uc2;buffer[offset + 24] = uc3;buffer[offset + 25] = uc4
				
				# Filename length
				buffer[offset + 26] = name_size & 0xFF;buffer[offset + 27] = (name_size & 0xFF00) >> 8
				
				# Extra field length
				buffer[offset + 28] = 0;buffer[offset + 29] = 0
				
				buffer.append_array(name_bytes)
				buffer.append_array(data)
				central_records.append({
					"name_bytes":name_bytes,
					"crc":crc,
					"uncomp_size":uncompressed_size,
					"offset":offset
				})
			var central_dir_offset:int = buffer.size()
			for rec in central_records:
				var name_size:int = rec.name_bytes.size()
				var name_bytes:PoolByteArray = rec.name_bytes
				var uncomp_size:int = rec.uncomp_size
				var uc1:int = uncomp_size & 0xFF
				var uc2:int = (uncomp_size & 0xFF00) >> 8
				var uc3:int = (uncomp_size & 0xFF0000) >> 16
				var uc4:int = (uncomp_size & 0xFF000000) >> 24
				var crc:int = rec.crc
				var offset:int = rec.offset
				var bsize:int = buffer.size()
				buffer.resize(bsize + 46)
				# Central dir magic number
				buffer[bsize] = 80;buffer[bsize + 1] = 75;buffer[bsize + 2] = 1;buffer[bsize + 3] = 2
				
				# Version created
				buffer[bsize + 4] = 20;buffer[bsize + 5] = 0
				
				# Version to decompress to
				buffer[bsize + 6] = 20;buffer[bsize + 7] = 0
				
				# General flag
				buffer[bsize + 8] = 0;buffer[bsize + 9] = 8
				
				# Store method (none)
				buffer[bsize + 10] = 0;buffer[bsize + 11] = 0
				
				# Time
				buffer[bsize + 12] = dt1;buffer[bsize + 13] = dt2
				
				# Date
				buffer[bsize + 14] = dt3;buffer[bsize + 15] = dt4
				
				# CRC32
				buffer[bsize + 16] = crc & 0xFF;buffer[bsize + 17] = (crc & 0xFF00) >> 8;buffer[bsize + 18] = (crc & 0xFF0000) >> 16;buffer[bsize + 19] = (crc & 0xFF000000) >> 24
				
				# Compressed size
				buffer[bsize + 20] = uc1;buffer[bsize + 21] = uc2;buffer[bsize + 22] = uc3;buffer[bsize + 23] = uc4
				
				# Uncompressed size
				buffer[bsize + 24] = uc1;buffer[bsize + 25] = uc2;buffer[bsize + 26] = uc3;buffer[bsize + 27] = uc4
				
				# Name length
				buffer[bsize + 28] = name_size & 0xFF;buffer[bsize + 29] = (name_size & 0xFF00) >> 8
				
				# Extra field length
				buffer[bsize + 30] = 0;buffer[bsize + 31] = 0
				
				# Comment length
				buffer[bsize + 32] = 0;buffer[bsize + 33] = 0
				
				# Disk
				buffer[bsize + 34] = 0;buffer[bsize + 35] = 0
				
				# File attributes
				buffer[bsize + 36] = 0;buffer[bsize + 37] = 0
				
				# External file attributes
				buffer[bsize + 38] = 0;buffer[bsize + 39] = 0;buffer[bsize + 40] = 0;buffer[bsize + 41] = 0
				
				# CD offset
				buffer[bsize + 42] = offset & 0xFF;buffer[bsize + 43] = (offset & 0xFF00) >> 8;buffer[bsize + 44] = (offset & 0xFF0000) >> 16;buffer[bsize + 45] = (offset & 0xFF000000) >> 24
				
				# File name bytes
				buffer.append_array(name_bytes)
			var central_dir_size:int = buffer.size() - central_dir_offset
			var cr_size:int = central_records.size()
			var cr1:int = cr_size & 0xFF
			var cr2:int = (cr_size & 0xFF00) >> 8
			var offset:int = buffer.size()
			buffer.resize(offset + 22)
			# EOCD magic number
			buffer[offset] = 80;buffer[offset + 1] = 75;buffer[offset + 2] = 5;buffer[offset + 3] = 6
			
			# Disk
			buffer[offset + 4] = 0;buffer[offset + 5] = 0;buffer[offset + 6] = 0;buffer[offset + 7] = 0
			
			# Size
			buffer[offset + 8] = cr1;buffer[offset + 9] = cr2;buffer[offset + 10] = cr1;buffer[offset + 11] = cr2
			
			# CD size
			buffer[offset + 12] = central_dir_size & 0xFF;buffer[offset + 13] = (central_dir_size & 0xFF00) >> 8;buffer[offset + 14] = (central_dir_size & 0xFF0000) >> 16;buffer[offset + 15] = (central_dir_size & 0xFF000000) >> 24
			
			# CD offset
			buffer[offset + 16] = central_dir_offset & 0xFF;buffer[offset + 17] = (central_dir_offset & 0xFF00) >> 8;buffer[offset + 18] = (central_dir_offset & 0xFF0000) >> 16;buffer[offset + 19] = (central_dir_offset & 0xFF000000) >> 24
			
			# Comment length
			buffer[offset + 20] = 0;buffer[offset + 21] = 0
			
			file.open("user://cache/.HevLib_Cache/Variable_Fetch/remove_pointer_casting.zip",File.WRITE)
			file.store_buffer(buffer)
			file.close()
#			ProjectSettings.load_resource_pack("user://cache/.HevLib_Cache/Variable_Fetch/remove_pointer_casting.zip")

var crc_table_0:Array = Array()
var crc_table_1:Array = Array()
var crc_table_2:Array = Array()
var crc_table_3:Array = Array()
var crc_table_4:Array = Array()
var crc_table_5:Array = Array()
var crc_table_6:Array = Array()
var crc_table_7:Array = Array()
var crc_table_8:Array = Array()
var crc_table_9:Array = Array()
var crc_table_10:Array = Array()
var crc_table_11:Array = Array()
var crc_table_12:Array = Array()
var crc_table_13:Array = Array()
var crc_table_14:Array = Array()
var crc_table_15:Array = Array()
var crc_table_16:Array = Array()
var crc_table_17:Array = Array()
var crc_table_18:Array = Array()
var crc_table_19:Array = Array()
var crc_table_20:Array = Array()
var crc_table_21:Array = Array()
var crc_table_22:Array = Array()
var crc_table_23:Array = Array()
var crc_table_24:Array = Array()
var crc_table_25:Array = Array()
var crc_table_26:Array = Array()
var crc_table_27:Array = Array()
var crc_table_28:Array = Array()
var crc_table_29:Array = Array()
var crc_table_30:Array = Array()
var crc_table_31:Array = Array()

func __get_crc_32(bytes: PoolByteArray) -> int:
	if crc_table_0.empty():
		var crcTables = load(modPath + "../../scripts/crc32_table_cache.gd")
		crc_table_0 = crcTables.T0
		crc_table_1 = crcTables.T1
		crc_table_2 = crcTables.T2
		crc_table_3 = crcTables.T3
		crc_table_4 = crcTables.T4
		crc_table_5 = crcTables.T5
		crc_table_6 = crcTables.T6
		crc_table_7 = crcTables.T7
		crc_table_8 = crcTables.T8
		crc_table_9 = crcTables.T9
		crc_table_10 = crcTables.T10
		crc_table_11 = crcTables.T11
		crc_table_12 = crcTables.T12
		crc_table_13 = crcTables.T13
		crc_table_14 = crcTables.T14
		crc_table_15 = crcTables.T15
		crc_table_16 = crcTables.T16
		crc_table_17 = crcTables.T17
		crc_table_18 = crcTables.T18
		crc_table_19 = crcTables.T19
		crc_table_20 = crcTables.T20
		crc_table_21 = crcTables.T21
		crc_table_22 = crcTables.T22
		crc_table_23 = crcTables.T23
		crc_table_24 = crcTables.T24
		crc_table_25 = crcTables.T25
		crc_table_26 = crcTables.T26
		crc_table_27 = crcTables.T27
		crc_table_28 = crcTables.T28
		crc_table_29 = crcTables.T29
		crc_table_30 = crcTables.T30
		crc_table_31 = crcTables.T31
	var crc:int = 0xFFFFFFFF
	var size:int = bytes.size()
	var groups:int = int(floor(size / 32.0))
	var i:int = 0
	for g in groups:
		# Rare me splitting a variable that isn't an array or dictionary between lines.
		# Impossible to read and work on otherwise so enjoy the readable code while you can :P
		crc = (
			crc_table_31[(crc & 0xFF) ^ bytes[i]] ^
			crc_table_30[((crc >> 8) & 0xFF) ^ bytes[i + 1]] ^
			crc_table_29[((crc >> 16) & 0xFF) ^ bytes[i + 2]] ^
			crc_table_28[((crc >> 24) & 0xFF) ^ bytes[i + 3]] ^
			crc_table_27[bytes[i + 4]] ^
			crc_table_26[bytes[i + 5]] ^
			crc_table_25[bytes[i + 6]] ^
			crc_table_24[bytes[i + 7]] ^
			crc_table_23[bytes[i + 8]] ^
			crc_table_22[bytes[i + 9]] ^
			crc_table_21[bytes[i + 10]] ^
			crc_table_20[bytes[i + 11]] ^
			crc_table_19[bytes[i + 12]] ^
			crc_table_18[bytes[i + 13]] ^
			crc_table_17[bytes[i + 14]] ^
			crc_table_16[bytes[i + 15]] ^
			crc_table_15[bytes[i + 16]] ^
			crc_table_14[bytes[i + 17]] ^
			crc_table_13[bytes[i + 18]] ^
			crc_table_12[bytes[i + 19]] ^
			crc_table_11[bytes[i + 20]] ^
			crc_table_10[bytes[i + 21]] ^
			crc_table_9[bytes[i + 22]] ^
			crc_table_8[bytes[i + 23]] ^
			crc_table_7[bytes[i + 24]] ^
			crc_table_6[bytes[i + 25]] ^
			crc_table_5[bytes[i + 26]] ^
			crc_table_4[bytes[i + 27]] ^
			crc_table_3[bytes[i + 28]] ^
			crc_table_2[bytes[i + 29]] ^
			crc_table_1[bytes[i + 30]] ^
			crc_table_0[bytes[i + 31]]
		)
		i += 32
	while i < size:
		crc = crc_table_0[(crc ^ bytes[i]) & 0xFF] ^ (crc >> 8)
		i += 1
	return crc ^ 0xFFFFFFFF

func testing():
#	file.open("C:/Program Files (x86)/Steam/steamapps/common/dV Rings of Saturn/mods/HevLib.zip",File.READ)
#	var buffer = file.get_buffer(file.get_len())
#	file.close()
#
#	pointers.Zip.modify_zip_buffer(buffer,{},["HevLib/changelog.txt"],true)
	
#	var files = pointers.Zip.__extract_files_from_zip_buffer(buffer,"user://dump")
#	var files = pointers.Zip.__read_select_files_from_zip_buffer(buffer,PoolStringArray(["HevLib/ModMain.gd"]))
	
#	var nb = __store_32_in_buffer(0x04034b50)
	
#	var t1 = Time.get_ticks_usec()
#	pointers.Zip.__create_zip("user://dump.zip",{"test.zip":buffer},false)
#	var t2 = Time.get_ticks_usec()
#	print(t2-t1)
#	var pck = pointers.Zip.__load_pck("user://test_pack.pck")["res://test.tscn"]["GetData"].get_string_from_utf8()
#	var pck = pointers.Zip.__load_pck("C:/Program Files (x86)/Steam/steamapps/common/dV Rings of Saturn/dlc/032_here-be-dragons.pck",true)
	
#	var out = pointers.SafeMode.get_dependancies_for_vanilla_file("res://enceladus/Dealer.tscn")
#	var sz = load("res://HevLib/scripts/simple_zip.gd").new()
	
	
	
	breakpoint
