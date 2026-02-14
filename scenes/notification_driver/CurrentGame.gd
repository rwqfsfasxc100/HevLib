extends "res://CurrentGame.gd"

signal generic_notification(dictionary)

func send_notification(data:Dictionary):
	emit_signal("generic_notification",data)

var modded_ship_list = []
var ship_driver_path = "user://cache/.HevLib_Cache/ShipDriver/"
func _ready():
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
	for i in range(clamp(modded_ship_list.size(),0,5)):
		usedShipsPool.append({"name":"HevLibShipyardEntry|%s" % i,"age":0})

func createShipInstanceWithCache(nv, age, sd, stock = false):
	if nv.begins_with("HevLibShipyardEntry") and age == 0:
		var entry = modded_ship_list[sd % modded_ship_list.size()]
		nv = entry.name
		age = entry.age
	return .createShipInstanceWithCache(nv, age, sd, stock)
