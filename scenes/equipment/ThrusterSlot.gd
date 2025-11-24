extends "res://ships/modules/ThrusterSlot.gd"

var auxslot_save_path = "user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/power/AuxSlot.json"

var file = File.new()
var mpdg = load("res://ships/modules/AuxMpd.tscn")
var smes = load("res://ships/modules/AuxSmes.tscn")
var thruster = load("res://sfx/thruster.tscn")
var exhaust = load("res://sfx/exhaust.tscn")

const torch_base_scale = Vector2(0.939,1.395)
const rcs_base_scale = Vector2(0.2,0.2)
const thruster_base_pos = Vector2(0,-3)

func _ready():
	file.open(auxslot_save_path,File.READ)
	var datastore = JSON.parse(file.get_as_text()).result
	file.close()
	var slotType = type.split(".")[0]
	var currentInstall = ship.getConfig(type)
	if slotType in datastore:
		for data in datastore[slotType]:
			var aux_path = data.get("path","")
			var aux_type = data.get("type","MPDG").to_upper()
			var item
			var sys = data.get("system","SYSTEM_NAME_MISSING")
			if sys == currentInstall:
				
				match aux_type:
					"MPDG":
						item = mpdg.instance()
					"SMES":
						item = smes.instance()
					"THRUSTER","RCS","TORCH","MAIN_PROPULSION":
						item = thruster.instance()
				
				
				item.name = sys
				
				item.repairReplacementPrice = data.get("price",30000)
				item.repairReplacementTime = data.get("repair_time",1)
				item.repairFixPrice = data.get("fix_price",5000)
				item.repairFixTime = data.get("fix_time",4)
				item.command = data.get("command","")
				item.powerDraw = data.get("power_draw",50000.0)
				item.systemName = sys
				item.mass = data.get("mass",0)
				
				
				match aux_type:
					"MPDG":
						
						item.thermal = data.get("thermal",500000.0)
						item.windupTime = data.get("windup_time",2)
						
						item.powerSupply = data.get("power_supply",350000.0)
						
					"SMES":
						
						item.capacitorRatio = data.get("capacitor_ratio",0.9)
						item.capacity = data.get("capacity",600000.0)
						item.switchTime = data.get("switch_time",2)
						
						item.powerSupply = data.get("power_supply",200000.0)
						item.repairReplacementPrice = data.get("price",40000)
						item.repairReplacementTime = data.get("repair_time",1)
						item.repairFixPrice = data.get("fix_price",25000)
						item.repairFixTime = data.get("fix_time",4)

						
					"THRUSTER","RCS","TORCH","MAIN_PROPULSION":
						
						item.priorityOffset = data.get("priority_offset",1)
						item.mainBrightRatio = data.get("main_bright_ratio",0.01)
						
						item.repairReplacementPrice = data.get("price",3000)
						item.repairReplacementTime = data.get("repair_time",1)
						item.repairFixPrice = data.get("fix_price",500)
						item.repairFixTime = data.get("fix_time",4)

						
						item.exhaustEmitOffset = data.get("exhaust_emit_offset",8)
						item.scaleOffsetWithPower = data.get("scale_offset_with_power",false)
						item.distanceScale = data.get("distance_scale",5)
						item.plumesFromSettings = data.get("plumes_from_settings",true)
						item.angularDegreedRange = data.get("angular_degree_range",30)
						item.rotationRange = data.get("rotation_range",3.142)
						item.consumeCargo = data.get("consume_cargo",PoolStringArray([]))
						item.canFizzle = data.get("can_fizzle",true)
						item.wearPowerMaxChance = data.get("wear_power_max_chance",0.95) 
						item.wearChance = data.get("wear_chance",0.01)
						
						item.accelerationFailLimit = data.get("acceleration_fail_limit",400)
						item.accelerationFailScale = data.get("acceleration_fail_scale",200)
						item.lightLagChance = data.get("light_lag_chance",0.5)
						item.startJolt = data.get("start_jolt",0)
						item.thrust = data.get("thrust",1)
						item.particleChance = data.get("particle_chance",0.25)
						item.chokeParticleAdjust = data.get("choke_particle_adjust",1)
						item.fadeSeconds = data.get("fade_seconds",0.2)
						item.windUpSeconds = data.get("wind_up_seconds",0.017)
						item.particleScale = data.get("particle_scale",5)
						item.randomness = data.get("randomness",0.5)
						item.heatCone = data.get("heat_cone",0.5)
						item.minPower = data.get("min_power",0.01)
						
						item.damageWearCapacity = data.get("damage_wear_capacity",3600)
						item.damageBentCapacity = data.get("damage_bent_capacity",3000)
						item.damageBentThreshold = data.get("damage_bent_threshold",350)
						item.damageChokeCapacity = data.get("damage_choke_capacity",3000)
						item.damageChokeThreshold = data.get("damage_choke_threshold",200)
						item.specialFuelLimit = data.get("special_fuel_limit",0)
						item.heatFireThreshold = data.get("heat_fire_threshold",200)
						item.heatFireScale = data.get("heat_fire_scale",8000)
						item.heatFireMax = data.get("heat_fire_max",0.5)
						item.maxMisalignment = data.get("max_misalignment",0.349)
						item.bendWearRatio = data.get("bend_wear_ratio",0.025)
						item.specificImpulse = data.get("specific_impulse",65)
						item.thermalFactor = data.get("thermal_factor",40)
						item.powerDraw = data.get("power_draw",5000)
						item.gimbalPowerDraw = data.get("gimbal_power_draw",100)
						item.thermalHitFactor = data.get("thermal_hit_factor",1)
						item.inspection = data.get("inspection",true)
						
						item.gimbal = deg2rad(data.get("gimbal",0))
						item.safetyProtocol = data.get("safety_protocol",true)
						item.safetyGimbalClear = data.get("safety_gimbal_clear",0.419)
						item.ignitionsPerSecond = data.get("ignitions_per_second",10)
						item.gimbalAccurancy = data.get("gimbal_accuracy",0.262)
						item.gimbalPerSecond = data.get("gimbal_per_second",3.14)
						item.gimbalRestAngle = data.get("gimbal_rest_angle",0)
						item.gimbalVectoredThrust = data.get("gimbal_vectored_thrust",false)
						
						item.pulsePerSecond = data.get("pulse_per_second",10)
						item.pulseEngine = data.get("pulse_engine",true)
						
						var exhaustScene = data.get("exhaust_path","")
						if exhaustScene and file.file_exists(exhaustScene):
							item.exhaust = load(exhaustScene)
						else:
							item.exhaust = exhaust
						
						item.externalPower = data.get("external_power",false)
						item.safetyMaxPower = data.get("safety_max_power",1)
						item.safetyExtraMargin = data.get("safety_extra_margin",1)
						item.tuneThrustMin = data.get("tune_thrust_min",0.5)
						item.tuneThrustMax = data.get("tune_thrust_max",1.5)
						item.sweepHostilityFactor = data.get("sweep_hostility_factor",0.2)
						
						item.maxVolume = data.get("max_volume",-20)
						item.rangeOverride = data.get("range_override",0)
						item.boresightAngleoverride = data.get("boresight_angle_override",0)
						item.pitchOverride = data.get("pitch_override",0)
						item.minChoke = data.get("min_choke",0.25)
						
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				if item:
					add_child(item)
