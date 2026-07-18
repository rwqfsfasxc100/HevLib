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

extends Node

var releases_URL = ""
var folder = ""
var nodeToReturnTo
var get_pre_releases = false
var file_preference = "any"
var file_to_download = "first"

var state_progress = true

func _ready():
	if not releases_URL == "":
		var urlSplitByGithub = releases_URL.split("https://github.com/")
		var urlSplitByReleases = urlSplitByGithub[1].split("/releases")
		
		if state_progress:
			nodeToReturnTo._get_github_progress("HEVLIB_GITHUB_PROGRESS_WAITING_ON_RESPONSE",0,0,0)
		
		var githubApiURL = "https://api.github.com/repos/" + urlSplitByReleases[0] + "/releases"
		$ReleasesURLHandler.get_pre_releases = get_pre_releases
		$ReleasesURLHandler.folder = folder
		$ZipDownloadHandler.filePath = folder
		$ZipDownloadHandler.state_progress = state_progress
		$ZipDownloadHandler.nodeToReturnTo = nodeToReturnTo
		$ReleasesURLHandler.file_preference = file_preference
		$ReleasesURLHandler.file_to_download = file_to_download
		$ReleasesURLHandler.request(githubApiURL)
	
