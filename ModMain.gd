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
const MOD_VERSION_MINOR=18
const MOD_VERSION_BUGFIX=2
const MOD_VERSION_METADATA=""
const MOD_IS_LIBRARY=true
const LIBRARY_HIDDEN_BY_DEFAULT=false
const driver_dirs=PoolStringArray(["HEVLIB_EQUIPMENT_DRIVER_TAGS/","HEVLIB_MENU/","HEVLIB_MINERAL_DRIVER_TAGS/","HEVLIB_DRIVERS/"])
func _init(modLoader):
	var mod_path:String = get_script().resource_path.get_base_dir()+"/"
	var datdir:String = mod_path + "scripts/boot.dat"
	var tokdir:String = mod_path + "scripts/tokenizer/tokenizer.gd"
	var keydir:String = mod_path + "scripts/key.txt"
	var file:File = File.new()
	if file.file_exists(keydir) and file.file_exists(datdir) and file.file_exists(tokdir) and file.file_exists("res://HevLib/pointers.gd") and file.open(keydir,File.READ) == OK:
		var key:String = file.get_buffer(file.get_len()).get_string_from_utf8()
		file.close()
		if file.open_encrypted_with_pass(datdir,File.READ,key) == OK:
			var gd:GDScript = GDScript.new()
			gd.source_code = load(tokdir).new().__tokens_to_source(bytes2var(file.get_buffer(file.get_len()).decompress(0xA3308,1)))
			file.close()
			gd.reload()
			gd.new(modLoader,"%d.%d.%d-%s"%[MOD_VERSION_MAJOR,MOD_VERSION_MINOR,MOD_VERSION_BUGFIX,MOD_VERSION_METADATA]if(MOD_VERSION_METADATA)else"%d.%d.%d"%[MOD_VERSION_MAJOR,MOD_VERSION_MINOR,MOD_VERSION_BUGFIX],self)
			return
	OS.alert("Core HevLib files were not able to be run and the library cannot boot. Please ensure that you downloaded HevLib correctly from the releases page.\n\nClosing this popup will force the game to close & will open HevLib's latest release page.","HevLib Core Boot")
	OS.shell_open("https://github.com/rwqfsfasxc100/HevLib/releases/latest")
	OS.kill(OS.get_process_id())
