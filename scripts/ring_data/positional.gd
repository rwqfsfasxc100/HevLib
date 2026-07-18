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

const pixelToKm = 10000
const map = preload("res://ring/ring-map.png")
const veins = preload("res://ring/ring-veins.png")

static func getPixelAt(pos: Vector2):
	var image = map.get_data()
	var size = image.get_size()
	var x = int(clamp(floor(pos.x / pixelToKm), 0, size.x - 1))
	var sy = int(size.y)
	var y = ((int(floor(pos.y / pixelToKm)) %sy) + sy) %sy
	var x1 = int(clamp(x + 1, 0, size.x - 1))
	var y1 = (y + 1) %int(size.y)
	
	if x <= 0:
		return Color(0, 0, 0, 0)
	
	image.lock()
	var p00 = image.get_pixel(x, y)
	var p10 = image.get_pixel(x1, y)
	var p11 = image.get_pixel(x1, y1)
	var p01 = image.get_pixel(x, y1)
	image.unlock()
	
	var cx = (pos.x - floor(pos.x / pixelToKm) * pixelToKm) / pixelToKm
	var cy = (pos.y - floor(pos.y / pixelToKm) * pixelToKm) / pixelToKm

	var pu = (p00 * (1 - cx) + p10 * (cx))
	var pd = (p01 * (1 - cx) + p11 * (cx))
	
	var pixel = pu * (1 - cy) + pd * (cy)
	return pixel

static func getVeinPixelAt(pos: Vector2) -> Color:
	var veinImage = veins.get_data()
	var veinSize = veinImage.get_size()
	var x = posmod(pos.x, veinSize.x)
	var y = posmod(pos.y, veinSize.y)
	var x1 = posmod(pos.x + 1, veinSize.x)
	var y1 = posmod(pos.y + 1, veinSize.y)
	
	veinImage.lock()
	var p00 = veinImage.get_pixel(x, y)
	var p10 = veinImage.get_pixel(x1, y)
	var p11 = veinImage.get_pixel(x1, y1)
	var p01 = veinImage.get_pixel(x, y1)
	veinImage.unlock()
	
	var cx = fposmod(pos.x, 1)
	var cy = fposmod(pos.y, 1)

	var pu = lerp(p00, p10, cx)
	var pd = lerp(p01, p11, cx)
	
	var pixel = lerp(pu, pd, cy)
	return pixel

static func getVeinAt(pos) -> String:
	var p1 = getVeinPixelAt(pos / 1861.0)
	var p2 = getVeinPixelAt(pos / - 2531.0)
	
	var values = [p1.r, p1.g, p1.b, p1.a, p2.r, p2.b, p2.g, p2.a]
		
	var total = 0
	for n in range(CurrentGame.traceMinerals.size()):
		var tm = CurrentGame.traceMinerals[n]
		values[n] = pow(values[n] / pow(CurrentGame.mineralPrices.get(tm, 1), 0.2), 4)
		total += values[n]
		
	var rnd = randf() * total
	var nr = 0
	for n in values:
		rnd -= n
		if rnd < 0:
			return CurrentGame.traceMinerals[nr]
		nr += 1
	
	return CurrentGame.traceMinerals[0]
