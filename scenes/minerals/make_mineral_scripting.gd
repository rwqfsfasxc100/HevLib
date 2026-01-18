extends Node

const DataFormat = preload("res://HevLib/pointers/DataFormat.gd")
const FolderAccess = preload("res://HevLib/pointers/FolderAccess.gd")

const custom_mineral_path = "user://cache/.HevLib_Cache/Minerals/mineral_store/"

static func make_mineral_scripting(is_onready = false):
	
	var FILE_PATHS = [
		"user://cache/.HevLib_Cache/Minerals/mineral_cache.json",
		"user://cache/.HevLib_Cache/Minerals/AsteroidSpawner.gd",
		"user://cache/.HevLib_Cache/Minerals/CurrentGame.gd",
		"user://cache/.HevLib_Cache/Minerals/TheRing.gd",
	]
	
	
	for file in FILE_PATHS:
		FolderAccess.__check_folder_exists(file.split(file.split("/")[file.split("/").size() - 1])[0])
	FolderAccess.__check_folder_exists(custom_mineral_path)
	for f in FolderAccess.__fetch_folder_files(custom_mineral_path,true,true):
		FolderAccess.__recursive_delete(f)
		
	var mineral_cache_file = FILE_PATHS[0]
	var asteroid_spawner_script = FILE_PATHS[1]
	var current_game_script = FILE_PATHS[2]
	var the_ring_script = FILE_PATHS[3]
	
	
	if is_onready:
		
		var version = DataFormat.__get_vanilla_version()
		var text = "HevLib Mineral Manager: observed game version of %s"  % str(version)
		Debug.l(text)
	
	
	var folders = FolderAccess.__fetch_folder_files("res://", true, true)
	
	
	
	
	
	var running_in_debugged = false
	var debugged_defined_mods = []
	var onready_mod_paths = []
	var onready_mod_folders = []
	
	# Use when not loading from ready
	if not is_onready:
		var p = load("res://ModLoader.gd")
		var ps = p.get_script_constant_map()
		for item in ps:
			if item == "is_debugged":
				running_in_debugged = true
				var pf = File.new()
#				if pf.file_exists("res://ModLoader.gd"):
#					l("Can see ModLoader.gd")
#				else:
#					l("Cannot see ModLoader.tscn")
				pf.open("res://ModLoader.gd",File.READ)
				var fs = pf.get_as_text(true)
				pf.close()
				var lines = fs.split("\n")
				var reading = false
				var contents = []
				for line in lines:

					if line.begins_with("var addedMods"):
						reading = true
					if reading:
						var split = line.split("\"")
						if split.size() > 1 and split.size() == 3:
							if split[0].begins_with("#"):
								contents.append(split[1])

				debugged_defined_mods = contents.duplicate(true)
	
	
	# Use when running on ready
	if is_onready:
		var mods = ModLoader.get_children()
		for mod in mods:
			var path = mod.get_script().get_path()
			onready_mod_paths.append(path)
			var split = path.split("/")
			onready_mod_folders.append(split[2])
	
	var f = File.new()
	
	
	f.open(mineral_cache_file,File.WRITE)
	f.store_string("[]")
	f.close()
	var mods_to_avoid = []
	for folder in folders:
		var semi_root = folder.split("/")[2]
		if semi_root.begins_with("."):
			continue
					
		if folder.ends_with("/"):
			
			if not is_onready:
				if running_in_debugged:
					for mod in debugged_defined_mods:
						var home = mod.split("/")[2]
						if home == semi_root:
								mods_to_avoid.append(home)
			var folder_2 = FolderAccess.__fetch_folder_files(folder, true, true)
			for check in folder_2:
				if not is_onready:
					if semi_root in mods_to_avoid:
						continue
				else:
					if not semi_root in onready_mod_folders:
						continue
				if check.ends_with("HEVLIB_MINERAL_DRIVER_TAGS/"): # MINERALDRIVER FILES
					var files = FolderAccess.__fetch_folder_files(check, false, true)
					var mod = check.hash()
					var mineral_dict = []
					for file in files:
						var last_bit = file.split("/")[file.split("/").size() - 1]
						match last_bit:
							"ADD_MINERALS.gd":
								var data = load(check + last_bit)
								var constants = data.get_script_constant_map()
								for item in constants:
									var equipment = data.get(item).duplicate(true)
									mineral_dict.append(equipment)
					
					f.open(mineral_cache_file,File.READ_WRITE)
					var md = JSON.parse(f.get_as_text(true)).result
					md.append_array(mineral_dict)
					f.store_string(JSON.print(md))
					f.close()
					
	
	f.open(mineral_cache_file,File.READ)
	var mineral_data = JSON.parse(f.get_as_text()).result
	
	installScriptExtension("res://HevLib/scenes/minerals/AstrogatorPanel.gd")
	installScriptExtension("res://HevLib/scenes/minerals/OMS.gd")
	f.close()
	for m in mineral_data:
		if "color" in m:
			var c = m["color"]
			var s = c.split(",")
			var color = Color(s[0],s[1],s[2],s[3])
			m["color"] = color
	var current_game = handle_mineral_values_and_colors(mineral_data)
	f.open(current_game_script,File.WRITE)
	f.store_string(current_game)
	f.close()
	var asteroid_spawner = handle_ore_scenes(mineral_data)
	f.open("user://cache/.HevLib_Cache/Minerals/AsteroidSpawner.gd",File.WRITE)
	f.store_string(asteroid_spawner)
	f.close()



static func handle_ore_scenes(mineral_data):
	var mineral_list = []
	for mineral in mineral_data:
		var mname = mineral["name"]
		var handle = mineral.get("handle","none")
		match handle:
			"scenes":
				var scenes = PoolStringArray([])
				for i in range(0,7):
					scenes.append(mineral.get("ore_%s" % (i + 1),""))
				var item = make_asteroid_spawner_section(mname,scenes)
				mineral_list.append(item)
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
				var roc = make_custom_rocks(mname,color,base)
				var rt = make_asteroid_spawner_section(mname,roc)
				mineral_list.append(rt)
			_:
				pass
	var content = as_header
	for m in mineral_list:
		content = content + m
	content = content + "})"
	return content
	

const as_header = "extends \"res://AsteroidSpawner.gd\"\n\nfunc _ready():\n\tobjectClass[objectClass.size()-1].merge({\n"

const folder_base = "user://cache/.HevLib_Cache/Minerals/mineral_store/%s-%s/"

static func make_custom_rocks(mineral,color,base):
	var header = "[gd_scene load_steps=2 format=2]\n\n[ext_resource path=\"res://HevLib/scenes/minerals/base_scenes/mineral-%s-%s.tscn\" type=\"PackedScene\" id=1]\n\n[node name=\"mineral\" instance=ExtResource( 1 )]"
	var content = "\nmineral = \"%s\"\ncolor = Color( %s, %s, %s, 1 )" % [mineral,color.r,color.g,color.b]
	var folder = folder_base % [mineral,str(int(color.r*255)) + str(int(color.g*255)) + str(int(color.b*255))]
	var file = File.new()
	
	var rt = []
	for i in range(0,7):
		var id = i + 1
		FolderAccess.__check_folder_exists(folder)
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
const ready_header = "func _ready():\n"
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
		colors.merge({mname:color})
		traces.append(mname)
	var price_text = price_header
	for price in prices:
		price_text = price_text + "\t\t\"" + str(price) + "\" : " + str(prices[price]) + ",\n"
	price_text = price_text + general_footer
	var color_text = color_header
	for color in colors:
		color_text = color_text + "\t\t\"" + str(color) + "\" : Color(" + str(colors[color].r) + "," + str(colors[color].g) + "," + str(colors[color].b) + "," + str(colors[color].a) + "),\n"
	color_text = color_text + general_footer
	var trace_text = trace_header
	for trace in traces:
		trace_text = trace_text + "\t\t\"" + str(trace) + "\",\n"
	trace_text = trace_text + "\t])"
	collective_text = collective_text + "\n\n" + price_text + "\n\n" + color_text + "\n\n" + trace_text
	return collective_text

static func installScriptExtension(path:String):
	var childScript:Script = ResourceLoader.load(path)
	childScript.new()
	var parentScript:Script = childScript.get_base_script()
	var parentPath:String = parentScript.resource_path
	childScript.take_over_path(parentPath)
