extends "res://CurrentGame.gd"

signal generic_notification(dictionary)

func send_notification(data:Dictionary):
	emit_signal("generic_notification",data)
var pointers
var modded_ship_list = []
var ship_driver_path = "user://cache/.HevLib_Cache/ShipDriver/"

var added_modded_ships = false

func _ready():
	yield(get_tree(),"idle_frame")
	pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	pointers.ConfigDriver.__establish_connection("init_ships_to_dealer",self)
	var file = File.new()
	file.open(ship_driver_path + "driver_data.json",File.READ)
	var data = JSON.parse(file.get_as_text()).result
	file.close()
	for mod in data:
		var md = data[mod]
		for ship in md:
			var fd = md[ship]
			if "dealer" in fd:
				var shipName = fd["name"]
				var age = fd["dealer"].get("age",200)
				var dict = {"name":shipName,"age":24 * 3600 * 365 * age}
				for i in range(max(0,fd["dealer"].get("weight",1))):
					modded_ship_list.append(dict)
	init_ships_to_dealer()

func createShipInstanceWithCache(nv, age, sd, stock = false):
	if nv.begins_with("HevLibShipyardEntry") and age == 0:
		var entry = modded_ship_list[sd % modded_ship_list.size()]
		nv = entry.name
		age = entry.age
	return .createShipInstanceWithCache(nv, age, sd, stock)

var previous_count = 0

func init_ships_to_dealer():
	var rng = pointers.ConfigDriver.__get_config("HevLib").get("HEVLIB_CONFIG_SECTION_DRIVERS",{}).get("max_modded_dealership_pools",7)
	if previous_count == rng:
		return
	previous_count = rng
	if added_modded_ships:
		clear_modded_ships()
	var vps = []
	for i in range(clamp(modded_ship_list.size(),0,rng)):
		vps.append({"name":"HevLibShipyardEntry|%s" % i,"age":0})
	usedShipsPool.append_array(vps)
	added_modded_ships = true

func clear_modded_ships():
	var list = []
	for r in range(usedShipsPool.size()):
		var i = usedShipsPool[r]
		if i["name"].begins_with("HevLibShipyardEntry"):
			list.append(r)
	while list.size() > 0:
		var a = list.pop_back()
		usedShipsPool.remove(a)
		pass
