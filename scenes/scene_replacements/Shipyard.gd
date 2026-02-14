extends "res://ships/Shipyard.gd"

var ship_driver_path = "user://cache/.HevLib_Cache/ShipDriver/"

func _ready():
	var file = File.new()
	yield(get_tree(),"idle_frame")
	resetter_timeout()
	var nano_delivery = {}
	file.open(ship_driver_path + "driver_data.json",File.READ)
	var drivers = JSON.parse(file.get_as_text()).result
	file.close()
	file.open(ship_driver_path + "register_data.json",File.READ)
	var drivers2 = JSON.parse(file.get_as_text()).result
	file.close()
	for mod in drivers:
		var data = drivers[mod]
		for ship in data:
			var sd = data[ship]
			var ship_name = sd.get("name","")
			var path = sd.get("path","")
			var alias = sd.get("alias",ship_name)
			var config = sd.get("config",{})
			if not "config" in config:
				var nc = {"config":config.duplicate(true)}
				config = nc
			var usedConfigs = sd.get("used_configs",[])
			if ship_name and path and file.file_exists(path):
				ships[ship_name] = load(path)
				configAlias[ship_name] = alias
				defaultShipConfig[ship_name] = config
				for cfg in usedConfigs:
					if not ship_name in usedShipConfigs:
						usedShipConfigs[ship_name] = []
					if "config" in cfg:
						var nv = cfg["config"].duplicate(true)
						cfg = nv
					usedShipConfigs[ship_name].append(cfg)
	for mod in drivers2:
		var data = drivers2[mod]
		for register in data:
			var sd = data[register]
			match register:
				"REGISTER_AMMO":
					for value in sd:
						var entries = sd[value]
						value = float(value)
						if "price" in entries:
							ammoValue[value] = float(entries["price"])
						if "delivery_speed" in entries:
							ammoDeliveryPerSeocond[value] = float(entries["delivery_speed"])
				"REGISTER_NANO":
					for value in sd:
						var entries = sd[value]
						value = float(value)
						if "price" in entries:
							droneValue[value] = float(entries["price"])
						if "delivery_speed" in entries:
							nano_delivery[value] = float(entries["delivery_speed"])
				"REGISTER_REACTOR_RODS":
					for value in sd:
						var entries = sd[value]
						value = float(value)
						if "price" in entries:
							rodsValue[value] = float(entries["price"])
						if "mass" in entries:
							rodsMass[value] = float(entries["mass"])
				"REGISTER_ULTRACAPACITORS":
					for value in sd:
						var entries = sd[value]
						value = float(value)
						if "price" in entries:
							capacitorValue[value] = float(entries["price"])
						if "mass" in entries:
							capacitorMass[value] = float(entries["mass"])
				"REGISTER_TURBINES":
					for value in sd:
						var entries = sd[value]
						value = float(value)
						if "price" in entries:
							turbineValue[value] = float(entries["price"])
						if "mass" in entries:
							turbineMass[value] = float(entries["mass"])
	file.open("user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/ships/drone_delivery_speed.json",File.WRITE)
	file.store_string(JSON.print(nano_delivery))
	file.close()
	pass

func resetter_timeout():
	for ship in ships:
		var path = ships[ship].resource_path
		var replacement = ResourceLoader.load(path,"",true)
		var sc = ships[ship]
		Tool.remove(sc)
		ships[ship] = null
		ships[ship] = replacement
	
