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

var developer_hint = {
	"__webtranslate":[
		"Loads translations from a given Gihub repository",
		"Has to be specifically a repository link",
		" -> E.G. https://github.com/rwqfsfasxc100/HevLib",
		"Optional fallback array is a list of files that will be used for translations in the case that WebTranslate can't fetch data after 10 seconds",
		" -> Defaults to an empty array ([])",
		" -> Each entry must be the full res:// path to the file"
	],
	"__webtranslate_reset_by_URL":[
		"Clears the translation cache of a provided URL",
		"Returns true if succeeded, false if it didn't"
	],
	"__webtranslate_timed":[
		"Similar function to __webtranslate, however performs the task repetitively",
		"URL is the same as the URL string for __webtranslate",
		"Optional MINUTES_DELAY integer is the delay between runs of the __webtranslate tool",
		" -> Defaults to 30 minutes if left blank",
		"Optional fallback array is a list of files that will be used for translations in the case that WebTranslate can't fetch data after 10 seconds",
		" -> Defaults to an empty array ([])",
		" -> Each entry must be the full res:// path to the file"
	],
	"__webtranslate_reset_by_file_check":[
		"Similar function to __webtranslate_reset_by_URL, instead resets by the file_check string used in __webtranslate",
		"file_check -> string used as the file check. If found in the cache, resets translations for it"
	]
}

static func __webtranslate(URL: String, fallback: Array = [], file_check: String = ""):
	preload("res://HevLib/pointers.gd").new().WebTranslate.__webtranslate(URL,fallback,file_check)
static func __webtranslate_reset_by_URL(URL: String) -> bool:
	return preload("res://HevLib/pointers.gd").new().WebTranslate.__webtranslate_reset(URL)
static func __webtranslate_reset_by_file_check(file_check: String) -> bool:
	return preload("res://HevLib/pointers.gd").new().WebTranslate.__webtranslate_reset_by_file_check(file_check)
static func __webtranslate_timed(URL: String, MINUTES_DELAY: int = 30, fallback: Array = [], file_check: String = ""):
	preload("res://HevLib/pointers.gd").new().WebTranslate.__webtranslate_timed(URL,MINUTES_DELAY,fallback,file_check)
