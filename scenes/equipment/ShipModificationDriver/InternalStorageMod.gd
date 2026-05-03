extends "res://ships/ship-ctrl.gd"

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

var system_name_registers = []
var add_systems = []


var cfgs_to_ignore = ["currentCargo","currentCargoBy","currentCargoComposition","damage","juryRig","preferredCrew","processedCargo","remoteCargo","tuning"]

var current = []
var installed = []




var mineral_trace_length = 6

func _enter_tree():
	var file = File.new()
	ismPointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	ismPointers.ConfigDriver.__establish_connection("hl_ism_UV",self)
	file.open("user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/ships/processed_storage_mods.json",File.READ)
	listings = JSON.parse(file.get_as_text()).result
	file.close()
	
	file.open("user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/ships/processed_storage_systems.json",File.READ)
	var sysNames = JSON.parse(file.get_as_text()).result
	file.close()
	configMutex.lock()
	current = ismPointers.DataFormat.__sift_ship_config(shipConfig.duplicate(true),sysNames,cfgs_to_ignore)
	configMutex.unlock()
	for i in current:
		installed.append(i.split(".")[i.split(".").size() - 1])
	
	
	
	init_vars()
	base_mass = mass * 1000
#	base_mass = currentMass
	nanodroneMagazine = getConfig("drones.capacity")
#	CurrentGame.setStory("dd.story.interplanetary",10)
	l("Readying ship. Base storage of %s proc / %s ammo / %s nanodrones on storage type of %s" % [base_proc_storage, base_ammo_storage, base_nano_storage, base_storage_type])
	
	
	
	
	
	var modifyable_type = base_storage_type
	var modifyable_capacity = base_proc_storage
	var modifyable_crew_count = base_crew_count
	var modifyable_crew_morale = base_crew_morale
	
	var total_added_capacity = 0
	
	var individual_capacity_changes = []
	
	for item in installed:
		var iddata = listings[item]
		var minimum_ammo_utilization_for_reduction = iddata.get("minimum_ammo_utilization_for_reduction",0.0)
		var minimum_nano_utilization_for_reduction = iddata.get("minimum_nano_utilization_for_reduction",0.0)
		var minimum_propellant_utilization_for_reduction = iddata.get("minimum_propellant_utilization_for_reduction",0.0)
		
		var current_ammo_amt = massDriverAmmoMax
		var current_nano_amt = dronePartsMax
		var current_propellant_amt = reactiveMassMax
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
					if (dname and dname != "") and ((not dname in system_name_registers) or mv):
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
						system_name_registers.append(dname)
						add_systems.append(o)
				"storage_multi":
					val = float(max(val,0.001))
					storage_multi *= val
					this_storage_multi *= val
				"ammo_multi":
					if val < 1.0 and minimum_ammo_utilization_for_reduction > 0.0:
						var ch = ((minimum_ammo_utilization_for_reduction * ammo_limit) - current_ammo_amt) / ammo_limit
						val = clamp(val + ch,val,1.0)
					val = float(max(val,0.001))
					ammo_multi *= val
					this_ammo_multi *= val
				"nano_multi":
					if val < 1.0 and minimum_nano_utilization_for_reduction > 0.0:
						var ch = ((minimum_nano_utilization_for_reduction * nano_limit) - current_nano_amt) / nano_limit
						val = clamp(val + ch,val,1.0)
					val = float(max(val,0.001))
					nano_multi *= val
					this_nano_multi *= val
				"propellant_multi":
					if val < 1.0 and minimum_propellant_utilization_for_reduction > 0.0:
						var ch = ((minimum_propellant_utilization_for_reduction * propellant_limit) - current_propellant_amt) / propellant_limit
						val = clamp(val + ch,val,1.0)
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
			modifyable_capacity = base_proc_storage * mineral_trace_length
		else:
			modifyable_capacity = base_proc_storage / mineral_trace_length
		processedCargoStorageType = modifyable_type
		l("Hold transformation resulted in storage capacity changing from %s to %s" % [base_proc_storage, modifyable_capacity])
	else:
		l("Hold type isn't changed (is this equipment in the right slot?)")
	if modifyable_type != "divided":
		storage_add = storage_add * mineral_trace_length
		l("Hold type isn't divided, multiplying addition of %s by 6 to new addition of %s" % [storage_add,storage_add])
	else:
		mass_per_processed_tonne = mass_per_processed_tonne * mineral_trace_length
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
	
	for a in range(add_systems.size()):
		var i = add_systems[a]
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
	
	file.open("user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/ships/drone_delivery_speed.json",File.READ)
	var droneData = JSON.parse(file.get_as_text()).result
	file.close()
	for amnt in droneData:
		nanoDeliveryPerSecond[int(amnt)] = droneData[amnt]
	
#	yield(CurrentGame.get_tree(),"physics_frame")
func _ready():
	l("Adding consumables: + %s ammo / + %s nanodrones / + %s propellant" % [ammo_add, nano_add, propellant_add])
	if propellant_add != 0:
		addPropellantCapacity(propellant_add)
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
		addPropellantCapacity(val)
	
	
	
	yield(CurrentGame.get_tree(),"physics_frame")
#	clampConsumables()
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
				deactivateCrew(crew)
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
func handleNanoDelivery(delta):
	var ps = nanoDeliveryPerSecond.get(nanodroneMagazine, nanoDeliveryPerSecond[0.0])
	availableNanoToDrawNow = clamp(availableNanoToDrawNow + delta * ps, 0, ps)
	if nano_speed_multi != 1.0:
		availableNanoToDrawNow *= nano_speed_multi
	availableNanoToDrawNow += nano_speed_add

func handleAmmoDelivery(delta):
	.handleAmmoDelivery(delta)
	if ammo_speed_multi != 1.0:
		availableAmmoToDrawNow *= ammo_speed_multi
	availableAmmoToDrawNow += ammo_speed_add
	
var ismPointers
#const ismCFGD = preload("res://HevLib/pointers/ConfigDriver.gd")
var limitDroneOutput = true
func drawDrones(kg, really = true):
	if limitDroneOutput:
		if availableNanoToDrawNow < kg:
			return 0
		else:
			if really:
				availableNanoToDrawNow -= kg
	return .drawDrones(kg, really)
var massNodeName = "InternalStorageMod_MassModifier"

func deactivateCrew(maximum):
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

func addPropellantCapacity(kg: float):
	var change = reactiveMassMax + kg
	if change < 0:
		kg += change
	reactiveMassMax += kg
	if reactiveMass == 0:
		reactiveMass += kg

func _physics_process(delta):
	if not dead and limitDroneOutput:
		handleNanoDelivery(delta)
	
func hl_ism_UV():
	if ismPointers:
		limitDroneOutput = ismPointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_EQUIPMENT","limit_nanodrone_output")


#var DataFormat = preload("res://HevLib/pointers/DataFormat.gd")

func l(text):
	if isPlayerControlled():
		Debug.l("HevLib Ship Modification: " + text)

func init_vars():
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
