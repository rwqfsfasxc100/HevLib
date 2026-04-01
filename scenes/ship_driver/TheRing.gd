extends "res://TheRing.gd"

var ship_driver_path = "user://cache/.HevLib_Cache/ShipDriver/"
func _ready():
	var file = File.new()
	file.open(ship_driver_path + "driver_data.json",File.READ)
	var data = JSON.parse(file.get_as_text()).result
	file.close()
	
	var ro = preload("res://story/RescueOperation.gd")
	for i in range(data.size()):
		var ship = data[i]
		if "derelict" in ship:
			var derelict_data = ship["derelict"]
			var model = ship.get("name","TRTL")
			var dname = ship["specific_event_name"] if "specific_event_name" in ship else ("ModdedDerelict_" + model)
			var node = ro.new()
			node.name = dname
			var newname = node.name
			node.randomChance = 0.0
			node.minimumChance = 0.0
			node.chaosLimit = 3.0
			
			node.model = model
			
			node.reEncouterChance = clamp(1.0 - derelict_data.get("stock_chance",0.2),0,1)
			node.damageDerelict = derelict_data.get("allow_damage",true)
			node.extraDamage = derelict_data.get("cause_extra_damage",true)
			node.denseClusterChance = derelict_data.get("rock_cluster_chance",0.3)
			node.denseClusterNumber = derelict_data.get("rock_cluster_count",33)
			node.clump = derelict_data.get("clump",false)
			node.clumpVelocity = derelict_data.get("clump_velocity",25)
			node.stormChance = derelict_data.get("ring_storm_chance",0.3)
			node.pirateChance = derelict_data.get("pirate_chance",0.3)
			node.rescue = derelict_data.get("rescue",false)
			
			add_child(node)
