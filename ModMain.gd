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
const strings=Array([null,"","",null])
const MOD_VERSION_STRING="%d.%d.%d-%s"%[MOD_VERSION_MAJOR,MOD_VERSION_MINOR,MOD_VERSION_BUGFIX,MOD_VERSION_METADATA]if(MOD_VERSION_METADATA)else"%d.%d.%d"%[MOD_VERSION_MAJOR,MOD_VERSION_MINOR,MOD_VERSION_BUGFIX]
func _init(modLoader=ModLoader):
	strings[0] = self
	var modPath:String=get_script().resource_path.get_base_dir()+"/"
	var pointers_dir:String=modPath+"pointers.gd"
	if!file_exists(pointers_dir):
		Debug.l("Folder structure not correct, exiting HevLib load");return
	strings[1] = modPath;strings[2] = pointers_dir
	var directory:Directory=Directory.new();directory.make_dir_recursive(variables_folder)
	for f in fetch_folder_files(variables_folder,false,true):directory.remove(f)
	handle_pointer_cast_clearing(process_gdnative_plugins(),modLoader._modZipFiles)
	var pointers:Node=load_pointers(modLoader)
	pointers.FileAccess.__load_precached_mods();pointers.ConfigDriver.__load_configs()
	
#	testing(modLoader,pointers)
	
	pointers.ManifestV2.__get_mod_versions()
	pointers.ConfigDriver.__store_value("HevLib","HEVLIB_CONFIG_SECTION_EVENTS","disabled_events",[])
	
	if OS.has_feature("editor"):
		pointers.ConfigDriver.__store_value("HevLib","HEVLIB_CONFIG_SECTION_POINTERS","compile",false)
		if!File.new().file_exists("res://VersionLabel.tscn"):
			printerr("FAILED TO FETCH FILE SYSTEM")
			l("ERROR! FAILED TO FETCH FILE SYSTEM")
	pointers.ManifestV2.__load_modlets()
	yield(self,"ready")
	var CRoot:Viewport=get_tree().get_root()
	yield(CRoot,"ready")
	CRoot.add_child(pointers)
	CRoot.add_child(load("res://HevLib/logging/_HevLib_Gamespace_Canvas.tscn").instance())
	CRoot.add_child(load("res://HevLib/scenes/keymapping/keybind_interrupt.tscn").instance())
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
const variables_folder:String="user://cache/Variable_Fetch/"
const class_names_to_clear:PoolStringArray=PoolStringArray(["HevLibPointers","MINIZ"])
const class_refs:Dictionary={"HevLibPointers":"res://HevLib/pointers.gd","MINIZ":"res://HevLib/scripts/miniz/miniz.gd"}
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
			var entry:String=data[0]
			var savePath:String="user://cache/Variable_Fetch/%d.gdnlib"%Time.get_ticks_usec()
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
static func handle_pointer_cast_clearing(replacements:Dictionary,modLoader:Array)->void:
	var script_paths:PoolStringArray=PoolStringArray()
	var file:File=File.new()
	for zip in modLoader:
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
		Directory.new().make_dir_recursive("user://cache/Variable_Fetch/")
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
	if replacements:ProjectSettings.load_resource_pack(load(strings[1] + "scripts/miniz/legacy_zipping.gd").new().compress_data(replacements,"user://cache/Variable_Fetch/remove_pointer_casting.zip"))
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
static func file_exists(file_path):return(((File.new().file_exists(file_path)||ResourceLoader.exists(file_path))&&OS.get_user_data_dir().to_lower().ends_with("/dv")))
static func load_pointers(modLoader:ModLoader):
	var pointers_dir:String=strings[2]
	var p:Node=load(pointers_dir).new(pointers_dir,strings[0],MOD_VERSION_STRING)
	modLoader._savedObjects.push_front(p)
	strings[3]=p
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
