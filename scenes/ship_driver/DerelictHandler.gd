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

extends Node

export (int, 1,5,1) var index = 1
export (String,"derelict","miner") var mode = "derelict"

var derelictConversation = load("res://comms/conversation/DerelictConversation.tscn")

var stormBeacon = load("res://story/StormBeacon.tscn")
var bounty = load("res://ships/LifepodPirate.tscn")
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

var pointers:HevLibPointers
var ship_pool = {}
var dataSet = null
func _ready():
	pointers = ModLoader._savedObjects[0]
	var data = pointers.Equipment.add_ships_store
	randomize()
	data.shuffle()
	for fd in data:
		if pointers.ConfigDriver.__validate_dictionary(fd,true,true,true,"settings_config") and mode in fd and "name" in fd and "path" in fd:
			var shipName = fd["name"]
			if "path" in fd and fd.path:
				if pointers.FileAccess.__file_exists(fd.path):
					var event = fd[mode]
					ship_pool.merge({shipName:event})
				else:
					pointers.l("ERROR: Failed to add modded derelict for ship [%s] due to it's ship scene not being a valid filepath." % shipName,"ShipDriver")
			else:
				pointers.l("Skipping addition of modded derelict instance of ship [%s] due to it not adding a ship scene." % shipName,"ShipDriver")
	if ship_pool.keys().size() < index:
		prevent = true

var stock_chance:float = 0.2
var allow_damage:bool = true
var cause_extra_damage:bool = true
var rock_cluster_chance:float = 0.3
var rock_cluster_count:int = 33
var clump:bool = false
var clump_velocity:int = 25
var ring_storm_chance:float = 0.3
var pirate_chance:float = 0.3
var rescue:bool = false

var maximum_velocity:float = 50.0
var maximum_angular_velocity:float = 0.5
var gauss:float = 2.0
var extra_kinetic_damage:float = 100000.0
var extra_emp_damage:float = 100000.0
var extra_damage_radius:float = 10.0
var new_derelict_conversation:String = ""
var new_storm_beacon:String = ""
var new_bounty:String = ""

var model = "TRTL"

func canBeAt(pos):
	if prevent:
		return false
	model = ship_pool.keys()[randi() % ship_pool.keys().size()]
	var selected:Dictionary = ship_pool[model]
	Debug.l("* %s handler %s attempting spawn of ship %s" % [mode,str(index),model])
	var permit:bool = true
	var isDerelict:bool = mode == "derelict"
	if isDerelict:
		var rc = clamp(selected.get("chance",1.0) * (1 - CurrentGame.getMoney() / selected.get("money",10000000.0)), selected.get("minimum_chance",0.1), 1)
		if randf() > rc:
			Debug.l("* Denied because of random chance of %f" % rc)
			permit = false
	if permit:
		permit = get_parent().getChaosAt(pos) > selected.get("chaos",0.0)
	if permit and isDerelict:
		stock_chance = selected.get("stock_chance",0.2)
		allow_damage = selected.get("allow_damage",true)
		cause_extra_damage = selected.get("cause_extra_damage",true)
		rock_cluster_chance = selected.get("rock_cluster_chance",0.3)
		rock_cluster_count = selected.get("rock_cluster_count",33)
		clump = selected.get("clump",true)
		clump_velocity = selected.get("clump_velocity",25)
		ring_storm_chance = selected.get("ring_storm_chance",0.3)
		pirate_chance = selected.get("pirate_chance",0.3)
		rescue = selected.get("rescue",false)
		maximum_velocity = selected.get("maximum_velocity",50.0)
		maximum_angular_velocity = selected.get("maximum_angular_velocity",0.5)
		gauss = selected.get("gauss",2)
		extra_kinetic_damage = selected.get("extra_kinetic_damage",100000.0)
		extra_emp_damage = selected.get("extra_emp_damage",100000.0)
		extra_damage_radius = selected.get("extra_damage_radius",10.0)
		new_derelict_conversation = selected.get("new_derelict_conversation","")
		new_storm_beacon = selected.get("new_storm_beacon","")
		new_bounty = selected.get("new_bounty","")
	return false
	

func makeAt(pos):
	
	var ships = []
	
	Debug.l("* %s handler %s spawning ship %s at (%d,%d)" % [mode,str(index),model,pos.x,pos.y])
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
			var velocity = Vector2(randf() - 0.5, randf() - 0.5).normalized() * pow(randf(), gauss) * (maximum_velocity * 10.0)
			
			var wreckage = Shipyard.createShipBuildByName(model, "helpless", randf() > clamp((1 - stock_chance),0,1))
			wreckage.angular_velocity = (grandf()) * (maximum_angular_velocity * 10)
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
			var dci
			if new_derelict_conversation and pointers.FileAccess.__file_exists(new_derelict_conversation):
				dci = load(new_derelict_conversation).instance()
			else:
				dci = derelictConversation.instance()
			wreckage.add_child(dci)
			wreckage.dialogTree = wreckage.get_path_to(dci)
			if cause_extra_damage:
				wreckage.connect("setup", self, "applyExtraDamage", [wreckage])
			
			ships.append(wreckage)
			
			if randf() < rock_cluster_chance:
				for i in rock_cluster_count:
					var bp = asteroids[randi() % asteroids.size()]
					var a = bp.instance()
					a.angular_velocity = (randf() - 0.5)
					a.linear_velocity = velocity
					ships.append(a)
					
			if randf() < ring_storm_chance:
				if new_storm_beacon and pointers.FileAccess.__file_exists(new_storm_beacon):
					ships.append(load(new_storm_beacon).instance())
				else:
					ships.append(stormBeacon.instance())
			if randf() < pirate_chance:
				match Settings.getDifficulty():
					0:
						Debug.l("Preventing spawn of abductor due to peaceful difficulty")
					_:
						ships.append(makeAbductor())
			
			if rescue:
				var helper = Shipyard.createShipBuildByName("MADCERF", "helper", randf() > clamp((1 - stock_chance),0,1))
				helper.ai = true
				helper.preheat = true
				helper.rotation = randf() * 2 * PI
				ships.append(helper)
			
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
	if new_bounty and pointers.FileAccess.__file_exists(new_bounty):
		ship.lifepod = load(new_bounty)
	else:
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
	var point = Vector2(randf() - 0.5, randf() - 0.5).normalized() * pow(randf(), gauss) * (extra_damage_radius * 10.0) + to.global_position
	to.applyKineticDamage(pow(randf(), gauss) * extra_kinetic_damage, point)
	to.applyEmpDamage(pow(randf(), gauss) * extra_emp_damage, point, 1.0 / 60.0)

func doClump(what, towards, velocity):
	Debug.l("Clumping asteroid %s towards %s" % [what, towards])
	var pos = CurrentGame.globalCoords(what.position)
	var target = (towards - pos).normalized()
	var tv = target * clump_velocity + velocity
	what.linear_velocity = tv


