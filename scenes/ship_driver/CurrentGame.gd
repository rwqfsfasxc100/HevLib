extends "res://CurrentGame.gd"

var pointersShipDriver
var modded_ship_list = []
var ship_driver_path = "user://cache/.HevLib_Cache/ShipDriver/"

var added_modded_ships = false

func _ready():
	pointersShipDriver = ModLoader._savedObjects[0]
	pointersShipDriver.ConfigDriver.__establish_connection("hl_shipdriver_init_ships_to_dealer",self)
	var add_ship_store = pointersShipDriver.Equipment.add_ships_store
	for fd in add_ship_store:
		if "dealer" in fd:
			var shipName = fd["name"]
			var age = fd["dealer"].get("age",200)
			var dict = {"name":shipName,"age":24 * 3600 * 365 * age}
			for i in range(max(0,fd["dealer"].get("weight",1))):
				modded_ship_list.append(dict)
	hl_shipdriver_init_ships_to_dealer()
	initialize_scrapwright(add_ship_store)

func createShipInstanceWithCache(nv, age, sd, stock = false):
	if nv.begins_with("HevLibShipyardEntry") and age == 0:
		var entry = modded_ship_list[sd % modded_ship_list.size()]
		nv = entry.name
		age = entry.age
	return .createShipInstanceWithCache(nv, age, sd, stock)

var previous_count = 0

func hl_shipdriver_init_ships_to_dealer():
	var rng = pointersShipDriver.ConfigDriver.__get_config("HevLib").get("HEVLIB_CONFIG_SECTION_DRIVERS",{}).get("max_modded_dealership_pools",7)
	if previous_count == rng:
		return
	previous_count = rng
	if added_modded_ships:
		hl_shipdriver_clear_modded_ships()
	var vps = []
	for i in range(clamp(modded_ship_list.size(),0,rng)):
		vps.append({"name":"HevLibShipyardEntry|%s" % i,"age":0})
	usedShipsPool.append_array(vps)
	added_modded_ships = true

func hl_shipdriver_clear_modded_ships():
	var list = []
	for r in range(usedShipsPool.size()):
		var i = usedShipsPool[r]
		if i["name"].begins_with("HevLibShipyardEntry"):
			list.append(r)
	while list.size() > 0:
		var a = list.pop_back()
		usedShipsPool.remove(a)

var scrap_header = "[gd_scene load_steps=3 format=2]\n\n[ext_resource path=\"res://comms/ConversationPlayer.gd\" type=\"Script\" id=1]\n[ext_resource path=\"res://comms/conversation/SalvageBanter.tscn\" type=\"PackedScene\" id=2]\n\n[node name=\"SalvageBanter\" instance=ExtResource( 2 )]\n"
var scrap_entry = "\n[node name=\"%s\" type=\"Node\" parent=\"DIALOG_SALVAGE_START_1\"]\nscript = ExtResource( 1 )\nweight = 0.1\nfakeTransponder = \"SE1-SRO\"\nnoReplyTimeout = 20.0\nimportChildren = NodePath(\"..\")\nstoryFlag = \"count\"\nstoryFlagMax = 2\nstoryFlagIncrement = 1\ntemporaryStory = true\npoiExposeName = \"%s\"\npoiExposeParam = \"{random/ship/1/shipname}\"\npoiExposeUnique = false\npoiExposeEvent = \"%s\"\npoiDistanceKm = 100.0\npoiDistanceRandom = 1500.0\npoiTrackable = false\npoiMustBeValid = true\npoiMustBeAlone = true\npoiValidationTries = 3\ntrueRandom = true\nonlyOnce = true\n"

func initialize_scrapwright(arr:Array):
	var scrap_concat = ""
	for data in arr:
		if "salvage_broadcast" in data:
			var salv = data["salvage_broadcast"]
			var dname = data.get("specific_derelict_name","ModdedDerelict_" + data.get("name","TRTL"))
			match typeof(salv):
				TYPE_ARRAY,TYPE_STRING_ARRAY:
					for i in salv:
						if i:
							scrap_concat += scrap_entry % [i,"POI_SALVAGE",dname]
				TYPE_DICTIONARY:
					for i in salv:
						if i:
							var id = salv[i]
							scrap_concat += scrap_entry % [i,id.get("poi_name","POI_SALVAGE"),dname]
	if scrap_concat:
		pointersShipDriver.DataFormat.__replace_scene(scrap_header + scrap_concat,"res://comms/conversation/SalvageBanter.tscn",ship_driver_path + "salvage_banter_extension.tscn")
