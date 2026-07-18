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

extends HTTPRequest

var pointers = ModLoader._savedObjects[0]
var folder = ""
var get_pre_releases = false
var file_preference = "any" # Accepts "any" or "zip"
var file_to_download = "first" # Accepts "first", "all" or "latest"

var urlToFetch = []

func _on_release_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		var releasesContent
		var assetURLs = []
		if not json.result == null:
			releasesContent = json.result
		var cycle = 0
		if not releasesContent == null:
			for n in releasesContent:
				if cycle == 0:
					if not checkIfAcceptable(n):
						pass
					else:
						for asset in n["assets"]:
							var assetURL = asset["browser_download_url"]
							var releaseDate = asset["updated_at"].split("Z")[0]
						
							assetURLs.append([assetURL, releaseDate])
						var githubTag = n["tag_name"]
						cycle += 1
			for item in assetURLs:
				var acceptable = true
				if file_preference == "zip":
					if not item[0].ends_with(".zip"):
						acceptable = false
				if file_to_download == "latest":
					var isLatest = true
					for item2 in assetURLs:
						var date = item2[1]
						var comparison = pointers.TimeAccess.__compare_dates(item[1],date)
						if comparison == "older":
							isLatest = false
					if not isLatest:
						acceptable = false
				if file_to_download == "all":
					Debug.l("HevLib Github Release Downloader: ERROR! IMPLEMENT HANDLING FOR \"ALL\" TAG")
					breakpoint  # IMPLEMENT HANDLING FOR "ALL" TAG
				if acceptable:
					urlToFetch.append(item[0])
					break
			
			if urlToFetch.size() == 1:
				downloadZip(urlToFetch[0], folder)
			elif urlToFetch.size() >= 2:
				Debug.l("HevLib Github Release Downloader: ERROR! IMPLEMENT HANDLING FOR \"ALL\" TAG")
				
				breakpoint # IMPLEMENT HANDLING FOR "ALL" TAG
	else:
		var outNode = get_parent().nodeToReturnTo
		outNode._downloaded_zip("","")
func checkIfAcceptable(n):
	if n["draft"]:
		return false
	if n["prerelease"]:
		if get_pre_releases:
			return true
		else:
			return false
	else:
		return true


func downloadZip(url, folder):
	if not folder.ends_with("/"):
		folder = folder + "/"
	var check = pointers.FolderAccess.__check_folder_exists(folder)
	if not check:
		return
	var zipName = url.split("/")[url.split("/").size() - 1]
	
	var dir = Directory.new()
	dir.open(folder)
	var does = dir.file_exists(zipName)
	
	if does:
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var rnd = rng.randi_range(1, 32767)
		
		zipName = str(rnd) + "_" + zipName
	var handler = get_parent().get_node("ZipDownloadHandler")
	handler.set_download_file(folder + zipName)
	handler.request(url)
	
