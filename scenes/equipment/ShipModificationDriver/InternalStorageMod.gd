extends "res://ships/ship-ctrl.gd"

var base_proc_storage = 0
var base_ammo_storage = 0
var base_nano_storage = 0
onready var base_storage_type = processedCargoStorageType
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
var emp_shielding = 0
var emp_scale_multi = 1.0

var nanodroneMagazine = 0
var listings = {}
var hevlib_config_data = {}

var system_name_registers = []
var add_systems = []

func _enter_tree():
	ismPointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	var file = File.new()
	file.open("user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/ships/processed_storage_mods.json",File.READ)
	hevlib_config_data = JSON.parse(file.get_as_text()).result
	file.close()
	
	
	for item in hevlib_config_data:
		var listingSystemName = item.get("system","SYSTEM_MISSING_NAME")
		var ls = {}
		
		for data in item:
			match data:
				"storage_flat":
					ls.merge({"storage_flat":item.get("storage_flat")})
				"show_modifier_system":
					ls.merge({"show_modifier_system":item.get("show_modifier_system")})
				"storage_ammo","storage_ammunition":
					ls.merge({"storage_ammo":item.get("storage_ammo",item.get("storage_ammunition"))})
				"storage_nano","storage_nanodrones":
					ls.merge({"storage_nano":item.get("storage_nano",item.get("storage_nanodrones"))})
				"storage_propellant","storage_prop":
					ls.merge({"storage_propellant":item.get("storage_propellant",item.get("storage_prop"))})
				"force_type":
					ls.merge({"force_type":item.get("force_type")})
				"crew_count":
					ls.merge({"crew_count":item.get("crew_count")})
				"crew_morale":
					ls.merge({"crew_morale":item.get("crew_morale")})
				"mass":
					ls.merge({"mass":item.get("mass")})
				"mass_per_crew_member":
					ls.merge({"mass_per_crew_member":item.get("mass_per_crew_member")})
				"mass_per_tonne_of_processed_ore":
					ls.merge({"mass_per_tonne_of_processed_ore":item.get("mass_per_tonne_of_processed_ore")})
				"mass_per_tonne_total_storage_added":
					ls.merge({"mass_per_tonne_total_storage_added":item.get("mass_per_tonne_total_storage_added")})
				"ammo_speed_add":
					ls.merge({"ammo_speed_add":item.get("ammo_speed_add")})
				"nano_speed_add":
					ls.merge({"nano_speed_add":item.get("nano_speed_add")})
				"emp_shielding":
					ls.merge({"emp_shielding":item.get("emp_shielding")})
		
		
		
		
		var dname = item.get("display_system",{})
		if dname.keys().size() > 0:
			ls.merge({"display_system":dname})
		
		
		
		
		
		
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
		
		
		var listingAmmoSpeedMulti = float(item.get("ammo_speed_multi_upper",1.0))/float(item.get("ammo_speed_multi_lower",1.0))
		if listingAmmoSpeedMulti != 1.0:
			ls.merge({"ammo_speed_multi":listingAmmoSpeedMulti})
		var listingNanoSpeedMulti = float(item.get("nano_speed_multi_upper",1.0))/float(item.get("nano_speed_multi_lower",1.0))
		if listingNanoSpeedMulti != 1.0:
			ls.merge({"nano_speed_multi":listingNanoSpeedMulti})
		
		var listingEmpScaleMulti = float(item.get("emp_scale_multi_upper",1.0))/float(item.get("emp_scale_multi_lower",1.0))
		if listingEmpScaleMulti != 1.0:
			ls.merge({"emp_scale_multi":listingEmpScaleMulti})
		
		
		listings.merge({
			listingSystemName:ls
		})
	configMutex.lock()
	current = ismPointers.DataFormat.__sift_ship_config(shipConfig.duplicate(true),listings.keys(),cfgs_to_ignore)
	configMutex.unlock()
	for i in current:
		installed.append(i.split(".")[i.split(".").size() - 1])

var cfgs_to_ignore = ["currentCargo","currentCargoBy","currentCargoComposition","damage","juryRig","preferredCrew","processedCargo","remoteCargo","tuning"]

var current = []
var installed = []
func _ready():
#	if not setup:
#		yield(self,"setup")
	var file = File.new()
	init_vars()
	base_mass = currentMass
	nanodroneMagazine = getConfig("drones.capacity")
	if isPlayerControlled():
		
		
#		CurrentGame.setStory("dd.story.interplanetary",10)
		var has_made_change = false
		l("Readying ship. Base storage of %s proc / %s ammo / %s nanodrones on storage type of %s" % [base_proc_storage, base_ammo_storage, base_nano_storage, base_storage_type])
		
		
		
		
		
		var modifyable_type = base_storage_type
		var modifyable_capacity = base_proc_storage
		var modifyable_crew_count = base_crew_count
		var modifyable_crew_morale = base_crew_morale
		
		var total_added_capacity = 0
		
		for item in installed:
			var iddata = listings[item]
			if iddata.get("show_modifier_system",true):
				has_made_change = true
			for key in iddata:
				var val = iddata[key]
				match key:
					"storage_flat":
						storage_add += val
						total_added_capacity += val
					"storage_ammo":
						ammo_add += val
						total_added_capacity += val
					"storage_nano":
						nano_add += val
						total_added_capacity += val
					"storage_multi":
						multi *= float(val)
					"ammo_multi":
						ammo_multi *= float(val)
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
					"nano_multi":
						nano_multi *= float(val)
					"propellant_multi":
						propellant_multi *= float(val)
					"emp_scale_multi":
						emp_scale_multi *= float(val)
					"mass_multi":
						mass_multi *= float(val)
					"storage_propellant":
						propellant_add += val
						total_added_capacity += val
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
		
		
		if modifyable_crew_count > 0:
			l("Adding mass @ %s kg for each of %s crew members" % [mass_per_crew,modifyable_crew_count])
			mass_add += (modifyable_crew_count * mass_per_crew)
		
		
		
		
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
				storage_add = storage_add * 6
				mass_per_processed_tonne = mass_per_processed_tonne * 6
				l("Hold type isn't divided, multiplying addition of %s by 6 to new addition of %s" % [storage_add,storage_add])
			
		else:
			l("No desired hold type being set, skipping hold manipulation")
		
		
		processedCargoCapacity = int(float(modifyable_capacity) * multi)
		l("Changing base hold size of %s by multiplier %s. Results in new size of %s" % [modifyable_capacity,multi,processedCargoCapacity])
		processedCargoCapacity += storage_add
		l("Adding storage bonus of %s. New size of %s" % [storage_add,processedCargoCapacity])
		
		processedCargoCapacity = clamp(processedCargoCapacity,0,INF)
		if multi != 1.0:
			var change = base_proc_storage - processedCargoCapacity
			total_added_capacity += change
		if ammo_multi != 1.0:
			var change = base_ammo_storage - massDriverAmmoMax
			total_added_capacity += change
		if nano_multi != 1.0:
			var change = base_nano_storage - dronePartsMax
			total_added_capacity += change
		if propellant_multi != 1.0:
			var change = base_propellant - reactiveMassMax
			total_added_capacity += change
		
		if mass_per_processed_tonne != 0:
			l("Adding mass @ %s kg for every tonne of processed capacity" % mass_per_processed_tonne)
			var change = ((float(processedCargoCapacity)/1000.0) * mass_per_processed_tonne)
			mass_add += change
		
		l("Modifying consumables multiplicatively")
		if ammo_multi != 1.0:
			var val = 0
			val = ((base_ammo_storage + ammo_add) * ammo_multi) - (base_ammo_storage + ammo_add)
			ammo_add += val
		if nano_multi != 1.0:
			var val = 0
			val = ((base_nano_storage + nano_add) * nano_multi) - (base_nano_storage + nano_add)
			nano_add += val
		if propellant_multi != 1.0:
			var val = 0
			val = ((base_propellant + propellant_add) * propellant_multi) - (base_propellant + propellant_add)
			propellant_add += val
		if mass_multi != 1.0:
			var val = 0
			val = ((mass * mass_add) * mass_multi) - (mass + mass_add)
			mass_add += val
		
		l("Adding consumables: + %s ammo / + %s nanodrones / + %s propellant" % [ammo_add, nano_add, propellant_add])
		var ammo_min = 0
		var nano_min = 0
		if massDriverAmmoMax:
			ammo_min = 100
		if dronePartsMax:
			nano_min = 100
		
		addPropellantCapacity(propellant_add)
		addAmmoCapacity(ammo_add)
		addDronesCapacity(nano_add)
		
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
		
		empShield += emp_shielding
		
		var modifyable_mass = float(mass_add)/1000.0
		
		
		
		l("Ensuring crew correctness")
		if chash == shash:
			if "preferredCrew" in CurrentGame.state.ship.config:
				if CurrentGame.state.ship.config["preferredCrew"].size() > crew:
					CurrentGame.state.ship.config["preferredCrew"].resize(crew)
		
		
			var active = getCurrentlyActiveCrewNames()
			if active.size() > crew:
				deactivateCrew(crew)
		
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
		
		if has_made_change:
			var vmass = Node2D.new()
			vmass.set_script(load("res://HevLib/scenes/equipment/var_nodes/add_mass.gd"))
			vmass.mass = mass_add
			vmass.name = massNodeName
			add_child(vmass)
			call_deferred("move_child",vmass,get_child_count())
			l("Adding %s kg of mass. Base ship mass changing from %s to %s" % [mass_add,base_mass * 1000,shipInitialMass * 1000])
		
		file.open("user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/ships/drone_delivery_speed.json",File.READ)
		var droneData = JSON.parse(file.get_as_text()).result
		file.close()
		for amnt in droneData:
			nanoDeliveryPerSecond[int(amnt)] = droneData[amnt]
		
		clampConsumables()

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
func drawDrones(kg, really = true):
	if ismPointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_EQUIPMENT","limit_nanodrone_output"):
		if availableNanoToDrawNow < kg:
			return 0
		else:
			if really:
				availableNanoToDrawNow -= kg
	return .drawDrones(kg, really)
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


func getCurrentlyActiveCrewNames():
	var pf = []
	for m in CurrentGame.state.crew:
		if CurrentGame.state.crew[m].get("active", true):
			pf.append(m)
	return pf

func _physics_process(delta):
	if not dead and ismPointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_EQUIPMENT","limit_nanodrone_output"):
		handleNanoDelivery(delta)
	

#var DataFormat = preload("res://HevLib/pointers/DataFormat.gd")

func l(text):
	if isPlayerControlled():
		Debug.l("HevLib Ship Modification: " + text)

func init_vars():
	base_proc_storage = processedCargoCapacity
	base_ammo_storage = massDriverAmmoMax
	base_nano_storage = dronePartsMax
	base_storage_type = processedCargoStorageType
	base_propellant = reactiveMassMax
	base_crew_count = crew
	base_crew_morale = crewMoraleBonus
	base_emp_shielding = empShield
