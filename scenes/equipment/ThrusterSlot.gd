extends "res://ships/modules/ThrusterSlot.gd"

var auxslot_save_path = "user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/power/AuxSlot.json"
var exhaust_cache_path = "user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/power/Exhaust_Cache"
var color_cache_path = "user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/ships/ship_thruster_colors.json"
var flare
var file = File.new()
var mpdg = load("res://ships/modules/AuxMpd.tscn")
var smes = load("res://ships/modules/AuxSmes.tscn")
var thruster = load("res://sfx/thruster.tscn")
var exhaust = load("res://sfx/exhaust.tscn")
var nozzle = load("res://ships/modules/nozzle-conventonal.tscn")
#const NodeAccess = preload("res://HevLib/pointers/NodeAccess.gd")


const torch_base_scale = [0.939,1.395]
const rcs_base_scale = [0.2,0.2]
const thruster_base_pos = [0,-3]

var timerObject
var fco

var shipName
var baseShipName

const nozzle_template = {
	"cool_time":4,
	"heat_time":0.25,
	"texture":"res://ships/modules/nozzle-cd.png",
	"normal":"res://ships/modules/nozzle-n.png",
	"heat":"res://ships/modules/nozzle-cl.png",
	"heat_normal":null,
	"region_enabled":false,
	"region_rect":[0,0,0,0],
	"region_filter_clip":false,
	"position":[0,0],
	"rotation":0,
	"scale":[1,1],
	"heat_region_enabled":false,
	"heat_region_rect":[0,0,0,0],
	"heat_region_filter_clip":false,
	"heat_position":[0,0],
	"heat_rotation":0,
	"heat_scale":[1,1],
}
var aux_type
func loadPlaceholder():
	modify()
	.loadPlaceholder()
#	yield(get_tree(),"idle_frame")
func modify():
	file.open(auxslot_save_path,File.READ)
	var datastore = JSON.parse(file.get_as_text()).result
	file.close()
	shipName = ship.shipName
	baseShipName = ship.baseShipName
	var slotType = type.split(".")[0]
	var currentInstall = ship.getConfig(type)
	if slotType in datastore:
		for data in datastore[slotType]:
			var aux_path = data.get("path","")
			aux_type = data.get("type","MPDG").to_upper()
			match aux_type:
				"THRUSTER":
					aux_type = "RCS"
				"MAIN_PROPULSION":
					aux_type = "TORCH"
			var item
			var sys = data.get("system","SYSTEM_NAME_MISSING")
			if sys == currentInstall:
				var valid_scene = false
				if aux_path != "":
					var s = load(aux_path)
					if s:
						valid_scene = true
						item = s.instance()
				
				if not valid_scene:
					match aux_type:
						"MPDG":
							item = mpdg.instance()
						"SMES":
							item = smes.instance()
						"RCS","TORCH":
							item = thruster.instance()
				
#				var sysn = name + "_" + sys
				item.name = sys
#				system = item
				
#				item.name = sys\
				if not valid_scene:
					item.repairReplacementPrice = data.get("price",30000)
					item.repairReplacementTime = data.get("repair_time",1)
					item.repairFixPrice = data.get("fix_price",5000)
					item.repairFixTime = data.get("fix_time",4)
					item.command = data.get("command","m" if aux_type == "TORCH" else "")
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

							
						"RCS","TORCH":
							
							item.priorityOffset = data.get("priority_offset",1 if aux_type == "RCS" else 8)
							item.mainBrightRatio = data.get("main_bright_ratio",0.01)
							
							item.repairReplacementPrice = data.get("price",3000 if aux_type == "RCS" else 15000)
							item.repairReplacementTime = data.get("repair_time",1 if aux_type == "RCS" else 4)
							item.repairFixPrice = data.get("fix_price",500 if aux_type == "RCS" else 1000)
							item.repairFixTime = data.get("fix_time",4 if aux_type == "RCS" else 12)

							
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
							item.thrust = data.get("thrust",1 if aux_type == "RCS" else 7500)
							item.particleChance = data.get("particle_chance",0.5 if aux_type == "RCS" else 1.0)
							item.chokeParticleAdjust = data.get("choke_particle_adjust",1)
							item.fadeSeconds = data.get("fade_seconds",0.2 if aux_type == "RCS" else 0.4)
							item.windUpSeconds = data.get("wind_up_seconds",0.017)
							item.particleScale = data.get("particle_scale",5)
							item.randomness = data.get("randomness",0.5)
							item.heatCone = data.get("heat_cone",0.5)
							item.minPower = data.get("min_power",0.2 if aux_type == "RCS" else 0.8)
							
							item.damageWearCapacity = data.get("damage_wear_capacity",3600)
							item.damageBentCapacity = data.get("damage_bent_capacity",3000)
							item.damageBentThreshold = data.get("damage_bent_threshold",200)
							item.damageChokeCapacity = data.get("damage_choke_capacity",6000)
							item.damageChokeThreshold = data.get("damage_choke_threshold",400)
							item.specialFuelLimit = data.get("special_fuel_limit",0)
							item.heatFireThreshold = data.get("heat_fire_threshold",200)
							item.heatFireScale = data.get("heat_fire_scale",8000)
							item.heatFireMax = data.get("heat_fire_max",0.5)
							item.maxMissalignment = data.get("max_misalignment",0.262 if aux_type == "RCS" else 0.02)
							item.bendWearRatio = data.get("bend_wear_ratio",0.025)
							item.specificImpulse = data.get("specific_impulse",65 if aux_type == "RCS" else 15)
							item.thermalFactor = data.get("thermal_factor",40)
							item.powerDraw = data.get("power_draw",5000 if aux_type == "RCS" else 100000)
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
							
							item.pulsePerSecond = data.get("pulse_per_second",10 if aux_type == "RCS" else 4)
							item.pulseEngine = data.get("pulse_engine",true)
							
							var exhaustScene = exhaust_cache_path + "/" + aux_type + "/" + sys
							if file.file_exists(exhaustScene):
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
							
							var md = data.get("modulate","")
							var sm = data.get("self_modulate","")
							if md != "":
								item.modulate = Color(md)
							if sm != "":
								item.self_modulate = Color(sm)
							
							
							var pt = "res://sfx/thrusters.png"
							var plumeTex = data.get("plume_texture","res://sfx/thrusters.png")
							if file.file_exists(plumeTex):
								pt = plumeTex
							item.texture = load(pt)
							var po = data.get("plume_offset",[-32,-16])
							if po.size() >= 2:
								item.offset = Vector2(po[0],po[1])
							item.centered = data.get("plume_centered",false)
							item.flip_h = data.get("plume_flip_h",false)
							item.flip_v = data.get("plume_flip_v",false)
							
							var tp = data.get("position",thruster_base_pos)
							if tp.size() >= 2:
								item.position = Vector2(tp[0],tp[1])
							var def_scale = rcs_base_scale
							
							match aux_type:
								"TORCH","MAIN_PROPULSION":
									def_scale = torch_base_scale
							
							var ts = data.get("scale",def_scale)
							if ts.size() >= 2:
								item.scale = Vector2(ts[0],ts[1])
							
							flare = item.get_node_or_null("Flare")
							if flare:
								flare.set_deferred("essentiality",data.get("flare_essentiality",0.5 if aux_type == "RCS" else 0.8))
								flare.set_deferred("offsetByCamera", data.get("flare_offset_by_camera",false))
								
								var ft = "res://lights/plume.png"
								var flareTex = data.get("flare_texture","res://lights/plume.png")
								
								if file.file_exists(flareTex):
									ft = flareTex
								flare.set_deferred("texture", load(ft))
								flare.set_deferred("energy",data.get("flare_energy",5))
								flare.set_deferred("range_height",data.get("flare_range_height",-15))
								var fo = data.get("flare_offset",[0,0])
								if fo.size() >= 2:
									flare.set_deferred("offset", Vector2(fo[0],fo[1]))
								flare.set_deferred("texture_scale", data.get("flare_texture_scale",6))
								flare.set_deferred("rotation",deg2rad(data.get("flare_rotation",0)))
								var fp = data.get("flare_position",[0,0])
								if fp.size() >= 2:
									flare.position = Vector2(fp[0],fp[1])
								var fnc = data.get("flare_color","3bafff")
								if fnc != "":
									flare.color = Color(fnc)
								var color_override = data.get("flare_override_color","")
								if color_override != "":
									fco = Color(color_override)
									make_timer()
							var after_nozzles = []
							var before_nozzles = []
							var noz = data.get("nozzle",{})
							var nd = convert_to_nozzle(noz)
							for i in data.get("extra_nozzles",[]):
								if i.get("order","after") == "before":
									before_nozzles.append(convert_to_nozzle(i))
								else:
									after_nozzles.append(convert_to_nozzle(i))
							var nozzleA = item.get_node_or_null("nozzle")
							modify_nozzle(nozzleA,nd)
							var noz_poz = nozzleA.get_position_in_parent()
							for n in before_nozzles:
								var thisNozzle = nozzle.instance()
								modify_nozzle(thisNozzle,n)
								if thisNozzle:
									item.add_child(thisNozzle)
									item.move_child(thisNozzle,noz_poz - 1)
							for n in after_nozzles:
								var thisNozzle = nozzle.instance()
								modify_nozzle(thisNozzle,n)
								if thisNozzle:
									item.add_child(thisNozzle)
							var extra_nodes = data.get("extra_nodes",[])
							for node in extra_nodes:
								if file.file_exists(node):
									var scene = load(node)
									if scene:
										item.add_child(scene.instance())
						
						
						
						
						
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				
				if item:
#					add_child(item)

					key = name + "_" + mounted
					add_child(item)
					systemName = _getSystemName()
					slotName = type
					repairFixPrice = _getRepairFixPrice()
					repairFixTime = _getRepairFixTime()
					repairReplacementPrice = _repairReplacementPrice()
					repairReplacementTime = _repairReplacementTime()
					mass = _getMass()
	get_colors()


func make_timer():
	if timerObject == null:
		timerObject = Timer.new()
		timerObject.wait_time = 0.5
		timerObject.one_shot = true
		timerObject.connect("timeout",self,"recolor")
		get_tree().get_root().add_child(timerObject)
		timerObject.call_deferred("start")

func convert_to_nozzle(noz):
	var nozzle = nozzle_template.duplicate(true)
	for i in nozzle:
		if i in noz and typeof(nozzle[i]) == typeof(noz[i]):
			nozzle[i] = noz[i]
	return nozzle

func recolor():
	if not flare:
		for node in get_children():
			if node.name.begins_with(name + "_"):
				flare = node.get_node_or_null("Flare")
	if flare and fco:
		flare.color = fco
	Tool.remove(timerObject)

func modify_nozzle(nozzleA,nd):
	if nozzleA:
		if aux_type != "NOT_A_THRUSTER":
			nozzleA.coolTime = nd.cool_time
			nozzleA.heatTime = nd.heat_time
		var t = "res://ships/modules/nozzle-cd.png"
		if file.file_exists(nd.texture):
			t = nd.texture
		var tr = load(t)
		nozzleA.texture = tr
		var l = "res://ships/modules/nozzle-n.png"
		if file.file_exists(nd.normal):
			l = nd.normal
		var tl = load(l)
		nozzleA.normal_map = tl
		var h = "res://ships/modules/nozzle-cl.png"
		if file.file_exists(nd.heat):
			h = nd.heat
		var th = load(h)
		var heat = nozzleA.get_node_or_null("heat")
		var hn = null
		if nd.heat_normal and file.file_exists(nd.heat_normal):
			hn = nd.heat
		var thn = null
		if hn:
			thn = load(hn)
		if heat:
			heat.texture = th
			if thn:
				heat.normal_map = thn
			heat.region_enabled = nd.heat_region_enabled
		
			var rr = nd.heat_region_rect
			if rr.size() >= 4:
				heat.region_rect = Rect2(rr[0],rr[1],rr[2],rr[3])
			heat.region_filter_clip = nd.heat_region_filter_clip
			var rp = nd.heat_position
			if rp.size() >= 2:
				heat.position = Vector2(rp[0],rp[1])
			heat.set_deferred("rotation",deg2rad(nd.heat_rotation))
			var rs = nd.heat_scale
			if rs.size() >= 2:
				heat.scale = Vector2(rs[0],rs[1])
		nozzleA.region_enabled = nd.region_enabled
		
		var rr = nd.region_rect
		if rr.size() >= 4:
			nozzleA.region_rect = Rect2(rr[0],rr[1],rr[2],rr[3])
		nozzleA.region_filter_clip = nd.region_filter_clip
		var rp = nd.position
		if rp.size() >= 2:
			nozzleA.position = Vector2(rp[0],rp[1])
		nozzleA.set_deferred("rotation",deg2rad(nd.rotation))
		var rs = nd.scale
		if rs.size() >= 2:
			nozzleA.scale = Vector2(rs[0],rs[1])

func get_colors():
	file.open(color_cache_path,File.READ)
	var color_data = JSON.parse(file.get_as_text()).result
	file.close()
	
	for i in color_data:
		var d = color_data[i]
		if i == shipName:
			modify_colors(d)
		if i == baseShipName and d.get("recurse_to_variants",false):
			modify_colors(d)
		

func modify_colors(data):
	var change = false
	if "type" in data:
		var c = data["type"]
		if type in c:
			var color = c[type]
			fco = color
			change = true
	if "node" in data:
		var c = data["node"]
		if name in c:
			var color = c[name]
			fco = color
			change = true
	if change:
		make_timer()
