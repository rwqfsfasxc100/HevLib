extends Button

var URL = "https://github.com/rwqfsfasxc100/HevLib"

var rng = RandomNumberGenerator.new()

var Globals = preload("res://HevLib/Functions.gd").new()

var hasGamespace = false
var hasActedOnGamespace = false
onready var panel = load("res://HevLib/ui/popup_main_base.tscn").instance()
var index = preload("res://HevLib/ui/core_scripts/index.gd").new()
var data = index.exampleDict
var ManifestV2 = preload("res://HevLib/pointers/ManifestV2.gd")
func _physics_process(delta):
	var noMargins = get_node_or_null("/root/_HevLib_Gamespace_Canvas/MarginContainer")
	panel.datastring = data
	if not noMargins == null:
		hasGamespace = true 
	if hasGamespace == true and hasActedOnGamespace == false:
		hasActedOnGamespace = true
		connect("pressed",panel,"_pressed")
		noMargins.call_deferred("add_child",panel)
		var nnd = load("res://HevLib/ui/core_scripts/get_nodes_to_act_on.gd").new()
		var pnt = nnd.get_nodes_to_act_on(data, Vector2(1600,900))


const DataFormat = preload("res://HevLib/pointers/DataFormat.gd")


func _on_Button_pressed():
	rng.randomize()
	var Translations = preload("res://HevLib/pointers/Translations.gd")
#	var mods = ManifestV2.__get_mod_data_from_files("user://cache/.HevLib_Cache/ManifestV2/derelictdelights/ModMain.gd", true)
#	var did = ManifestV2.__compare_versions(mods)
#	var webtranslate = preload("res://HevLib/pointers/WebTranslate.gd")
#	webtranslate.webtranslate(URL)
#	var pss = Globals.__get_current_achievements()
#	var psm = Globals.__get_achievement_data("DIVER_10")
#	var ap = Globals.__get_lib_variables()
#	var stat = Globals.__get_stat_data("stat:salvaged_ships")
#	Globals.__webtranslate_timed(URL, 5)
#	var text = TranslationServer.translate("DIALOG_SALVAGE_EXPOSE_FAST_K37_3")
#	
#	var gh = preload("res://HevLib/pointers/Github.gd").new()
#	gh.__get_github_filesystem(URL, self, "normal", "1.0.0")
#	
#	gh.__get_github_release("https://github.com/rwqfsfasxc100/HevLib", "user://temp", self, false, "any", "latest")
#	var hevlib_check = preload("res://HevLib/examples and documentation/hevlib_check.gd")
#	var hevlib_check_with_version = preload("res://HevLib/examples and documentation/hevlib_check_with_version.gd")
#	var does1 = hevlib_check.__hevlib_check()
#	var does2 = hevlib_check_with_version.__hevlib_check_with_version([1,7,1])
#	webtranslate.__webtranslate_reset_by_file_check("file_check")
	var tData = {
		"en":{
			"SHIP_OCP209_SPECS":"Yes",
			"STRING_B":"No",
		},
	}
#	Translations.__updateTL_drom_dictionary(tData)
#	Translations.__inject_translations(tData)
#	breakpoint
#	var node = Node.new()	
	
#	var wps = load("res://weapons/WeaponSlot.tscn").instance()
#	var nodes = []
#	for child in wps.get_children():
#		nodes.append(child.name)
	
	
	
#	var s = ManifestV2.__get_mod_by_id("hev.LIBRARY")
#	breakpoint
#	var ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")
#
#	ConfigDriver.__store_config(config,"He/vL/ib/")
#
#	ConfigDriver.__store_value("HevLib","equipment","do_sort_equipment_by_price",false)
#	var does = ConfigDriver.__get_config("HevLib")
#	var el = ConfigDriver.__get_value("HevLib","equipment","do_sort_equipment_by_price")
	
	
	
#	var NodeAccess = preload("res://HevLib/pointers/NodeAccess.gd")
#	var crew = NodeAccess.__dynamic_crew_expander("user://cache/.HevLib_Cache/",25)
#	if not crew == "":
#		var scene := load(crew)
#		scene.take_over_path("res://comms/conversation/subtrees/DIALOG_DERELICT_RANDOM.tscn")
#
#	var crew2 = NodeAccess.__dynamic_crew_expander("user://cache/.HevLib_Cache/",30)
#	if not crew2 == "":
#		var scene2 := load(crew2)
#		scene2.take_over_path("res://comms/conversation/subtrees/DIALOG_DERELICT_RANDOM.tscn")
#
#	var test = load("res://comms/conversation/subtrees/DIALOG_DERELICT_RANDOM.tscn").instance()
#	var children = test.get_children()
#	var names = []
#	for child in children:
#		names.append(child.name)
	
#	var RingInfo = preload("res://HevLib/pointers/RingInfo.gd")
#	var p = RingInfo.__get_pixel_at(Vector2(100000,100000))
	
#	var tex_path = "user://cache/.HevLib_Cache/pixel.png"
#	var tex_path2 = "user://cache/.HevLib_Cache/chaos.png"
#	var tex_path3 = "user://cache/.HevLib_Cache/density.png"
#	var img = Image.new()
#	var img2 = Image.new()
#	var img3 = Image.new()
#	img.create(3000,3000,false,Image.FORMAT_RGBA8)
#	img2.create(3000,3000,false,Image.FORMAT_RGBA8)
#	img3.create(3000,3000,false,Image.FORMAT_RGBA8)
#	img.lock()
#	img2.lock()
#	img3.lock()
#	for x in range(1,3000):
#		for y in range(1,3000):
#			var point = Vector2(x,y)
#			var it = RingInfo.__get_pixel_at(point*10000)
#			img.set_pixelv(point,it)
#			img2.set_pixelv(point,Color(it.r,0,0,1))
#			img2.set_pixelv(point,Color(0,0,it.b,1))
#	img.unlock()
#	img2.unlock()
#	img3.unlock()
#	img.save_png(tex_path)
#	img2.save_png(tex_path2)
#	img3.save_png(tex_path3)
	
#	var s = preload("res://HevLib/scripts/generate_ring_images.gd")
#	for x in range(0,15):
#		for y in range(0,15):
#			var data = {
#				"h_index":x,
#				"v_index":y,
#				"factor":2
#			}
#			var thread = Thread.new()
#			thread.start(s.new(),"generate",data)
#			running.append(thread)
	
#	thread_1.start(s.new(),"generate",0)
#	thread_2.start(s.new(),"generate",1)
#	thread_3.start(s.new(),"generate",2)
#	thread_4.start(s.new(),"generate",3)
#
#	thread_5.start(s.new(),"generate",4)
#	thread_6.start(s.new(),"generate",5)
#	thread_7.start(s.new(),"generate",6)
#	thread_8.start(s.new(),"generate",7)
#
#	thread_9.start(s.new(),"generate",8)
#	thread_10.start(s.new(),"generate",9)
#	thread_11.start(s.new(),"generate",10)
#	thread_12.start(s.new(),"generate",11)
#
#	thread_13.start(s.new(),"generate",12)
#	thread_14.start(s.new(),"generate",13)
#	thread_15.start(s.new(),"generate",14)
#	thread_16.start(s.new(),"generate",15)
#	OS.window_minimized = true
	
	
	
	
#	var compare = DataFormat.__compare_versions(1,0,0,1,0,1)
#	var compare2 = DataFormat.__compare_versions(1,0,1,1,0,1)
#	var compare3 = DataFormat.__compare_versions(1,0,2,1,0,1)
#
#	var minerals = load("res://HevLib/scenes/minerals/icons/minerals-c-overlay.png")
#	var md = minerals.get_data()
#	md.lock()
#	var img = Image.new()
#	img.create(1024,2048,false,Image.FORMAT_RGBA8)
#	img.lock()
#	var img2 = Image.new()
#	img2.create(1024,2048,false,Image.FORMAT_RGBA8)
#	img2.lock()
#	for x in range(0,1024):
#		for y in range(0,2048):
#			var p = md.get_pixel(x, y)
#			if p.r == 0.0 and p.g == 0.0 and p.b == 0.0:
#				img.set_pixel(x,y,Color(0,0,0,0))
#			else:
#				img.set_pixel(x,y,p)
#	md.unlock()
#	img.unlock()
#	img2.unlock()
#	img.save_png("user://cache/.HevLib_Cache/equal.png")
#	img2.save_png("user://cache/.HevLib_Cache/unequal.png")
#
	
	breakpoint

var running = []

#var thread_1 = Thread.new()
#var thread_2 = Thread.new()
#var thread_3 = Thread.new()
#var thread_4 = Thread.new()
#var thread_5 = Thread.new()
#var thread_6 = Thread.new()
#var thread_7 = Thread.new()
#var thread_8 = Thread.new()
#var thread_9 = Thread.new()
#var thread_10 = Thread.new()
#var thread_11 = Thread.new()
#var thread_12 = Thread.new()
#var thread_13 = Thread.new()
#var thread_14 = Thread.new()
#var thread_15 = Thread.new()
#var thread_16 = Thread.new()
var updates = {}
var count = 1

func _on_update_completed(data):
	if data:
		updates.merge({count:data})
		count += 1

func _github_filesystem_data(data):
	pass

func _downloaded_zip(file, folder):
	pass



var config = {
	"equi/pme/nt":{
		"do_sort_equipment_by_price":true,
	},
	"e/vents":{
		"disabled_events":[  ],
		"write_events":true,
	},
	"de/bug":{
		"input_debugger":false,
		"ring_position_data_debugger":false,
		"ring_position_accurate_events":false,
	},
	"in/put":{
		"open_debug_event_menu":[  ],
		"debugger":[ "F10" ],
		"toggle_debug_menus":[ "F9" ],
	}, 
}
