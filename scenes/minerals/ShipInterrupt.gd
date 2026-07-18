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

var ship

var pointers

func _init(p):
	pointers = p
	pointers.ConfigDriver.__establish_connection("hl_shipinterruptupdate",self)
	hl_shipinterruptupdate()

func hl_shipinterruptupdate():
	if pointers:
		cargo_limit = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_EQUIPMENT","processed_mineral_max_display_limit")

var cargo_limit:int = 15

var page:int = 0


var counter:int = 0
func handle_list(ores,oresize) -> Array:
	if oresize > cargo_limit:
		var out:Array = []
		counter += 1
		var offset:int = page * cargo_limit
		var thisSize:int = min(cargo_limit,oresize - offset)
		var pages:int = int(ceil(float(oresize) / float(cargo_limit)))
		for i in range(thisSize):
			out.append(ores[offset + i])
		if counter > 49:
			counter = 0
			if page > pages: page = 0
			else: page += 1
		return out
	else:
		counter = 0
		page = 0
		return ores









func getProcessedCargoTypes(how):
	var out = ship.getProcessedCargoTypes(how)
	if out:
		return handle_list(out,out.size())
	return out


func getProcessedCargo(which,how):
	var out = ship.getProcessedCargo(which,how)
	
	return out


func getProcessedCargoCapacity(how):
	var out = ship.getProcessedCargoCapacity(how)
	
	return out

func soundAlert():
	ship.soundAlert()

