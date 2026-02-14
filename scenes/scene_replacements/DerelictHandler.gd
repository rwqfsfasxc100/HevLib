extends Node

export (int, 1,5,1) var index = 1
export (String,"derelict","miner") var mode = "derelict"

export (int) var gauss = 2
export (int) var maxLinear = 500
export (float) var maxAngular = 0.5
export var derelictConversation = preload("res://comms/conversation/DerelictConversation.tscn")

export (int) var extraRadius = 100
export (float) var extraKinetic = 100000.0
export (float) var extraEmp = 100000.0
export var stormBeacon = preload("res://story/StormBeacon.tscn")
export var bounty = preload("res://ships/LifepodPirate.tscn")
var specificShipName = ""

func setParam(param):
	if param:
		specificShipName = param

var asteroids = [
	preload("res://asteroids/class-11.tscn"), 
	preload("res://asteroids/class-12.tscn"), 
	preload("res://asteroids/class-13.tscn"), 
	
	preload("res://asteroids/class-22.tscn"), 
	preload("res://asteroids/class-23.tscn"), 
	preload("res://asteroids/class-24.tscn"), 
	preload("res://asteroids/class-25.tscn"), 
	preload("res://asteroids/class-26.tscn"), 
	preload("res://asteroids/class-27.tscn")
]

func _exit_tree():
	asteroids.clear()

var prevent = false

var ship_pool = {}
var ship_driver_path = "user://cache/.HevLib_Cache/ShipDriver/"
func _ready():
	var file = File.new()
	file.open(ship_driver_path + "driver_data.json",File.READ)
	var data = JSON.parse(file.get_as_text()).result
	file.close()
	for mod in data:
		var md = data[mod]
		for ship in md:
			var fd = md[ship]
			if mode in fd:
				var shipName = fd["name"]
				var event = fd[mode]
				ship_pool.merge({shipName:event})
	if ship_pool.keys().size() < index:
		prevent = true

var chance = 1.0
var minimum_chance = 0.1
var money = 10000000.0
var stock_chance = 0.2
var allow_damage = true
var cause_extra_damage = true
var rock_cluster_chance = 0.3
var rock_cluster_count = 33
var clump = false
var clump_velocity = 25
var ring_storm_chance = 0.3
var pirate_chance = 0.3
var chaos = 0.0

var model = "TRTL"

func canBeAt(pos):
	if prevent:
		return false
	var sn = ship_pool.keys()[randi() % ship_pool.keys().size()]
	var selected = ship_pool[sn]
	model = sn
	for i in selected:
		set(i,selected[i])
	match mode:
		"miner":
			var cv = get_parent().getChaosAt(pos)
			return cv > chaos
		
		"derelict":
			
			var rc = clamp(chance * (1 - CurrentGame.getMoney() / money), minimum_chance, 1)
			if randf() > rc:
				Debug.l("* Denied because of random chance of %f" % rc)
				return false
			var cv = get_parent().getChaosAt(pos)
			return cv >= chaos

func makeAt(pos):
	
	var ships = []
	
	
	match mode:
		"miner":
			var config = Shipyard.getBuildConfigByName(model)
			config.faction = "civilian"
			var miner = Shipyard.createShipByConfig(config)
			miner.ai = true
			miner.aiExcavationValueOffset = 0
			miner.preheat = true
			miner.rotation = randf() * 2 * PI
			miner.hostilityHitWhenEncelading = - 0.2
			ships.append(miner)
		
		"derelict":
			var velocity = Vector2(randf() - 0.5, randf() - 0.5).normalized() * pow(randf(), gauss) * maxLinear
			
			var wreckage = Shipyard.createShipBuildByName(model, "helpless", randf() > clamp((1 - stock_chance),0,1))
			wreckage.angular_velocity = (grandf()) * maxAngular
			wreckage.linear_velocity = velocity
			wreckage.setReactorState(false)
			wreckage.rotation = randf() * 2 * PI
			wreckage.ai = true
			wreckage.alwaysAI = true
			wreckage.factionIndependent = true
			wreckage.reactiveMass = 0
			wreckage.aiMinimumReactiveMass = 0
			wreckage.aiCuriosityDisance = 1500
			wreckage.initialize = false
			wreckage.abandoned = true
			wreckage.hailable = false
			wreckage.astrogating = false
			if specificShipName:
				wreckage.setShipName(specificShipName)
			if allow_damage:
				wreckage.damageLimit = 1
			var dci = derelictConversation.instance()
			wreckage.add_child(dci)
			wreckage.dialogTree = wreckage.get_path_to(dci)
			if cause_extra_damage:
				wreckage.connect("setup", self, "applyExtraDamage", [wreckage])
			
			ships.append(wreckage)
			
			if randf() < rock_cluster_chance:
				for i in range(rock_cluster_count):
					var bp = asteroids[randi() % asteroids.size()]
					var a = bp.instance()
					a.angular_velocity = (randf() - 0.5)
					a.linear_velocity = velocity
					ships.append(a)
					
			if randf() < ring_storm_chance:
				var storm = stormBeacon.instance()
				ships.append(storm)

			if randf() < pirate_chance:
				ships.append(makeAbductor())

			if clump:
				for s in ships:
					s.connect("tree_entered", self, "doClump", [s, pos, velocity])
	return ships

func makeAbductor():
	var cfg = Shipyard.getDefaultConfigByName("MADCERF")
	cfg.config.weaponSlot = {
		"left": {"type": "SYSTEM_EMD17RF"}, 
		"left2": {"type": "SYSTEM_EMD17RF"}, 
		"left3": {"type": "SYSTEM_MWG"}, 
		"right": {"type": "SYSTEM_EMD17RF"}, 
		"right2": {"type": "SYSTEM_EMD17RF"}, 
		"right3": {"type": "SYSTEM_MWG"}, 
	}
	cfg.config.ammo = {
		"capacity": 15000, 
		"initial": 15000
	}
	cfg.config.turbine.power = 500
	cfg.config.capacitor.capacity = 3000
	cfg.faction = "pirate"
	var ship = Shipyard.createShipByConfig(cfg)
	ship.ai = true
	ship.preheat = true
	ship.autopilotMaxVelocity = 500
	ship.rotation = randf() * 2 * PI
	ship.lifepod = bounty
	ship.hostilityHitWhenEncelading = 0.2
	return ship

func grandf():
	var v = pow(randf(), gauss)
	if randi() % 2 == 0:
		return v
	else:
		return - v

func applyExtraDamage(to):
	Debug.l("Applying extra damage to %s" % [to])
	var point = Vector2(randf() - 0.5, randf() - 0.5).normalized() * pow(randf(), gauss) * extraRadius + to.global_position
	to.applyKineticDamage(pow(randf(), gauss) * extraKinetic, point)
	to.applyEmpDamage(pow(randf(), gauss) * extraEmp, point, 1.0 / 60.0)

func doClump(what, towards, velocity):
	Debug.l("Clumping asteroid %s towards %s" % [what, towards])
	var pos = CurrentGame.globalCoords(what.position)
	var target = (towards - pos).normalized()
	var tv = target * clump_velocity + velocity
	what.linear_velocity = tv


