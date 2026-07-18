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

var nodeToReturnTo

var filePath = ""

var updating_percent = false
var percent:float = 0
var bytes_downloaded: int = 0
var total_bytes: int = 0

var state_progress = true

func _ready():
	is_updating(false)

func request(url,custom_headers:PoolStringArray = [],ssl_validate_domain: bool = true, method = 0,request_data:String = ""):
	if state_progress:
		nodeToReturnTo._get_github_progress("HEVLIB_GITHUB_PROGRESS_ZIP_FOUND_AND_REQUESTING",0,0,0)
		Tool.deferCallInPhysics(self,"is_updating",[true])
	.request(url,custom_headers,ssl_validate_domain,method,request_data)

func _on_zip_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var downloadedFile = ""
		var headerSplitter = "Content-Disposition: attachment; filename="
		for m in headers:
			if m.begins_with(headerSplitter):
				downloadedFile = m.split(headerSplitter)[1]
		if not filePath.ends_with("/"):
			filePath = filePath + "/"
		filePath = filePath + downloadedFile
		if state_progress:
			is_updating(false)
			nodeToReturnTo._get_github_progress("HEVLIB_GITHUB_PROGRESS_DOWNLOADED_FILE",0,0,0)
		nodeToReturnTo._downloaded_zip(downloadedFile, filePath)
	else:
		nodeToReturnTo._downloaded_zip("","")
	
#	Tool.deferCallInPhysics(self,"is_updating",[false])
	

func _physics_process(delta):
	if updating_percent:
		total_bytes = get_body_size()
		bytes_downloaded = get_downloaded_bytes()
		var frac = float(bytes_downloaded)/float(total_bytes)
		var f2 = frac * 100
		percent = f2
		print("HevLib GitHub Zip Downloader: Updating percent: %s%% | %s of %s" % [str(percent),bytes_downloaded,total_bytes])
		if bytes_downloaded > 0.0:
			_handle_downloaded_percent()

func is_updating(how):
	print("HevLib GitHub Zip Downloader: setting physics process to [%s]" % str(how))
	set_physics_process(how)
	updating_percent = how
	if not how:
		percent = 0
		bytes_downloaded = 0
		total_bytes = 0

func _handle_downloaded_percent():
	if nodeToReturnTo.has_method("_get_github_progress"):
		if total_bytes > 0:
			nodeToReturnTo._get_github_progress("HEVLIB_GITHUB_PROGRESS_DOWNLOADING",percent,bytes_downloaded,total_bytes)
		else:
			nodeToReturnTo._get_github_progress("HEVLIB_GITHUB_PROGRESS_DOWNLOADING_ONLY_BYTES",percent,bytes_downloaded,total_bytes)
		
