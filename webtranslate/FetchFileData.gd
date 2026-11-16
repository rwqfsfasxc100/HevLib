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

extends HTTPRequest

var file_check:String = ""
var file:File = File.new()

var pointers:HevLibPointers = ModLoader._savedObjects[0]

func _ready():
	connect("request_completed",self,"_on_request_complete")


func _on_request_complete(result, response_code, headers, body):
	if not result:
		var nameContent:PoolStringArray = get_parent().currentFile.split("https://raw.githubusercontent.com/")[1].split("/refs/heads/")
		var index:String = get_parent().indexData.split("\n")[0]
		var delim:String = index.split("delimiter:")[1] if index.begins_with("delimiter:") else "|"
		var utfc:String = ""
		for ut in delim.to_utf8():
			if utfc:
				utfc += "-~-" + str(ut)
			else:
				utfc = str(ut)
		var base_folder:String = "user://cache/WebTranslate/" + nameContent[0].split("/").join("~_~")
		Directory.new().make_dir_recursive(base_folder)
		
		var fileName:String = base_folder + "/" + nameContent[1].split("/").join("~_~") + ".hev--" + utfc
		file.open(fileName,File.WRITE)
		file.store_string(body.get_string_from_utf8())
		file.close()
		
		pointers.Translations.__updateTL(fileName,delim)
		if file_check:
			file.open(base_folder + "/" + str(file_check.hash()) + ".file_check_cache",File.WRITE)
			file.store_string(file_check)
			file.close()
		else:
			pointers.FolderAccess.__recursive_delete(fileName)
		get_parent().fetchTranslations()
	else:
		get_parent().on_timeout()


