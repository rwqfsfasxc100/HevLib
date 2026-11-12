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
const MOD_VERSION_STRING="%d.%d.%d-%s"%[MOD_VERSION_MAJOR,MOD_VERSION_MINOR,MOD_VERSION_BUGFIX,MOD_VERSION_METADATA]if(MOD_VERSION_METADATA)else"%d.%d.%d"%[MOD_VERSION_MAJOR,MOD_VERSION_MINOR,MOD_VERSION_BUGFIX]
func _init(modLoader=ModLoader):
	strings.append(self);var is_editor:bool=OS.has_feature("editor")
	var modPath:String=get_script().resource_path.get_base_dir()+"/"
	var pointers_dir:String=modPath+"pointers.gd"
	if!file_exists(pointers_dir):
		Debug.l("Folder structure not correct, exiting HevLib load")
		return
	strings.append(modPath)
	strings.append(pointers_dir)
	create_zip_for_overrides(handle_pointer_cast_clearing(process_gdnative_plugins(),modLoader),self)
	var pointers:Node=load_pointers(modLoader)
	recache(pointers)
	pointers.FolderAccess.__recursive_delete(variables_folder,PoolStringArray(["remove_pointer_casting.zip"]))
	var directory:Directory=Directory.new();
	pointers.FileAccess.__load_precached_mods();pointers.ConfigDriver.__load_configs()
	
	testing(modLoader,pointers)
	
	pointers.ManifestV2.__get_mod_versions(true)
	pointers.ConfigDriver.__store_value("HevLib","HEVLIB_CONFIG_SECTION_EVENTS","disabled_events",[])
	
	if is_editor:
		pointers.ConfigDriver.__store_value("HevLib","HEVLIB_CONFIG_SECTION_POINTERS","compile",false)
		if!File.new().file_exists("res://VersionLabel.tscn"):
			printerr("FAILED TO FETCH FILE SYSTEM")
			l("ERROR! FAILED TO FETCH FILE SYSTEM")
	pointers.Scripting.make_mineral_scripting()
	pointers.Equipment.__make_upgrades_scene()
	pointers.NodeAccess.__dynamic_crew_expander()
	pointers.ManifestV2.__load_modlets()
	yield(self,"ready")
	var CRoot:Viewport=get_tree().get_root()
	CRoot.call_deferred("add_child",pointers)
	CRoot.call_deferred("add_child",load("res://HevLib/logging/_HevLib_Gamespace_Canvas.tscn").instance())
	CRoot.call_deferred("add_child",load("res://HevLib/scenes/keymapping/keybind_interrupt.tscn").instance())
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
	var scene:Resource=ResourceLoader.load(strings[1].plus_file(newPath),"Resource")
	scene.take_over_path(oldPath)
	_savedObjects.append(scene)
	l("Finished updating:%s"%oldPath)
static func replaceSceneLiteral(newPath:String,oldPath:String):
	l("Updating scene literal:%s"%newPath)
	var scene:Resource=ResourceLoader.load(newPath,"Resource")
	if scene:
		scene.take_over_path(oldPath)
		_savedObjects.append(scene)
		l("Finished updating literal:%s"%oldPath)
static func l(msg:String,title:String=MOD_NAME):strings[3].l(msg,"%s V%s"%[title,MOD_VERSION_STRING])
const driver_dirs=PoolStringArray(["HEVLIB_EQUIPMENT_DRIVER_TAGS/","HEVLIB_MENU/","HEVLIB_MINERAL_DRIVER_TAGS/","HEVLIB_DRIVERS/"])
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
const dependancies_store="user://cache/.Mod_Menu_2_Cache/updates/dependancies.json"
const conflicts_store="user://cache/.Mod_Menu_2_Cache/updates/conflicts.json"
const complementary_store="user://cache/.Mod_Menu_2_Cache/updates/complementary.json"
const class_names_to_clear:PoolStringArray=PoolStringArray(["HevLibPointers","MINIZ"])
const class_refs:Dictionary={"HevLibPointers":"res://HevLib/pointers.gd","MINIZ":"res://HevLib/scripts/miniz/miniz.gd"}
static func recache(pointers):
	var d:Directory=Directory.new()
	d.make_dir_recursive(variables_folder)
	d.make_dir_recursive(validation_check_path.get_base_dir())
	d.make_dir_recursive("user://cache/.Mod_Menu_2_Cache/updates/zip_cache/")
	d.make_dir_recursive("user://cache/.Mod_Menu_2_Cache/github_list/icon_cache/")
	d.make_dir_recursive("user://cache/.Mod_Menu_2_Cache/github_list/downloaded_zips/")
	d.make_dir_recursive("user://cache/.HevLib_Cache/Event_Driver/")
	var file:File=File.new()
	pointers.FolderAccess.__recursive_delete("user://cache/.Mod_Menu_2_Cache/updates/zip_cache/")
	pointers.FolderAccess.__recursive_delete("user://cache/.Mod_Menu_2_Cache/github_list/downloaded_zips/")
	if file.file_exists(releases_cache):
		var age:float=Time.get_unix_time_from_system()-file.get_modified_time(releases_cache)
		if age>3600:
			file.open(releases_cache,File.WRITE)
			file.store_string("{}")
			file.close()
			Debug.l("Releases cache older than an hour (%s minutes old), clearing"%[floor(age/60.0)])
		else:
			Debug.l("Releases cache too new (%s minutes old), not clearing"%[floor(age/60.0)])
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
const remap_str:String="[remap]\n\npath=\"res://%s\"\n"
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
									if!entry.begins_with("res://"):entry=mod_dir + entry
									if entry.get_extension()=="gdnlib":all_libraries.append(entry)
		var copied_files:PoolStringArray=PoolStringArray()
		var existing_libs:PoolStringArray=PoolStringArray()
		var lib_resave:Array=Array()
		var configFile:ConfigFile=ConfigFile.new()
		var file:File=File.new()
		var directory:Directory=Directory.new()
		directory.make_dir_recursive(exePath)
		var libs_to_copy:Dictionary=Dictionary()
		for entry in all_libraries:
			configFile.load(entry)
			var cfg_sections:Array=configFile.get_sections()
			var data:Array=[entry,{},{}]
			if"entry"in cfg_sections:
				for oper in configFile.get_section_keys("entry"):
					var lib_path:String=configFile.get_value("entry",oper)
					var new_path:String=exePath+lib_path.get_file()
					if file_exists(lib_path):
						file.open(lib_path,File.READ)
						libs_to_copy[new_path]=file.get_buffer(file.get_len())
						file.close()
						data[1][oper]=new_path
						existing_libs.append(new_path.get_file())
			if"dependencies"in cfg_sections:
				for oper in configFile.get_section_keys("dependencies"):
					var lib_paths:Array=configFile.get_value("dependencies",oper)
					for lbr in lib_paths.size():
						var lib_path:String=lib_paths[lbr]
						var new_path:String=exePath+lib_path.get_file()
						if file_exists(lib_path):
							file.open(lib_path,File.READ)
							libs_to_copy[new_path]=file.get_buffer(file.get_len())
							file.close()
							lib_paths[lbr]=new_path
							existing_libs.append(new_path.get_file())
					data[2][oper]=lib_paths
			lib_resave.append(data)
			for f in libs_to_copy:
				file.open(f,File.WRITE)
				file.store_buffer(libs_to_copy[f])
				file.close()
			copied_files.append_array(libs_to_copy.keys())
		for data in lib_resave:
			var entry:String=lib_resave[0]
			var savePath:String="user://cache/.HevLib_Cache/Variable_Fetch/%d.gdnlib"%Time.get_ticks_usec()
			configFile.clear()
			var entries:Dictionary=data[1]
			var dependencies:Dictionary=data[2]
			for key in entries.keys():configFile.set_value("entry",key,entries[key])
			for key in dependencies.keys():configFile.set_value("dependencies",key,dependencies[key])
			configFile.save(savePath)
			file.open(savePath,File.READ)
			var bfr:PoolByteArray=file.get_buffer(file.get_len())
			file.close()
			fetchPaths[entry.substr(6)]=bfr
		configFile.clear()
		for f in fetch_folder_files(exePath):if!f in existing_libs:directory.remove(exePath+f)
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
		var tokenizer = load("res://HevLib/scripts/tokenizer/tokenizer.gd").new()
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
				replacements[script]=PoolByteArray()
			elif regex.search(text) is RegExMatch:
				replacements[script+".remap"]=(remap_str%remapped_path).to_utf8()
				replacements[remapped_path]=tokenizer.__decast_source(text,class_names_to_clear,class_refs).to_utf8()
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
	var p:Node=load(pointers_dir).new(pointers_dir,strings[0],MOD_VERSION_STRING)
	modLoader._savedObjects.push_front(p)
	strings.append(p)
	p.webtranslate_modmain=modLoader
	return p
func testing(modLoader:ModLoader,pointers):
	var file:File = File.new()
	var script_shadow_creator=load("res://HevLib/development_tools/helper_scripts/ScriptShadowCreationTool.gd").new()
	
	
	var t1=Time.get_ticks_usec()
	for i in 100000:
		pass
	var t2=Time.get_ticks_usec()
	for i in 100000:
		pass
	var t3=Time.get_ticks_usec()
	var d1=t2-t1
	var d2=t3-t2
	
	
	breakpoint
