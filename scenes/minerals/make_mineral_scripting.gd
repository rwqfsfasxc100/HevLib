extends Node

#const DataFormat = preload("res://HevLib/pointers/DataFormat.gd")
#const FolderAccess = preload("res://HevLib/pointers/FolderAccess.gd")
#const DriverManagement = preload("res://HevLib/pointers/DriverManagement.gd")

const custom_mineral_path = "user://cache/.HevLib_Cache/Minerals/mineral_store/"

static func make_mineral_scripting(is_onready = false,pointers = null):
	
	var FILE_PATHS = [
		"user://cache/.HevLib_Cache/Minerals/mineral_cache.json",
		"user://cache/.HevLib_Cache/Minerals/AsteroidSpawner.gd",
		"user://cache/.HevLib_Cache/Minerals/CurrentGame.gd",
		"user://cache/.HevLib_Cache/Minerals/TheRing.gd",
	]
	
	
	for file in FILE_PATHS:
		pointers.FolderAccess.__check_folder_exists(file.split(file.split("/")[file.split("/").size() - 1])[0])
	pointers.FolderAccess.__check_folder_exists(custom_mineral_path)
	for f in pointers.FolderAccess.__fetch_folder_files(custom_mineral_path,true,true):
		pointers.FolderAccess.__recursive_delete(f)
		
	var mineral_cache_file = FILE_PATHS[0]
	var asteroid_spawner_script = FILE_PATHS[1]
	var current_game_script = FILE_PATHS[2]
	var the_ring_script = FILE_PATHS[3]
	
	
	if is_onready:
		
		var version = pointers.DataFormat.__get_vanilla_version()
		var text = "HevLib Mineral Manager: observed game version of %s"  % str(version)
		Debug.l(text)
	
	var f = File.new()
	var drivers = pointers.DriverManagement.__get_drivers()
	var mineral_data = []
	for driver in drivers:
		var dv = driver["drivers"]
		if "ADD_MINERALS.gd" in dv:
			var mineral_dict = dv["ADD_MINERALS.gd"]
			for mineral in mineral_dict:
				mineral_data.append(mineral_dict[mineral])
	installScriptExtension("res://HevLib/scenes/minerals/AstrogatorPanel.gd")
	installScriptExtension("res://HevLib/scenes/minerals/OMS.gd")
	var current_game = handle_mineral_values_and_colors(mineral_data)
	f.open(current_game_script,File.WRITE)
	f.store_string(current_game)
	f.close()
	var asteroid_spawner = handle_ore_scenes(mineral_data,pointers)
	f.open("user://cache/.HevLib_Cache/Minerals/AsteroidSpawner.gd",File.WRITE)
	f.store_string(asteroid_spawner)
	f.close()



static func handle_ore_scenes(mineral_data,pointers):
	var mineral_list = {}
	for mineral in mineral_data:
		var mname = mineral["name"]
		var handle = mineral.get("handle","none")
		var price = mineral.get("price",0.0)
		if price > 0.0:
			match handle:
				"scenes":
					var scenes = PoolStringArray([])
					for i in range(0,7):
						scenes.append(mineral.get("ore_%s" % (i + 1),""))
					var item = make_asteroid_spawner_section(mname,scenes)
					mineral_list.merge({mname:item})
					Debug.l("HevLib Mineral Manager: adding mineral %s using handler [scene]" % mname)
				"recolor":
					var base = "fe"
					var color = mineral.get("color",Color(1,1,1,1))
					match mineral.get("base","fe").to_lower():
						"fe","iron":
							base = "fe"
						"v","vanadium":
							base = "v"
						"be","beryllium":
							base = "be"
						"pd","palladium":
							base = "pd"
						"pt","platinum":
							base = "pt"
						"w","tungsten","wolfram":
							base = "w"
					var roc = make_custom_rocks(mname,color,base,pointers)
					var rt = make_asteroid_spawner_section(mname,roc)
					mineral_list.merge({mname:rt})
					Debug.l("HevLib Mineral Manager: adding mineral %s using handler [recolor]" % mname)
				_:
					
					Debug.l("HevLib Mineral Manager: mineral %s using incorrect handler, set price to 0.0 or less to prevent being registered to exist in the ring or crashes may happen" % mineral)
		else:
			Debug.l("HevLib Mineral Manager: adding only color references for mineral %s, value set to zero or below" % mineral)
	var content = as_header
	for m in mineral_list:
		content = content + dict_checker % [m,"objectClass[objectClass.size() - 1]","objectClass[objectClass.size() - 1]"] + mineral_list[m] + "})"
#	content = content
	return content
	

const as_header = "extends \"res://AsteroidSpawner.gd\"\n\nfunc _init():\n\tpass"#\n\tobjectClass[objectClass.size()-1].merge({\n"

const dict_checker = "\n\tif not \"%s\" in %s:\n\t\t%s.merge({"
const arr_checker = "\n\tif not \"%s\" in %s:\n\t\t%s.append("

const folder_base = "user://cache/.HevLib_Cache/Minerals/mineral_store/%s-%s/"

static func make_custom_rocks(mineral,color,base,pointers):
	var header = "[gd_scene load_steps=2 format=2]\n\n[ext_resource path=\"res://HevLib/scenes/minerals/base_scenes/mineral-%s-%s.tscn\" type=\"PackedScene\" id=1]\n\n[node name=\"mineral\" instance=ExtResource( 1 )]"
	var content = "\nmineral = \"%s\"\ncolor = Color( %s, %s, %s, 1 )" % [mineral,color.r,color.g,color.b]
	var folder = folder_base % [mineral,str(int(color.r*255)) + str(int(color.g*255)) + str(int(color.b*255))]
	var file = File.new()
	
	var rt = []
	for i in range(0,7):
		var id = i + 1
		pointers.FolderAccess.__check_folder_exists(folder)
		var fn = folder + "h%s.tscn" % id
		var data = header % [base,id] + content
		file.open(fn,File.WRITE)
		file.store_string(data)
		file.close()
		rt.append(fn)
	return rt

static func make_asteroid_spawner_section(mineral : String,scenes : PoolStringArray):
	if scenes.size() != 7:
		return ""
	var mh = "\n\t\"" + str(mineral) + "\":[\n"
	for mineral in scenes:
		mh = mh + "\t\tpreload(\"" + mineral + "\"),\n"
	mh = mh + "\t],\n"
	return mh


const cg_header = "extends \"res://CurrentGame.gd\"\n\n"
const ready_header = "func _init():\n\tpass\n"
const price_header = "\tmineralPrices.merge({\n"
const color_header = "\tspecificMineralColors.merge({\n"
const trace_header = "\ttraceMinerals.append_array([\n"
const general_footer = "\t})\n\n"
static func handle_mineral_values_and_colors(mineral_data):
	
	var collective_text = cg_header + ready_header
	
	var prices = {}
	var colors = {}
	var traces = []
	for mineral in mineral_data:
		var mname = mineral["name"]
		var price = mineral["price"]
		var color = mineral["color"]
		if price > 0.0:
			prices.merge({mname:price})
			traces.append(mname)
		colors.merge({mname:color})
	var price_text = ""#price_header
	for price in prices:
		price_text = price_text + dict_checker % [price,"mineralPrices","mineralPrices"] + "\"" + str(price) + "\" : " + str(prices[price]) + "})"
#	price_text = price_text + general_footer
	var color_text = ""#color_header
	for color in colors:
		color_text = color_text + dict_checker % [color,"specificMineralColors","specificMineralColors"] + "\"" + str(color) + "\" : Color(" + str(colors[color]) + ")})"
#	color_text = color_text + general_footer
	var trace_text = ""#trace_header
	for trace in traces:
#		trace_text = trace_text + "\t\t\"" + str(trace) + "\",\n"
		trace_text = trace_text + arr_checker % [trace,"traceMinerals","traceMinerals"] + "\"" + str(trace) + "\")"
#	trace_text = trace_text + "\t])"
	collective_text = collective_text + "\n\n" + price_text + "\n\n" + color_text + "\n\n" + trace_text
	return collective_text

static func installScriptExtension(path:String):
	var childScript:Script = ResourceLoader.load(path)
	childScript.new()
	var parentScript:Script = childScript.get_base_script()
	var parentPath:String = parentScript.resource_path
	childScript.take_over_path(parentPath)
