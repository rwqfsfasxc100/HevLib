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

var developer_hint = {
	"__get_github_filesystem":[
		"Fetches a filesystem from github",
		"'URL' string is the desired Github repository URL",
		"'node_to_return_to' is the node where the data will be sent once fetched",
		" -> if behaviour is set to normal, or has a typo, requires a function with the name \"_github_filesystem_data(data)\" to handle the returned data (data variant can be whatever name you desire)",
		" -> returns an array of all files and their paths relative to the Github root",
		"'behaviour' string to set what the function outputs and requires as input (current options are 'normal' and 'version_check')",
		"'special_behaviour_data' can be any variant, dependant on what behaviour is set to",
		" -> setting behaviour to 'normal' does not require anything, and so can be left blank",
		" -> setting behavior to 'version_check' requires a string to check the version against that found in the Github's mod manifest or mod main"
	],
	"__get_github_release":[
		"Downloads the latest release from a github",
		"3 required variant inputs, and 3 other optional variants",
		" -> URL - The repository's URL to fetch release data from",
		" -> folder - the folder to save the files to",
		" -> node_to_return_to - node that receives the _downloaded_zip(file, filepath) signal, which returns two variants - file being the filename, and filepath being the file's full path",
		" -> Optional get_pre_releases - bool to decide whether it should consider pre-releases as viable releases to download from",
		" -> Optional file_preference - string that lets you selectively choose the downloaded file type, currently supports 'any' for all filetypes, or 'zip' to only consider zip downloads",
		" -> Optional file_to_download - string that decides what order to choose the file, currently supports 'first' to get the first file in the list, or 'latest' to get the latest uploaded file"
	]
}
const ggf = preload("res://HevLib/scenes/fetch_from_github/get_github_filesystem.gd")
static func __get_github_filesystem(URL: String, node_to_return_to: Node, behaviour: String = "normal", special_behaviour_data = ""):
	var f = ggf.new()
	var s = f.get_github_filesystem(URL, node_to_return_to, behaviour, special_behaviour_data)
	
const ggr = preload("res://HevLib/scenes/fetch_from_github/get_github_release.gd")
static func __get_github_release(URL: String, folder: String, node_to_return_to: Node, get_pre_releases: bool = false, file_preference: String = "any", file_to_download: String = "first"):
	var f = ggr.new()
	var s = f.get_github_release(URL, folder, node_to_return_to, get_pre_releases, file_preference, file_to_download)
	
