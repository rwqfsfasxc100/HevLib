extends "res://ships/Shipyard.gd"

var syPointers

var inverseShipAliases = {}

func _ready():
	syPointers = ModLoader._savedObjects[0]
	var file = File.new()
	yield(get_tree(),"idle_frame")
	hl_shipdriver_resetter_timeout()
	sys_slot_refs = syPointers.Equipment.equipment_validity_for_slots.duplicate(true)
	for tag in sys_slot_refs:
		var equipment = sys_slot_refs[tag]
		for item in equipment:
			if not item in inverted_sys_slot_refs:
				inverted_sys_slot_refs[item] = []
			if not tag in inverted_sys_slot_refs[item]:
				inverted_sys_slot_refs[item].append(tag)
	var ship_build_mod_store:Array = syPointers.Equipment.ship_build_mod_store.duplicate(true)
	numericRegEx.compile("[0-9]")
	
	
	# Ship driver
	var alternates = {}
	for sd in syPointers.Equipment.add_ships_store:
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
			if syPointers.DataFormat.__load_if_can(path):
				ships[ship_name] = syPointers.DataFormat.__get_load()
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
	
	for ship in configAlias:
		var baseShip = configAlias[ship]
		if not baseShip in inverseShipAliases:
			inverseShipAliases[baseShip] = []
		inverseShipAliases[baseShip].append(ship)
	
	# Ship numerics handler
	var register_ship_numerics = syPointers.Equipment.register_ship_numerics_store
	var nano_delivery = {}
	for data in register_ship_numerics:
		match data:
			"REGISTER_AMMO":
				for v in register_ship_numerics[data]:
					for value in v:
						var entries = v[value]
						value = float(value)
						if "price" in entries:
							ammoValue[value] = float(entries["price"])
						if "delivery_speed" in entries:
							ammoDeliveryPerSeocond[value] = float(entries["delivery_speed"])
			"REGISTER_NANO":
				for v in register_ship_numerics[data]:
					for value in v:
						var entries = v[value]
						value = float(value)
						if "price" in entries:
							droneValue[value] = float(entries["price"])
						if "delivery_speed" in entries:
							nano_delivery[value] = float(entries["delivery_speed"])
			"REGISTER_REACTOR_RODS":
				for v in register_ship_numerics[data]:
					for value in v:
						var entries = v[value]
						value = float(value)
						if "price" in entries:
							rodsValue[value] = float(entries["price"])
						if "mass" in entries:
							rodsMass[value] = float(entries["mass"])
			"REGISTER_ULTRACAPACITORS":
				for v in register_ship_numerics[data]:
					for value in v:
						var entries = v[value]
						value = float(value)
						if "price" in entries:
							capacitorValue[value] = float(entries["price"])
						if "mass" in entries:
							capacitorMass[value] = float(entries["mass"])
			"REGISTER_TURBINES":
				for v in register_ship_numerics[data]:
					for value in v:
						var entries = v[value]
						value = float(value)
						if "price" in entries:
							turbineValue[value] = float(entries["price"])
						if "mass" in entries:
							turbineMass[value] = float(entries["mass"])
	syPointers.Equipment.drone_delivery_speed = nano_delivery
	
	# Modify ship builds
	for entry in ship_build_mod_store:
		var ship = entry.ship_name
		var mode = entry.mode
		var recurse = entry.recurse_for_alias
		if not ship in cfg_mod_refs:
			cfg_mod_refs[ship] = []
		cfg_mod_refs[ship].append(entry.duplicate(true))
		if recurse:
			var related_aliases = []
			if ship in configAlias:
				var aliasOf = configAlias[ship]
				related_aliases.append(aliasOf)
			if ship in inverseShipAliases:
				for aliasOf in inverseShipAliases[ship]:
					if not aliasOf in related_aliases:
						related_aliases.append(aliasOf)
			for aliasOf in related_aliases:
				if not aliasOf in cfg_mod_refs:
					cfg_mod_refs[aliasOf] = []
				cfg_mod_refs[aliasOf].append(entry.duplicate(true))




func hl_shipdriver_resetter_timeout():
	for ship in ships:
		var path = ships[ship].resource_path
		var replacement = load(path)
		var sc = ships[ship]
		Tool.remove(sc)
		ships[ship] = null
		ships[ship] = replacement

var numericRegEx = RegEx.new()

var sys_slot_refs:Dictionary = {}
var inverted_sys_slot_refs:Dictionary = {}
var cfg_mod_refs:Dictionary = {}

func getBuildsFor(s: String):
	var out = .getBuildsFor(s)
	if s in cfg_mod_refs:
		for config in cfg_mod_refs[s]:
			if syPointers.ConfigDriver.__validate_dictionary(config,true,false,false):
				var cfgHash = hash(config)
				var now = CurrentGame.getInGameTimestamp()
				var day = int(floor(now / (24 * 3600)))
				var rand = CurrentGame.sraf(day + cfgHash)
				if config.get("chance",0.1) >= rand:
						match config.get("mode",null):
							"if_equipment_in_slot":
								for dict in out:
									if numerics_check(config,dict):
										if conditional_system_check(config,dict,"do_add_if") and not conditional_system_check(config,dict,"dont_add_if"):
											setConfigHevLib(config.get("slot"),dict,config.get("system"))
							"if_tag_in_slot":
								for dict in out:
									if numerics_check(config,dict):
										if conditional_tag_check(config,dict,"do_add_if") and not conditional_tag_check(config,dict,"dont_add_if"):
											setConfigHevLib(config.get("slot"),dict,config.get("system"))
							"if_equipment":
								for dict in out:
									if numerics_check(config,dict):
										var doAdd = config.get("do_add_if",[])
										var dontAdd = config.get("dont_add_if",[])
										var wantedSystems = doAdd + dontAdd
										var systems = syPointers.DataFormat.__sift_ship_config(dict.duplicate(true),wantedSystems,["currentCargo","currentCargoBy","currentCargoComposition","damage","juryRig","preferredCrew","processedCargo","remoteCargo","tuning"],true)
										if systems:
											var add = true
											for r in systems:
												if r in dontAdd:
													add = false
											if add:
												setConfigHevLib(config.get("slot"),dict,config.get("system"))
							"if_tag":
								for dict in out:
									if numerics_check(config,dict):
										var doAdd = config.get("do_add_if",[])
										var dontAdd = config.get("dont_add_if",[])
										var doSystems = []
										var dontSystems = []
										for i in inverted_sys_slot_refs:
											if i in doAdd:
												doSystems.append_array(inverted_sys_slot_refs[i])
											if i in dontAdd:
												dontSystems.append_array(inverted_sys_slot_refs[i])
										var wantedSystems = doSystems + dontSystems
										var systems = syPointers.DataFormat.__sift_ship_config(dict.duplicate(true),wantedSystems,["currentCargo","currentCargoBy","currentCargoComposition","damage","juryRig","preferredCrew","processedCargo","remoteCargo","tuning"],true)
										if systems:
											var add = true
											for r in systems:
												if r in dontSystems:
													add = false
											if add:
												setConfigHevLib(config.get("slot"),dict,config.get("system"))
							"random":
								for dict in out:
									if numerics_check(config,dict):
										setConfigHevLib(config.get("slot"),dict,config.get("system"))
	return out

func conditional_system_check(config,dict,op:String):
	var canAdd:bool = true
	if canAdd and op in config:
		var do = config[op]
		for slot in do:
			var slotcheck = do[slot]
			var orChecks:PoolStringArray = slot.split("||",false)
			var orPassed = false
			for o in orChecks:
				var andChecks:PoolStringArray = o.split("&&",false)
				var andPassed = true
				for a in andChecks:
					var inSlot = getConfigHevLib(a,dict)
					if not inSlot in slotcheck:
						andPassed = false
				if andPassed:
					orPassed = true
					break
			if not orPassed:
				canAdd = false
	return canAdd

func conditional_tag_check(config,dict,op:String):
	var canAdd:bool = true
	if canAdd and op in config:
		var do = config[op]
		for slot in do:
			var slotcheck = do[slot]
			var orChecks:PoolStringArray = slot.split("||",false)
			var orPassed = false
			for o in orChecks:
				var andChecks:PoolStringArray = o.split("&&",false)
				var andPassed = true
				for a in andChecks:
					var inSlot = getConfigHevLib(a,dict)
					if not inSlot in sys_slot_refs:
						andPassed = false
					else:
						for g in slotcheck:
							if g in sys_slot_refs[inSlot]:
								andPassed = false
				if andPassed:
					orPassed = true
					break
			if not orPassed:
				canAdd = false
	return canAdd

func numerics_check(config,dict):
	var pass_numeric_check = true
	if "check_numerics" in config:
		var ccheck = config.check_numerics
		for slot in ccheck:
			var slotArgs = ccheck[slot]
			var op:String = slotArgs.get("operation",slotArgs.get("expression","=="))
			var val = slotArgs.get("comparison",slotArgs.get("value",0))
			match typeof(val):
				TYPE_INT,TYPE_REAL:
					val = float(val)
				TYPE_STRING:
					var find = numericRegEx.search(val)
					if find:
						val = float(val)
				_:
					continue
			var inSlot = getConfigHevLib(slot,dict)
			var isnt = true
			if op.begins_with("!"):
				isnt = false
				op = op.substr(1)
			match op:
				"==":
					pass_numeric_check = (val == inSlot) == isnt
				"<":
					pass_numeric_check = (val < inSlot) == isnt
				">":
					pass_numeric_check = (val > inSlot) == isnt
				"<=":
					pass_numeric_check = (val <= inSlot) == isnt
				">=":
					pass_numeric_check = (val >= inSlot) == isnt
	return pass_numeric_check

var configMutexHevLib = Mutex.new()
func getConfigHevLib(key, c, default = null):
	configMutexHevLib.lock()
	for k in key.split("."):
		c = nestedGetHevLib(c, k)
	configMutexHevLib.unlock()
	if c == null:
		return default
	else:
		return c

func setConfigHevLib(key, c, value):
	configMutexHevLib.lock()
	var path = key.split(".")
	for n in range(path.size() - 1):
		var k = path[n]
		if not (k in c):
			c[k] = {}
		c = c[k]
	c[path[path.size() - 1]] = value
	configMutexHevLib.unlock()

func nestedGetHevLib(from, key):
	if from == null:
		return null
	if key in from:
		return from[key]
	return null
