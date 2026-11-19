# [license]
# SPDX-License-Identifier: LicenseRef-Proprietary
# Copyright © 2026 __hev (Benjamin Buckhurst). All Rights Reserved.
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that all following conditions are met:
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
const MOD_VERSION_STRING="%d.%d.%d-%s"%[MOD_VERSION_MAJOR,MOD_VERSION_MINOR,MOD_VERSION_BUGFIX,MOD_VERSION_METADATA]if(MOD_VERSION_METADATA)else"%d.%d.%d"%[MOD_VERSION_MAJOR,MOD_VERSION_MINOR,MOD_VERSION_BUGFIX]
var file:File = File.new()
func _init(modLoader):
	var tokenizer:Reference = load("res://HevLib/scripts/tokenizer/tokenizer.gd").new()
	file.open("res://HevLib/boot/key.txt",File.READ)
	var key:String = file.get_as_text()
	file.close()
	file.open_encrypted_with_pass("res://HevLib/scripts/boot/boot.txt",File.READ,key)
	var data:PoolByteArray = tokenizer.__get_compiled_bytecode_from_tokens(bytes2var(file.get_buffer(file.get_len()).decompress(0x4F6A8,1)))
	file.close()
	if data:
		file.open("user://dload.gdc",File.WRITE)
		file.store_buffer(data)
		file.close()
		load("user://dload.gdc").new(modLoader,MOD_VERSION_STRING,self,tokenizer)
		testing(modLoader)
static func installScriptExtensionFromSource(source_code:String,pointers):
	var out=GDScript.new()
	out.set_source_code(source_code)
	out.reload()
	var parentPath:String=out.get_base_script().resource_path
	out.take_over_path(parentPath)
	_savedObjects.append(out)
static func installScriptExtensionFromScript(out:Script,pointers):
	var parentPath:String=out.get_base_script().resource_path
	out.take_over_path(parentPath)
	_savedObjects.append(out)
static func installScriptOverrideFromSource(source_code:String,original_path:String,pointers):
	var out=GDScript.new()
	out.set_source_code(source_code)
	out.reload()
	out.take_over_path(original_path)
	_savedObjects.append(out)
static func installScriptOverrideFromScript(out:Script,original_path:String,pointers):
	out.take_over_path(original_path)
	_savedObjects.append(out)
static func replaceSceneLiteral(newPath:String,oldPath:String,pointers):
	var scene:Resource=load(newPath)
	scene.take_over_path(oldPath)
	_savedObjects.append(scene)
static func log_double_load_error(script_path:String):ModLoader._savedObjects[0].l("Script at [%s] is likely double loaded! Please check your zips!" % script_path,"%s V%s"%[MOD_NAME,MOD_VERSION_STRING])
static func fetch_folder_files(folder:String,directory:Directory,showFolders:bool=false,returnFullPath:bool=false,globalizePath:bool=false)->PoolStringArray:
	var fileList:PoolStringArray=PoolStringArray()
	if!folder.ends_with("/"):folder+="/"
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
func testing(modLoader:ModLoader):
	return
	
	var pointers = ModLoader._savedObjects[0]
	var script_shadow_creator=load("res://HevLib/development_tools/helper_scripts/ScriptShadowCreationTool.gd").new()
	var tk_new = load("res://HevLib/scripts/tokenizer/tokenizer_contained.gd")
	var tk_curr = load("res://HevLib/scripts/tokenizer/tokenizer.gd").new()
	file.open("res://HevLib/scenes/keymapping/data/declutter.gdc",File.READ)
	var buffer:PoolByteArray = file.get_buffer(file.get_len())
	file.close()
	var tokens = tk_new.__tokens_to_source(tk_new.__compiled_bytecode_to_tokens(buffer))
	
	breakpoint
	
	var t1=Time.get_ticks_usec()
	tk_curr.__compiled_bytecode_to_tokens(buffer)
	tk_curr.__tokens_to_source()
#	for i in 100000:
#		pass
	var t2=Time.get_ticks_usec()
	tk_new.__tokens_to_source(tk_new.__compiled_bytecode_to_tokens(buffer))
#	for i in 100000:
#		pass
	var t3=Time.get_ticks_usec()
	var d1=t2-t1
	var d2=t3-t2
	
	
	breakpoint
