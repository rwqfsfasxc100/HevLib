extends "res://ships/Shipyard.gd"

#const DriverManagement = preload("res://HevLib/pointers/DriverManagement.gd")
onready var pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")

func _ready():
	var file = File.new()
#	var timer = Timer.new()
#	timer.name = "removal_timer"
#	timer.one_shot = true
#	timer.wait_time = 0.2
#	timer.connect("timeout",self,"resetter_timeout")
#	add_child(timer)
#	timer.start()
	yield(get_tree(),"idle_frame")
	resetter_timeout()
	var nano_delivery = {}
	var drivers = pointers.DriverManagement.__get_drivers()
	for mod in drivers:
		var list = mod["drivers"]
		if "ADD_SHIPS.gd" in list:
			var data = list["ADD_SHIPS.gd"]
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
		if "REGISTER_SHIP_NUMERICS.gd" in list:
			var data = list["REGISTER_SHIP_NUMERICS.gd"]
			for register in data:
				var sd = data[register]
				match register:
					"REGISTER_AMMO":
						for value in sd:
							var entries = sd[value]
							if "price" in entries:
								ammoValue[value] = entries["price"]
							if "delivery_speed" in entries:
								ammoDeliveryPerSeocond[value] = entries["delivery_speed"]
					"REGISTER_NANO":
						for value in sd:
							var entries = sd[value]
							if "price" in entries:
								droneValue[value] = entries["price"]
							if "delivery_speed" in entries:
								nano_delivery[value] = entries["delivery_speed"]
					"REGISTER_REACTOR_RODS":
						for value in sd:
							var entries = sd[value]
							if "price" in entries:
								rodsValue[value] = entries["price"]
							if "mass" in entries:
								rodsMass[value] = entries["mass"]
					"REGISTER_ULTRACAPACITORS":
						for value in sd:
							var entries = sd[value]
							if "price" in entries:
								capacitorValue[value] = entries["price"]
							if "mass" in entries:
								capacitorMass[value] = entries["mass"]
					"REGISTER_TURBINES":
						for value in sd:
							var entries = sd[value]
							if "price" in entries:
								turbineValue[value] = entries["price"]
							if "mass" in entries:
								turbineMass[value] = entries["mass"]
	file.open("user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/ships/drone_delivery_speed.json",File.WRITE)
	file.store_string(JSON.print(nano_delivery))
	file.close()
#	yield(get_tree(),"idle_frame")
#	yield(get_tree(),"idle_frame")
#	yield(get_tree(),"idle_frame")
#	yield(get_tree(),"idle_frame")
#	yield(get_tree(),"idle_frame")
#	for ship in ships:
#		var dt = ships[ship]
#		var iv = dt.instance()
#		if "handleSystemToggles" in iv:
#			print(TranslationServer.translate(iv.shipName) + " does")
#		else:
#			print(TranslationServer.translate(iv.shipName) + " does not")
	pass

func resetter_timeout():
	for ship in ships:
		var path = ships[ship].resource_path
		var replacement = ResourceLoader.load(path,"",true)
		var sc = ships[ship]
		Tool.remove(sc)
		ships[ship] = null
		ships[ship] = replacement
	
#	var sc = load("res://ships/ship-ctrl.gd")
#	var methods = sc.get_script_constant_map()
#	pass
#	yield(get_tree(),"idle_frame")
#	for ship in ships:
#		var d = ships[ship]
#		var lastErr = OK
#		while not lastErr == ERR_FILE_EOF:
#			lastErr = d.poll()
#		ships[ship] = d.get_resource()


func createShipByConfig(cfg: Dictionary, new = true, age = 24 * 3600 * 365 * 100, sd = 0):
	var ship = .createShipByConfig(cfg, new, age, sd)
#	var script = load("res://ships/ship-ctrl.gd")
#	ship.set_script(script)
	return ship
