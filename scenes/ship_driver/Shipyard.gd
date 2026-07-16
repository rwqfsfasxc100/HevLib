extends "res://ships/Shipyard.gd"

# [license]
# 3-Clause BSD NON-AI License
# 
# Copyright 2026 __hev (Benjamin Buckhurst)
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.
# 
# 4. The source code and the binary form, and any modifications made to them may not be used for the purpose of input data, the training of, or improvment of machine learning algorithms,
# including but not limited to artificial intelligence, natural language processing, or data mining. This condition applies to any derivatives,
# modifications, or updates based on the Software code. Any usage of the source code or the binary form in an AI-training dataset is considered a breach of this License.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# [/license]

var syPointers

var inverseShipAliases = {}

func _ready():
	syPointers = ModLoader._savedObjects[0]
	syPointers.ConfigDriver.__establish_connection("hl_shipyard_shipdriver_update",self)
	hl_shipyard_shipdriver_update()
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

var maxRolls = 10
var modChanceScale = 1.0

func hl_shipyard_shipdriver_update():
	maxRolls = syPointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_EQUIPMENT","max_dealership_modification_rolls")
	modChanceScale = syPointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_EQUIPMENT","dealership_modification_roll_chance_scale")


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

var rehash_rand:Dictionary = {}

func getBuildsFor(s: String):
	var wraparound = 0x0000FFFFFFFFFFFF
	var out = .getBuildsFor(s)
	var now = CurrentGame.getInGameTimestamp()
	var day = int(floor(now / (24 * 3600)))
	for i in rehash_rand:
		if i < day - 5:
			rehash_rand.erase(i)
	if not day in rehash_rand:
		rehash_rand[day] = {}
	seed(hash(CurrentGame.state.time) + hash(CurrentGame.state.soldShips))
	if out and s in cfg_mod_refs:
		var scfgs = cfg_mod_refs[s].size()
		var useTheseConfigs = []
		var outHash = hash(out) + hash(s)
		var cfrRand = ((CurrentGame.srai(day + outHash + scfgs, 1)[0]) % wraparound) + randi()
		if not s in rehash_rand[day]:
			rehash_rand[day][s] = []
		seed(cfrRand)
		var tcfgs = cfg_mod_refs[s].duplicate(true)
		tcfgs.shuffle()
		for i in range(min(maxRolls,scfgs)):
			useTheseConfigs.append(tcfgs[(randi() % ((2 * i) + 0xFF)) % scfgs])
		cfrRand = (cfrRand + randi()) % wraparound
		for cnum in range(useTheseConfigs.size()):
			var config = useTheseConfigs[cnum]
			var rand = CurrentGame.sraf(cfrRand % (cnum + 0xFF))# * 1.33
			if syPointers.ConfigDriver.__validate_dictionary(config,true,false,false):
				if (clamp(config.get("chance",0.1),0.0,1.0) * modChanceScale) > (rand * 1.33):
					match config.get("mode",null):
						"if_equipment_in_slot":
							for dict in out:
								if numerics_check(config,dict):
									if conditional_system_check(config,dict,"do_add_if") and not conditional_system_check(config,dict,"dont_add_if"):
										for thisSlot in config.get("slot","").split("&&",false):
											var sys = config.get("system")
											match typeof(sys):
												TYPE_ARRAY,TYPE_STRING_ARRAY:
													setConfigHevLib(thisSlot.strip_edges(),dict,sys[(hash(tcfgs) + randi()) % sys.size()])
												_:
													setConfigHevLib(thisSlot.strip_edges(),dict,sys)
						"if_tag_in_slot":
							for dict in out:
								if numerics_check(config,dict):
									if conditional_tag_check(config,dict,"do_add_if") and not conditional_tag_check(config,dict,"dont_add_if"):
										for thisSlot in config.get("slot","").split("&&",false):
											var sys = config.get("system")
											match typeof(sys):
												TYPE_ARRAY,TYPE_STRING_ARRAY:
													setConfigHevLib(thisSlot.strip_edges(),dict,sys[(hash(tcfgs) + randi()) % sys.size()])
												_:
													setConfigHevLib(thisSlot.strip_edges(),dict,sys)
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
											for thisSlot in config.get("slot","").split("&&",false):
												var sys = config.get("system")
												match typeof(sys):
													TYPE_ARRAY,TYPE_STRING_ARRAY:
														setConfigHevLib(thisSlot.strip_edges(),dict,sys[(hash(tcfgs) + randi()) % sys.size()])
													_:
														setConfigHevLib(thisSlot.strip_edges(),dict,sys)
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
											for thisSlot in config.get("slot","").split("&&",false):
												var sys = config.get("system")
												match typeof(sys):
													TYPE_ARRAY,TYPE_STRING_ARRAY:
														setConfigHevLib(thisSlot.strip_edges(),dict,sys[(hash(tcfgs) + randi()) % sys.size()])
													_:
														setConfigHevLib(thisSlot.strip_edges(),dict,sys)
						"random":
							for dict in out:
								if numerics_check(config,dict):
									for thisSlot in config.get("slot","").split("&&",false):
										var sys = config.get("system")
										match typeof(sys):
											TYPE_ARRAY,TYPE_STRING_ARRAY:
												setConfigHevLib(thisSlot.strip_edges(),dict,sys[(hash(tcfgs) + randi()) % sys.size()])
											_:
												setConfigHevLib(thisSlot.strip_edges(),dict,sys)
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
				var andChecks:PoolStringArray = o.strip_edges().split("&&",false)
				var andPassed = true
				for a in andChecks:
					var inSlot = getConfigHevLib(a.strip_edges(),dict)
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
				var andChecks:PoolStringArray = o.strip_edges().split("&&",false)
				var andPassed = true
				for a in andChecks:
					var inSlot = getConfigHevLib(a.strip_edges(),dict)
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
			var inSlot = getConfigHevLib(slot,dict,0.0)
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
