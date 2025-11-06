extends "res://ships/ship-ctrl.gd"

var base_proc_storage = 0
var base_ammo_storage = 0
var base_nano_storage = 0
var base_storage_type = 0
var base_propellant = 0
var base_crew_count = 0
var base_crew_morale = 0
var base_mass = 0
var base_emp_shielding = 0


var storage_add = 0
var ammo_add = 0
var nano_add = 0
var multi = 1.0
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
var emp_shieldingance = 0


var nanodroneMagazine = 0

func _ready():
	nanodroneMagazine = getConfig("drones.capacity")
	base_proc_storage = processedCargoCapacity
	base_ammo_storage = massDriverAmmoMax
	base_nano_storage = dronePartsMax
	base_storage_type = processedCargoStorageType
	base_propellant = reactiveMassMax
	base_crew_count = crew
	base_crew_morale = crewMoraleBonus
	base_mass = currentMass
	base_emp_shielding = empShield
	
	
	var has_made_change = false
	l("Readying ship. Base storage of %s proc / %s ammo / %s nanodrones on storage type of %s" % [base_proc_storage, base_ammo_storage, base_nano_storage, base_storage_type])
	var file = File.new()
	file.open("user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/ships/processed_storage_mods.json",File.READ)
	var config_data = JSON.parse(file.get_as_text()).result
	file.close()
	
	var listings = {}
	for item in config_data:
		var listingSystemName = item.get("system","SYSTEM_MISSING_NAME")
		var ls = {}
		
		var listingStorageFlat = item.get("storage_flat",0)
		if listingStorageFlat != 0.0:
			ls.merge({"storage_flat":listingStorageFlat})
		var listingStorageAmmo = item.get("storage_ammo",0)
		if listingStorageAmmo != 0.0:
			ls.merge({"storage_ammo":listingStorageAmmo})
		var listingStorageNano = item.get("storage_nanodrones",0.0)
		if listingStorageNano != 0.0:
			ls.merge({"storage_nano":listingStorageNano})
		var listingStoragePropellant = item.get("storage_propellant",0.0)
		if listingStoragePropellant != 0.0:
			ls.merge({"storage_propellant":listingStoragePropellant})
		var listingStorageMulti = float(item.get("storage_multi_upper",1.0))/float(item.get("storage_multi_lower",1.0))
		if listingStorageMulti != 1.0:
			ls.merge({"storage_multi":listingStorageMulti})
		var listingAmmoMulti = float(item.get("ammo_multi_upper",1.0))/float(item.get("ammo_multi_lower",1.0))
		if listingAmmoMulti != 1.0:
			ls.merge({"ammo_multi":listingAmmoMulti})
		var nanoMulti = float(item.get("nano_multi_upper",1.0))/float(item.get("nano_multi_lower",1.0))
		if nanoMulti != 1.0:
			ls.merge({"nano_multi":nanoMulti})
		var propellantMulti = float(item.get("propellant_multi_upper",1.0))/float(item.get("propellant_multi_lower",1.0))
		if propellantMulti != 1.0:
			ls.merge({"propellant_multi":propellantMulti})
		var massMulti = float(item.get("mass_multi_upper",1.0))/float(item.get("mass_multi_lower",1.0))
		if massMulti != 1.0:
			ls.merge({"mass_multi":massMulti})
		var listingForceType = item.get("force_type","")
		if listingForceType != "":
			ls.merge({"force_type":listingForceType})
		var listingCrewCount = item.get("crew_count",0)
		if listingCrewCount != 0.0:
			ls.merge({"crew_count":listingCrewCount})
		var listingCrewMorale = item.get("crew_morale",0.0)
		if listingCrewMorale != 0.0:
			ls.merge({"crew_morale":listingCrewMorale})
		var listingMass = float(item.get("mass",0.0))
		if listingMass != 0.0:
			ls.merge({"mass":listingMass})
		
		var listingCrewMassMod = float(item.get("mass_per_crew_member",0.0))
		if listingCrewMassMod != 0.0:
			ls.merge({"mass_per_crew_member":listingCrewMassMod})
		var listingOreMassMod = float(item.get("mass_per_tonne_of_processed_ore",0.0))
		if listingOreMassMod != 0.0:
			ls.merge({"mass_per_tonne_of_processed_ore":listingOreMassMod})
		var listingTotalAddedStorageMassMod = float(item.get("mass_per_tonne_total_storage_added",0.0))
		if listingTotalAddedStorageMassMod != 0.0:
			ls.merge({"mass_per_tonne_total_storage_added":listingTotalAddedStorageMassMod})
		var listingAmmoSpeed = float(item.get("ammo_speed_add",0.0))
		if listingAmmoSpeed != 0.0:
			ls.merge({"ammo_speed_add":listingAmmoSpeed})
		var listingNanoSpeed = float(item.get("nano_speed_add",0.0))
		if listingNanoSpeed != 0.0:
			ls.merge({"nano_speed_add":listingNanoSpeed})
		var listingAmmoSpeedMulti = float(item.get("ammo_speed_multi_upper",1.0))/float(item.get("ammo_speed_multi_lower",1.0))
		if listingAmmoSpeedMulti != 1.0:
			ls.merge({"ammo_speed_multi":listingAmmoSpeedMulti})
		var listingNanoSpeedMulti = float(item.get("nano_speed_multi_upper",1.0))/float(item.get("nano_speed_multi_lower",1.0))
		if listingNanoSpeedMulti != 1.0:
			ls.merge({"nano_speed_multi":listingNanoSpeedMulti})
		var listingEMP = int(item.get("emp_shielding",0))
		if listingEMP != 0:
			ls.merge({"emp_shielding":listingEMP})
		
		listings.merge({
			listingSystemName:ls
		})
	var skip_keys = ["damage"]
	
	var nf_config = {}
	for obj in shipConfig.keys():
		if obj in skip_keys:
			pass
		else:
			nf_config.merge({obj:shipConfig[obj]})
	
	var installed = DataFormat.__sift_dictionary(nf_config,listings.keys())
	
	var modifyable_type = base_storage_type
	var modifyable_ammo = base_ammo_storage
	var modifyable_nano = base_nano_storage
	var modifyable_capacity = base_proc_storage
	var modifyable_crew_count = base_crew_count
	var modifyable_crew_morale = base_crew_morale
	
	var total_added_capacity = 0
	
	for item in installed:
		var iddata = listings[item]
		for key in iddata:
			var val = iddata[key]
			match key:
				"storage_flat":
					storage_add += val
					total_added_capacity += val
					has_made_change = true
				"storage_ammo":
					ammo_add += val
					total_added_capacity += val
					has_made_change = true
				"storage_nano":
					nano_add += val
					total_added_capacity += val
					has_made_change = true
				"storage_multi":
					multi *= float(val)
					has_made_change = true
				"ammo_multi":
					ammo_multi *= float(val)
					has_made_change = true
				"nano_multi":
					nano_multi *= float(val)
					has_made_change = true
				"propellant_multi":
					propellant_multi *= float(val)
					has_made_change = true
				"mass_multi":
					mass_multi *= float(val)
					has_made_change = true
				"storage_propellant":
					propellant_add += val
					total_added_capacity += val
					has_made_change = true
				"force_type":
					modifyable_type = val
					has_made_change = true
				"crew_count":
					modifyable_crew_count += val
					has_made_change = true
				"crew_morale":
					modifyable_crew_morale += val
					has_made_change = true
				"mass":
					mass_add += val
					has_made_change = true
				"mass_per_crew_member":
					mass_per_crew += val
					has_made_change = true
				"mass_per_tonne_of_processed_ore":
					mass_per_processed_tonne += val
					has_made_change = true
				"mass_per_tonne_total_storage_added":
					mass_per_tonne_total_storage_added += val
					has_made_change = true
				"ammo_speed_add":
					ammo_speed_add += val
					has_made_change = true
				"nano_speed_add":
					nano_speed_add += val
					has_made_change = true
				"ammo_speed_multi":
					ammo_speed_multi *= val
					has_made_change = true
				"nano_speed_multi":
					nano_speed_multi *= val
					has_made_change = true
				"emp_shielding":
					emp_shieldingance += val
					has_made_change = true
	
	
	if modifyable_crew_count > 0:
		l("Adding mass @ %s kg for each of %s crew members" % [mass_per_crew,modifyable_crew_count])
		mass_add += (modifyable_crew_count * mass_per_crew)
	
	var modifyable_add_capacity = storage_add
	var modifyable_add_ammo = ammo_add
	var modifyable_add_nano = nano_add
	var modifyable_multi = multi
	var modifyable_propellant = propellant_add
	
	
	
	if modifyable_type != "":
		l("Setting desired hold type")
		if modifyable_type != base_storage_type:
			l("Transforming hold type from %s to %s" % [base_storage_type, modifyable_type])
			if modifyable_type != "divided":
				
				modifyable_capacity = base_proc_storage * 6
			else:
				modifyable_capacity = base_proc_storage / 6
			processedCargoStorageType = modifyable_type
			l("Hold transformation resulted in storage capacity changing from %s to %s" % [base_proc_storage, modifyable_capacity])
		else:
			l("Hold type isn't changed (is this equipment in the right slot?)")
		if modifyable_type != "divided":
			modifyable_add_capacity = storage_add * 6
			mass_per_processed_tonne = mass_per_processed_tonne * 6
			l("Hold type isn't divided, multiplying addition of %s by 6 to new addition of %s" % [storage_add,modifyable_add_capacity])
		
	else:
		l("No desired hold type being set, skipping hold manipulation")
	
	
	processedCargoCapacity = int(float(modifyable_capacity) * modifyable_multi)
	l("Changing base hold size of %s by multiplier %s. Results in new size of %s" % [modifyable_capacity,modifyable_multi,processedCargoCapacity])
	processedCargoCapacity += modifyable_add_capacity
	l("Adding storage bonus of %s. New size of %s" % [modifyable_add_capacity,processedCargoCapacity])
	
	processedCargoCapacity = clamp(processedCargoCapacity,0,INF)
	if multi != 1.0:
		var change = base_proc_storage - processedCargoCapacity
		total_added_capacity += change
	
	if mass_per_processed_tonne != 0:
		l("Adding mass @ %s kg for every tonne of processed capacity" % mass_per_processed_tonne)
		var change = ((float(processedCargoCapacity)/1000.0) * mass_per_processed_tonne)
		mass_add += change
	
	l("Modifying consumables multiplicatively")
	if ammo_multi != 1.0:
		modifyable_add_ammo += ((base_ammo_storage + modifyable_add_ammo) * ammo_multi) - (base_ammo_storage + modifyable_add_ammo) 
	if nano_multi != 1.0:
		modifyable_add_nano += (base_nano_storage + modifyable_add_nano) - ((base_nano_storage + modifyable_add_nano) * nano_multi)
	if propellant_multi != 1.0:
		propellant_add += (base_nano_storage + propellant_add) - ((base_propellant + propellant_add) * propellant_multi)
	if mass_multi != 1.0:
		mass_add += (mass + mass_add) - ((mass * mass_add) * mass_multi)
	
	l("Adding consumables: + %s ammo / + %s nanodrones / + %s propellant" % [modifyable_add_ammo, modifyable_add_nano, modifyable_propellant])
	
	extra_ammo += clamp(modifyable_add_ammo,0,INF)
	extra_nano += clamp(modifyable_add_nano,0,INF)
	extra_propellant += clamp(modifyable_propellant,0,INF)
	
	if mass_per_tonne_total_storage_added != 0:
		l("Changing mass by %s kg for every tonne of total storage changed by" % total_added_capacity)
		var change = ((float(total_added_capacity) /1000.0) * mass_per_tonne_total_storage_added)
		mass_add += change
	
	
	l("Making modificatins to crew. Crew count changed from %s to %s / crew morale changed from %s to %s" % [base_crew_count,modifyable_crew_count,base_crew_morale,modifyable_crew_morale])
	
	crew = clamp(modifyable_crew_count,0,INF)
	crewMoraleBonus = clamp(modifyable_crew_morale,-0.5,0.5)
	
	var cfg = shipConfig
	var state = CurrentGame.state.ship.config
	
	var chash = cfg.hash()
	var shash = state.hash()
	
	empShield += emp_shieldingance
	
	var modifyable_mass = float(mass_add)/1000.0
	
	
	
	l("Ensuring crew correctness")
	if chash == shash:
		if "preferredCrew" in CurrentGame.state.ship.config:
			if CurrentGame.state.ship.config["preferredCrew"].size() > crew:
				CurrentGame.state.ship.config["preferredCrew"].resize(crew)
	
	
		var active = getCurrentlyActiveCrewNames()
		if active.size() > crew:
			deactivateCrew(crew)
	
	if has_made_change:
		var vmass = Node2D.new()
		vmass.set_script(load("res://HevLib/scenes/equipment/var_nodes/add_mass.gd"))
		vmass.mass = mass_add
		vmass.name = massNodeName
		add_child(vmass)
		call_deferred("move_child",vmass,get_child_count())
	
	l("Adding %s kg of mass. Base ship mass changing from %s to %s" % [mass_add,base_mass * 1000,shipInitialMass * 1000])

var extra_ammo = 0
var extra_nano = 0
var extra_propellant = 0

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
	

const ismCFGD = preload("res://HevLib/pointers/ConfigDriver.gd")
func drawAmmo(kg,really = true):
	if availableAmmoToDrawNow < kg:
		return 0
	if extra_ammo > 0:
		availableAmmoToDrawNow -= kg
		if really:
			if extra_ammo >= kg:
				extra_ammo -= kg
			elif extra_ammo + massDriverAmmo >= kg:
				var take = kg - extra_ammo
				extra_ammo = 0.0
				massDriverAmmo -= take
			else:
				massDriverAmmo -= kg
		return kg
	else:
		return .drawAmmo(kg,really)

func drawDrones(kg, really = true):
	if ismCFGD.__get_value("HevLib","HEVLIB_CONFIG_SECTION_EQUIPMENT","limit_nanodrone_output"):
		if availableNanoToDrawNow < kg:
			return 0
		else:
			if really:
				availableNanoToDrawNow -= kg
	if extra_nano > 0:
		if really:
			if extra_nano >= kg:
				extra_nano -= kg
			elif extra_nano + droneParts >= kg:
				var take = kg - extra_nano
				extra_nano = 0.0
				droneParts -= take
			else:
				droneParts -= kg
		return kg
	else:
		return .drawDrones(kg,really)

func drawReactiveMass(kg, really = true):
	if extra_propellant > 0:
		if really:
			if extra_propellant >= kg:
				extra_propellant -= kg
			elif extra_propellant + reactiveMass >= kg:
				var take = kg - extra_propellant
				extra_propellant = 0.0
				reactiveMass -= take
			else:
				reactiveMass -= kg
		return kg
	else:
		return .drawReactiveMass(kg,really)

func sensorGet(sensor):
	match sensor:
		"ammo":
			return .sensorGet(sensor) + extra_ammo
		"drones":
			return .sensorGet(sensor) + extra_nano
		"fuel":
			return .sensorGet(sensor) + extra_propellant
		_:
			return .sensorGet(sensor)

var massNodeName = "InternalStorageMod_MassModifier"

func deactivateCrew(maximum):
	var count = 0
	for m in CurrentGame.state.crew:
		if count < maximum:
			if CurrentGame.state.crew[m].get("active", true):
				count += 1
		else:
			if CurrentGame.state.crew[m].get("active", true):
				CurrentGame.state.crew[m]["active"] = false


func getCurrentlyActiveCrewNames():
	var pf = []
	for m in CurrentGame.state.crew:
		if CurrentGame.state.crew[m].get("active", true):
			pf.append(m)
	return pf

func _physics_process(delta):
	if not dead and ismCFGD.__get_value("HevLib","HEVLIB_CONFIG_SECTION_EQUIPMENT","limit_nanodrone_output"):
		handleNanoDelivery(delta)

var DataFormat = preload("res://HevLib/pointers/DataFormat.gd")

func l(text):
	if isPlayerControlled():
		Debug.l("HevLib Ship Modification: " + text)
