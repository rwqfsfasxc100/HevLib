extends "res://ships/ship-ctrl.gd"

onready var base_proc_storage = processedCargoCapacity
onready var base_ammo_storage = massDriverAmmoMax
onready var base_nano_storage = dronePartsMax
onready var base_storage_type = processedCargoStorageType
onready var base_propellant = reactiveMassMax
onready var base_crew_count = crew
onready var base_crew_morale = crewMoraleBonus
onready var base_mass = mass

var storage_add = 0
var ammo_add = 0
var nano_add = 0
var multi = 1.0
var propellant_add = 0
var mass_add = 0

func _ready():
	l("Readying ship. Base storage of %s proc / %s ammo / %s nanodrones on storage type of %s" % [base_proc_storage, base_ammo_storage, base_nano_storage, base_storage_type])
	var file = File.new()
	file.open("user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/ships/processed_storage_mods.json",File.READ)
	var config_data = JSON.parse(file.get_as_text()).result
	file.close()
	
	var listings = {}
	for item in config_data:
		var listingSystemName = item.get("system","SYSTEM_MISSING_NAME")
		var listingStorageFlat = item.get("storage_flat",0)
		var listingStorageAmmo = item.get("storage_ammo",0)
		var listingStorageNano = item.get("storage_nanodrones",0)
		var listingStoragePropellant = item.get("storage_propellant",0)
		var listingStorageMulti = float(item.get("storage_multi_upper",1.0))/float(item.get("storage_multi_lower",1.0))
		var listingForceType = item.get("force_type","")
		var listingCrewCount = item.get("crew_count",0)
		var listingCrewMorale = item.get("crew_morale",0.0)
		var listingMass = float(item.get("mass",0.0))
		listings.merge({
			listingSystemName:{
				"storage_flat":listingStorageFlat,
				"storage_ammo":listingStorageAmmo,
				"storage_nano":listingStorageNano,
				"storage_multi":listingStorageMulti,
				"force_type":listingForceType,
				"storage_propellant":listingStoragePropellant,
				"crew_count":listingCrewCount,
				"crew_morale":listingCrewMorale,
				"mass":listingMass,
			}
		})
	var installed = DataFormat.__sift_dictionary(shipConfig,listings.keys())
	
	var modifyable_type = base_storage_type
	var modifyable_ammo = base_ammo_storage
	var modifyable_nano = base_nano_storage
	var modifyable_capacity = base_proc_storage
	var modifyable_crew_count = base_crew_count
	var modifyable_crew_morale = base_crew_morale
	
	for item in installed:
		var iddata = listings[item]
		for key in iddata:
			match key:
				"storage_flat":
					var val = iddata[key]
					storage_add += val
				"storage_ammo":
					var val = iddata[key]
					ammo_add += val
				"storage_nano":
					var val = iddata[key]
					nano_add += val
				"storage_multi":
					var val = iddata[key]
					multi *= float(val)
				"storage_propellant":
					var val = iddata[key]
					propellant_add += val
				"force_type":
					var val = iddata[key]
					modifyable_type = val
				"crew_count":
					var val = iddata[key]
					modifyable_crew_count += val
				"crew_morale":
					var val = iddata[key]
					modifyable_crew_morale += val
				"mass":
					var val = iddata[key]
					mass_add += val
				
	
	var modifyable_add_capacity = storage_add
	var modifyable_add_ammo = ammo_add
	var modifyable_add_nano = nano_add
	var modifyable_multi = multi
	var modifyable_propellant = propellant_add
	var modifyable_mass = float(mass_add)/1000.0
	
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
			l("Hold type isn't divided, multiplying addition of %s by 6 to new addition of %s" % [storage_add,modifyable_add_capacity])
		
	else:
		l("No desired hold type being set, skipping hold manipulation")
	
	
	processedCargoCapacity = int(float(modifyable_capacity) * modifyable_multi)
	l("Changing base hold size of %s by multipler %s. Results in new size of %s" % [modifyable_capacity,modifyable_multi,processedCargoCapacity])
	processedCargoCapacity += modifyable_add_capacity
	l("Adding storage bonus of %s. New size of %s" % [modifyable_add_capacity,processedCargoCapacity])
	
	
	l("Adding consumables: + %s ammo / + %s nanodrones / + %s propellant" % [modifyable_add_ammo, modifyable_add_nano, modifyable_propellant])
	
	massDriverAmmoMax += modifyable_add_ammo
	dronePartsMax += modifyable_add_nano
	reactiveMassMax += modifyable_propellant
	
	l("Making modificatins to crew. Crew count changed from %s to %s / crew morale changed from %s to %s" % [base_crew_count,modifyable_crew_count,base_crew_morale,modifyable_crew_morale])
	
	crew = modifyable_crew_count
	crewMoraleBonus = clamp(modifyable_crew_morale,-0.5,0.5)
	
	l("Ensuring crew correctness")
	if "preferredCrew" in shipConfig:
		if shipConfig["preferredCrew"].size() > crew:
			shipConfig["preferredCrew"].resize(crew)
	
	
	var active = getCurrentlyActiveCrewNames()
	if active.size() > crew:
		deactivateCrew(crew)
	if mass_add > 0:
		var new_mass = mass + modifyable_mass
		mass = new_mass
		l("Adding %s kg of mass. Base ship mass changing from %s to %s" % [mass_add,base_mass * 1000,new_mass * 1000])
	else:
		l("No additional mass needed, skipping")

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



var DataFormat = preload("res://HevLib/pointers/DataFormat.gd")

func l(text):
	if isPlayerControlled():
		Debug.l("HevLib Ship Modification: " + text)
