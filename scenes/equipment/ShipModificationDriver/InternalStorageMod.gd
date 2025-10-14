extends "res://ships/ship-ctrl.gd"

onready var base_proc_storage = processedCargoCapacity
onready var base_ammo_storage = massDriverAmmoMax
onready var base_nano_storage = dronePartsMax
onready var base_storage_type = processedCargoStorageType
onready var base_propellant = reactiveMassMax
onready var base_crew_count = crew
onready var base_crew_morale = crewMoraleBonus
onready var base_mass = currentMass

var storage_add = 0
var ammo_add = 0
var nano_add = 0
var multi = 1.0
var propellant_add = 0
var mass_add = 0
var mass_per_crew = 0
var mass_per_processed_tonne = 0
var mass_per_tonne_total_storage_added = 0

func _ready():
	if isPlayerControlled():
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
				ls.merge({"mass_per_tonne_total_storage_added":listingOreMassMod})
			
			
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
				match key:
					"storage_flat":
						var val = iddata[key]
						storage_add += val
						total_added_capacity += val
					"storage_ammo":
						var val = iddata[key]
						ammo_add += val
						total_added_capacity += val
					"storage_nano":
						var val = iddata[key]
						nano_add += val
						total_added_capacity += val
					"storage_multi":
						var val = iddata[key]
						multi *= float(val)
					"storage_propellant":
						var val = iddata[key]
						propellant_add += val
						total_added_capacity += val
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
					"mass_per_crew_member":
						var val = iddata[key]
						mass_per_crew += val
					"mass_per_tonne_of_processed_ore":
						var val = iddata[key]
						mass_per_processed_tonne += val
					"mass_per_tonne_total_storage_added":
						var val = iddata[key]
						mass_per_tonne_total_storage_added += val
		
		
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
		
		
		if multi != 1.0:
			var change = base_proc_storage - processedCargoCapacity
			total_added_capacity += change
		
		if mass_per_processed_tonne > 0:
			l("Adding mass @ %s kg for every tonne of processed capacity" % mass_per_processed_tonne)
			mass_add += ((float(processedCargoCapacity)/1000.0) * mass_per_processed_tonne)
		
		
		l("Adding consumables: + %s ammo / + %s nanodrones / + %s propellant" % [modifyable_add_ammo, modifyable_add_nano, modifyable_propellant])
		
		massDriverAmmoMax += modifyable_add_ammo
		dronePartsMax += modifyable_add_nano
		reactiveMassMax += modifyable_propellant
		
		if mass_per_tonne_total_storage_added != 0:
			l("Changing mass by %s kg for every tonne of total storage changed by" % total_added_capacity)
			mass_add += ((float(total_added_capacity) /1000.0) * mass_per_tonne_total_storage_added)
		
		
		l("Making modificatins to crew. Crew count changed from %s to %s / crew morale changed from %s to %s" % [base_crew_count,modifyable_crew_count,base_crew_morale,modifyable_crew_morale])
		if modifyable_crew_count < 0:
			crew = 0
		else:
			crew = modifyable_crew_count
		crewMoraleBonus = clamp(modifyable_crew_morale,-0.5,0.5)
		
		var cfg = shipConfig
		var state = CurrentGame.state.ship.config
		
		var chash = cfg.hash()
		var shash = state.hash()
		
		
		var modifyable_mass = float(mass_add)/1000.0
		
		
		
		l("Ensuring crew correctness")
		if chash == shash:
			if "preferredCrew" in CurrentGame.state.ship.config:
				if CurrentGame.state.ship.config["preferredCrew"].size() > crew:
					CurrentGame.state.ship.config["preferredCrew"].resize(crew)
		
		
			var active = getCurrentlyActiveCrewNames()
			if active.size() > crew:
				deactivateCrew(crew)
		var massNodeName = "InternalStorageMod_MassModifier"
		var vn = get_node_or_null(massNodeName)
		if vn != null:
			vn.mass = mass_add
		else:
			var vmass = Node2D.new()
			vmass.set_script(load("res://HevLib/scenes/equipment/var_nodes/add_mass.gd"))
			vmass.mass = mass_add
			vmass.name = massNodeName
			add_child(vmass)
		l("Adding %s kg of mass. Base ship mass changing from %s to %s" % [mass_add,base_mass * 1000,shipInitialMass * 1000])

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
