extends "res://TheRing.gd"

var ship_driver_path = "user://cache/.HevLib_Cache/ShipDriver/"
func _ready():
	var file = File.new()
	file.open(ship_driver_path + "driver_data.json",File.READ)
	var data = JSON.parse(file.get_as_text()).result
	file.close()
	
	var ro = load("res://story/RescueOperation.gd")
	for i in range(data.size()):
		var ship = data[i]
		if "derelict" in ship:
			var derelict_data = ship["derelict"]
			var dname = ship["specific_event_name"] if "specific_event_name" in ship else ("ModdedDerelict_" + ship.get("name",str(i)))
			var node = ro.new()
			node.name = dname
			var newname = node.name
			node.randomChance = 0.0
			node.minimumChance = 0.0
			node.chaosLimit = 3.0
			node.rescue = false
			add_child(node)
