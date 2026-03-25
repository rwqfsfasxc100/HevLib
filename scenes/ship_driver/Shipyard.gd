extends "res://ships/Shipyard.gd"

var ship_driver_path = "user://cache/.HevLib_Cache/ShipDriver/"

func _ready():
	var file = File.new()
	yield(get_tree(),"idle_frame")
	resetter_timeout()
	
	# Ship driver
	file.open(ship_driver_path + "driver_data.json",File.READ)
	var drivers = JSON.parse(file.get_as_text()).result
	file.close()
	var alternates = {}
	for sd in drivers:
		var ship_name = sd.get("name","")
		var path = sd.get("path","")
		var alias = sd.get("alias",ship_name)
		var config = sd.get("config",{})
		if not "config" in config:
			var nc = {"config":config.duplicate(true)}
			config = nc
		var usedConfigs = sd.get("used_configs",[])
		
		var alts = sd.get("alternate_configs","")
		if alts:
			alternates.merge({ship_name:alts})
		
		if ship_name:
			if path and file.file_exists(path):
				ships[ship_name] = load(path)
			if alias != ship_name:
				configAlias[ship_name] = alias
			if config:
				defaultShipConfig[ship_name] = config
			for cfg in usedConfigs:
				if not ship_name in usedShipConfigs:
					usedShipConfigs[ship_name] = []
				if "config" in cfg:
					var nv = cfg["config"].duplicate(true)
					cfg = nv
				usedShipConfigs[ship_name].append(cfg)
	for ship_name in alternates:
		var alts = alternates[ship_name]
		var usedConfigs = []
		match typeof(alts):
			TYPE_STRING:
				if alts in defaultShipConfig:
					var cf = defaultShipConfig[alts]
					if "config" in cf:
						cf = cf["config"].duplicate(true)
					else:
						cf = cf.duplicate(true)
					usedConfigs.append(cf)
				if alts in usedShipConfigs:
					var cf = usedShipConfigs[alts].duplicate(true)
					usedConfigs.append_array(cf)
				
			TYPE_ARRAY:
				for a in alts:
					if a in defaultShipConfig:
						var cf = defaultShipConfig[a]
						if "config" in cf:
							cf = cf["config"].duplicate(true)
						else:
							cf = cf.duplicate(true)
						usedConfigs.append(cf)
					if a in usedShipConfigs:
						var cf = usedShipConfigs[a].duplicate(true)
						usedConfigs.append_array(cf)
		for cfg in usedConfigs:
			if not ship_name in usedShipConfigs:
				usedShipConfigs[ship_name] = []
			if "config" in cfg:
				var nv = cfg["config"].duplicate(true)
				cfg = nv
			usedShipConfigs[ship_name].append(cfg)
	
	# Ship numerics handler
	file.open(ship_driver_path + "register_data.json",File.READ)
	var drivers2 = JSON.parse(file.get_as_text()).result
	file.close()
	var nano_delivery = {}
	for data in drivers2:
		match data:
			"REGISTER_AMMO":
				for v in drivers2[data]:
					for value in v:
						var entries = v[value]
						value = float(value)
						if "price" in entries:
							ammoValue[value] = float(entries["price"])
						if "delivery_speed" in entries:
							ammoDeliveryPerSeocond[value] = float(entries["delivery_speed"])
			"REGISTER_NANO":
				for v in drivers2[data]:
					for value in v:
						var entries = v[value]
						value = float(value)
						if "price" in entries:
							droneValue[value] = float(entries["price"])
						if "delivery_speed" in entries:
							nano_delivery[value] = float(entries["delivery_speed"])
			"REGISTER_REACTOR_RODS":
				for v in drivers2[data]:
					for value in v:
						var entries = v[value]
						value = float(value)
						if "price" in entries:
							rodsValue[value] = float(entries["price"])
						if "mass" in entries:
							rodsMass[value] = float(entries["mass"])
			"REGISTER_ULTRACAPACITORS":
				for v in drivers2[data]:
					for value in v:
						var entries = v[value]
						value = float(value)
						if "price" in entries:
							capacitorValue[value] = float(entries["price"])
						if "mass" in entries:
							capacitorMass[value] = float(entries["mass"])
			"REGISTER_TURBINES":
				for v in drivers2[data]:
					for value in v:
						var entries = v[value]
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
	
