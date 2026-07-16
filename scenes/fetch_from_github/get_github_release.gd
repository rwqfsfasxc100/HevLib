extends Node

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

func get_github_release(URL: String, folder: String, node_to_return_to: Node, get_pre_releases: bool = false, file_preference: String = "any", file_to_download: String = "first"):
	var cancel = false
	if node_to_return_to == null or (not node_to_return_to is Node):
		cancel = true
		var e = "HevLib Github Release Downloader: ERROR! Provided node [%s] either does not exist or is not of [Node] type." % str(node_to_return_to)
		Debug.l(e)
		printerr(e)
	if not node_to_return_to.has_method("_downloaded_zip"):
		cancel = true
		var e = "HevLib Github Release Downloader: ERROR! Provided node [%s] does not have the method [_downloaded_zip]" % str(node_to_return_to)
		Debug.l(e)
		printerr(e)
	if cancel:
		return
	var CRoot = Tool.get_tree().get_root()
	var gitHubFS = preload("res://HevLib/scenes/fetch_from_github/releases/NetHandles.tscn").instance()
	if not node_to_return_to.has_method("_get_github_progress"):
		gitHubFS.state_progress = false
		Debug.l("HevLib Github Release Downloader: NOTICE! Provided node [%s] does not have the method [_get_github_progress]. No download progress will be reported." % str(node_to_return_to))
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	gitHubFS.releases_URL = URL
	gitHubFS.folder = folder
	gitHubFS.get_pre_releases = get_pre_releases
	gitHubFS.file_preference = file_preference
	gitHubFS.file_to_download = file_to_download
	gitHubFS.nodeToReturnTo = node_to_return_to
	gitHubFS.name = "git_release_" + str(rng.randi_range(1, 32767))
	CRoot.call_deferred("add_child",gitHubFS)
	
