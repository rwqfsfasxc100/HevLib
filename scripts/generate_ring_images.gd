extends Node

static func generate(thread_num: int = 0):
	var RingInfo = preload("res://HevLib/pointers/RingInfo.gd")
	var FolderAccess = preload("res://HevLib/pointers/FolderAccess.gd")
	FolderAccess.__check_folder_exists("user://cache/.HevLib_Cache/image_gen")
	var width = 750
	var height = 3000
	var thread_count = 4
	if thread_num > thread_count:
		Debug.l("Ring Image Generator: invalid thread index")
		return
	var offset = 1
	var tex_path = "user://cache/.HevLib_Cache/image_gen/pixel_%s.png" % thread_num
	var tex_path2 = "user://cache/.HevLib_Cache/image_gen/chaos_%s.png" % thread_num
	var tex_path3 = "user://cache/.HevLib_Cache/image_gen/density_%s.png" % thread_num
	var tex_path4 = "user://cache/.HevLib_Cache/image_gen/vein_%s.png" % thread_num
	var img = Image.new()
	var img2 = Image.new()
	var img3 = Image.new()
	var img4 = Image.new()
	Debug.l("Ring Image Generator: gemerating images with scale of (%s,%s) and offset of [%s]" % [width,height,thread_num])
	img.create(width,height,false,Image.FORMAT_RGBA8)
	img2.create(width,height,false,Image.FORMAT_RGBA8)
	img3.create(width,height,false,Image.FORMAT_RGBA8)
	img4.create(width,height,false,Image.FORMAT_RGBA8)
	img.lock()
	img2.lock()
	img3.lock()
	img4.lock()
	for x in range(thread_num * width + offset,width + (thread_num * width) + offset):
		Debug.l("Ring Image Generator: Operating on column %s at offset [%s]" % [x,thread_num])
		Debug.l("Ring Image Generator: Range set to [%s,%s]" % [1 + (thread_num * width),width + (thread_num * width)])
		for y in range(0,height):
			Debug.l("Ring Image Generator: Operating on row %s at offset [%s]" % [y,thread_num])
			var point = Vector2(x,y)
			var it = RingInfo.__get_pixel_at(point*10000)
			var v = RingInfo.__get_vein_pixel_at(point*10000)
			img.set_pixelv(point - Vector2(width * thread_num + offset,0),it)
			img2.set_pixelv(point - Vector2(width * thread_num + offset,0),Color(it.r,0,0,1))
			img3.set_pixelv(point - Vector2(width * thread_num + offset,0),Color(0,0,it.b,1))
			img4.set_pixelv(point - Vector2(width * thread_num + offset,0),v)
			Debug.l("Ring Image Generator: Finished pixel (%s,%s) at offset [%s]" % [x,y,thread_num])
	img.unlock()
	img2.unlock()
	img3.unlock()
	img4.unlock()
	img.save_png(tex_path)
	img2.save_png(tex_path2)
	img3.save_png(tex_path3)
	img4.save_png(tex_path4)
	Debug.l("Ring Image Generator: image generation finished")
	OS.request_attention()
