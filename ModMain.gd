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
const MOD_NAME="HevLib"
const MOD_VERSION_MAJOR=1
const MOD_VERSION_MINOR=17
const MOD_VERSION_BUGFIX=8
const MOD_VERSION_METADATA=""
const MOD_IS_LIBRARY=true
const LIBRARY_HIDDEN_BY_DEFAULT=false
const _savedObjects=Array()
const strings=Array()
func _init(modLoader=ModLoader):
	strings.append(self)
	var modPath:String=get_script().resource_path.get_base_dir()+"/"
	var pointers_dir:String=modPath+"pointers.gd"
	if!file_exists(pointers_dir):
		Debug.l("Folder structure not correct, exiting HevLib load")
		return
	strings.append(modPath)
	strings.append(pointers_dir)
	create_zip_for_overrides(handle_pointer_cast_clearing(process_gdnative_plugins(),modLoader),self)
	var pointers=load_pointers(modLoader)
	l("Initializing Equipment Driver")
	pointers.FolderAccess.__recursive_delete(variables_folder,PoolStringArray(["remove_pointer_casting.zip"]))
	var directory:Directory=Directory.new();directory.make_dir_recursive(variables_folder);directory.make_dir_recursive(validation_check_path.get_base_dir())
	pointers.FileAccess.__load_precached_mods();pointers.ConfigDriver.__load_configs()
	
#	testing(modLoader,pointers)
	
	recache(pointers)
	pointers.ManifestV2.__get_mod_versions(true)
	
	if OS.has_feature("editor")&&!File.new().file_exists("res://VersionLabel.tscn"):
		printerr("FAILED TO FETCH FILE SYSTEM")
		l("ERROR! FAILED TO FETCH FILE SYSTEM")
	
	pointers.Scripting.make_mineral_scripting()
	pointers.Equipment.__make_upgrades_scene()
	var ncrew:Dictionary=pointers.ManifestV2.__get_manifest_entry("tags","TAG_HANDLE_EXTRA_CREW")
	var count:int=24
	for mod in ncrew.keys():
		var data:int=ncrew[mod]
		if data>count:count=data
	var crewsize_entry:String=pointers.NodeAccess.__dynamic_crew_expander("user://cache/.HevLib_Cache/",count)
	if crewsize_entry:
		files_to_load.append([crewsize_entry,"res://comms/conversation/subtrees/DIALOG_DERELICT_RANDOM.tscn"])
	pointers.ManifestV2.__load_modlets(files_to_load)
	yield(self,"ready")
	var CRoot:Viewport=get_tree().get_root()
	CRoot.call_deferred("add_child",pointers)
	CRoot.call_deferred("add_child",load("res://HevLib/logging/_HevLib_Gamespace_Canvas.tscn").instance())
	CRoot.call_deferred("add_child",load("res://HevLib/scenes/keymapping/keybind_interrupt.tscn").instance())
const files_to_load:Array=[
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
	"res://HevLib/scenes/equipment/ThrusterSlot.gd",
	"res://HevLib/scenes/weaponslot/weapon_slot_handler.gd",
	"res://HevLib/scenes/equipment/ShipModificationDriver/AddNodes.gd",
	"res://HevLib/scenes/equipment/ShipModificationDriver/InternalStorageMod.gd",
	"res://HevLib/scenes/ship_driver/Shipyard.gd",
	"res://HevLib/scenes/ship_driver/CurrentGame.gd",
	"res://HevLib/scenes/ship_driver/TheRing.gd",
	"res://HevLib/scripts/Namer.gd",
	"res://HevLib/events/TheRing.gd",
	"res://HevLib/events/Game.gd",
	"res://HevLib/events/controls/camera.gd",
	"res://HevLib/events/controls/ship-ctrl.gd",
	"res://HevLib/events/controls/CurrentGame.gd",
	PoolStringArray(["res://HevLib/events/chaos_map/RingTelescopeView.tscn","res://hud/components/RingTelescopeView.tscn"]),
	"res://HevLib/events/custom_events/TheRing.gd",
	PoolStringArray(["res://HevLib/scenes/notification_driver/Notifications.tscn","res://achievement/Notifications.tscn"]),
	"res://HevLib/scenes/notification_driver/CurrentGame.gd",
	PoolStringArray(["res://HevLib/scenes/better_title_screen/TitleScreen.tscn","res://TitleScreen.tscn"]),
	"res://HevLib/scenes/better_title_screen/SaveSlotButton.gd",
	"res://HevLib/scenes/better_title_screen/CurrentlyPlaying.gd",
	"res://HevLib/ui/ExtensionPopup.gd",
	"res://HevLib/ui/mod_menu/titlescreen/TitleMenu.gd",
	"res://HevLib/ui/mod_menu/titlescreen/DLClist.gd",
	PoolStringArray(["res://HevLib/scenes/crew_extensions/base_expansion_x24.tscn","res://comms/conversation/subtrees/DIALOG_DERELICT_RANDOM.tscn"]),
	"res://HevLib/scripts/transit_tips/TransitTip.gd",
	"res://HevLib/scripts/easters/Screensaver.gd",
	"res://HevLib/scripts/easters/TitleMenu.gd",
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
	"res://HevLib/scripts/Boot.gd",
	"res://HevLib/scenes/minerals/multiminerals/mineral.gd",
	"res://HevLib/scenes/minerals/multiminerals/MineralProcessingUnit.gd",
	"res://HevLib/scenes/minerals/multiminerals/AsteroidSpawner.gd",
	"res://HevLib/scenes/service_driver/Services.gd",
	["res://HevLib/scripts/Screensaver.gd",1000],
	PoolStringArray(["user://cache/.HevLib_Cache/Variable_Fetch/upgrades.tscn","res://enceladus/Upgrades.tscn"]),
	PoolStringArray(["user://cache/.HevLib_Cache/Variable_Fetch/ship_limitations.tscn","res://enceladus/Upgrades.tscn"]),
]
static func installScriptExtension(path:String):
	var childPath:String=strings[1]+path
	var childScript:Script=ResourceLoader.load(childPath,"Script").new()
	var parentPath:String=childScript.get_base_script().resource_path
	strings[3].l("Installing script extension:%s <- %s"%[parentPath,childPath])
	childScript.take_over_path(parentPath)
	_savedObjects.append(childScript)
static func installScriptExtensionFromSource(source_code:String):
	var out=GDScript.new()
	out.set_source_code(source_code)
	out.reload()
	var parentPath:String=out.get_base_script().resource_path
	l("Installing script extension from [%s <- Source Code]"%parentPath)
	out.take_over_path(parentPath)
	_savedObjects.append(out)
static func installScriptExtensionFromScript(out:Script):
	var parentPath:String=out.get_base_script().resource_path
	l("Installing script extension from [%s <- %s]"%[parentPath,out])
	out.take_over_path(parentPath)
	_savedObjects.append(out)
static func installScriptOverrideFromSource(source_code:String,original_path:String):
	var out=GDScript.new()
	out.set_source_code(source_code)
	out.reload()
	l("Installing script override from [%s <- Source Code]"%original_path)
	out.take_over_path(original_path)
	_savedObjects.append(out)
static func installScriptOverrideFromScript(out:Script,original_path:String):
	l("Installing script override from [%s <- %s]"%[original_path,out])
	out.take_over_path(original_path)
	_savedObjects.append(out)
static func replaceScene(newPath:String,oldPath:String=""):
	l("Updating scene:%s"%newPath)
	if oldPath.empty():
		oldPath="res://"+newPath
	var scene:=ResourceLoader.load(strings[1].plus_file(newPath))
	scene.take_over_path(oldPath)
	_savedObjects.append(scene)
	l("Finished updating:%s"%oldPath)
static func replaceSceneLiteral(newPath:String,oldPath:String):
	l("Updating scene literal:%s"%newPath)
	var scene:=ResourceLoader.load(newPath)
	if scene:
		scene.take_over_path(oldPath)
		_savedObjects.append(scene)
		l("Finished updating literal:%s"%oldPath)
static func l(msg:String,title:String=MOD_NAME,version:String="%d.%d.%d"%[MOD_VERSION_MAJOR,MOD_VERSION_MINOR,MOD_VERSION_BUGFIX]):
	if MOD_VERSION_METADATA:
		version+="-"+MOD_VERSION_METADATA
	strings[3].l(msg,"%s V%s"%[title,version])
const gdnative_library_extensions:PoolStringArray=PoolStringArray(["gdnlib"])
const driver_dirs=PoolStringArray([
	"HEVLIB_EQUIPMENT_DRIVER_TAGS/",
	"HEVLIB_MENU/",
	"HEVLIB_MINERAL_DRIVER_TAGS/",
	"HEVLIB_DRIVERS/",
])
const variables_folder:String="user://cache/.HevLib_Cache/Variable_Fetch/"
const validation_check_path:String="user://cache/.HevLib_Cache/SafeMode/recache_validation.json"
const releases_cache="user://cache/.Mod_Menu_2_Cache/github_list/releases_cache.json"
const url_store="user://cache/.Mod_Menu_2_Cache/updates/url_refs.json"
const has_updated_store="user://cache/.Mod_Menu_2_Cache/updates/has_updated.txt"
const update_store="user://cache/.Mod_Menu_2_Cache/updates/needs_updates.json"
const event_log_file="user://cache/.HevLib_Cache/Event_Driver/event_log.json"
const active_events_file="user://cache/.HevLib_Cache/Event_Driver/active_events.txt"
const latest_event_file="user://cache/.HevLib_Cache/Event_Driver/latest_event.txt"
const modlet_toggle_restart_path="user://cache/.Mod_Menu_2_Cache/updates/modlet_restart_requests.json"
const updateCacheFile :String="user://cache/.Mod_Menu_2_Cache/updates/mods_to_update.json"
const dependancies_store="user://cache/.Mod_Menu_2_Cache/dependancies/dependancies.json"
const conflicts_store="user://cache/.Mod_Menu_2_Cache/conflicts/conflicts.json"
const complementary_store="user://cache/.Mod_Menu_2_Cache/complementary/complementary.json"
const class_names_to_clear:PoolStringArray=PoolStringArray(["HevLibPointers","MINIZ"])
const class_refs:Dictionary={"HevLibPointers":"res://HevLib/pointers.gd","MINIZ":"res://HevLib/scripts/miniz/miniz.gd"}
static func recache(pointers):
	pointers.FolderAccess.__check_folder_exists("user://cache/.Mod_Menu_2_Cache/updates/manifest_cache/")
	pointers.FolderAccess.__check_folder_exists("user://cache/.Mod_Menu_2_Cache/updates/zip_cache/")
	pointers.FolderAccess.__check_folder_exists("user://cache/.Mod_Menu_2_Cache/dependancies/")
	pointers.FolderAccess.__check_folder_exists("user://cache/.Mod_Menu_2_Cache/conflicts/")
	pointers.FolderAccess.__check_folder_exists("user://cache/.Mod_Menu_2_Cache/complementary/")
	pointers.FolderAccess.__check_folder_exists("user://cache/.Mod_Menu_2_Cache/github_list/icon_cache/")
	pointers.FolderAccess.__check_folder_exists("user://cache/.Mod_Menu_2_Cache/github_list/downloaded_zips/")
	pointers.FolderAccess.__check_folder_exists("user://cache/.HevLib_Cache/Event_Driver/")
	var d:Directory=Directory.new()
	var file:File=File.new()
	for f in PoolStringArray(pointers.FolderAccess.__fetch_folder_files("user://cache/.Mod_Menu_2_Cache/updates/zip_cache/",true,true)):d.remove(f)
	for f in PoolStringArray(pointers.FolderAccess.__fetch_folder_files("user://cache/.Mod_Menu_2_Cache/github_list/downloaded_zips/",true,true)):d.remove(f)
	for f in PoolStringArray(pointers.FolderAccess.__fetch_folder_files("user://cache/.Mod_Menu_2_Cache/updates/manifest_cache/",true,true)):d.remove(f)
	if file.file_exists(releases_cache):
		var age:float=Time.get_unix_time_from_system()-file.get_modified_time(releases_cache)
		if age>3600:
			file.open(releases_cache,File.WRITE)
			file.store_string("{}")
			file.close()
			Debug.l("Releases cache older than an hour (%s minutes old), clearing"%[floor(age/60.0)])
		else:
			Debug.l("Releases cache too new (%s minutes old), not clearing"%[floor(age/60)])
	file.open(url_store,File.WRITE)
	file.store_string("[]")
	file.close()
	file.open(has_updated_store,File.WRITE)
	file.store_8(0)
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
	file.open(updateCacheFile,File.WRITE)
	file.store_string("[]")
	file.close()
	file.open(conflicts_store,File.WRITE)
	file.store_string(JSON.print(pointers.ManifestV2.__check_conflicts()))
	file.close()
	file.open(dependancies_store,File.WRITE)
	file.store_string(JSON.print(pointers.ManifestV2.__check_dependancies()))
	file.close()
	file.open(complementary_store,File.WRITE)
	file.store_string(JSON.print(pointers.ManifestV2.__check_complementary()))
	file.close()
const remap_str:String="[remap]\n\npath=\"%s\"\n"
static func process_gdnative_plugins()->Dictionary:
	var fetchPaths:Dictionary={}
	var exePath:String=OS.get_executable_path().get_base_dir()+"/hevlib_dll_store/"
	if!OS.has_feature("editor"):
		var all_libraries:PoolStringArray=PoolStringArray()
		for first in fetch_folder_files("res://",true):
			if first.ends_with("/"):
				for second in fetch_folder_files("res://"+first,true):
					if second in driver_dirs:
						for driverFile in fetch_folder_files("res://"+first+second):
							if driverFile=="DLL_MAPPER.gd":
								var mod_dir:String="res://"+first
								for entry in PoolStringArray(load(mod_dir+second+"DLL_MAPPER.gd").get_script_constant_map().get("DLL_MAPPER",[])):
									if!entry.begins_with("res://"):entry=mod_dir.plus_file(entry)
									if entry.get_extension()in gdnative_library_extensions:all_libraries.append(entry)
		var copied_files:PoolStringArray=PoolStringArray()
		var existing_libs:PoolStringArray=PoolStringArray()
		var lib_resave:Dictionary=Dictionary()
		var configFile:ConfigFile=ConfigFile.new()
		var file:File=File.new()
		var directory:Directory=Directory.new()
		directory.make_dir_recursive(exePath)
		var libs_to_copy:Dictionary=Dictionary()
		for entry in all_libraries:
			configFile.load(entry)
			var cfg_sections:Array=configFile.get_sections()
			var data:Dictionary={}
			for section in cfg_sections:
				var dta:Dictionary={}
				for key in configFile.get_section_keys(section):dta[key]=configFile.get_value(section,key)
				data[section]=dta
			if"entry"in data:
				for oper in data["entry"]:
					var lib_path:String=data["entry"][oper]
					var new_path:String=exePath+lib_path.get_file()
					if file_exists(lib_path):
						file.open(lib_path,File.READ)
						libs_to_copy[new_path]=file.get_buffer(file.get_len())
						file.close()
						data["entry"][oper]=new_path
						existing_libs.append(new_path.get_file())
			if"dependencies"in data:
				for oper in data["dependencies"]:
					var lib_paths:Array=data["dependencies"][oper]
					for lbr in lib_paths.size():
						var lib_path:String=lib_paths[lbr]
						var new_path:String=exePath+lib_path.get_file()
						if file_exists(lib_path):
							file.open(lib_path,File.READ)
							libs_to_copy[new_path]=file.get_buffer(file.get_len())
							file.close()
							lib_paths[lbr]=new_path
							existing_libs.append(new_path.get_file())
					data["dependencies"][oper]=lib_paths
			lib_resave[entry]=data
			for f in libs_to_copy:
				file.open(f,File.WRITE)
				file.store_buffer(libs_to_copy[f])
				file.close()
			copied_files.append_array(libs_to_copy.keys())
		for entry in lib_resave:
			var data:Dictionary=lib_resave[entry]
			var savePath:String="user://cache/.HevLib_Cache/Variable_Fetch/%d.gdnlib"%Time.get_ticks_usec()
			configFile.clear()
			for section in data.keys():
				var keys:Dictionary=data[section]
				for key in keys.keys():configFile.set_value(section,key,keys[key])
			configFile.save(savePath)
			file.open(savePath,File.READ)
			var bfr:PoolByteArray=file.get_buffer(file.get_len())
			file.close()
			fetchPaths[entry.substr(6)]=bfr
		configFile.clear()
		for f in fetch_folder_files(exePath):
			if!f in existing_libs:directory.remove(exePath+f)
	return fetchPaths
static func handle_pointer_cast_clearing(replacements:Dictionary,modLoader:ModLoader)->Dictionary:
	var script_paths:PoolStringArray=PoolStringArray()
	var file:File=File.new()
	for zip in modLoader._modZipFiles:
		file.open(zip,File.READ)
		var buffer:PoolByteArray=file.get_buffer(file.get_len())
		file.close()
		var buffer_len:int=buffer.size()
		if buffer_len<22:continue
		# Fetch EOCD, including max potential comment size
		# More mem efficient than fetching entire buffer
		var tail:PoolByteArray=buffer.subarray(0,buffer_len-max(buffer_len-0x06054b50-65536,0)-1)
		var eocd_pos:int=-1
		var i:int=tail.size()-22
		while i>-1:
			if tail[i]==0x50&&tail[i+1]==0x4b&&tail[i+2]==0x05&&tail[i+3]==0x06:
				eocd_pos=i
				break
			i -=1
		if eocd_pos<0:continue
		var total_entries:int=(tail[eocd_pos+10]|(tail[eocd_pos+10+1]<<8))
		var current_offset:int=(tail[eocd_pos+16]|(tail[eocd_pos+16+1]<<8)|(tail[eocd_pos+16+2]<<16)|(tail[eocd_pos+16+3]<<24))
		for ctr in total_entries:
			var magic:int=(tail[current_offset]|(tail[current_offset+1]<<8)|(tail[current_offset+2]<<16)|(tail[current_offset+3]<<24))
			var magicCheck:int=0x02014b50
			if magic!=magicCheck:break
			current_offset+=28 # magic num. and skip written version+required version + flag and compression method and skip time + date + CRC32 + comp_size + uncomp_size
			var name_len:int=(tail[current_offset]|(tail[current_offset+1]<<8))
			var extra_len:int=(tail[current_offset+2]|(tail[current_offset+3]<<8))
			var comment_len:int=(tail[current_offset+4]|(tail[current_offset+5]<<8))
			current_offset+=18 # comment length and skip disk num. + internal attrib + external attrib. + local_offset
			var file_name:String=tail.subarray(current_offset,current_offset+name_len-1).get_string_from_utf8()
			current_offset+=name_len
			if extra_len>0:current_offset+=extra_len
			if comment_len>0:current_offset+=comment_len
			if file_name.get_extension()=="gd":script_paths.append(file_name)
	if script_paths:
		Directory.new().make_dir_recursive("user://cache/.HevLib_Cache/Variable_Fetch/")
		for sc in script_paths:
			if sc.get_file()=="DEFINED_CLASS_NAMES.gd"&&sc.split("/",false)[-2]in driver_dirs:
				var fetched:Dictionary=load(sc).get_script_constant_map().get("DEFINED_CLASS_NAMES",{})
				for i in fetched.keys():
					if!i in class_names_to_clear&&typeof(fetched[i])==TYPE_STRING:
						class_names_to_clear.append(i)
						class_refs[i]=fetched[i]
		var regex:RegEx=RegEx.new() # Checks for object literal
		var regex2:RegEx=RegEx.new() # Checks for common signatures of memory-unsafe code
		regex.compile("|".join(class_names_to_clear))
		regex2.compile("(?m)^.*?\\K(#)(?:.*?(?:%s))"%"|".join(PoolStringArray(["-".repeat(7),"=".repeat(7),"─".repeat(7)])))
		var sct:int=script_paths.size()
		var scr:Array=range(sct)
		seed(strings.hash()+Time.get_ticks_usec())
		scr.shuffle()
		for sc in sct:
			var script:String=script_paths[sc]
			file.open("res://"+script,File.READ)
			var text:String=file.get_as_text(true)
			file.close()
			var remapped_path:String="hlremapper/%05d.gd"%scr[sc]
			if regex2.search(text) is RegExMatch:
				replacements[script+".remap"]=(remap_str%remapped_path).to_utf8()
				replacements[remapped_path]=PoolByteArray()
			elif regex.search(text) is RegExMatch:
				replacements[script+".remap"]=(remap_str%remapped_path).to_utf8()
				replacements[remapped_path]=remove_type_casting(text,class_refs).to_utf8()
	return replacements
static func create_zip_for_overrides(replacements:Dictionary,md:Node):
	if replacements:
		var datetime:Dictionary=Time.get_datetime_dict_from_system()
		var dos_time:int=(datetime.hour<<11)|(datetime.minute<<5)|int(datetime.second/2.0)
		var dos_date:int=(int(max(datetime.year-1980,0))<<9)|(datetime.month<<5)|datetime.day
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
			var crc:int=md.get_crc_32(data)
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
		var cdrs:int=buffer.size()-cdr
		var crs:int=central_records.size()
		var cr1:int=crs
		var cr2:int=(crs>>8)&0xFF
		var offset:int=buffer.size()
		buffer.resize(offset+22)
		buffer[offset]=80;buffer[offset+1]=75;buffer[offset+2]=5;buffer[offset+3]=6 # EOCD magic number
		buffer[offset+4]=0;buffer[offset+5]=0;buffer[offset+6]=0;buffer[offset+7]=0 # Disk
		buffer[offset+8]=cr1;buffer[offset+9]=cr2;buffer[offset+10]=cr1;buffer[offset+11]=cr2 # Size
		buffer[offset+12]=cdrs&0xFF;buffer[offset+13]=(cdrs&0xFF00)>>8;buffer[offset+14]=(cdrs&0xFF0000)>>16;buffer[offset+15]=(cdrs&0xFF000000)>>24 # CD size
		buffer[offset+16]=cdr&0xFF;buffer[offset+17]=(cdr&0xFF00)>>8;buffer[offset+18]=(cdr&0xFF0000)>>16;buffer[offset+19]=(cdr&0xFF000000)>>24 # CD offset
		buffer[offset+20]=0;buffer[offset+21]=0 # Comment length
		var castFile:String="user://cache/.HevLib_Cache/Variable_Fetch/remove_pointer_casting.zip"
		var file:File=File.new()
		file.open(castFile,File.WRITE)
		file.store_buffer(buffer)
		file.close()
		ProjectSettings.load_resource_pack(castFile)
const blankspace:PoolStringArray=PoolStringArray([" ","\t","\n"])
enum{TOKEN_COMMENT,TOKEN_STRING,TOKEN_NUMBER,TOKEN_IDENTIFIER,TOKEN_SYMBOL}
static func remove_type_casting(source_code:String,class_data:Dictionary)->String:
	source_code=source_code.replace("\r","")
	var tokens:Array=Array()
	var class_names:PoolStringArray=PoolStringArray(class_data.keys())
	var length:int=source_code.length()
	var i:int=0
	var comment_starter:PoolStringArray=PoolStringArray(["'","\""])
	var additional_nums:PoolStringArray=PoolStringArray([".","_","x","a","b","c","d","e","f"])
	while i<length:
		var c:String=source_code[i]
		if c in blankspace:# Skip blankspace/newlines
			i+=1
			continue
		if c=="#":# Skip comments
			var cstart:int=i
			while i<length&&source_code[i]!="\n":i+=1
			tokens.append({"type":TOKEN_COMMENT,"text":source_code.substr(cstart,i-cstart),"start":cstart,"end":i})
			continue
		if c in comment_starter:# String handling
			var sstart:int=i
			if (i+2<length&&source_code[i+1]==c&&source_code[i+2]==c):# If triple quote comment
				i+=3
				while i<length:
					if source_code[i]=="\\":
						i+=2
						continue
					if i+2<length&&source_code[i]==c&&source_code[i+1]==c&&source_code[i+2]==c:
						i+=3
						break
					i+=1
			else:
				i+=1
				while i<length:
					if source_code[i]=="\\":
						i+=2
						continue
					if source_code[i]==c:
						i+=1
						break
					if source_code[i]=="\n":break
					i+=1
			tokens.append({"type":TOKEN_STRING,"text":source_code.substr(sstart,i-sstart),"start":sstart,"end":i})
			continue
		if word_is_number(ord(c))||(c=="."&&i+1<length&&word_is_number(ord(source_code[i+1]))):# Handle ints&&floats
			var nstart:int=i
			while i<length:
				var nc:String=source_code[i].to_lower()
				if word_is_number(ord(nc))||nc in additional_nums:i+=1
				else:break
			tokens.append({"type":TOKEN_NUMBER,"text":source_code.substr(nstart,i-nstart),"start":nstart,"end":i})
			continue
		if c=="_"||word_is_alpha(ord(c)):# Identifier literals
			var istart:int=i
			while i<length&&(source_code[i]=="_"||word_is_alpha(ord(source_code[i]))||word_is_number(ord(source_code[i]))):i+=1
			tokens.append({"type":TOKEN_IDENTIFIER,"text":source_code.substr(istart,i-istart),"start":istart,"end":i})
			continue
		if c=="-"&&i+1<length&&source_code[i+1]==">":# Function type cast
			tokens.append({"type":TOKEN_SYMBOL,"text":"->","start":i,"end":i+2})
			i+=2
			continue
		if c==":"&&i+1<length&&source_code[i+1]=="=":# Auto type cast
			tokens.append({"type":TOKEN_SYMBOL,"text":":=","start":i,"end":i+2})
			i+=2
			continue
		tokens.append({"type":TOKEN_SYMBOL,"text":c,"start":i,"end":i+1})
		i+=1
	var modifications:Array=Array()
	i=0
	var n:int=tokens.size()
	while i<n:
		var t:Dictionary=tokens[i]
		var ttype:int=t.type
		match ttype:
			TOKEN_IDENTIFIER:
				pass
			TOKEN_COMMENT:
				modifications.append({"start":t.start,"end":t.end,"text":""})
			_:
				i+=1
				continue
		if t.text=="var"||t.text=="const":
			i+=1
			if i<n&&tokens[i].type==TOKEN_IDENTIFIER:
				var name_tok:Dictionary=tokens[i]
				i+=1
				if i<n&&tokens[i].type==TOKEN_SYMBOL&&tokens[i].text==":":
					i+=1
					if i<n&&tokens[i].type==TOKEN_IDENTIFIER:
						var path_info:Dictionary=check_following_tokens(tokens,i,n)
						i=path_info.next_i
						if path_info.base in class_names:
							modifications.append({"start":name_tok.end,"end":path_info.end,"text":""})
			continue
		elif t.text=="func":
			i+=1
			if i<n&&tokens[i].type==TOKEN_IDENTIFIER:
				i+=1
			if (i<n&&tokens[i].type==TOKEN_SYMBOL&&tokens[i].text=="("):
				i+=1
				var depth:int=1
				var expect_name:bool=true
				var just_saw_name:bool=false
				var current_name_end:int=-1
				var close_paren_end:int=-1
				while i<n&&depth>0:
					var tk:Dictionary=tokens[i]
					if tk.type==TOKEN_SYMBOL&&(tk.text=="("||tk.text=="["||tk.text=="{"):
						depth+=1
						just_saw_name=false
						i+=1
						continue
					if tk.type==TOKEN_SYMBOL&&(tk.text==")"||tk.text=="]"||tk.text=="}"):
						depth -= 1
						if depth==0:
							close_paren_end=tk.end
							i+=1
							break
						just_saw_name=false
						i+=1
						continue
					if depth==1&&tk.type==TOKEN_SYMBOL&&tk.text==",":
						expect_name=true
						just_saw_name=false
						i+=1
						continue
					if depth==1&&tk.type==TOKEN_SYMBOL&&tk.text==":"&&just_saw_name:
						i+=1
						just_saw_name=false
						if i<n&&tokens[i].type==TOKEN_IDENTIFIER:
							var p_path:Dictionary=check_following_tokens(tokens,i,n)
							i=p_path.next_i
							if p_path.base in class_names:
								modifications.append({"start":current_name_end,"end":p_path.end,"text":""})
						continue
					if tk.type==TOKEN_IDENTIFIER&&expect_name:
						current_name_end=tk.end
						expect_name=false
						just_saw_name=true
						i+=1
						continue
					if tk.type==TOKEN_IDENTIFIER:
						if tk.text in class_names:
							modifications.append({"start":tk.start,"end":tk.end,"text":"load(\""+escape_text(class_data[tk.text])+"\")"})
						just_saw_name=false
						i+=1
						continue
					just_saw_name=false
					i+=1
				if close_paren_end!=-1&&i<n&&tokens[i].type==TOKEN_SYMBOL&&tokens[i].text=="->":
					i+=1
					if i<n&&tokens[i].type==TOKEN_IDENTIFIER:
						var ret_path:Dictionary=check_following_tokens(tokens,i,n)
						i=ret_path.next_i
						if ret_path.base in class_names:
							modifications.append({"start":close_paren_end,"end":ret_path.end,"text":""})
			continue
		elif t.text=="export":
			var export_tok:Dictionary=tokens[i]
			i+=1
			if (i<n&&tokens[i].type==TOKEN_SYMBOL&&tokens[i].text=="("):
				i+=1
				var depth:int=1
				var top_level_tokens:Array=Array()
				var close_tok=null
				while i<n&&depth>0:
					var tk:Dictionary=tokens[i]
					if tk.type==TOKEN_SYMBOL&&(tk.text=="("||tk.text=="["||tk.text=="{"):
						depth+=1
						top_level_tokens.append(tk)
						i+=1
						continue
					if tk.type==TOKEN_SYMBOL&&(tk.text==")"||tk.text=="]"||tk.text=="}"):
						depth -= 1
						if depth==0:
							close_tok=tk
							i+=1
							break
						top_level_tokens.append(tk)
						i+=1
						continue
					if depth==1:
						top_level_tokens.append(tk)
					i+=1
				if close_tok!=null&&top_level_tokens.size()==1:
					var only:Dictionary=top_level_tokens[0]
					if only.type==TOKEN_IDENTIFIER&&only.text in class_names:
						modifications.append({"start":export_tok.end,"end":close_tok.end,"text":"","eat_trailing_space":true})
			continue
		elif t.text=="extends":
			i+=1
			if i<n&&tokens[i].type==TOKEN_IDENTIFIER&&tokens[i].text in class_names:
				var ext_tok:Dictionary=tokens[i]
				modifications.append({"start":ext_tok.start,"end":ext_tok.end,"text":"\""+escape_text(class_data[ext_tok.text])+"\""})
				i+=1
			continue
		elif t.text=="class_name"||t.text=="class":
			i+=1
			if i<n&&tokens[i].type==TOKEN_IDENTIFIER:
				i+=1
			continue
		else:
			if t.text in class_names:
				modifications.append({"start":t.start,"end":t.end,"text":"load(\""+escape_text(class_data[t.text])+"\")"})
			i+=1
			continue
	var result:String=""
	var cursor:int=0
	for e in modifications:
		result+=source_code.substr(cursor,e.start-cursor)
		result+=e.text
		var end:int=e.end
		if"eat_trailing_space"in e&&end<length&&source_code[end]==" ":
			end+=1
		cursor=end
	result+=source_code.substr(cursor,length-cursor)
	return result
static func check_following_tokens(tokens:Array,i:int,n:int)->Dictionary:
	var base_text:String=tokens[i].text
	var end:int=tokens[i].end
	i+=1
	while i+1<n&&tokens[i].type==TOKEN_SYMBOL&&tokens[i].text=="."&&tokens[i+1].type==TOKEN_IDENTIFIER:
		end=tokens[i+1].end
		i+=2
	return{"base":base_text,"end":end,"next_i":i}
static func escape_text(s:String)->String:
	return s.replace("\\","\\\\").replace("\"","\\\"")
static func word_is_number(c:int)->bool:
	return c>47&&c<58
static func word_is_alpha(c:int)->bool:
	return(c>96&&c<123)||(c>64&&c<91)
static func word_is_tex(c:int)->bool:
	return(c>96&&c<123)||(c>64&&c<91)||(c>47&&c<58)||c==95
enum{
	TK_EMPTY,TK_IDENTIFIER,TK_CONSTANT,TK_SELF,TK_BUILT_IN_TYPE,TK_BUILT_IN_FUNC,TK_OP_IN,TK_OP_EQUAL,
	TK_OP_NOT_EQUAL,TK_OP_LESS,TK_OP_LESS_EQUAL,TK_OP_GREATER,TK_OP_GREATER_EQUAL,TK_OP_AND,TK_OP_OR,
	TK_OP_NOT,TK_OP_ADD,TK_OP_SUB,TK_OP_MUL,TK_OP_DIV,TK_OP_MOD,TK_OP_SHIFT_LEFT,TK_OP_SHIFT_RIGHT,TK_OP_ASSIGN,
	TK_OP_ASSIGN_ADD,TK_OP_ASSIGN_SUB,TK_OP_ASSIGN_MUL,TK_OP_ASSIGN_DIV,TK_OP_ASSIGN_MOD,TK_OP_ASSIGN_SHIFT_LEFT,
	TK_OP_ASSIGN_SHIFT_RIGHT,TK_OP_ASSIGN_BIT_AND,TK_OP_ASSIGN_BIT_OR,TK_OP_ASSIGN_BIT_XOR,TK_OP_BIT_AND,
	TK_OP_BIT_OR,TK_OP_BIT_XOR,TK_OP_BIT_INVERT,TK_CF_IF,TK_CF_ELIF,TK_CF_ELSE,TK_CF_FOR,TK_CF_WHILE,TK_CF_BREAK,
	TK_CF_CONTINUE,TK_CF_PASS,TK_CF_RETURN,TK_CF_MATCH,TK_PR_FUNCTION,TK_PR_CLASS,TK_PR_CLASS_NAME,TK_PR_EXTENDS,
	TK_PR_IS,TK_PR_ONREADY,TK_PR_TOOL,TK_PR_STATIC,TK_PR_EXPORT,TK_PR_SETGET,TK_PR_CONST,TK_PR_VAR,TK_PR_AS,
	TK_PR_VOID,TK_PR_ENUM,TK_PR_PRELOAD,TK_PR_ASSERT,TK_PR_YIELD,TK_PR_SIGNAL,TK_PR_BREAKPOINT,TK_PR_REMOTE,
	TK_PR_SYNC,TK_PR_MASTER,TK_PR_SLAVE,TK_PR_PUPPET,TK_PR_REMOTESYNC,TK_PR_MASTERSYNC,TK_PR_PUPPETSYNC,
	TK_BRACKET_OPEN,TK_BRACKET_CLOSE,TK_CURLY_BRACKET_OPEN,TK_CURLY_BRACKET_CLOSE,TK_PARENTHESIS_OPEN,
	TK_PARENTHESIS_CLOSE,TK_COMMA,TK_SEMICOLON,TK_PERIOD,TK_QUESTION_MARK,TK_COLON,TK_DOLLAR,TK_FORWARD_ARROW,
	TK_NEWLINE,TK_CONST_PI,TK_CONST_TAU,TK_WILDCARD,TK_CONST_INF,TK_CONST_NAN,TK_ERROR,TK_EOF,TK_CURSOR,}
const token_lookup = {
	TK_EMPTY:"TK_EMPTY",
	TK_IDENTIFIER:"TK_IDENTIFIER",
	TK_CONSTANT:"TK_CONSTANT",
	TK_SELF:"TK_SELF",
	TK_BUILT_IN_TYPE:"TK_BUILT_IN_TYPE",
	TK_BUILT_IN_FUNC:"TK_BUILT_IN_FUNC",
	TK_OP_IN:"TK_OP_IN",
	TK_OP_EQUAL:"TK_OP_EQUAL",
	TK_OP_NOT_EQUAL:"TK_OP_NOT_EQUAL",
	TK_OP_LESS:"TK_OP_LESS",
	TK_OP_LESS_EQUAL:"TK_OP_LESS_EQUAL",
	TK_OP_GREATER:"TK_OP_GREATER",
	TK_OP_GREATER_EQUAL:"TK_OP_GREATER_EQUAL",
	TK_OP_AND:"TK_OP_AND",
	TK_OP_OR:"TK_OP_OR",
	TK_OP_NOT:"TK_OP_NOT",
	TK_OP_ADD:"TK_OP_ADD",
	TK_OP_SUB:"TK_OP_SUB",
	TK_OP_MUL:"TK_OP_MUL",
	TK_OP_DIV:"TK_OP_DIV",
	TK_OP_MOD:"TK_OP_MOD",
	TK_OP_SHIFT_LEFT:"TK_OP_SHIFT_LEFT",
	TK_OP_SHIFT_RIGHT:"TK_OP_SHIFT_RIGHT",
	TK_OP_ASSIGN:"TK_OP_ASSIGN",
	TK_OP_ASSIGN_ADD:"TK_OP_ASSIGN_ADD",
	TK_OP_ASSIGN_SUB:"TK_OP_ASSIGN_SUB",
	TK_OP_ASSIGN_MUL:"TK_OP_ASSIGN_MUL",
	TK_OP_ASSIGN_DIV:"TK_OP_ASSIGN_DIV",
	TK_OP_ASSIGN_MOD:"TK_OP_ASSIGN_MOD",
	TK_OP_ASSIGN_SHIFT_LEFT:"TK_OP_ASSIGN_SHIFT_LEFT",
	TK_OP_ASSIGN_SHIFT_RIGHT:"TK_OP_ASSIGN_SHIFT_RIGHT",
	TK_OP_ASSIGN_BIT_AND:"TK_OP_ASSIGN_BIT_AND",
	TK_OP_ASSIGN_BIT_OR:"TK_OP_ASSIGN_BIT_OR",
	TK_OP_ASSIGN_BIT_XOR:"TK_OP_ASSIGN_BIT_XOR",
	TK_OP_BIT_AND:"TK_OP_BIT_AND",
	TK_OP_BIT_OR:"TK_OP_BIT_OR",
	TK_OP_BIT_XOR:"TK_OP_BIT_XOR",
	TK_OP_BIT_INVERT:"TK_OP_BIT_INVERT",
	TK_CF_IF:"TK_CF_IF",
	TK_CF_ELIF:"TK_CF_ELIF",
	TK_CF_ELSE:"TK_CF_ELSE",
	TK_CF_FOR:"TK_CF_FOR",
	TK_CF_WHILE:"TK_CF_WHILE",
	TK_CF_BREAK:"TK_CF_BREAK",
	TK_CF_CONTINUE:"TK_CF_CONTINUE",
	TK_CF_PASS:"TK_CF_PASS",
	TK_CF_RETURN:"TK_CF_RETURN",
	TK_CF_MATCH:"TK_CF_MATCH",
	TK_PR_FUNCTION:"TK_PR_FUNCTION",
	TK_PR_CLASS:"TK_PR_CLASS",
	TK_PR_CLASS_NAME:"TK_PR_CLASS_NAME",
	TK_PR_EXTENDS:"TK_PR_EXTENDS",
	TK_PR_IS:"TK_PR_IS",
	TK_PR_ONREADY:"TK_PR_ONREADY",
	TK_PR_TOOL:"TK_PR_TOOL",
	TK_PR_STATIC:"TK_PR_STATIC",
	TK_PR_EXPORT:"TK_PR_EXPORT",
	TK_PR_SETGET:"TK_PR_SETGET",
	TK_PR_CONST:"TK_PR_CONST",
	TK_PR_VAR:"TK_PR_VAR",
	TK_PR_AS:"TK_PR_AS",
	TK_PR_VOID:"TK_PR_VOID",
	TK_PR_ENUM:"TK_PR_ENUM",
	TK_PR_PRELOAD:"TK_PR_PRELOAD",
	TK_PR_ASSERT:"TK_PR_ASSERT",
	TK_PR_YIELD:"TK_PR_YIELD",
	TK_PR_SIGNAL:"TK_PR_SIGNAL",
	TK_PR_BREAKPOINT:"TK_PR_BREAKPOINT",
	TK_PR_REMOTE:"TK_PR_REMOTE",
	TK_PR_SYNC:"TK_PR_SYNC",
	TK_PR_MASTER:"TK_PR_MASTER",
	TK_PR_SLAVE:"TK_PR_SLAVE",
	TK_PR_PUPPET:"TK_PR_PUPPET",
	TK_PR_REMOTESYNC:"TK_PR_REMOTESYNC",
	TK_PR_MASTERSYNC:"TK_PR_MASTERSYNC",
	TK_PR_PUPPETSYNC:"TK_PR_PUPPETSYNC",
	TK_BRACKET_OPEN:"TK_BRACKET_OPEN",
	TK_BRACKET_CLOSE:"TK_BRACKET_CLOSE",
	TK_CURLY_BRACKET_OPEN:"TK_CURLY_BRACKET_OPEN",
	TK_CURLY_BRACKET_CLOSE:"TK_CURLY_BRACKET_CLOSE",
	TK_PARENTHESIS_OPEN:"TK_PARENTHESIS_OPEN",
	TK_PARENTHESIS_CLOSE:"TK_PARENTHESIS_CLOSE",
	TK_COMMA:"TK_COMMA",
	TK_SEMICOLON:"TK_SEMICOLON",
	TK_PERIOD:"TK_PERIOD",
	TK_QUESTION_MARK:"TK_QUESTION_MARK",
	TK_COLON:"TK_COLON",
	TK_DOLLAR:"TK_DOLLAR",
	TK_FORWARD_ARROW:"TK_FORWARD_ARROW",
	TK_NEWLINE:"TK_NEWLINE",
	TK_CONST_PI:"TK_CONST_PI",
	TK_CONST_TAU:"TK_CONST_TAU",
	TK_WILDCARD:"TK_WILDCARD",
	TK_CONST_INF:"TK_CONST_INF",
	TK_CONST_NAN:"TK_CONST_NAN",
	TK_ERROR:"TK_ERROR",
	TK_EOF:"TK_EOF",
	TK_CURSOR:"TK_CURSOR",
}

const func_index={
	"sin":0,"cos":1,"tan":2,"sinh":3,"cosh":4,"tanh":5,"asin":6,"acos":7,"atan":8,"atan2":9,
	"sqrt":10,"fmod":11,"fposmod":12,"posmod":13,"floor":14,"ceil":15,"round":16,"abs":17,"sign":18,"pow":19,
	"log":20,"exp":21,"is_nan":22,"is_inf":23,"is_equal_approx":24,"is_zero_approx":25,"ease":26,"decimals":27,
	"step_decimals":28,"stepify":29,"lerp":30,"lerp_angle":31,"inverse_lerp":32,"range_lerp":33,
	"smoothstep":34,"move_toward":35,"dectime":36,"randomize":37,"randi":38,"randf":39,"rand_range":40,"seed":41,
	"rand_seed":42,"deg2rad":43,"rad2deg":44,"linear2db":45,"db2linear":46,"polar2cartesian":47,
	"cartesian2polar":48,"wrapi":49,"wrapf":50,"max":51,"min":52,"clamp":53,"nearest_po2":54,
	"weakref":55,"funcref":56,"convert":57,"typeof":58,"type_exists":59,"char":60,"ord":61,"str":62,
	"print":63,"printt":64,"prints":65,"printerr":66,"printraw":67,"print_debug":68,"push_error":69,
	"push_warning":70,"var2str":71,"str2var":72,"var2bytes":73,"bytes2var":74,"range":75,"load":76,
	"inst2dict":77,"dict2inst":78,"validate_json":79,"parse_json":80,"to_json":81,"hash":82,"Color8":83,"ColorN":84,
	"print_stack":85,"get_stack":86,"instance_from_id":87,"len":88,"is_instance_valid":89,"deep_equal":90,
}
const type_index={
	"bool":TYPE_BOOL,"int":TYPE_INT,"float":TYPE_REAL,"String":TYPE_STRING,
	"Vector2":TYPE_VECTOR2,"Rect2":TYPE_RECT2,"Vector3":TYPE_VECTOR3,"Transform2D":TYPE_TRANSFORM2D,
	"Plane":TYPE_PLANE,"Quat":TYPE_QUAT,"AABB":TYPE_AABB,"Basis":TYPE_BASIS,
	"Transform":TYPE_TRANSFORM,"Color":TYPE_COLOR,"NodePath":TYPE_NODE_PATH,"RID":TYPE_RID,
	"Object":TYPE_OBJECT,"Dictionary":TYPE_DICTIONARY,"Array":TYPE_ARRAY,
	"PoolByteArray":TYPE_RAW_ARRAY,"PoolIntArray":TYPE_INT_ARRAY,"PoolRealArray":TYPE_REAL_ARRAY,
	"PoolStringArray":TYPE_STRING_ARRAY,"PoolVector2Array":TYPE_VECTOR2_ARRAY,
	"PoolVector3Array":TYPE_VECTOR3_ARRAY,"PoolColorArray":TYPE_COLOR_ARRAY,
}
const keywords={
	"in":TK_OP_IN,"not":TK_OP_NOT,"or":TK_OP_OR,"and":TK_OP_AND,
	"func":TK_PR_FUNCTION,"class":TK_PR_CLASS,"class_name":TK_PR_CLASS_NAME,
	"extends":TK_PR_EXTENDS,"is":TK_PR_IS,"onready":TK_PR_ONREADY,
	"tool":TK_PR_TOOL,"static":TK_PR_STATIC,"export":TK_PR_EXPORT,
	"setget":TK_PR_SETGET,"var":TK_PR_VAR,"as":TK_PR_AS,"void":TK_PR_VOID,
	"preload":TK_PR_PRELOAD,"assert":TK_PR_ASSERT,"yield":TK_PR_YIELD,
	"signal":TK_PR_SIGNAL,"breakpoint":TK_PR_BREAKPOINT,
	"remote":TK_PR_REMOTE,"master":TK_PR_MASTER,"slave":TK_PR_SLAVE,
	"puppet":TK_PR_PUPPET,"sync":TK_PR_SYNC,"remotesync":TK_PR_REMOTESYNC,
	"mastersync":TK_PR_MASTERSYNC,"puppetsync":TK_PR_PUPPETSYNC,
	"const":TK_PR_CONST,"enum":TK_PR_ENUM,
	"if":TK_CF_IF,"elif":TK_CF_ELIF,"else":TK_CF_ELSE,"for":TK_CF_FOR,
	"while":TK_CF_WHILE,"break":TK_CF_BREAK,"continue":TK_CF_CONTINUE,
	"return":TK_CF_RETURN,"match":TK_CF_MATCH,"pass":TK_CF_PASS,
	"self":TK_SELF,"PI":TK_CONST_PI,"TAU":TK_CONST_TAU,"_":TK_WILDCARD,
	"INF":TK_CONST_INF,"NAN":TK_CONST_NAN,
}
const compile_err_header="SCRIPT COMPILE ERR-line %d: %s"
enum{
	KEY_HORIZONTALTAB=9,KEY_LINEFEED=10,KEY_CARRIAGERETURN=13,KEY_SINGLEQUOTE=39,
	KEY_DOUBLEQUOTE=34,KEY_BELL=7,KEY_BACKSPACE=8,KEY_VERTICALTAB=11,KEY_FORMFEED=12,}
const blankspace_nolf_chars:PoolIntArray=PoolIntArray([9,32])
const quote_chars:PoolIntArray=PoolIntArray([34,39])
const post_store:PoolIntArray=PoolIntArray([0,0,0])
const type_store:PoolIntArray=PoolIntArray()
const args_store:Array=Array()
const line_store:PoolIntArray=PoolIntArray()
const char_store:PoolIntArray=PoolIntArray()
static func source_to_bytecode(source_code:String)->PoolByteArray:
	source_code=source_code.replace("\r","")
	var source_length:int=source_code.length()
	post_store[0]=0
	post_store[1]=0
	post_store[2]=source_length
	type_store.clear()
	args_store.clear()
	line_store.clear()
	char_store.clear()
	char_store.resize(source_length)
	for i in source_length:
		char_store[i]=source_code.ord_at(i)
	while true:
		if!next_token():
			return PoolByteArray()
		if type_store[-1]==TK_EOF:
			break
#	var store=[]
#	for i in 1000:
#		store.append(token_lookup[type_store[i]])
#	for r in class_names_to_clear:
#		var ctr:int = 0
#		while true:
#			var location:int = args_store.find(r,ctr)
#			if location > -1:
#				var lookbehind:Array = []
#				var back:int = location - 1
#				while type_store[back] != TK_NEWLINE:
#					lookbehind.append(token_lookup[type_store[back]])
#					back -= 1
#				var lookbehind_sz:int = lookbehind.size()
#				if lookbehind_sz==1 and lookbehind[0] == "TK_PR_CLASS_NAME":
#					pass
#				elif lookbehind[-1] in [TK_PR_VAR,TK_PR_CONST] and lookbehind[-3]:
#					breakpoint
#				ctr = location + 1
#			else:break
#
#		breakpoint
#
#	breakpoint
	var identifier_map:Dictionary={}
	var identifiers:PoolStringArray=PoolStringArray()
	var constant_map:Dictionary={}
	var constants:Array=Array()
	var line_tokens:PoolIntArray=PoolIntArray()
	var line_numbers:PoolIntArray=PoolIntArray()
	var token_array:PoolIntArray=PoolIntArray()
	var line:int=-1
	for k in type_store.size():
		if line_store[k]!=line:
			line=line_store[k]
			line_tokens.append(k)
			line_numbers.append(line)
		var t:int=type_store[k]
		var local_token:int=t
		if t==TK_IDENTIFIER:
			var id:String=args_store[k]
			if!id in identifier_map:
				identifier_map[id]=identifiers.size()
				identifiers.append(id)
			local_token|=identifier_map[id]<<8
		elif t==TK_CONSTANT:
			var constant_val=args_store[k]
			var key:String=""
			match typeof(constant_val):
				TYPE_NIL:
					key="nil"
				TYPE_BOOL:
					key="b"+str(constant_val)
				TYPE_INT:
					key="i"+str(constant_val)
				TYPE_REAL:
					var tmp:StreamPeerBuffer=StreamPeerBuffer.new()
					tmp.put_double(constant_val)
					key="f"+str(tmp.data_array)
				TYPE_STRING:
					key="s"+constant_val
				TYPE_NODE_PATH:
					key="n"+str(constant_val)
				_:
					key="?"+str(constant_val)
			if!key in constant_map:
				constant_map[key]=constants.size()
				constants.append(constant_val)
			local_token|=constant_map[key]<<8
		elif t==TK_BUILT_IN_TYPE||t==TK_BUILT_IN_FUNC||t==TK_NEWLINE:
			local_token|=args_store[k]<<8
		token_array.append(local_token)
	var out:StreamPeerBuffer=StreamPeerBuffer.new()
	out.put_u8(0x47) # G
	out.put_u8(0x44) # D
	out.put_u8(0x53) # S
	out.put_u8(0x43) # C
	out.put_u32(13)
	out.put_u32(identifiers.size())
	out.put_u32(constants.size())
	out.put_u32(line_tokens.size())
	out.put_u32(token_array.size())
	for id in identifiers:
		var cs:PoolByteArray=id.to_utf8()
		var l:int=cs.size()+1
		var extra:int=4-(l%4)
		if extra==4:
			extra=0
		out.put_u32(l+extra)
		for b in cs:
			out.put_u8(b^0xb6)
		out.put_u8(0^0xb6)
		for e in extra:
			out.put_u8(0^0xb6)
	for v in constants:
		match typeof(v):
			TYPE_NIL:
				out.put_u32(0)
			TYPE_BOOL:
				out.put_u32(1)
				out.put_u32(1 if v else 0)
			TYPE_INT:
				if v>2147483647||v<-2147483648:
					out.put_u32(2|(1<<16))
					out.put_64(v)
				else:
					out.put_u32(2)
					out.put_32(v)
			TYPE_REAL:
				var tmp:StreamPeerBuffer=StreamPeerBuffer.new()
				tmp.put_float(v)
				tmp.seek(0)
				var bits:StreamPeerBuffer=StreamPeerBuffer.new()
				bits.put_double(v)
				bits.put_double(tmp.get_float())
				bits.seek(0)
				if bits.get_64()==bits.get_64():
					out.put_u32(3)
					out.put_float(v)
				else:
					out.put_u32(3|(1<<16))
					out.put_double(v)
			TYPE_STRING:
				out.put_u32(4)
				stream_string(out,v)
			TYPE_NODE_PATH:
				var np:NodePath=v
				out.put_u32(15)
				out.put_u32(np.get_name_count()|0x80000000)
				out.put_u32(np.get_subname_count())
				out.put_u32(1 if np.is_absolute()else 0)
				for i in np.get_name_count():
					stream_string(out,np.get_name(i))
				for i in np.get_subname_count():
					stream_string(out,np.get_subname(i))
			_:
				printerr("Cannot encode constant of type %d"%typeof(v))
				return PoolByteArray()
	for k in line_tokens.size():
		out.put_u32(line_tokens[k])
		out.put_u32(line_numbers[k])
	for tk in token_array:
		if tk & ~0xFF:
			out.put_u32(tk|0x80)
		else:
			out.put_u8(tk)
	return out.data_array
static func push_token(type:int,arg=null)->void:
	type_store.append(type)
	args_store.append(arg)
	line_store.append(post_store[1])
static func get_char(offset:int)->int:
	var p:int=post_store[0]+offset
	if p<0||p>=post_store[2]:
		return 0
	return char_store[p]
static func stream_string(out:StreamPeerBuffer,s:String)->void:
	var u:PoolByteArray=s.to_utf8()
	out.put_u32(u.size())
	for b in u:
		out.put_u8(b)
	for p in((4-(u.size()%4))%4):
		out.put_u8(0)
static func next_token():
	if post_store[0]>post_store[2]:
		push_token(TK_EOF)
		return true
	while true:
		var ch:int=get_char(0)
		if ch==0:
			push_token(TK_EOF)
			return true
		if ch==KEY_BACKSLASH:
			post_store[0]+=1
			if get_char(0)!=KEY_LINEFEED:
				printerr(compile_err_header%[post_store[1],"Expected newline after '\\'."])
				return false
			post_store[0]+=1
			post_store[1]+=1
			while true:
				if!get_char(0) in PoolIntArray([KEY_SPACE,KEY_HORIZONTALTAB]):
					break
				post_store[0]+=1
			continue
		
		if ch==KEY_HORIZONTALTAB||ch==KEY_SPACE:
			post_store[0]+=1
			continue
		
		if ch==KEY_NUMBERSIGN:
			while get_char(0)!=KEY_LINEFEED:
				post_store[0]+=1
				if get_char(0)==0:
					push_token(TK_EOF)
					return true
			ch=KEY_LINEFEED
		
		if ch==KEY_LINEFEED:
			post_store[1]+=1
			post_store[0]+=1
			var used_spaces:bool=get_char(0)==KEY_SPACE
			var i:int=0
			while true:
				var wc:int=get_char(i)
				if wc==KEY_SPACE:
					if!used_spaces:
						printerr(compile_err_header%[post_store[1],"Mixed tabs&&spaces in indentation"])
						return false
					i+=1
				elif wc==KEY_HORIZONTALTAB:
					if used_spaces:
						printerr(compile_err_header%[post_store[1],"Spaces used before tabs on a line"])
						return false
					i+=1
				else:
					break
			push_token(TK_NEWLINE,i)
			return true
		
		if ch==KEY_AT||ch==KEY_DOUBLEQUOTE||ch==KEY_SINGLEQUOTE:
			return read_string_token(ch)
		
		if word_is_number(ch)||(ch==KEY_PERIOD&&word_is_number(get_char(1))):
			return read_number_token()
		if word_is_tex(ch):
			return read_word_token(ch)
		var n1:int=get_char(1)
		var n2:int=get_char(2)
		var tok:int=-1
		var width:int=1
		match ch:
			KEY_SLASH:
				if n1==KEY_EQUAL:
					tok=TK_OP_ASSIGN_DIV
					width=2
				else:
					tok=TK_OP_DIV
			KEY_EQUAL:
				if n1==KEY_EQUAL:
					tok=TK_OP_EQUAL
					width=2
				else:
					tok=TK_OP_ASSIGN
			KEY_LESS:
				if n1==KEY_EQUAL:
					tok=TK_OP_LESS_EQUAL
					width=2
				elif n1==KEY_LESS:
					if n2==KEY_EQUAL:
						tok=TK_OP_ASSIGN_SHIFT_LEFT
						width=3
					else:
						tok=TK_OP_SHIFT_LEFT
						width=2
				else:
					tok=TK_OP_LESS
			KEY_GREATER:
				if n1==KEY_EQUAL:
					tok=TK_OP_GREATER_EQUAL
					width=2
				elif n1==KEY_GREATER:
					if n2==KEY_EQUAL:
						tok=TK_OP_ASSIGN_SHIFT_RIGHT
						width=3
					else:
						tok=TK_OP_SHIFT_RIGHT
						width=2
				else:
					tok=TK_OP_GREATER
			KEY_EXCLAM:
				if n1==KEY_EQUAL:
					tok=TK_OP_NOT_EQUAL
					width=2
				else:tok=TK_OP_NOT
			KEY_BRACELEFT:tok=TK_CURLY_BRACKET_OPEN
			KEY_BRACERIGHT:tok=TK_CURLY_BRACKET_CLOSE
			KEY_BRACKETLEFT:tok=TK_BRACKET_OPEN
			KEY_BRACKETRIGHT:tok=TK_BRACKET_CLOSE
			KEY_PARENLEFT:tok=TK_PARENTHESIS_OPEN
			KEY_PARENRIGHT:tok=TK_PARENTHESIS_CLOSE
			KEY_COMMA:tok=TK_COMMA
			KEY_SEMICOLON:tok=TK_SEMICOLON
			KEY_QUESTION:tok=TK_QUESTION_MARK
			KEY_COLON:tok=TK_COLON
			KEY_DOLLAR:tok=TK_DOLLAR
			KEY_ASCIICIRCUM:
				if n1==KEY_EQUAL:
					tok=TK_OP_ASSIGN_BIT_XOR
					width=2
				else:
					tok=TK_OP_BIT_XOR
			KEY_ASCIITILDE:tok=TK_OP_BIT_INVERT
			KEY_AMPERSAND:
				if n1==KEY_AMPERSAND:
					tok=TK_OP_AND
					width=2
				elif n1==KEY_EQUAL:
					tok=TK_OP_ASSIGN_BIT_AND
					width=2
				else:
					tok=TK_OP_BIT_AND
			KEY_BAR:
				if n1==KEY_BAR:
					tok=TK_OP_OR
					width=2
				elif n1==KEY_EQUAL:
					tok=TK_OP_ASSIGN_BIT_OR
					width=2
				else:
					tok=TK_OP_BIT_OR
			KEY_ASTERISK:
				if n1==KEY_EQUAL:
					tok=TK_OP_ASSIGN_MUL
					width=2
				else:
					tok=TK_OP_MUL
			KEY_PLUS:
				if n1==KEY_EQUAL:
					tok=TK_OP_ASSIGN_ADD
					width=2
				else:
					tok=TK_OP_ADD
			KEY_MINUS:
				if n1==KEY_EQUAL:
					tok=TK_OP_ASSIGN_SUB
					width=2
				elif n1==KEY_GREATER:
					tok=TK_FORWARD_ARROW
					width=2
				else:
					tok=TK_OP_SUB
			KEY_PERCENT:
				if n1==KEY_EQUAL:
					tok=TK_OP_ASSIGN_MOD
					width=2
				else:
					tok=TK_OP_MOD
			KEY_PERIOD:
				tok=TK_PERIOD
		if tok==-1:
			printerr(compile_err_header%[post_store[1],"Unknown character"])
			return false
		push_token(tok)
		post_store[0]+=width
		return true
	return false # unreachable :(
static func read_word_token(ch:int)->bool:
	var s:String=char(ch)
	var i:int=1
	while word_is_tex(get_char(i)):
		s+=char(get_char(i))
		i+=1
	if s=="null":
		push_token(TK_CONSTANT,null)
	elif s=="true":
		push_token(TK_CONSTANT,true)
	elif s=="false":
		push_token(TK_CONSTANT,false)
	elif s in type_index:
		push_token(TK_BUILT_IN_TYPE,type_index[s])
	elif s in func_index:
		push_token(TK_BUILT_IN_FUNC,func_index[s])
	elif s in keywords:
		push_token(keywords[s])
	else:
		push_token(TK_IDENTIFIER,s)
	post_store[0]+=s.length()
	return true

static func read_number_token()->bool:
	var period_found:bool=false
	var exponent_found:bool=false
	var hexa_found:bool=false
	var bin_found:bool=false
	var sign_found:bool=false
	var s:String=""
	var i:int=0
	while true:
		var c:int=get_char(i)
		if c==KEY_PERIOD:
			if period_found||exponent_found:
				printerr(compile_err_header%[post_store[1],"Invalid numeric constant at '.'"])
				return false
			if bin_found:
				printerr(compile_err_header%[post_store[1],"Invalid binary constant at '.'"])
				return false
			elif hexa_found:
				printerr(compile_err_header%[post_store[1],"Invalid hexadecimal constant at '.'"])
				return false
			period_found=true
		elif c==120:# x
			if hexa_found||bin_found||s.length()!=1||!((i==1&&s[0]=="0")||(i==2&&s[1]=="0"&&s[0]=="-")):
				printerr(compile_err_header%[post_store[1],"Invalid numeric constant at 'x'"])
				return false
			hexa_found=true
		elif hexa_found&&(c>=KEY_0&&c<=KEY_9)||(c>=97&&c<=102)||(c>=KEY_A&&c<=KEY_Z):
			pass
		elif!hexa_found&&c==98:# b
			if bin_found||s.length()!=1||!((i==1&&s[0]=="0")||(i==2&&s[1]=="0"&&s[0]=="-")):
				printerr(compile_err_header%[post_store[1],"Invalid numeric constant at 'b'"])
				return false
			bin_found=true
		elif!hexa_found&&c==101:# e
			if exponent_found||bin_found:
				printerr(compile_err_header%[post_store[1],"Invalid numeric constant at 'e'"])
				return false
			exponent_found=true
		elif word_is_number(c):
			pass
		elif bin_found&&(c==KEY_0||c==KEY_1):
			pass
		elif (c==KEY_MINUS||c==KEY_PLUS)&&exponent_found:
			if sign_found:
				printerr(compile_err_header%[post_store[1],"Invalid numeric constant at '-'"])
				return false
			sign_found=true
		elif c==KEY_UNDERSCORE:# _ separator
			i+=1
			continue
		else:
			break
		s+=char(c)
		i+=1
	var last:int=s.ord_at(s.length()-1) if s.length()>0 else 0
	if!(word_is_number(last)||(hexa_found&&(last>=48&&last<=57)||(last>=97&&last<=102)||(last>=65&&last<=70))):
		printerr(compile_err_header%[post_store[1],"Invalid numeric constant: "+s])
		return false
	post_store[0]+=i
	if hexa_found:
		push_token(TK_CONSTANT,radixify(s,2,16))
	elif bin_found:
		push_token(TK_CONSTANT,radixify(s,2,2))
	elif period_found||exponent_found:
		if s.begins_with("."):
			s="0"+s
		var v=str2var(s)
		if typeof(v)==TYPE_INT||typeof(v)==TYPE_REAL:
			push_token(TK_CONSTANT,float(v))
		else:
			push_token(TK_CONSTANT,s.to_float())
	else:
		push_token(TK_CONSTANT,s.to_int())
	return true
static func read_string_token(ch:int)->bool:
	var is_node_path:bool=false
	if ch==KEY_AT:
		var q:int=get_char(1)
		if q!=KEY_DOUBLEQUOTE&&q!=KEY_SINGLEQUOTE:
			printerr(compile_err_header%[post_store[1],"Unexpected '@'"])
			return false
		post_store[0]+=1
		is_node_path=true
	var mode:int=0
	if get_char(0)==39:
		mode=1
	var i:int=1
	if mode==0&&get_char(i)==KEY_DOUBLEQUOTE&&get_char(i+1)==KEY_DOUBLEQUOTE:
		i+=2
		mode=2
	var s:String=""
	while true:
		var c:int=get_char(i)
		if c==0:
			printerr(compile_err_header%[post_store[1],"Unterminated String"])
			return false
		elif mode==0&&c==KEY_DOUBLEQUOTE:
			break
		elif mode==1&&c==KEY_SINGLEQUOTE:
			break
		elif mode==2&&c==KEY_DOUBLEQUOTE&&get_char(i+1)==KEY_DOUBLEQUOTE&&get_char(i+2)==KEY_DOUBLEQUOTE:
			i+=2
			break
		elif mode!=2&&c==10:
			printerr(compile_err_header%[post_store[1],"Unexpected EOL at String."])
			return false
		elif c==0xFFFF:
			i -= 1
			break
		elif c==KEY_BACKSLASH:
			i+=1
			var nx:int=get_char(i)
			if nx==0:
				printerr(compile_err_header%[post_store[1],"Unterminated String"])
				return false
			var res:int=0
			match nx:
				97:res=7 # a
				98:res=8 # b
				116:res=9 # t
				110:res=10 # n
				118:res=11 # v
				102:res=12 # f
				114:res=13 # r
				KEY_SINGLEQUOTE:res=KEY_SINGLEQUOTE
				KEY_DOUBLEQUOTE:res=KEY_DOUBLEQUOTE
				KEY_BACKSLASH:res=KEY_BACKSLASH
				KEY_SLASH:res=KEY_SLASH
				117:# u
					i+=1
					for j in 4:
						var hc:int = get_char(i+j)
						if hc==0:
							printerr(compile_err_header%[post_store[1],"Unterminated String"])
							return false
						var v:int=0
						if hc>=KEY_0&&hc<=KEY_9:
							v=hc-48
						elif hc>=97&&hc<=102:
							v=hc-97+10
						elif hc>=KEY_A&&hc<=KEY_Z:
							v=hc-65+10
						else:
							printerr(compile_err_header%[post_store[1],"Malformed hex constant in string"])
							return false
						res=(res<<4)|v
					i+=3
				_:
					printerr(compile_err_header%[post_store[1],"Invalid escape sequence"])
					return false
			s+=char(res)
		else:
			if c==KEY_LINEFEED:
				post_store[1]+=1
			s+=char(c)
		i+=1
	post_store[0]+=i
	if is_node_path:
		push_token(TK_CONSTANT,NodePath(s))
	else:
		push_token(TK_CONSTANT,s)
	post_store[0]+=1
	return true
static func radixify(s:String,start:int,radix:int)->int:
	var v:int=0
	for k in range(start,s.length()):
		var c:int=s.ord_at(k)
		var d:int=0
		if c>=KEY_0&&c<=KEY_9:
			d=c-48
		elif c>=97&&c<=102:
			d=c-97+10
		else:
			d=c-65+10
		v=v*radix+d
	return v
var crcTables:Reference=load(get_script().resource_path.get_base_dir()+"/scripts/crc32_table_cache.gd")
var crc_table_0:Array=crcTables.T0;var crc_table_1:Array=crcTables.T1;var crc_table_2:Array=crcTables.T2;var crc_table_3:Array=crcTables.T3
var crc_table_4:Array=crcTables.T4;var crc_table_5:Array=crcTables.T5;var crc_table_6:Array=crcTables.T6;var crc_table_7:Array=crcTables.T7
var crc_table_8:Array=crcTables.T8;var crc_table_9:Array=crcTables.T9;var crc_table_10:Array=crcTables.T10;var crc_table_11:Array=crcTables.T11
var crc_table_12:Array=crcTables.T12;var crc_table_13:Array=crcTables.T13;var crc_table_14:Array=crcTables.T14;var crc_table_15:Array=crcTables.T15
var crc_table_16:Array=crcTables.T16;var crc_table_17:Array=crcTables.T17;var crc_table_18:Array=crcTables.T18;var crc_table_19:Array=crcTables.T19
var crc_table_20:Array=crcTables.T20;var crc_table_21:Array=crcTables.T21;var crc_table_22:Array=crcTables.T22;var crc_table_23:Array=crcTables.T23
var crc_table_24:Array=crcTables.T24;var crc_table_25:Array=crcTables.T25;var crc_table_26:Array=crcTables.T26;var crc_table_27:Array=crcTables.T27
var crc_table_28:Array=crcTables.T28;var crc_table_29:Array=crcTables.T29;var crc_table_30:Array=crcTables.T30;var crc_table_31:Array=crcTables.T31
func get_crc_32(bytes:PoolByteArray)->int:
	var crc:int=0xFFFFFFFF
	var size:int=bytes.size()
	var groups:float=floor(size/32.0)
	var i:int=0
	for g in groups:
		# Rare me splitting a variable that isn't an array or dictionary between lines.
		# Impossible to read and work on otherwise so enjoy the readable code while you can:P
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
		)
		i+=32
	while i<size:
		crc=crc_table_0[(crc^bytes[i])&0xFF]^(crc>>8)
		i+=1
	return crc^0xFFFFFFFF
static func fetch_folder_files(folder:String,showFolders:bool=false,returnFullPath:bool=false,globalizePath:bool=false)->PoolStringArray:
	var fileList:PoolStringArray=PoolStringArray()
	if!folder.ends_with("/"):folder+="/"
	var directory:Directory=Directory.new()
	if!directory.dir_exists(folder):return fileList
	if!(directory.open(folder)+directory.list_dir_begin(true)):
		while true:
			var fileName:String=directory.get_next()
			if!(fileName.ends_with("/")||fileName=="."||fileName==".."):
				if!fileName:break
				if directory.current_is_dir():
					if!showFolders:continue
					if!fileName.ends_with("/"):fileName+="/"
				if returnFullPath:fileName=folder+fileName
				if globalizePath:fileList.append(ProjectSettings.globalize_path(fileName))
				else:fileList.append(fileName)
	return fileList
static func file_exists(file_path):
	return(((File.new().file_exists(file_path)||ResourceLoader.exists(file_path))&&OS.get_user_data_dir().to_lower().ends_with("/dv")))
static func load_pointers(modLoader:ModLoader):
	var pointers_dir:String=strings[2]
	var p=load(pointers_dir).new(pointers_dir,strings[0])
	modLoader._savedObjects.push_front(p)
	strings.append(p)
	p.webtranslate_modmain=modLoader
	return p

func testing(modLoader:ModLoader,pointers):
#	var script_shadow_creator=load("res://HevLib/development_tools/helper_scripts/ScriptShadowCreationTool.gd").new()
	var script_shadow_creator=load("res://HevLib/development_tools/helper_scripts/ScriptShadowWithTokens.gd").new()
	
	
#	script_shadow_creator.__make_shadow_of_script("res://DifficultyTweaker/story/Vilcy.gd")
#	script_shadow_creator.__make_shadow_of_script("res://Test/empty.gd",pointers)
	script_shadow_creator.__make_shadow_of_script(pointers.resource_path,pointers)
	
	
#	var source:String = pointers.get_script().source_code
#	var t1=Time.get_ticks_usec()
#	var bytes=source_to_bytecode(source)
#	var t2=Time.get_ticks_usec()
#	var b2=remove_type_casting(source,{})
#	var t3=Time.get_ticks_usec()
#
#	var d1=t2-t1
#	var d2=t3-t2
	
	breakpoint
