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

const MOD_PRIORITY=-INF

const MOD_NAME="HevLib Library Equipment Driver Module"
const MOD_VERSION="1.0.0"
const MOD_VERSION_MAJOR=1
const MOD_VERSION_MINOR=0
const MOD_VERSION_BUGFIX=0
const MOD_VERSION_METADATA=""
const MOD_IS_LIBRARY=true

var modPath:String=get_script().resource_path.get_base_dir()+"/"

var _savedObjects:=[]

var variables_folder:String="user://cache/.HevLib_Cache/Variable_Fetch/"
var validation_check_path:String="user://cache/.HevLib_Cache/SafeMode/recache_validation.json"

var file:File=File.new()
var directory:Directory=Directory.new()
var pointers_dir:String=modPath.get_base_dir().get_base_dir().get_base_dir()+"/pointers.gd"
var correct:bool=ResourceLoader.exists(pointers_dir)
var pointers=null

var do_safe_load:bool=true

var is_editor:bool=OS.has_feature("editor")

func _init(modLoader:ModLoader=ModLoader):
	if!correct:
		Debug.l("Folder structure!correct, exiting HevLib load")
		return
	create_zip_for_overrides(handle_pointer_cast_clearing(process_gdnative_plugins(),modLoader))
	load_pointers(modLoader)
	l("Initializing Equipment Driver")
	pointers.FolderAccess.__recursive_delete(variables_folder,PoolStringArray(["remove_pointer_casting.zip"]))
	directory.make_dir_recursive(variables_folder);directory.make_dir_recursive(validation_check_path.get_base_dir())
	pointers.FileAccess.__load_precached_mods()
	pointers.ConfigDriver.__load_configs()
	
#	testing()
	
	pointers.Scripting.make_mineral_scripting()
	
	var files_to_load:Array=[
		"res://HevLib/scenes/minerals/AstrogatorPanel.gd",
		"res://HevLib/scenes/minerals/OMS.gd",
		"res://HevLib/scenes/minerals/CargoScanner.gd",
		"res://HevLib/scenes/minerals/ProcessedCargoManifest.gd",
		"user://cache/.HevLib_Cache/Minerals/cg.gd",
		"user://cache/.HevLib_Cache/Minerals/as.gd",
		"res://HevLib/scenes/minerals/TheRing.gd",
		"res://HevLib/scenes/research/Enceladus.gd",
		"res://HevLib/scenes/research/overhead_handle/CurrentGame.gd",
		"res://HevLib/scenes/equipment/SystemShipUpgradeUI.gd",
		"res://HevLib/scenes/equipment/SystemBuyUI.gd",
		"res://HevLib/scenes/equipment/UpgradeGroup.gd",
		"res://HevLib/scenes/equipment/hardpoints/EquipmentItemTemplate.gd",
		"res://HevLib/scenes/equipment/ThrusterSlot.gd",
		"res://HevLib/scenes/weaponslot/weapon_slot_handler.gd",
		"res://HevLib/scenes/equipment/ShipModificationDriver/AddNodes.gd",
		"res://HevLib/scenes/equipment/ShipModificationDriver/InternalStorageMod.gd",
		"res://HevLib/scenes/ship_driver/Shipyard.gd",
		"res://HevLib/scenes/ship_driver/CurrentGame.gd",
		"res://HevLib/scenes/ship_driver/TheRing.gd",
		"res://HevLib/scripts/Namer.gd",
		"res://HevLib/events/TheRing.gd",
		"res://HevLib/events/controls/camera.gd",
		"res://HevLib/events/controls/ship-ctrl.gd",
		"res://HevLib/events/controls/CurrentGame.gd",
		["res://HevLib/events/chaos_map/RingTelescopeView.tscn","res://hud/components/RingTelescopeView.tscn"],
		"res://HevLib/events/custom_events/TheRing.gd",
		["res://HevLib/scenes/notification_driver/Notifications.tscn","res://achievement/Notifications.tscn"],
		"res://HevLib/scenes/notification_driver/CurrentGame.gd",
		["res://HevLib/scenes/better_title_screen/TitleScreen.tscn","res://TitleScreen.tscn"],
		"res://HevLib/scenes/better_title_screen/SaveSlotButton.gd",
		"res://HevLib/scenes/better_title_screen/CurrentlyPlaying.gd",
		"res://HevLib/ui/ExtensionPopup.gd",
		"res://HevLib/ui/mod_menu/titlescreen/TitleMenu.gd",
		"res://HevLib/scenes/scene_replacements/DLClist.gd",
		["res://HevLib/scenes/crew_extensions/base_expansion_x24.tscn","res://comms/conversation/subtrees/DIALOG_DERELICT_RANDOM.tscn"],
		"res://HevLib/scripts/transit_tips/TransitTip.gd",
		"res://HevLib/scenes/minerals/Summary.gd",
		"res://HevLib/scenes/rpc/Crew.gd",
		"res://HevLib/scenes/rpc/Dealer.gd",
		"res://HevLib/scenes/rpc/DiveTarget.gd",
		"res://HevLib/scenes/rpc/Enceladus.gd",
		"res://HevLib/scenes/rpc/Game.gd",
		"res://HevLib/scenes/rpc/Logs.gd",
		"res://HevLib/scenes/rpc/MineralMarket.gd",
		"res://HevLib/scenes/rpc/Music.gd",
		"res://HevLib/scenes/rpc/PreFlightInspection.gd",
		"res://HevLib/scenes/rpc/Repairs.gd",
		"res://HevLib/scenes/rpc/Services.gd",
		"res://HevLib/scenes/rpc/SimulationLayer.gd",
		"res://HevLib/scenes/rpc/Summary.gd",
		"res://HevLib/scenes/rpc/TitleMenu.gd",
		"res://HevLib/scenes/rpc/Tuning.gd",
		"res://HevLib/scenes/rpc/Upgrades.gd",
		"res://HevLib/scenes/keymapping/bind_displays/AnalogAxisDisplay.gd",
		"res://HevLib/scenes/keymapping/bind_displays/GamepadKeybindDisplay.gd",
		"res://HevLib/scenes/keymapping/bind_displays/KeybindDisplay.gd",
		"res://HevLib/scenes/keymapping/bind_displays/MousebindDisplay.gd",
		"res://HevLib/scripts/SteamWebAPI.gd",
	]
	
	if pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DRIVERS","multiple_minerals_per_chunk"):
		files_to_load.append_array([
			"res://HevLib/scenes/minerals/multiminerals/mineral.gd",
			"res://HevLib/scenes/minerals/multiminerals/MineralProcessingUnit.gd",
			"res://HevLib/scenes/minerals/multiminerals/AsteroidSpawner.gd",
		])
	
	var ncrew:Dictionary=pointers.ManifestV2.__get_manifest_entry("tags","TAG_HANDLE_EXTRA_CREW")
	var count:int=24
	for mod in ncrew.keys():
		var data:int=ncrew[mod]
		if data>count:
			count=data
	var crewsize_entry:String=pointers.NodeAccess.__dynamic_crew_expander("user://cache/.HevLib_Cache/",count)
	if crewsize_entry:
		files_to_load.append([crewsize_entry,"res://comms/conversation/subtrees/DIALOG_DERELICT_RANDOM.tscn"])
	
	if is_editor:
		files_to_load.append(["res://HevLib/ui/mod_menu/titlescreen/editor/TitleScreen.tscn","res://TitleScreen.tscn"])
	
	do_safe_load=pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DRIVERS","safe_modlet_loading")
	if!do_safe_load:
		for i in files_to_load:
			match typeof(i):
				TYPE_STRING:
					match i.get_extension():
						"gd":
							installScriptExtension(i)
						"tscn":
							replaceScene(i)
				TYPE_ARRAY:
					if i[0].get_extension()=="tscn":
						replaceScene(i[0],i[1])
	
	for old_path in pointers.ManifestV2.__load_modlets(false,do_safe_load,files_to_load):
		pointers.DataFormat.__reload_scene(old_path)
const libid:String="hev.LIBRARY"
func _ready():
	if!correct:
		Debug.l("HevLib Equipment Driver onready process cannot be carried out")
		return
	l("Readying")
	
	initiate_mod_update_fetch()
	
	pointers.Equipment.__make_upgrades_scene()
	
	replaceScene("Upgrades.tscn","res://enceladus/Upgrades.tscn")
	if !do_safe_load:
		for old_path in pointers.ManifestV2.__load_modlets(true,do_safe_load):
			pointers.DataFormat.__reload_scene(old_path)
	l("Ready")

# Mod update checking
signal updates_fetched

const update_store:String="user://cache/.Mod_Menu_2_Cache/updates/needs_updates.json"
const api_url:String="https://publicactiontrigger.azurewebsites.net/api/dispatches/rwqfsfasxc100/dv_update_database"
const updateDB_url:String="https://raw.githubusercontent.com/rwqfsfasxc100/dv_update_database/refs/heads/main/manifest_path_store.json"

func initiate_mod_update_fetch():
	var http:HTTPRequest=HTTPRequest.new()
	http.connect("request_completed",self,"updatelist_return",[http])
	http.timeout=20
	add_child(http)
	http.request(updateDB_url)

func updatelist_return(result, response_code,headers,body,mh):
	if result==0&&response_code==200:
		var p:Dictionary=JSON.parse(body.get_string_from_utf8()).result
		var ids:PoolStringArray=pointers.ManifestV2.__get_mod_ids()
		var updates:Dictionary={}
		for ID in p:if ID in ids:
			var fetchData:Dictionary=p[ID]
			var modData:Dictionary=pointers.ManifestV2.__get_mod_by_id(ID)
			var current_version:Dictionary=modData["version_data"]
			var doUpdate:bool=false
			var newVer:Array=[fetchData["major"],fetchData["minor"],fetchData["bugfix"]]
			var ctr:int=0
			while(!doUpdate)and(ctr<3):
				match ctr:
					0:
						if newVer[0]>current_version["version_major"]:doUpdate=true
						elif newVer[0]<current_version["version_major"]:ctr=5
					1:
						if newVer[1]>current_version["version_minor"]:doUpdate=true
						elif newVer[1]<current_version["version_minor"]:ctr=5
					2:
						if newVer[2]>current_version["version_bugfix"]:doUpdate=true
						elif newVer[2]<current_version["version_bugfix"]:ctr=5
				ctr+=1
			if doUpdate:
				var file_name:String=fetchData.get("file_name","file.zip")
				var mod_name:String=modData.get("name","")
				updates[ID]={"name":mod_name,"id":ID,"version":[current_version["version_major"],current_version["version_minor"],current_version["version_bugfix"]],"new_version":newVer,"github":"https://github.com/rwqfsfasxc100/dv_update_database/raw/refs/heads/main/zip_store/%s/%d.%d.%d/%s"%[ID,newVer[0],newVer[1],newVer[2],file_name],"file_name":file_name,"display":mod_name+"("+ID+")"}
		var dont:bool=false
		if libid in p:
			var curr:Dictionary=pointers.ManifestV2.__get_mod_by_id(libid)["version_data"]
			var major:int=p[libid].major
			var minor:int=p[libid].minor
			var bugfix:int=p[libid].bugfix
			var cm:int=curr.version_major
			var cn:int=curr.version_minor
			var cb:int=curr.version_bugfix
			if major>cm:
				if minor>0:dont=true
				elif bugfix>5:dont=true
			elif minor>cn:if bugfix>cb+4:dont=true
			elif bugfix>cb+10:dont=true
		if dont:
			pointers.DataFormat.__exit(false,"cannot collect version specific data. Is HevLib out of date?","pointers.SafeMode",60.0)
		file.open(update_store,File.WRITE)
		file.store_string(JSON.print(updates))
		file.close()
		emit_signal("updates_fetched")
		if!is_editor||pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","always_send_new_mods"):
			var md:Dictionary=pointers.ManifestV2.__get_mod_data()
			for mod in pointers.ManifestV2.__get_mod_list_keys():
				var mod_data:Dictionary=md[mod]
				if mod_data["manifest"]["has_manifest"]:
					var manifest:Dictionary=mod_data["manifest"]["manifest_data"]
					if"mod_information"in manifest:
						var mid:String=manifest["mod_information"].get("id","")
						if mid&&!mid in p:
							var mURL:String=""
							var gURL:String=""
							if"manifest_definitions"in manifest:
								mURL=manifest["manifest_definitions"].get("manifest_url","")
							if"links"in manifest:
								if"HEVLIB_GITHUB"in manifest["links"]:
									gURL=manifest["links"]["HEVLIB_GITHUB"].get("URL","")
							if mURL&&gURL:
								var payload:String=JSON.print({
									"event_type":"add_mod_entry",
									"client_payload":{
										"data":JSON.print({
											"id":mid,
											"manifest_url":mURL,
											"github_url":gURL
										})
									}
								})
								var tHTTP:HTTPRequest=HTTPRequest.new()
								add_child(tHTTP)
								tHTTP.request(api_url,[],true,HTTPClient.METHOD_POST,payload)
								yield(get_tree().create_timer(300),"timeout")
								Tool.deferCallInPhysics(Tool,"remove",[tHTTP])
	Tool.deferCallInPhysics(Tool,"remove",[mh])

func installScriptExtension(path:String):
	var childPath:String=str(modPath+path)
	var childScript:Script=load(childPath)

	childScript.new()

	var parentScript:Script=childScript.get_base_script()
	var parentPath:String=parentScript.resource_path

	l("Installing script extension:%s <- %s"%[parentPath, childPath])

	childScript.take_over_path(parentPath)
	_savedObjects.append(childScript)

func installScriptExtensionFromSource(source_code:String):
	var out=GDScript.new()
	out.set_source_code(source_code)
	out.reload()
	var parentScript:Script=out.get_base_script()
	var parentPath:String=parentScript.resource_path
	l("Installing script extension from [Source Code -> %s]"%parentPath)
	out.take_over_path(parentPath)
	_savedObjects.append(out)

func installScriptExtensionFromScript(out:Script):
	var parentScript:Script=out.get_base_script()
	var parentPath:String=parentScript.resource_path
	l("Installing script extension from [%s -> %s]"%[str(out),parentPath])
	out.take_over_path(parentPath)
	_savedObjects.append(out)

func installScriptOverrideFromSource(source_code:String,original_path:String):
	var out=GDScript.new()
	out.set_source_code(source_code)
	out.reload()
	l("Installing script override from [Source Code -> %s]"%original_path)
	out.take_over_path(original_path)
	_savedObjects.append(out)

func installScriptOverrideFromScript(out:Script,original_path:String):
	l("Installing script override from [%s -> %s]"%[str(out),original_path])
	out.take_over_path(original_path)
	_savedObjects.append(out)


# Helper function to replace scenes
# Can either be passed a single path,||two paths
# With a single path, it will replace the vanilla scene in the same relative position
func replaceScene(newPath:String, oldPath:String=""):
	l("Updating scene:%s"%newPath)

	if oldPath.empty():
		oldPath=str("res://"+newPath)

	newPath=str(modPath+newPath)

	var scene:=load(newPath)
	scene.take_over_path(oldPath)
	_savedObjects.append(scene)
	l("Finished updating:%s"%oldPath)
func replaceSceneLiteral(newPath:String, oldPath:String):
	l("Updating scene literal:%s"%newPath)

	var scene:=load(newPath)
	if scene&&scene.can_instance():
		scene.take_over_path(oldPath)
		_savedObjects.append(scene)
		l("Finished updating literal:%s"%oldPath)

# Func to print messages to the logs
func l(msg:String, title:String=MOD_NAME, version:String=MOD_VERSION):
	var line="%s V%s"%[title, version]
	pointers.l(msg,line)

const gdnative_library_extensions:PoolStringArray=PoolStringArray(["gdnlib"])
const driver_dirs=PoolStringArray([
	"HEVLIB_EQUIPMENT_DRIVER_TAGS/",
	"HEVLIB_MENU/",
	"HEVLIB_MINERAL_DRIVER_TAGS/",
	"HEVLIB_DRIVERS/",
])




func process_gdnative_plugins() -> Dictionary:
	var fetchPaths:Dictionary={}
	var exePath:String=OS.get_executable_path().get_base_dir()+"/hevlib_dll_store/"
	if!is_editor:
		var all_libraries:PoolStringArray=PoolStringArray()
		for first in fetch_folder_files("res://",true):
			if first.ends_with("/"):
				for second in fetch_folder_files("res://"+first,true):
					if second in driver_dirs:
						for driverFile in fetch_folder_files("res://"+first+second):
							if driverFile=="DLL_MAPPER.gd":
								var mod_dir:String="res://"+first
								var mapper:PoolStringArray=PoolStringArray(get_script_constant_map_without_load(mod_dir+second+"DLL_MAPPER.gd").get("DLL_MAPPER",[]))
								for entry in mapper:
									if!entry.begins_with("res://"):
										entry=mod_dir.plus_file(entry)
									if entry.get_extension() in gdnative_library_extensions:
										all_libraries.append(entry)
		var copied_files:PoolStringArray=PoolStringArray()
		var existing_libs:PoolStringArray=PoolStringArray()
		var lib_resave:Dictionary=Dictionary()
		var configFile:ConfigFile=ConfigFile.new()
		if all_libraries:
			directory.make_dir_recursive(exePath)
			var libs_to_copy:Dictionary=Dictionary()
			for entry in all_libraries:
				configFile.clear()
				configFile.load(entry)
				var cfg_sections:Array=configFile.get_sections()
				var data:Dictionary={}
				for section in cfg_sections:
					var dta:Dictionary={}
					for key in configFile.get_section_keys(section):
						dta[key]=configFile.get_value(section,key)
					data[section]=dta
				if"entry"in data:
					for oper in data["entry"]:
						var lib_path:String=data["entry"][oper]
						var new_path:String=exePath+lib_path.get_file()
						if file_exists(lib_path):
							if!file_exists(new_path):
								file.open(lib_path,File.READ)
								var buffer:PoolByteArray=file.get_buffer(file.get_len())
								file.close()
								libs_to_copy[new_path]=buffer
							data["entry"][oper]=new_path
							existing_libs.append(new_path.get_file())
				if"dependencies"in data:
					for oper in data["dependencies"]:
						var lib_paths:Array=data["dependencies"][oper]
						for lbr in lib_paths.size():
							var lib_path:String=lib_paths[lbr]
							var new_path:String=exePath+lib_path.get_file()
							if file_exists(lib_path):
								if!file_exists(new_path):
									file.open(lib_path,File.READ)
									var buffer:PoolByteArray=file.get_buffer(file.get_len())
									file.close()
									libs_to_copy[new_path]=buffer
								lib_paths[lbr]=new_path
								existing_libs.append(new_path.get_file())
						data["dependencies"][oper]=lib_paths
				lib_resave[entry]=data
				for f in libs_to_copy:
					if!file_exists(f):
						file.open(f,File.WRITE)
						file.store_buffer(libs_to_copy[f])
						file.close()
				copied_files.append_array(libs_to_copy.keys())
		if lib_resave:
			for entry in lib_resave:
				var data:Dictionary=lib_resave[entry]
				var savePath="user://cache/.HevLib_Cache/Variable_Fetch/%d.gdnlib"%Time.get_ticks_usec()
				configFile.clear()
				for section in data.keys():
					var keys=data[section]
					for key in keys.keys():
						configFile.set_value(section,key,keys[key])
				configFile.save(savePath)
				file.open(savePath,File.READ)
				var bfr:PoolByteArray=file.get_buffer(file.get_len())
				file.close()
				fetchPaths[entry.substr(6)]=bfr
		for f in fetch_folder_files(exePath):
			if!f in existing_libs:
				directory.remove(exePath.plus_file(f))
	return fetchPaths

func handle_pointer_cast_clearing(replacements:Dictionary,modLoader:ModLoader) -> Dictionary:
	var script_paths:PoolStringArray=PoolStringArray()
	for zip in modLoader._modZipFiles:
		file.open(zip,File.READ)
		var buffer:PoolByteArray=file.get_buffer(file.get_len())
		file.close()
		
		var buffer_len:int=buffer.size()
		if buffer_len<22:
			continue
		# Fetch EOCD, including max potential comment size
		# More mem efficient than fetching entire buffer
		var search_start:int=max(buffer_len-0x06054b50-65536, 0)
		var tail:PoolByteArray=buffer.subarray(0,buffer_len-search_start-1)
		var eocd_pos:int=-1
		var i:int=tail.size()-22
		while i>-1:
			if tail[i]==0x50&&tail[i+1]==0x4b&&tail[i+2]==0x05&&tail[i+3]==0x06:
				eocd_pos=i
				break
			i -=1
		if eocd_pos<0:
			continue
		var total_entries:int=(tail[eocd_pos+10]|(tail[eocd_pos+10+1]<<8))
		var current_offset:int=(tail[eocd_pos+16]|(tail[eocd_pos+16+1]<<8)|(tail[eocd_pos+16+2]<<16)|(tail[eocd_pos+16+3]<<24))
		for ctr in total_entries:
			var magic:int=(tail[current_offset]|(tail[current_offset+1]<<8)|(tail[current_offset+2]<<16)|(tail[current_offset+3]<<24))
			var magicCheck:int=0x02014b50
			if magic!=magicCheck:
				break
			current_offset+=28 # magic num. && skip written version+required version+flag && compression method && skip time+date+CRC32+comp_size+uncomp_size
			var name_len:int=(tail[current_offset]|(tail[current_offset+1]<<8))
			var extra_len:int=(tail[current_offset+2]|(tail[current_offset+3]<<8))
			var comment_len:int=(tail[current_offset+4]|(tail[current_offset+5]<<8))
			current_offset+=18 # comment length && skip disk num.+internal attrib+external attrib.+local_offset
			var file_name:String=tail.subarray(current_offset,current_offset+name_len-1).get_string_from_utf8()
			current_offset+=name_len
			if extra_len>0:
				current_offset+=extra_len
			if comment_len>0:
				current_offset+=comment_len
			if file_name.get_extension()=="gd":
				script_paths.append(file_name)
	if script_paths:
		directory.make_dir_recursive("user://cache/.HevLib_Cache/Variable_Fetch/")
		var class_names_to_clear:PoolStringArray=PoolStringArray(["HevLibPointers","MINIZ"])
		var class_refs:Dictionary={"HevLibPointers":"res://HevLib/pointers.gd","MINIZ":"res://HevLib/scripts/miniz/miniz.gd"}
		var driver_dirs:PoolStringArray=PoolStringArray([
			"HEVLIB_EQUIPMENT_DRIVER_TAGS",
			"HEVLIB_MENU",
			"HEVLIB_MINERAL_DRIVER_TAGS",
			"HEVLIB_DRIVERS",
		])
		for sc in script_paths:
			if sc.get_file()=="DEFINED_CLASS_NAMES.gd"&&sc.split("/",false)[-2] in driver_dirs:
				var fetched=load(sc).get_script_constant_map().get("DEFINED_CLASS_NAMES",[])
				match typeof(fetched):
					TYPE_ARRAY,TYPE_STRING_ARRAY:
						for i in fetched:
							match typeof(i):
								TYPE_ARRAY,TYPE_STRING_ARRAY:
									var itemName:String=i[0]
									if!itemName in class_names_to_clear:
										class_names_to_clear.append(itemName)
										class_refs[itemName]=i[1]
								TYPE_STRING:
									if!i in class_names_to_clear:
										class_names_to_clear.append(i)
										class_refs[i]=""
					TYPE_DICTIONARY:
						for i in fetched.keys():
							if!i in class_names_to_clear&&typeof(fetched[i])==TYPE_STRING:
								class_names_to_clear.append(i)
								class_refs[i]=fetched[i]
		var clearlist:String="|".join(class_names_to_clear)
		var regex:RegEx=RegEx.new() # Checks for type-casting
		var regex2:RegEx=RegEx.new() # Checks for object literal
		var regex3:RegEx=RegEx.new() # Checks for method casting
#		regex.compile("\\b(?:var)\\s+\\w+\\K\\s*:\\s*(?!(?:%s)\\b)\\w+"%vanilla_classes)
		var compiler_A:String="\\b(?:var|\\-\\>)\\s+\\w+\\K\\s*:\\s*(?:%s)\\b"%clearlist
		var compiler_B:String=clearlist
		var compiler_C:String="(?:\\-\\>)\\s+(?:%s)\\b\\s*(?:\\:)"%clearlist
		
		
		regex.compile(compiler_A)
		regex2.compile(compiler_B)
		regex3.compile(compiler_C)
		for script in script_paths:
			file.open("res://"+script,File.READ)
			var text:String=file.get_as_text(true)
			file.close()
			var doSave:bool=false
			var ignoreChars:PoolStringArray=PoolStringArray(["\n","=",";"])
			var entries:Array=regex.search_all(text)
			if entries:
				var cases:Array=Array()
				var cHashes:Array=Array()
				for entry in entries:
					var endPos:int=entry.get_end()
					var appendage:String=""
					while endPos<text.length():
						var c:String=text[endPos]
						if c in ignoreChars:
							break
						appendage+=c
						endPos+=1
					for s in entry.strings:
						var sp:String=s+appendage
						if!sp in cases:
							var case:Array=[sp,""]
							var ch:int=hash(case)
							if!ch in cHashes:
								cases.append(case)
								cHashes.append(ch)
				if cases:
					doSave=true
					for r in cases:
						text=text.replace(r[0],r[1])
#			var entries_3:Array=regex3.search_all(text)
#			if entries_3:
#				var cases:Array=Array()
#				var cHashes:Array=Array()
#				for entry in entries_3:
#					for s in entry.strings:
#						if!s in cases:
#							var case:Array=[s,":"]
#							var ch:int=hash(case)
#							if!ch in cHashes:
#								cases.append(case)
#								cHashes.append(ch)
#				if cases:
#					doSave=true
#					for r in cases:
#						text=text.replace(r[0],r[1])
#			var entries_2:Array=regex2.search_all(text)
#			if entries_2:
#				var cases:Array=Array()
#				var cHashes:Array=Array()
#				for entry in entries_2:
#					var endPos:int=entry.get_end()
#					var maxLen:int=text.length()
#					var appendage:String=text.substr(endPos,4)
#					for s in entry.strings:
#						var case:Array=[s,"load(\"%s\")"%class_refs.get(s,"")]
#						var ch:int=hash(case)
#						if!ch in cHashes:
#							cases.append(case)
#							cHashes.append(ch)
#				if cases:
#					doSave=true
#					for r in cases:
#						text=text.replace(r[0],r[1])
			if doSave:
				replacements[script]=text.to_utf8()
	return replacements
func create_zip_for_overrides(replacements:Dictionary):
	if replacements:
		var datetime:Dictionary=Time.get_datetime_dict_from_system()
		var dos_time:int=(datetime.hour<<11)|(datetime.minute<<5)|int(datetime.second/2.0)
		var dos_date:int=(int(max(datetime.year-1980, 0))<<9)|(datetime.month<<5)|datetime.day
		var dt1:int=dos_time&0xFF
		var dt2:int=(dos_time>>8)&0xFF
		var dt3:int=dos_date&0xFF
		var dt4:int=(dos_date>>8)&0xFF
		
		var buffer:PoolByteArray=PoolByteArray()
		var central_records:Array=Array()
		central_records.resize(replacements.size())
		var entry_idx:int=0
		for entry_path in replacements:
			var data:PoolByteArray=replacements[entry_path]
			var offset:int=buffer.size()
			var uncompressed_size:int=data.size()
			var name_bytes:PoolByteArray=entry_path.to_utf8()
			var crc:int=get_crc_32(data)
			var name_size:int=name_bytes.size()
			var uc1:int=uncompressed_size&0xFF
			var uc2:int=(uncompressed_size>>8)&0xFF
			var uc3:int=(uncompressed_size>>16)&0xFF
			var uc4:int=(uncompressed_size>>24)&0xFF
			buffer.resize(offset+30)
			buffer[offset]=80;buffer[offset+1]=75;buffer[offset+2]=3;buffer[offset+3]=4 # Local entry magic number
			buffer[offset+4]=20;buffer[offset+5]=0 # Version to extract
			buffer[offset+6]=0;buffer[offset+7]=8 # General purpose flag, marks use of UTF8
			buffer[offset+8]=0;buffer[offset+9]=0 # Compression (none)
			buffer[offset+10]=dt1;buffer[offset+11]=dt2 # Time
			buffer[offset+12]=dt3;buffer[offset+13]=dt4 # Date
			buffer[offset+14]=crc&0xFF;buffer[offset+15]=(crc>>8)&0xFF;buffer[offset+16]=(crc>>16)&0xFF;buffer[offset+17]=(crc>>24)&0xFF # CRC32
			buffer[offset+18]=uc1;buffer[offset+19]=uc2;buffer[offset+20]=uc3;buffer[offset+21]=uc4 # Compressed size
			buffer[offset+22]=uc1;buffer[offset+23]=uc2;buffer[offset+24]=uc3;buffer[offset+25]=uc4 # Uncompressed size
			buffer[offset+26]=name_size&0xFF;buffer[offset+27]=(name_size>>8)&0xFF # Filename length
			buffer[offset+28]=0;buffer[offset+29]=0 # Extra field length
			buffer.append_array(name_bytes)
			buffer.append_array(data)
			central_records[entry_idx]={"name_bytes":name_bytes,"crc":crc,"uncomp_size":uncompressed_size,"offset":offset}
			entry_idx+=1
		var cdr:int=buffer.size()
		for rec in central_records:
			var name_bytes:PoolByteArray=rec.name_bytes
			var name_size:int=name_bytes.size()
			var uncomp_size:int=rec.uncomp_size
			var uc1:int=uncomp_size&0xFF
			var uc2:int=(uncomp_size>>8)&0xFF
			var uc3:int=(uncomp_size>>16)&0xFF
			var uc4:int=(uncomp_size>>24)&0xFF
			var crc:int=rec.crc
			var offset:int=rec.offset
			var bsize:int=buffer.size()
			buffer.resize(bsize+46)
			buffer[bsize]=80;buffer[bsize+1]=75;buffer[bsize+2]=1;buffer[bsize+3]=2 # Central dir magic number
			buffer[bsize+4]=20;buffer[bsize+5]=0 # Version created
			buffer[bsize+6]=20;buffer[bsize+7]=0 # Version to decompress to
			buffer[bsize+8]=0;buffer[bsize+9]=8 # General flag, marks use of UTF8
			buffer[bsize+10]=0;buffer[bsize+11]=0 # Store method (none)
			buffer[bsize+12]=dt1;buffer[bsize+13]=dt2 # Time
			buffer[bsize+14]=dt3;buffer[bsize+15]=dt4 # Date
			buffer[bsize+16]=crc&0xFF;buffer[bsize+17]=(crc>>8)&0xFF;buffer[bsize+18]=(crc>>16)&0xFF;buffer[bsize+19]=(crc>>24)&0xFF # CRC32
			buffer[bsize+20]=uc1;buffer[bsize+21]=uc2;buffer[bsize+22]=uc3;buffer[bsize+23]=uc4 # Compressed size
			buffer[bsize+24]=uc1;buffer[bsize+25]=uc2;buffer[bsize+26]=uc3;buffer[bsize+27]=uc4 # Uncompressed size
			buffer[bsize+28]=name_size&0xFF;buffer[bsize+29]=(name_size>>8)&0xFF # Name length
			buffer[bsize+30]=0;buffer[bsize+31]=0 # Extra field length
			buffer[bsize+32]=0;buffer[bsize+33]=0 # Comment length
			buffer[bsize+34]=0;buffer[bsize+35]=0 # Disk
			buffer[bsize+36]=0;buffer[bsize+37]=0 # File attributes
			buffer[bsize+38]=0;buffer[bsize+39]=0;buffer[bsize+40]=0;buffer[bsize+41]=0 # External file attributes
			buffer[bsize+42]=offset&0xFF;buffer[bsize+43]=(offset>>8)&0xFF;buffer[bsize+44]=(offset>>16)&0xFF;buffer[bsize+45]=(offset>>24)&0xFF # CD offset
			buffer.append_array(name_bytes) # File name bytes
		var central_dir_size:int=buffer.size()-cdr
		var cr_size:int=central_records.size()
		var cr1:int=cr_size;var cr2:int=(cr_size>>8)&0xFF
		var offset:int=buffer.size()
		buffer.resize(offset+22)
		buffer[offset]=80;buffer[offset+1]=75;buffer[offset+2]=5;buffer[offset+3]=6 # EOCD magic number
		buffer[offset+4]=0;buffer[offset+5]=0;buffer[offset+6]=0;buffer[offset+7]=0 # Disk
		buffer[offset+8]=cr1;buffer[offset+9]=cr2;buffer[offset+10]=cr1;buffer[offset+11]=cr2 # Size
		buffer[offset+12]=central_dir_size&0xFF;buffer[offset+13]=(central_dir_size&0xFF00)>>8;buffer[offset+14]=(central_dir_size&0xFF0000)>>16;buffer[offset+15]=(central_dir_size&0xFF000000)>>24 # CD size
		buffer[offset+16]=cdr&0xFF;buffer[offset+17]=(cdr&0xFF00)>>8;buffer[offset+18]=(cdr&0xFF0000)>>16;buffer[offset+19]=(cdr&0xFF000000)>>24 # CD offset
		buffer[offset+20]=0;buffer[offset+21]=0 # Comment length
		var castFile:String="user://cache/.HevLib_Cache/Variable_Fetch/remove_pointer_casting.zip"
		file.open(castFile,File.WRITE);file.store_buffer(buffer);file.close()
		ProjectSettings.load_resource_pack(castFile)
var crcTables:Reference=load(modPath+"../../scripts/crc32_table_cache.gd")
var crc_table_0:Array=crcTables.T0
var crc_table_1:Array=crcTables.T1
var crc_table_2:Array=crcTables.T2
var crc_table_3:Array=crcTables.T3
var crc_table_4:Array=crcTables.T4
var crc_table_5:Array=crcTables.T5
var crc_table_6:Array=crcTables.T6
var crc_table_7:Array=crcTables.T7
var crc_table_8:Array=crcTables.T8
var crc_table_9:Array=crcTables.T9
var crc_table_10:Array=crcTables.T10
var crc_table_11:Array=crcTables.T11
var crc_table_12:Array=crcTables.T12
var crc_table_13:Array=crcTables.T13
var crc_table_14:Array=crcTables.T14
var crc_table_15:Array=crcTables.T15
var crc_table_16:Array=crcTables.T16
var crc_table_17:Array=crcTables.T17
var crc_table_18:Array=crcTables.T18
var crc_table_19:Array=crcTables.T19
var crc_table_20:Array=crcTables.T20
var crc_table_21:Array=crcTables.T21
var crc_table_22:Array=crcTables.T22
var crc_table_23:Array=crcTables.T23
var crc_table_24:Array=crcTables.T24
var crc_table_25:Array=crcTables.T25
var crc_table_26:Array=crcTables.T26
var crc_table_27:Array=crcTables.T27
var crc_table_28:Array=crcTables.T28
var crc_table_29:Array=crcTables.T29
var crc_table_30:Array=crcTables.T30
var crc_table_31:Array=crcTables.T31
func get_crc_32(bytes:PoolByteArray) -> int:
	var crc:int=0xFFFFFFFF;var size:int=bytes.size();var groups:float=floor(size/32.0);var i:int=0
	for g in groups:
		# Rare me splitting a variable that isn't an array||dictionary between lines.
		# Impossible to read&&work on otherwise so enjoy the readable code while you can:P
		crc=(
			crc_table_31[(crc&0xFF)^bytes[i]]^
			crc_table_30[((crc>>8)&0xFF)^bytes[i+1]]^
			crc_table_29[((crc>>16)&0xFF)^bytes[i+2]]^
			crc_table_28[((crc>>24)&0xFF)^bytes[i+3]]^
			crc_table_27[bytes[i+4]]^
			crc_table_26[bytes[i+5]]^
			crc_table_25[bytes[i+6]]^
			crc_table_24[bytes[i+7]]^
			crc_table_23[bytes[i+8]]^
			crc_table_22[bytes[i+9]]^
			crc_table_21[bytes[i+10]]^
			crc_table_20[bytes[i+11]]^
			crc_table_19[bytes[i+12]]^
			crc_table_18[bytes[i+13]]^
			crc_table_17[bytes[i+14]]^
			crc_table_16[bytes[i+15]]^
			crc_table_15[bytes[i+16]]^
			crc_table_14[bytes[i+17]]^
			crc_table_13[bytes[i+18]]^
			crc_table_12[bytes[i+19]]^
			crc_table_11[bytes[i+20]]^
			crc_table_10[bytes[i+21]]^
			crc_table_9[bytes[i+22]]^
			crc_table_8[bytes[i+23]]^
			crc_table_7[bytes[i+24]]^
			crc_table_6[bytes[i+25]]^
			crc_table_5[bytes[i+26]]^
			crc_table_4[bytes[i+27]]^
			crc_table_3[bytes[i+28]]^
			crc_table_2[bytes[i+29]]^
			crc_table_1[bytes[i+30]]^
			crc_table_0[bytes[i+31]]
		);i+=32
	while i<size:
		crc=crc_table_0[(crc^bytes[i])&0xFF]^(crc>>8);i+=1
	return crc^0xFFFFFFFF
func fetch_folder_files(folder:String,showFolders:bool=false,returnFullPath:bool=false,globalizePath:bool=false) -> PoolStringArray:
	var fileList:PoolStringArray=PoolStringArray()
	if!folder.ends_with("/"):folder+="/"
	if!directory.dir_exists(folder):return fileList
	directory.open(folder)
	directory.list_dir_begin(true)
	while true:
		var fileName:String=directory.get_next()
		if!(fileName.ends_with("/")||fileName=="."||fileName==".."):
			if!fileName:break
			if directory.current_is_dir():
				if!showFolders:continue
				if!fileName.ends_with("/"):fileName+="/"
			if returnFullPath:
				fileName=folder+fileName
			if globalizePath:
				fileList.append(ProjectSettings.globalize_path(fileName))
			else:
				fileList.append(fileName)
	return fileList
func file_exists(file_path):
	return file.file_exists(file_path)||ResourceLoader.exists(file_path)
func load_pointers(modLoader:ModLoader):
	pointers=load(pointers_dir).new(pointers_dir,self)
	if modLoader._savedObjects:
		var new_objects:Array=[pointers]
		var firstItemCheck=modLoader._savedObjects[0]
		if"resource_path"in firstItemCheck:
			var RP:String=firstItemCheck.resource_path
			if RP=="res://HevLib/pointers.gd"||RP==pointers_dir:OS.alert("HevLib is double-loaded. Please remove any extra zip files&&restart the game.","Warning!")
		for i in modLoader._savedObjects:new_objects.append(i)
		modLoader._savedObjects=new_objects
	else:modLoader._savedObjects.append(pointers)
const function_prefixes=["func","static func","remote func","master func","puppet func","remotesync func","mastersync func","puppetsync func","sync func"]
const all_prefixes=["func","static func","remote func","master func","puppet func","remotesync func","mastersync func","puppetsync func","sync func","onready","var","signal","const","export","extends"]
func get_script_constant_map_without_load(script_path:String) -> Dictionary:
	var concat:String=""
	var script_source:Script=load(script_path)
	var const_names:Array=[]
	if script_source:
		var extend_this:bool=true
		var data:String=script_source.get_source_code()
		var streaming:bool=false
		var this_stream:String=""
		var lines:PoolStringArray=data.split("\n")
		for line in lines:
			var result:String=""
			var is_part_of_string:bool=false
			var prev_char_escape:bool=false
			while line!="":
				var part:String=line.substr(0,1)
				if part=="\\":prev_char_escape=!prev_char_escape
				else:prev_char_escape=false
				if part=="\""&&!prev_char_escape:is_part_of_string=!is_part_of_string
				if part=="#"&&(!is_part_of_string&&!prev_char_escape):break
				line.erase(0,1)
				result+=part
			line=result
			var has_prefix:bool=false
			var has_sig:bool=false
			for prefix in function_prefixes:
				if line.begins_with(prefix):has_prefix=true
			if line.begins_with("signal"):has_sig=true
			if has_prefix:
				if streaming:
					concat+=this_stream.strip_edges()+"\n"
					this_stream=""
					streaming=false
			elif has_sig:
				if streaming:
					concat+=this_stream.strip_edges()+"\n"
					this_stream=""
					streaming=false
			elif line.begins_with("const"):
				if streaming:
					concat+=this_stream.strip_edges()+"\n"
					this_stream=""
					streaming=false
				const_names.append(line.split("=",false)[0].strip_edges().split("const",true)[1].strip_edges().split(":",false)[0].strip_edges())
				streaming=true
			elif line.begins_with("var")||((line.begins_with("onready")||line.begins_with("export"))&&"var"in line):
				if streaming:
					concat+=this_stream.strip_edges()+"\n"
					this_stream=""
					streaming=false
				streaming=true
			elif line.begins_with("extends"):
				if streaming:
					concat+=this_stream.strip_edges()+"\n"
					this_stream=""
					streaming=false
				if extend_this:
					streaming=true
			if streaming:
				this_stream=this_stream+"\n"+line
		if streaming:
			concat+=this_stream.strip_edges()+"\n"
			this_stream=""
			streaming=false
	if!const_names:return {}
	var dict:Dictionary={}
	var rld:GDScript=GDScript.new()
	rld.set_source_code(concat)
	rld.reload()
	return rld.get_script_constant_map()

func testing():
	var script_shadow_creator=load("res://HevLib/development_tools/helper_scripts/ScriptShadowCreationTool.gd").new()
	
	
	
	
	
	breakpoint
