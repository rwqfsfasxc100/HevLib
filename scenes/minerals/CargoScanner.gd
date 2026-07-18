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

extends "res://hud/CargoScanner.gd"

var HevLib_pointers

func _enter_tree():
	HevLib_pointers = ModLoader._savedObjects[0]
	HevLib_pointers.ConfigDriver.__establish_connection("hl_cargo_limiter_uv",self)
	hl_cargo_limiter_uv()

func hl_cargo_limiter_uv():
	if HevLib_pointers:
		cargo_limit = HevLib_pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_EQUIPMENT","cargo_scanner_mineral_display_limit")

var cargo_limit = 15

func hl_cs_compare_for_order(a,b):
	return smooth[a] > smooth[b]

func smoothValue(dict, s):
	.smoothValue(dict,s)
	var sms = smooth.size()
	if sms > 10:
		var top = hl_cs_clear_non_minerals(smooth.keys())
		sms = top.size()
		top.sort_custom(self,"hl_cs_compare_for_order")
		if sms > cargo_limit:
			for a in range(sms - cargo_limit):
				smooth.erase(top[a + cargo_limit])
	return smooth

func hl_cs_clear_non_minerals(arr: Array):
	arr.erase("")
	arr.erase("cargo_space")
	arr.erase("_")
	arr.erase("SHIP")
	arr.erase("CARGO_EQUIPMENT")
	return arr
