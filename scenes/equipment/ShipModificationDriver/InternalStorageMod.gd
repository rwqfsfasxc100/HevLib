extends "res://ships/ship-ctrl.gd"

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

var base_proc_storage = 0
var base_ammo_storage = 0
var base_nano_storage = 0
var base_storage_type = processedCargoStorageType
var base_propellant = 0
var base_crew_count = 0
var base_crew_morale = 0
var base_mass = 0
var base_emp_shielding = 0


var storage_add = 0
var ammo_add = 0
var nano_add = 0
var storage_multi = 1.0
var ammo_multi = 1.0
var nano_multi = 1.0
var propellant_multi = 1.0
var mass_multi = 1.0
var propellant_add = 0
var mass_add = 0
var mass_per_crew = 0
var mass_per_processed_tonne = 0
var mass_per_tonne_total_storage_added = 0
var ammo_speed_add = 0
var nano_speed_add = 0
var ammo_speed_multi = 1.0
var nano_speed_multi = 1.0
var emp_shielding = 0
var emp_scale_multi = 1.0

var nanodroneMagazine = 0
var listings = {}

var hl_ism_system_name_registers = []
var hl_ism_add_systems = []

var currentInstalledEquipmentWithChanges = []
var hl_ism_installedequipment = []




var hl_ism_mineral_trace_length = 6

func _enter_tree():
	ismPointers = ModLoader._savedObjects[0]
	if ismPointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_EQUIPMENT","extend_divided_storage_multiplier"):
		hl_ism_mineral_trace_length = CurrentGame.traceMinerals.size()
	ismPointers.ConfigDriver.__establish_connection("hl_ism_UV",self)
	listings = ismPointers.Equipment.processed_storage_mods
	
	var sysNames = ismPointers.Equipment.processed_storage_systems
	configMutex.lock()
	currentInstalledEquipmentWithChanges = ismPointers.DataFormat.__sift_ship_config(shipConfig.duplicate(true),sysNames,["currentCargo","currentCargoBy","currentCargoComposition","damage","juryRig","preferredCrew","processedCargo","remoteCargo","tuning"])
	configMutex.unlock()
	for i in currentInstalledEquipmentWithChanges:
		hl_ism_installedequipment.append(i.split(".")[i.split(".").size() - 1])
	
	
	
	hl_ism_init_vars()
	base_mass = mass * 1000
#	base_mass = currentMass
	
#	CurrentGame.setStory("dd.story.interplanetary",10)
	l("Readying ship. Base storage of %s proc / %s ammo / %s nanodrones on storage type of %s" % [base_proc_storage, base_ammo_storage, base_nano_storage, base_storage_type])
	
	
	
	
	
	var modifyable_type = base_storage_type
	var modifyable_capacity = base_proc_storage
	var modifyable_crew_count = base_crew_count
	var modifyable_crew_morale = base_crew_morale
	
	var total_added_capacity = 0
	
	var individual_capacity_changes = []
	
	for item in hl_ism_installedequipment:
		var iddata = listings[item]
		if not ismPointers.ConfigDriver.__validate_dictionary(iddata):
			continue
		var minimum_ammo_utilization_for_reduction = iddata.get("minimum_ammo_utilization_for_reduction",0.0)
		var minimum_nano_utilization_for_reduction = iddata.get("minimum_nano_utilization_for_reduction",0.0)
		var minimum_propellant_utilization_for_reduction = iddata.get("minimum_propellant_utilization_for_reduction",0.0)
		
		var current_ammo_amt = base_ammo_storage
		var current_nano_amt = base_nano_storage
		var current_propellant_amt = base_propellant
		var ammo_limit = upgradeLimits["ammo.capacity"][1]
		var nano_limit = upgradeLimits["drones.capacity"][1]
		var propellant_limit = upgradeLimits["fuel.capacity"][1]
		
		var this_added_capacity = 0
		var this_storage_multi = 1
		var this_ammo_multi = 1
		var this_nano_multi = 1
		var this_propellant_multi = 1
		var mass_per_tonne_storage_added = 0
		
		for key in iddata:
			var val = iddata[key]
			match key:
				"storage_flat":
					storage_add += val
					this_added_capacity += val
				"storage_ammo":
					ammo_add += val
					this_added_capacity += val
				"storage_nano":
					nano_add += val
					this_added_capacity += val
				"storage_propellant":
					propellant_add += val
					this_added_capacity += val
				"display_system":
					var dname = val.get("name","")
					var mv = val.get("can_display_multiple",false)
					if (dname and dname != "") and ((not dname in hl_ism_system_name_registers) or mv):
						var status = val.get("status",100.0)
						var power = val.get("power",0.0)
						var inspect = val.get("affect_inspection",false)
						var o = {
							"name":dname,
							"can_display_multiple":mv,
							"power":power,
							"status":status,
							"affect_inspection":inspect
						}
						hl_ism_system_name_registers.append(dname)
						hl_ism_add_systems.append(o)
				"storage_multi":
					val = float(max(val,0.001))
					storage_multi *= val
					this_storage_multi *= val
				"ammo_multi":
					if val < 1.0 and minimum_ammo_utilization_for_reduction > 0.0:
						var diff = 1.0 - val
						var curr = ((minimum_ammo_utilization_for_reduction * nano_limit) - current_nano_amt) / nano_limit
						if curr >= 0:
							val += diff
						else:
							val = clamp(val + (diff + curr),val,1.0)
					val = float(max(val,0.001))
					ammo_multi *= val
					this_ammo_multi *= val
				"nano_multi":
					if val < 1.0 and minimum_nano_utilization_for_reduction > 0.0:
						var diff = 1.0 - val
						var curr = ((minimum_nano_utilization_for_reduction * nano_limit) - current_nano_amt) / nano_limit
						if curr >= 0:
							val += diff
						else:
							val = clamp(val + (diff + curr),val,1.0)
					val = float(max(val,0.001))
					nano_multi *= val
					this_nano_multi *= val
				"propellant_multi":
					if val < 1.0 and minimum_propellant_utilization_for_reduction > 0.0:
						var diff = 1.0 - val
						var curr = ((minimum_propellant_utilization_for_reduction * nano_limit) - current_nano_amt) / nano_limit
						if curr >= 0:
							val += diff
						else:
							val = clamp(val + (diff + curr),val,1.0)
					val = float(max(val,0.001))
					propellant_multi *= val
					this_propellant_multi *= val
				"emp_scale_multi":
					emp_scale_multi *= float(max(val,0.001))
				"mass_multi":
					mass_multi *= float(max(val,0.001))
				"force_type":
					modifyable_type = val
				"crew_count":
					modifyable_crew_count += val
				"crew_morale":
					modifyable_crew_morale += val
				"mass":
					mass_add += val
				"mass_per_crew_member":
					mass_per_crew += val
				"mass_per_tonne_of_processed_ore":
					mass_per_processed_tonne += val
				"mass_per_tonne_total_storage_added":
					mass_per_tonne_total_storage_added += val
				"mass_per_tonne_storage_added":
					mass_per_tonne_storage_added = val
				"ammo_speed_add":
					ammo_speed_add += val
				"nano_speed_add":
					nano_speed_add += val
				"ammo_speed_multi":
					ammo_speed_multi *= val
				"nano_speed_multi":
					nano_speed_multi *= val
				"emp_shielding":
					emp_shielding += val
		total_added_capacity += this_added_capacity
		if mass_per_tonne_storage_added != 0:
			individual_capacity_changes.append([
				mass_per_tonne_storage_added,
				this_added_capacity,
				this_ammo_multi,
				this_nano_multi,
				this_propellant_multi,
				this_storage_multi,
			])
		
	if modifyable_crew_count > 0:
		l("Adding mass @ %s kg for each of %s crew members" % [mass_per_crew,modifyable_crew_count])
		mass_add += (modifyable_crew_count * mass_per_crew)
	
	
	
	
	l("Setting desired hold type")
	if modifyable_type != base_storage_type:
		l("Transforming hold type from %s to %s" % [base_storage_type, modifyable_type])
		if modifyable_type != "divided":
			modifyable_capacity = base_proc_storage * hl_ism_mineral_trace_length
		else:
			modifyable_capacity = base_proc_storage / hl_ism_mineral_trace_length
		processedCargoStorageType = modifyable_type
		l("Hold transformation resulted in storage capacity changing from %s to %s" % [base_proc_storage, modifyable_capacity])
	else:
		l("Hold type isn't changed (is this equipment in the right slot?)")
	if modifyable_type != "divided":
		storage_add = storage_add * hl_ism_mineral_trace_length
		l("Hold type isn't divided, multiplying addition of %s by 6 to new addition of %s" % [storage_add,storage_add])
	else:
		mass_per_processed_tonne = mass_per_processed_tonne * hl_ism_mineral_trace_length
		l("Hold type is divided, additional mass per tonne is scaled for the new mineral size")
	
	processedCargoCapacity = int(float(modifyable_capacity) * storage_multi)
	l("Changing base hold size of %s by multiplier %s. Results in new size of %s" % [modifyable_capacity,storage_multi,processedCargoCapacity])
	processedCargoCapacity += storage_add
	l("Adding storage bonus of %s. New size of %s" % [storage_add,processedCargoCapacity])
	
	processedCargoCapacity = max(processedCargoCapacity,0)
	if storage_multi != 1.0:
		var change = processedCargoCapacity - modifyable_capacity
		total_added_capacity += change
	if ammo_multi != 1.0:
		var change = (base_ammo_storage * ammo_multi) - base_ammo_storage
		total_added_capacity += change
	if nano_multi != 1.0:
		var change = (base_nano_storage * nano_multi) - base_nano_storage
		total_added_capacity += change
	if propellant_multi != 1.0:
		var change = (base_propellant * propellant_multi) - base_propellant
		total_added_capacity += change
	
	if mass_per_processed_tonne != 0:
		l("Adding mass @ %s kg for every tonne of processed capacity" % mass_per_processed_tonne)
		var change = ((float(processedCargoCapacity)/1000.0) * mass_per_processed_tonne)
		mass_add += change
	
	if mass_multi != 1.0:
		var val = 0
		val = ((mass + mass_add) * mass_multi) - (mass + mass_add)
		mass_add += val
	
	
	
	
	if mass_per_tonne_total_storage_added != 0:
		l("Changing mass by %s kg for every tonne of total storage changed by" % total_added_capacity)
		var change = ((float(total_added_capacity) /1000.0) * mass_per_tonne_total_storage_added)
		mass_add += change
	for c in individual_capacity_changes:
		var massChangePerTonne = c[0]
		var capacity = c[1]
		capacity += (base_ammo_storage * c[2]) - base_ammo_storage
		capacity += (base_nano_storage * c[3]) - base_nano_storage
		capacity += (base_propellant * c[4]) - base_propellant
		capacity += (c[5] * modifyable_capacity) - modifyable_capacity
		var change = int(round((float(capacity) / 1000.0) * massChangePerTonne))
		mass_add += change
	
	l("Making modificatins to crew. Crew count changed from %s to %s / crew morale changed from %s to %s" % [base_crew_count,modifyable_crew_count,base_crew_morale,modifyable_crew_morale])
	
	crew = max(0,modifyable_crew_count)
	crewMoraleBonus = clamp(modifyable_crew_morale,-0.5,0.5)
	
	
	
	
	
	empShield += emp_shielding
	
	for a in range(hl_ism_add_systems.size()):
		var i = hl_ism_add_systems[a]
		var dname = i.get("name","")
		var power = i.get("power",0.0)
		var status = i.get("status",100.0)
		var inspect = i.get("affect_inspection",false)
		
		
		var sys = Node2D.new()
		sys.set_script(load("res://HevLib/scenes/equipment/var_nodes/system_display.gd"))
		sys.systemName = dname
		sys.power = power
		sys.status = status
		sys.affect_inspection = inspect
		add_child(sys)
		call_deferred("move_child",sys,get_child_count())
	
	
	var droneData = ismPointers.Equipment.drone_delivery_speed
	for amnt in droneData:
		nanoDeliveryPerSecond[float(amnt)] = droneData[amnt]
func _ready():
	l("Adding consumables: + %s ammo / + %s nanodrones / + %s propellant" % [ammo_add, nano_add, propellant_add])
	if propellant_add != 0:
		hl_ism_addPropellantCapacity(propellant_add)
	if ammo_add != 0:
		addAmmoCapacity(ammo_add)
	if nano_add != 0:
		addDronesCapacity(nano_add)
	l("Modifying consumables multiplicatively")
	if ammo_multi != 1.0:
		var val = 0
		val = (massDriverAmmoMax * ammo_multi) - massDriverAmmoMax
		addAmmoCapacity(val)
	if nano_multi != 1.0:
		var val = 0
		val = (dronePartsMax * nano_multi) - dronePartsMax
		addDronesCapacity(val)
	if propellant_multi != 1.0:
		var val = 0
		val = (reactiveMassMax * propellant_multi) - reactiveMassMax
		hl_ism_addPropellantCapacity(val)
	nanodroneMagazine = float(getConfig("drones.capacity",0.0))
	massDriverMagazine = float(getConfig("ammo.capacity", 0.0))
	
	yield(CurrentGame.get_tree(),"physics_frame")
	clampConsumables()
	if isPlayerControlled():
		var cfg = shipConfig
		var state = CurrentGame.state.ship.config
		l("Ensuring crew correctness")
		var chash = cfg.hash()
		var shash = state.hash()
		if chash == shash:
			if "preferredCrew" in CurrentGame.state.ship.config:
				if CurrentGame.state.ship.config["preferredCrew"].size() > crew:
					CurrentGame.state.ship.config["preferredCrew"].resize(crew)
		
		
			var active = CurrentGame.getCurrentlyActiveCrewNames()
			if active.size() > crew:
				hl_ism_deactivateCrew(crew)
func temporaryCargoMass() -> float:
	var out = .temporaryCargoMass()
	out += mass_add
	return out

var nanoDeliveryPerSecond = {
	0.0: 20, 
	1000.0: 20, 
	5000.0: 100, 
	10000.0: 100, 
	20000.0: 100, 
	50000.0: 100
}

var availableNanoToDrawNow = 0.0
func hl_ism_handleNanoDelivery(delta):
	var ps = nanoDeliveryPerSecond.get(nanodroneMagazine, nanoDeliveryPerSecond[0.0])
	var current = availableNanoToDrawNow
	availableNanoToDrawNow = clamp(availableNanoToDrawNow + delta * ps, 0, ps)
	var diff = availableNanoToDrawNow - current
	if nano_speed_multi != 1.0:
		availableNanoToDrawNow += diff * (nano_speed_multi - 1.0)
	availableNanoToDrawNow += nano_speed_add

func handleAmmoDelivery(delta):
	if unrestrictedAmmoOutput:
		availableAmmoToDrawNow = 90000000000
	else:
		var currentDraw = availableAmmoToDrawNow
		.handleAmmoDelivery(delta)
		var diff = availableAmmoToDrawNow - currentDraw
		if ammo_speed_multi != 1.0:
			availableAmmoToDrawNow += diff * (ammo_speed_multi - 1.0)
		availableAmmoToDrawNow += ammo_speed_add
	
var ismPointers


var limitDroneOutput = true
var unrestrictedAmmoOutput = false
func drawDrones(kg, really = true):
	if limitDroneOutput:
		if availableNanoToDrawNow < kg:
			return 0
		else:
			if really:
				availableNanoToDrawNow -= kg
	return .drawDrones(kg, really)
var massNodeName = "InternalStorageMod_MassModifier"

func hl_ism_deactivateCrew(maximum):
	var count = 0
	for m in CurrentGame.getCurrentlyActiveCrewNames():
		if count < maximum:
			if CurrentGame.state.crew[m].get("active", true):
				count += 1
		else:
			if CurrentGame.state.crew[m].get("active", true):
				CurrentGame.state.crew[m]["active"] = false
	CurrentGame.emit_signal("employmentChanged")
func addAmmoCapacity(kg: float):
	var change = massDriverAmmoMax + kg
	if change < 0:
		kg += change
	.addAmmoCapacity(kg)

func addDronesCapacity(kg: float):
	var change = dronePartsMax + kg
	if change < 0:
		kg += change
	.addDronesCapacity(kg)

func hl_ism_addPropellantCapacity(kg: float):
	var change = reactiveMassMax + kg
	if change < 0:
		kg += change
	reactiveMassMax += kg
	if reactiveMass == 0:
		reactiveMass += kg

func _physics_process(delta):
	if not dead and limitDroneOutput:
		hl_ism_handleNanoDelivery(delta)
	
func hl_ism_UV():
	if ismPointers:
		limitDroneOutput = ismPointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_EQUIPMENT","limit_nanodrone_output")
		unrestrictedAmmoOutput = ismPointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_EQUIPMENT","unrestricted_ammo_output")



func l(text):
	if isPlayerControlled():
		ismPointers.l(text,"HevLib Ship Modification")

func hl_ism_init_vars():
	base_storage_type = processedCargoStorageType
	base_proc_storage = processedCargoCapacity
	base_crew_count = crew
	base_crew_morale = crewMoraleBonus
	base_emp_shielding = max(empShield, getConfig("shielding.emp", 0))
	base_ammo_storage = getConfig("ammo.capacity", max(massDriverAmmo, getConfig("ammo.initial", massDriverAmmo)))
	base_nano_storage = getConfig("drones.capacity", max(droneParts, getConfig("drones.initial", droneParts)))
	base_propellant = getConfig("fuel.capacity", max(reactiveMass, reactiveMassMax))
#	base_propellant = reactiveMassMax
#	base_ammo_storage = massDriverAmmoMax
#	base_nano_storage = dronePartsMax
#	base_emp_shielding = empShield
