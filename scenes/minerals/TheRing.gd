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
# 4. The source code and the binary form, and any modifications made to them may not be used for the purpose of input data, reference code snippets and/or files, OR used in the training of, or improvement of machine learning algorithms,
# including but not limited to artificial intelligence, natural language processing, or data mining. This condition applies to any derivatives,
# modifications, or updates based on the Software code. Any usage of the source code or the binary form may not be present in any form as data fed, inputted, or provided to an AI, or present in any AI-training dataset is considered a breach of this License.
# 
# 5. Any projects deriving work from this project MUST include a copy of this license and all other license and/or copyright agreements posed within other source material,
# all of which must be followed to its entirety. Failure to follow these licenses prohibit all modification and redistribution of the material until all licensing has been reinstated.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# [/license]

extends "res://TheRing.gd"

var pix_values:PoolIntArray = PoolIntArray()

const not_random_seeds = PoolIntArray([1337,1776,2014,1384,2684,842,2802,1597,2116,755,1596,2661,1928,-1861,-2531,-1337,-1776,-2014,-1384,-2684,-842,-2802,-1597,-2116,-755,-1596,-2661,-1928,1861,-2531,1337,-1776,2014,-1384,2684,-842,2802,-1597,2116,-755,1596,-2661,1928,1861,-2531,1337,-1776,2014,-1384,2684,-842,2802,-1597,2116,-755,1596,-2661,1928])

func get_pixel_values(pos:Vector2) -> PoolRealArray:
	if pix_values.empty():
		var mineral_size:int = int(floor(CurrentGame.traceMinerals.size() / 4.0)) - 1
		pix_values.resize(mineral_size + 2)
		pix_values[0] = 1861.0
		pix_values[1] = - 2531.0
		if mineral_size:
			var random:bool = ModLoader._savedObjects[0].ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DRIVERS","randomize_minerals")
			var nsi:int = not_random_seeds.size()
			for i in mineral_size:
				if random:
					pix_values[i + 2] = ((randi() % 2250) + 750) * sign(randf() - 0.5)
				else:
					pix_values[i + 2] = not_random_seeds[i%nsi]
	var pxSize:int = pix_values.size()
	var out:PoolRealArray = PoolRealArray()
	out.resize(pxSize * 4)
	for i in pxSize:
		var pixel:Color = getVeinPixelAt(pos / pix_values[i])
		var offset:int = i * 4
		out[offset] = pixel.r
		out[offset + 1] = pixel.g
		out[offset + 2] = pixel.b
		out[offset + 3] = pixel.a
	return out

func getVeinAt(pos) -> String:
	
	var values:PoolRealArray = get_pixel_values(pos)
		
	var total:float = 0.0
	for n in CurrentGame.traceMinerals.size():
		var tm:String = CurrentGame.traceMinerals[n]
		values[n] = pow(values[n] / pow(CurrentGame.mineralPrices.get(tm, 1), 0.2), 4)
		total += values[n]
		
	var rnd:float = randf() * total
	var nr:int = 0
	for n in values:
		rnd -= n
		if rnd < 0:
			return CurrentGame.traceMinerals[nr]
		nr += 1
	
	return CurrentGame.traceMinerals[0]
