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

static func generate(data: Dictionary = {}):
	var h_index = data.get("h_index",0)
	var v_index = data.get("v_index",0)
	var factor : int = data.get("factor",1)
	var width = data.get("width",750)
	var height = data.get("height",750)
	var generate_vein : bool = data.get("generate_vein",false)
	
	
	
	OS.window_minimized = true
	var thread_num = str(h_index) + "x" + str(v_index)
	var file = File.new()
	h_index = floor(h_index/factor)
	v_index = floor(v_index/factor)
	width = floor(width/factor)
	height = floor(height/factor)
	file.open("user://logs/ring_image_log_%s.txt" % thread_num,File.WRITE)
	file.store_string("Ring Image Generator [%s] INITIALIZED!\n\nProcess started at time [%s]\n\n" % [thread_num,Time.get_datetime_string_from_system(true,true)])
	file.close()
	var RingInfo = preload("res://HevLib/pointers/RingInfo.gd")
	var FolderAccess = preload("res://HevLib/pointers/FolderAccess.gd")
	FolderAccess.__check_folder_exists("user://cache/.HevLib_Cache/image_gen")
	var offset = 1
	var tex_path = "user://cache/.HevLib_Cache/image_gen/pixel_%s.png" % thread_num
	var tex_path2 = "user://cache/.HevLib_Cache/image_gen/chaos_%s.png" % thread_num
	var tex_path3 = "user://cache/.HevLib_Cache/image_gen/density_%s.png" % thread_num
	var tex_path4 = "user://cache/.HevLib_Cache/image_gen/vein_%s.png" % thread_num
	var tex_path5 = "user://cache/.HevLib_Cache/image_gen/chaos_border_%s.png" % thread_num
	var img = Image.new()
	var img2 = Image.new()
	var img3 = Image.new()
	var img4 = Image.new()
	var img5 = Image.new()
	l("gemerating images with scale of (%s,%s) and offset of [%s]" % [width,height,thread_num],thread_num)
	img.create(width,height,false,Image.FORMAT_RGBA8)
	img2.create(width,height,false,Image.FORMAT_RGBA8)
	img3.create(width,height,false,Image.FORMAT_RGBA8)
	img5.create(width,height,false,Image.FORMAT_RGBA8)
	img4.create(width,height,false,Image.FORMAT_RGBA8)
	for x in range(h_index * width + offset,width + (h_index * width) + offset):
		img.lock()
		img2.lock()
		img3.lock()
		img4.lock()
		img5.lock()
		l("Operating on column %s at offset [%s]" % [x,h_index],thread_num)
#		l("Range set to [%s,%s]" % [1 + (thread_num * width),width + (thread_num * width)],thread_num)
		for y in range(v_index * height,height + (v_index * height)):
#			l("Operating on row %s at offset [%s]" % [y,thread_num],thread_num)
			var point = Vector2(x,y)
			var it = RingInfo.__get_pixel_at(point*10000)
			img.set_pixelv(point - Vector2(width * h_index + offset,height * v_index),it)
			img2.set_pixelv(point - Vector2(width * h_index + offset,height * v_index),Color(it.r,0,0,1))
			img3.set_pixelv(point - Vector2(width * h_index + offset,height * v_index),Color(0,0,it.b,1))
			if generate_vein:
				var v = RingInfo.__get_vein_pixel_at(point*10000 * factor)
				img4.set_pixelv(point - Vector2(width * h_index + offset,height * v_index),v)
			var chaos = str(it.r)
			var rnd = float(chaos.substr(0,5))
			var nc = Color(0,0,0,0)
			
#			if rnd >= 0.000:
#				var c = Color.from_hsv(rnd,1,1,1)
#				nc = c
			if rnd >= 0.050:
				var c = Color.from_hsv(0.05,1,1,1)
				nc = c
			if rnd >= 0.100:
				var c = Color.from_hsv(0.100,1,1,1)
				nc = c
			if rnd >= 0.150:
				var c = Color.from_hsv(0.15,1,1,1)
				nc = c
			if rnd >= 0.200:
				var c = Color.from_hsv(0.2,1,1,1)
				nc = c
			if rnd >= 0.250:
				var c = Color.from_hsv(0.25,1,1,1)
				nc = c
			if rnd >= 0.300:
				var c = Color.from_hsv(0.3,1,1,1)
				nc = c
			if rnd >= 0.350:
				var c = Color.from_hsv(0.35,1,1,1)
				nc = c
			if rnd >= 0.400:
				var c = Color.from_hsv(0.4,1,1,1)
				nc = c
			if rnd >= 0.450:
				var c = Color.from_hsv(0.45,1,1,1)
				nc = c
			if rnd >= 0.500:
				var c = Color.from_hsv(0.5,1,1,1)
				nc = c
			if rnd >= 0.550:
				var c = Color.from_hsv(0.55,1,1,1)
				nc = c
			if rnd >= 0.600:
				var c = Color.from_hsv(0.6,1,1,1)
				nc = c
			if rnd >= 0.650:
				var c = Color.from_hsv(0.65,1,1,1)
				nc = c
			if rnd >= 0.700:
				var c = Color.from_hsv(0.7,1,1,1)
				nc = c
			if rnd >= 0.750:
				var c = Color.from_hsv(0.75,1,1,1)
				nc = c
			if rnd >= 0.800:
				var c = Color.from_hsv(0.8,1,1,1)
				nc = c
			if rnd >= 0.850:
				var c = Color.from_hsv(0.85,1,1,1)
				nc = c
			if rnd >= 0.900:
				var c = Color.from_hsv(0.9,1,1,1)
				nc = c
			if rnd >= 0.950:
				var c = Color.from_hsv(0.95,1,1,1)
				nc = c
			if rnd >= 1.000:
				var c = Color.from_hsv(1,1,1,1)
				nc = c
			img5.set_pixelv(point - Vector2(width * h_index + offset,height * v_index),nc)
			
			
			l("Finished pixel (%s,%s) at offset [%s]" % [x,y,h_index],thread_num)
		
		img.unlock()
		img2.unlock()
		img3.unlock()
		img4.unlock()
		img5.unlock()
		img.save_png(tex_path)
		img2.save_png(tex_path2)
		img3.save_png(tex_path3)
		img5.save_png(tex_path5)
		if generate_vein:
			img4.save_png(tex_path4)
	l("image generation finished at time [%s]" % Time.get_datetime_string_from_system(true,true),thread_num)
	OS.request_attention()

static func l(text: String,file_count = 0):
	var file = File.new()
	file.open("user://logs/ring_image_log_%s.txt" % file_count,File.READ_WRITE)
	var txt = file.get_as_text(true)
	file.store_line(txt + "[" + str(Time.get_datetime_string_from_system(true,true)) + "] Ring Image Generator" + ": " + str(text))
	file.close()
