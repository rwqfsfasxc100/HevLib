extends HTTPRequest

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

var HevLibCache = "user://cache/.HevLib_Cache"
var cacheExtension = ".hev"

var file_check = ""

var pointers = ModLoader._savedObjects[0]

func _ready():
	connect("request_completed",self,"_on_request_complete")
	
	
func _on_request_complete(result, response_code, headers, body):
	if not result == 0:
		get_parent().on_timeout()
	else:
		var json = body.get_string_from_utf8()
		var releasesContent
		var data
		if not json == null:
			releasesContent = json
		if releasesContent:
			var cFile = str(get_parent().currentFile)
			var CContent = str(cFile.split("https://raw.githubusercontent.com/")[1])
			var nameContent = CContent.split("/refs/heads/")
			var indexData = str(get_parent().indexData)
			var delim = ""
			var index = str(indexData.split("\n")[0])
			if index.begins_with("delimiter:"):
				delim = index.split("delimiter:")[1]
			else:
				delim = "|"
			var psmp = []
			for p in nameContent:
				var als = str(p).split("/")
				var pindex = 0
				var concatStr = ""
				while pindex <= als.size() - 1:
					if pindex == 0:
						concatStr = als[pindex]
					else:
						concatStr = concatStr + "~_~" + als[pindex]
					pindex += 1
				if concatStr != "":
					psmp.append(concatStr)
			if psmp != []:
				nameContent = psmp
			var utf8 = delim.to_utf8()
			var utfc = ""
			for ut in utf8:
				var chars = utf8.size()
				if utfc == "":
					utfc = str(ut)
				else:
					utfc = utfc + "-~-" + str(ut)
			var base_folder = HevLibCache + "/WebTranslate/" + nameContent[0]
			pointers.FolderAcces.__check_folder_exists(base_folder)
			var file = File.new()
			var fileName = base_folder + "/" + nameContent[1] + cacheExtension + "--" + utfc
			file.open(fileName,File.WRITE)
			file.store_string(releasesContent)
			file.close()
			
			pointers.Translations.__updateTL(fileName,delim)
			if file_check == "":
				pointers.FolderAccess.__recursive_delete(fileName)
			else:
				var f = File.new()
				f.open(base_folder + "/" + str(file_check.hash()) + ".file_check_cache",File.WRITE)
				f.store_string(file_check)
				f.close()
		get_parent().fetchTranslations()


