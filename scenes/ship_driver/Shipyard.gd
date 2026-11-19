# [license]
# SPDX-License-Identifier: LicenseRef-Proprietary
# Copyright © 2026 __hev (Benjamin Buckhurst). All Rights Reserved.
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that all following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.
# 
# 4. The source code and the binary form, and any modifications made to them may not be used for the purpose of input data, reference code snippets and/or files, OR used in the training of, or improvement of machine learning algorithms,
# including but not limited to artificial intelligence, natural language processing, or data mining. This condition applies to any derivatives,
# modifications, or updates based on the Software code. Any usage of the source code or the binary form may not be present in any form as data fed, inputted, or provided to an AI, or present in any AI-training dataset is considered a breach of this License.
# 
# 5. Any projects deriving work from this project MUST include a copy of this license and all other license and/or copyright agreements posed within other source material,
# all of which must be followed to its entirety. Failure to follow these licenses prohibit all modification and redistribution of the material until all licensing has been reinstated.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# [/license]

extends "res://ships/Shipyard.gd"

onready var syPointers:HevLibPointers = ModLoader._savedObjects[0]

var inverseShipAliases:Dictionary = Dictionary()

var file:File = File.new()

var numericRegEx:RegEx = RegEx.new()

onready var sys_slot_refs:Dictionary = syPointers.Equipment.equipment_validity_for_slots.duplicate(true)
var inverted_sys_slot_refs:Dictionary = Dictionary()
var cfg_mod_refs:Dictionary = Dictionary()

var rehash_rand:Dictionary = Dictionary()

var hl_shipdrivershipyardhandler_uinit : bool = false
func _ready():
	if hl_shipdrivershipyardhandler_uinit:
		syPointers.main_modmain.log_double_load_error(get_script().resource_path)
	hl_shipdrivershipyardhandler_uinit = true
	syPointers.ConfigDriver.__establish_connection("hl_shipyard_shipdriver_update",self)
	hl_shipyard_shipdriver_update()
	yield(syPointers,"process_tick")
	hl_shipdriver_resetter_timeout()
	for tag in sys_slot_refs.keys():
		for item in sys_slot_refs[tag]:
			if not item in inverted_sys_slot_refs:
				inverted_sys_slot_refs[item] = [tag]
			elif not tag in inverted_sys_slot_refs[item]:
				inverted_sys_slot_refs[item].append(tag)
	numericRegEx.compile("[0-9]")
	
	
	# Ship driver
	var alternates:Dictionary = Dictionary()
	for sd in syPointers.Equipment.add_ships_store:
		var ship_name:String = sd.get("name","")
		var path:String = sd.get("path","")
		var alias:String = sd.get("alias",ship_name)
		var config:Dictionary = sd.get("config",Dictionary()).duplicate(true)
		if not "config" in config:
			config = {"config":config}
		var usedConfigs:Array = sd.get("used_configs",Array()).duplicate(true)
		var alts = sd.get("alternate_configs","")
		if alts:
			if not ship_name in alternates:
				alternates[ship_name] = Array()
			if alts is String:
				alternates[ship_name].append(alts)
			elif alts is Array or alts is PoolStringArray:
				alternates[ship_name].append_array(alts)
		
		if ship_name:
			if path:
				if syPointers.DataFormat.__load_if_can(path):
					ships[ship_name] = syPointers.DataFormat.__get_load()
				else:
					syPointers.l("ERROR: Failed to load ship scene for [%s], located at [%s]" % [ship_name,path],"ShipDriver")
			if alias != ship_name:
				configAlias[ship_name] = alias
			if config.config:
				if ship_name in defaultShipConfig:
					defaultShipConfig[ship_name]["config"].merge(config.config,true)
				else:
					defaultShipConfig[ship_name] = config
			for cfg in usedConfigs:
				if not ship_name in usedShipConfigs:
					usedShipConfigs[ship_name] = Array()
				if "config" in cfg.keys():
					usedShipConfigs[ship_name].append(cfg["config"])
				else:
					usedShipConfigs[ship_name].append(cfg)
	for ship_name in alternates:
		var usedConfigs:Array = Array()
		for a in alternates[ship_name]:
			var cfgalias:String = getShipAlias(a)
			if a in defaultShipConfig:
				var cf:Dictionary = defaultShipConfig[a]
				if "config" in cf:
					cf = cf["config"].duplicate(true)
				else:
					cf = cf.duplicate(true)
				usedConfigs.append(cf)
			if a in usedShipConfigs:
				usedConfigs.append_array(usedShipConfigs[a].duplicate(true))
			if cfgalias in defaultShipConfig:
				var cf:Dictionary = defaultShipConfig[cfgalias].duplicate(true)
				if "config" in cf:
					usedConfigs.append(cf["config"])
				else:
					usedConfigs.append(cf)
			if cfgalias in usedShipConfigs:
				usedConfigs.append_array(usedShipConfigs[cfgalias].duplicate(true))
		for cfg in usedConfigs:
			if not ship_name in usedShipConfigs:
				usedShipConfigs[ship_name] = Array()
			if "config" in cfg:
				usedShipConfigs[ship_name].append(cfg["config"].duplicate(true))
			else:
				usedShipConfigs[ship_name].append(cfg.duplicate(true))
			var cfgalias:String = getShipAlias(ship_name)
			if cfgalias != ship_name:
				usedShipConfigs[cfgalias].append(cfg.duplicate(true))
	
	for ship in configAlias:
		var baseShip:String = configAlias[ship]
		if not baseShip in inverseShipAliases:
			inverseShipAliases[baseShip] = [ship]
		else:
			inverseShipAliases[baseShip].append(ship)
	
	# Ship numerics handler
	var register_ship_numerics:Dictionary = syPointers.Equipment.register_ship_numerics_store
	var nano_delivery:Dictionary = Dictionary()
	for data in register_ship_numerics.keys():
		match data:
			"REGISTER_AMMO":
				for v in register_ship_numerics[data]:
					for value in v:
						var entries:Dictionary = v[value]
						var ek:Array = entries.keys()
						value = float(value)
						if "price" in ek:
							ammoValue[value] = float(entries["price"])
						if "delivery_speed" in ek:
							ammoDeliveryPerSeocond[value] = float(entries["delivery_speed"])
			"REGISTER_NANO":
				for v in register_ship_numerics[data]:
					for value in v:
						var entries:Dictionary = v[value]
						var ek:Array = entries.keys()
						value = float(value)
						if "price" in ek:
							droneValue[value] = float(entries["price"])
						if "delivery_speed" in ek:
							nano_delivery[value] = float(entries["delivery_speed"])
			"REGISTER_REACTOR_RODS":
				for v in register_ship_numerics[data]:
					for value in v:
						var entries:Dictionary = v[value]
						var ek:Array = entries.keys()
						value = float(value)
						if "price" in ek:
							rodsValue[value] = float(entries["price"])
						if "mass" in ek:
							rodsMass[value] = float(entries["mass"])
			"REGISTER_ULTRACAPACITORS":
				for v in register_ship_numerics[data]:
					for value in v:
						var entries:Dictionary = v[value]
						var ek:Array = entries.keys()
						value = float(value)
						if "price" in ek:
							capacitorValue[value] = float(entries["price"])
						if "mass" in ek:
							capacitorMass[value] = float(entries["mass"])
			"REGISTER_TURBINES":
				for v in register_ship_numerics[data]:
					for value in v:
						var entries:Dictionary = v[value]
						var ek:Array = entries.keys()
						value = float(value)
						if "price" in ek:
							turbineValue[value] = float(entries["price"])
						if "mass" in ek:
							turbineMass[value] = float(entries["mass"])
			"REGISTER_PROPELLANT":
				for v in register_ship_numerics[data]:
					for value in v:
						var entries:Dictionary = v[value]
						if "price" in entries.keys():
							turbineValue[float(value)] = float(entries["price"])
	syPointers.Equipment.drone_delivery_speed = nano_delivery
	
	# Modify ship builds
	for entry in syPointers.Equipment.ship_build_mod_store.duplicate(true):
		var ship:String = entry.ship_name
		if ship in cfg_mod_refs:
			cfg_mod_refs[ship].append(entry.duplicate(true))
		else:
			cfg_mod_refs[ship] = [entry.duplicate(true)]
		if entry.recurse_for_alias:
			var related_aliases:Array = Array()
			if ship in configAlias:
				related_aliases.append(configAlias[ship])
			if ship in inverseShipAliases:
				for aliasOf in inverseShipAliases[ship]:
					if not aliasOf in related_aliases:
						related_aliases.append(aliasOf)
			for aliasOf in related_aliases:
				if aliasOf in cfg_mod_refs:
					cfg_mod_refs[aliasOf].append(entry.duplicate(true))
				else:
					cfg_mod_refs[aliasOf] = [entry.duplicate(true)]

var maxRolls:int = 10
var modChanceScale:float = 1.0

func hl_shipyard_shipdriver_update():
	maxRolls = syPointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DRIVERS","max_dealership_modification_rolls",10)
	modChanceScale = syPointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DRIVERS","dealership_modification_roll_chance_scale",1.0)

func hl_shipdriver_resetter_timeout():
	for ship in ships:
		var ship_path:String = ships[ship].resource_path
		Tool.remove(ships[ship])
		ships[ship] = null
		ships[ship] = ResourceLoader.load(ship_path,"PackedScene")

const wraparound:int = 0x0000FFFFFFFFFFFF

func getBuildsFor(s: String):
	var out = .getBuildsFor(s)
	var day:int = int(floor(CurrentGame.getInGameTimestamp() / (24 * 3600)))
	for i in rehash_rand:
		if i < day - 5:
			rehash_rand.erase(i)
	if not day in rehash_rand:
		rehash_rand[day] = Dictionary()
	seed(hash(CurrentGame.state.time) + hash(CurrentGame.state.soldShips))
	if out and s in cfg_mod_refs:
		var scfgs:int = cfg_mod_refs[s].size()
		var useTheseConfigs:Array = Array()
		var outHash:int = hash(out) + hash(s) + syPointers.ManifestV2.currentModHash
		var cfrRand:int = ((CurrentGame.srai(day + outHash + scfgs, 1)[0]) % wraparound) + randi()
		if not s in rehash_rand[day]:
			rehash_rand[day][s] = Array()
		seed(cfrRand)
		var tcfgs:Array = cfg_mod_refs[s].duplicate(true)
		tcfgs.shuffle()
		for i in min(maxRolls,scfgs):
			useTheseConfigs.append(tcfgs[(randi() % ((2 * i) + 0xFF)) % scfgs])
		cfrRand = (cfrRand + randi()) % wraparound
		for cnum in useTheseConfigs.size():
			var config:Dictionary = useTheseConfigs[cnum]
			var rand:float = CurrentGame.sraf(cfrRand % (cnum + 0xFF))# * 1.33
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
									var doAdd = config.get("do_add_if",Array())
									var dontAdd = config.get("dont_add_if",Array())
									var wantedSystems = doAdd + dontAdd
									var systems:Array = syPointers.DataFormat.__sift_ship_config(dict.duplicate(true),wantedSystems,["currentCargo","currentCargoBy","currentCargoComposition","damage","juryRig","preferredCrew","processedCargo","remoteCargo","tuning"],true)
									if systems:
										var add:bool = true
										for r in systems:
											if r in dontAdd:
												add = false
												break
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
									var doAdd:Array = config.get("do_add_if",Array())
									var dontAdd:Array = config.get("dont_add_if",Array())
									var doSystems:Array = Array()
									var dontSystems:Array = Array()
									for i in inverted_sys_slot_refs:
										if i in doAdd:
											doSystems.append_array(inverted_sys_slot_refs[i])
										if i in dontAdd:
											dontSystems.append_array(inverted_sys_slot_refs[i])
									var wantedSystems:Array = doSystems + dontSystems
									var systems:Array = syPointers.DataFormat.__sift_ship_config(dict.duplicate(true),wantedSystems,["currentCargo","currentCargoBy","currentCargoComposition","damage","juryRig","preferredCrew","processedCargo","remoteCargo","tuning"],true)
									if systems:
										var add:bool = true
										for r in systems:
											if r in dontSystems:
												add = false
												break
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
		var do:Dictionary = config[op]
		for slot in do.keys():
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
						break
				if andPassed:
					orPassed = true
					break
			if not orPassed:
				canAdd = false
				break
	return canAdd

func conditional_tag_check(config,dict,op:String):
	var canAdd:bool = true
	if canAdd and op in config:
		var do:Dictionary = config[op]
		for slot in do.keys():
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
						break
					else:
						for g in slotcheck:
							if g in sys_slot_refs[inSlot]:
								andPassed = false
								break
						if not andPassed:
							break
				if andPassed:
					orPassed = true
					break
			if not orPassed:
				canAdd = false
				break
	return canAdd

func numerics_check(config,dict):
	var pass_numeric_check:bool = true
	if "check_numerics" in config:
		var ccheck:Dictionary = config.check_numerics
		for slot in ccheck.keys():
			var slotArgs:Dictionary = ccheck[slot]
			var op:String = slotArgs.get("operation",slotArgs.get("expression","=="))
			var val = slotArgs.get("comparison",slotArgs.get("value",0))
			
			if val is int or val is float:
				val = float(val)
			elif val is String:
				if numericRegEx.search(val):
					val = float(val)
			else:
				continue
			var inSlot = getConfigHevLib(slot,dict,0.0)
			var isnt:bool = true
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

var configMutexHevLib:Mutex = Mutex.new()
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
	var path:PoolStringArray = key.split(".")
	for n in (path.size() - 1):
		var k = path[n]
		if not (k in c):
			c[k] = Dictionary()
		c = c[k]
	c[path[path.size() - 1]] = value
	configMutexHevLib.unlock()

func nestedGetHevLib(from, key):
	if from == null:
		return null
	if key in from:
		return from[key]
	return null
