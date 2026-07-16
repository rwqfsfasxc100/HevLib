extends Label

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

func clear():
	text = "HEVLIB_PLEASE_WAIT"
	set_process(false)
var download_text = ""
var current_mod_text = ""
var frameCounter = 0.0

func _get_github_progress(response:String,percent:float,bytes_downloaded:int,total_bytes:int):
	var txt = ""
	frameCounter = 0.0
	match response:
		"HEVLIB_GITHUB_PROGRESS_WAITING_ON_RESPONSE":
			txt = TranslationServer.translate(response)
		"HEVLIB_GITHUB_PROGRESS_ZIP_FOUND_AND_REQUESTING":
			txt = TranslationServer.translate(response)
		"HEVLIB_GITHUB_PROGRESS_DOWNLOADED_FILE":
			txt = TranslationServer.translate(response)
		"HEVLIB_GITHUB_PROGRESS_DOWNLOADING":
			var c = float(bytes_downloaded)
			var t = float(total_bytes)
			var c_label = "HEVLIB_SIZE_LABEL_BYTES"
			var t_label = "HEVLIB_SIZE_LABEL_BYTES"
			if c > 1000:
				c /= 1024
				c_label = "HEVLIB_SIZE_LABEL_KILOBYTES"
				if c > 1000:
					c /=1024
					c_label = "HEVLIB_SIZE_LABEL_MEGABYTES"
			if t > 1000:
				t /= 1024
				t_label = "HEVLIB_SIZE_LABEL_KILOBYTES"
				if t > 1000:
					t /=1024
					t_label = "HEVLIB_SIZE_LABEL_MEGABYTES"
			txt = TranslationServer.translate(response) % [percent,c,TranslationServer.translate(c_label),t,TranslationServer.translate(t_label)]
		"HEVLIB_GITHUB_PROGRESS_DOWNLOADING_ONLY_BYTES":
			var c = float(bytes_downloaded)
			var c_label = "HEVLIB_SIZE_LABEL_BYTES"
			if c > 1000:
				c /= 1024
				c_label = "HEVLIB_SIZE_LABEL_KILOBYTES"
				if c > 1000:
					c /=1024
					c_label = "HEVLIB_SIZE_LABEL_MEGABYTES"
			txt = TranslationServer.translate(response) % [c,TranslationServer.translate(c_label)]
	if txt != "":
		download_text = txt

var prev_dt = ""
func _process(delta):
	if is_visible_in_tree():
		if frameCounter > 10:
			download_text = ""
		if download_text != prev_dt:
			text = current_mod_text + "\n\n" + download_text
			prev_dt = download_text
		frameCounter += delta
