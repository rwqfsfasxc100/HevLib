extends Node

const scripts_to_fetch_from = [
	"res://story/DeadBody.gd",
	"res://story/FlightForRescue.gd",
	"res://story/HumongousHollowRock.gd",
	"res://story/HybridHunter.gd",
	"res://story/InstanceWithChance.gd",
	"res://story/InterCrewBanter.gd",
	"res://story/LifepodIsFloating.gd",
	"res://story/LocustSwarm.gd",
	"res://story/Minefield.gd",
	"res://story/MinerMining.gd",
	"res://story/PirateCombat.gd",
	"res://story/PirateTrap.gd",
	"res://story/RescueOperation.gd",
	"res://story/RingRace.gd",
	"res://story/Singularity.gd",
	"res://story/TeslaIsFloating.gd",
	"res://story/TimedEvent.gd",
	"res://story/Vilcy.gd",
]

# Used to determine a failure chance for the event
export (bool) var use_random_chance = false			# Whether this should be a factor used when deciding if an event can spawn
export (float, 0, 1, 0.01) var randomChance = 1.0	# The base chance for the spawn to pass this check
export (float, 0, 1, 0.01) var minimumChance = 0.1	# The minimum chance if the base chance is modified by external factors

# Used to determine if the event is eligible for the storyteller rotation.
# If true, this event can only be instanced through conversation, astrogation POIs, or other means. 
export (bool) var eventOnly = true

# Used to determine a minimum and maximum chaos value for the event to require. 
# 0.65 marks the minimum for the Western Music to play, and is the recommended maximum for this value
export (float, 0, 1, 0.05) var min_chaos = 0.0
export (float, 0, 1, 0.05) var max_chaos = 1.0

# Used to determine a minimum and maximum raw density value for the event to require.
# This is a static density constant for the area, and won't change based on excavation
export (float, 0, 1, 0.05) var max_density = 0.0
export (float, 0, 1, 0.05) var min_density = 1.0

# Used to determine if a specific crew agenda must be onboard for the event to happen
export (bool) var require_crew_agenda = false				# Whether this should be a factor used when deciding if an event can spawn
export  var agenda = "AGENDA_LOOKING_FOR_SIBLING"	# The agenda required to be on board to pass this check

# Used to determine damage performed on ships with the extra_damage tag set to true
# Initial point of damage is calculated with the following equation: Vector2(randf() - 0.5, randf() - 0.5).normalized()
export  var gauss = 2					# The power to set a random value from 0-1. The result of this is used to multiply the initial point of damage value, as well as the extra_kinetic and extra_emp damage values.
export  var extra_kinetic = 100000.0	# Used for a base kinetic damage dealt to be randomly set to, this is multiplied by the previous value's resulting formula. 
export  var extra_emp = 100000.0		# Used for a base EMP damage dealt to be randomly set to, this is multiplied by the previous value's resulting formula.
export  var extra_radius = 100			# Used to multiply the initial point of damage value by itself to provide the resultant damage radius range. Calculated after the gauss equation.

# Used to spawn asteroids as a part of the event spawn
export (bool) var spawn_asteroids = false	# Used to determine if asteroids should be spawned as part of the event
export  var asteroid_number = 1				# The number of asteroids to spawn with the event
export  var asteroid_angular = 1.0			# The factor used to multiply the angular velocity by, which by default is ±0.5 rad/s (about ±29 deg/s)
export  var asteroid_aim = true				# Whether the asteroid should be aimed at your ship's current position
export  var asteroid_velocity = 250			# The velocity the asteroids should be set to. This is measured in 10 cm per unit (50 m/s = 500)
export  var asteroid_clump = false			# Whether the asteroids should have their velocity vector cause all asteroids to clump towards the target position

# Used to set the types of asteroids that can spawn within the asteroid part of the event
export  var include_class_1_asteroids = false	# Class 1 asteroids, the largest asteroids
export  var include_class_2_asteroids = false	# Class 2 asteroids
export  var include_class_3_asteroids = false	# Class 3 asteroids
export  var include_class_4_asteroids = false	# Class 4 asteroids
export  var include_class_5_asteroids = false	# Class 5 asteroids, the smallest asteroids

# Used to spawn shower asteroids as part of the event
export (bool) var spawn_shower_asteroids = false	# Used to determine if a shower of asteroids should be spawned as part of the event
export  var shower_velocity = 2000					# 
export  var shower_random_velocity = 100			# 
export  var shower_angular = 5.0					# 
export  var shower_number = 20						# 

# Used to set the types of asteroids that can spawn within the asteroid shower part of the event
export  var include_class_1_asteroids_shower = false	# Class 1 asteroids, the largest asteroids
export  var include_class_2_asteroids_shower = false	# Class 2 asteroids
export  var include_class_3_asteroids_shower = false	# Class 3 asteroids
export  var include_class_4_asteroids_shower = false	# Class 4 asteroids
export  var include_class_5_asteroids_shower = false	# Class 5 asteroids, the smallest asteroids


# Example dictionary used in variables needing a ship
# This contains all variables needed to properly setup a ship
var example_ship_dict = {
	"model":"AT225-R", # Ship model, references a ship instanced in Shipyard.gd
	"booted_up":false, # Whether the ship's reactor should be automatically online and producing when the ship is instanced
	"empty":false, # Whether the ship will be empty of propellant or not
	"imperative":AI.stop, # The specific AI enum that the ship will be given. See the enumeration below to get the specifics.
	"imperative_strength":20, # 
	"damage_ship":false, # Whether to allow the ship to be damaged.
	"extra_damage":false, # Whether to perform additional damage setting, see gauss, extra_kinetic, extra_emp, and extra_radius values
	"custom_conversation_path":"", # File path for a replacement conversation node. Used to allow specific conversations to happen.
	"agenda":"", # Agenda used to specify the ship name in agenda_ship_name
	"agenda_ship_name":"{agenda/ship/0/shipname}", # Format used for the shipname if an agenda is set.
	"specific_ship_name":"", # Used to set a specific ship name, is overridden by an agenda ship name if set
	"faction":"civilian", # Faction to set the ship to. 
	"new_ship":false, # Whether to use a new ship loadout from the dealer. Otherwise uses the used ship loadouts.
	
}

enum AI{
	ignore, 
	examine, 
	run, 
	flee, 
	fight, 
	watch, 
	catch, 
	excavate, 
	exit, 
	dock, 
	stop, 
	support, 
	playDead, 
	go, 
	shadow, 
	playDeadButTalk, 
	birdFeed, 
}

const asteroids_1 = [
		preload("res://asteroids/class-11.tscn"), 
		preload("res://asteroids/class-12.tscn"), 
		preload("res://asteroids/class-13.tscn")
	]
	
const asteroids_2 = [
		preload("res://asteroids/class-21.tscn"), 
		preload("res://asteroids/class-22.tscn"), 
		preload("res://asteroids/class-23.tscn"), 
		preload("res://asteroids/class-24.tscn"), 
		preload("res://asteroids/class-25.tscn"), 
		preload("res://asteroids/class-26.tscn"), 
		preload("res://asteroids/class-27.tscn"), 
	]
const asteroids_3 = [
		preload("res://asteroids/class-31.tscn"), 
		preload("res://asteroids/class-32.tscn"), 
		preload("res://asteroids/class-33.tscn"), 
		preload("res://asteroids/class-34.tscn"), 
		preload("res://asteroids/class-35.tscn"), 
		preload("res://asteroids/class-36.tscn"), 
		preload("res://asteroids/class-37.tscn"), 
		preload("res://asteroids/class-38.tscn"), 
		preload("res://asteroids/class-39.tscn"), 
	]
const asteroids_4 = [
		preload("res://asteroids/class-41.tscn"), 
		preload("res://asteroids/class-42.tscn"), 
		preload("res://asteroids/class-43.tscn"), 
		preload("res://asteroids/class-44.tscn"), 
		preload("res://asteroids/class-45.tscn"), 
		preload("res://asteroids/class-46.tscn"), 
		preload("res://asteroids/class-47.tscn"), 
		preload("res://asteroids/class-48.tscn"), 
		preload("res://asteroids/class-49.tscn"), 
	]
const asteroids_5 = [
		preload("res://asteroids/class-51.tscn"), 
		preload("res://asteroids/class-52.tscn"), 
		preload("res://asteroids/class-53.tscn"), 
		preload("res://asteroids/class-54.tscn"), 
		preload("res://asteroids/class-55.tscn"), 
		preload("res://asteroids/class-56.tscn"), 
		preload("res://asteroids/class-57.tscn"), 
		preload("res://asteroids/class-58.tscn"), 
		preload("res://asteroids/class-59.tscn"), 
	]


var aimerAsteroids = []
var showerAsteroids = []
func _exit_tree():
	aimerAsteroids.clear()
	showerAsteroids.clear()

func make_ship(ship_dict):
	var model = ship_dict.get("model",null)
	var bootedUp = ship_dict.get("booted_up",true)
	var empty = ship_dict.get("empty",false)
	var imperative = ship_dict.get("imperative",10)
	var imperativeStrength = ship_dict.get("imperative_strength",20)
	var damageShip = ship_dict.get("damage_ship",false)
	var conv = ship_dict.get("custom_conversation_path","")
	var conversation
	if conv:
		conversation = load(conv)
	var extraDamage = ship_dict.get("extra_damage",false)
	var agenda = ship_dict.get("agenda","")
	var agenda_ship_name = ship_dict.get("agenda_ship_name","")
	var custom_ship_name_literal = ship_dict.get("specific_ship_name","{agenda/ship/0/shipname}")
	var faction = ship_dict.get("faction","civilian")
	var newShip = ship_dict.get("new_ship",false)
	
	
	
	
	var ship = Shipyard.createShipBuildByName(model, faction, newShip)
	if bootedUp:
		ship.preheat = true
		ship.setReactorState(true)
	else:
		ship.setReactorState(false)
	
	if agenda and agenda_ship_name:
		var member = CurrentGame.getAgendaMember(agenda)
		var dict = Tool.getTranslationDictionary(null, null, member, "")
		ship.setShipName(agenda_ship_name.format(dict))
	elif custom_ship_name_literal:
		ship.setShipName(custom_ship_name_literal)
	
	ship.rotation = randf() * 2 * PI
	ship.ai = true
	ship.alwaysAI = true
	ship.factionIndependent = true
	if empty:
		ship.reactiveMass = 0
		ship.aiMinimumReactiveMass = 0
	else:
		ship.reactiveMass = ship.reactiveMassMax
	if imperative >= 0:
		ship.aiImperative = imperative
		ship.aiImperativeStrenght = imperativeStrength
		ship.aiImperativeTarget = CurrentGame.getPlayerShip()
	ship.aiCuriosityDisance = 2500
	ship.initialize = true
	ship.abandoned = true
	ship.hailable = false
	ship.astrogating = false
	if damageShip:
		ship.damageLimit = 1
	if conversation:
		var dci = conversation.instance()
		ship.add_child(dci)
		ship.dialogTree = ship.get_path_to(dci)
	if extraDamage:
		ship.connect("setup", self, "applyExtraDamage", [ship])
	return ship

func applyExtraDamage(to):
	Debug.l("Applying extra damage to %s" % [to])
	var point = Vector2(randf() - 0.5, randf() - 0.5).normalized() * pow(randf(), gauss) * extra_radius
	to.applyKineticDamage(pow(randf(), gauss) * extra_kinetic, point)
	to.applyEmpDamage(pow(randf(), gauss) * extra_emp, point, 1.0 / 60.0)

func make_asteroids(pos):
	var out = []
	if include_class_1_asteroids:
		aimerAsteroids.append_array(asteroids_1)
	if include_class_2_asteroids:
		aimerAsteroids.append_array(asteroids_2)
	if include_class_3_asteroids:
		aimerAsteroids.append_array(asteroids_3)
	if include_class_4_asteroids:
		aimerAsteroids.append_array(asteroids_4)
	if include_class_5_asteroids:
		aimerAsteroids.append_array(asteroids_5)
	var player = CurrentGame.getPlayerShip()
	for i in range(asteroid_number):
		var bp = aimerAsteroids[randi() % aimerAsteroids.size()]
		var a = bp.instance()
		if asteroid_aim:
			Debug.l("Aimer asteroid %s spawned" % a)
			var pc = CurrentGame.globalCoords(player.position)
			var target = (pc - pos).normalized()
			var tv = target * asteroid_velocity + player.linear_velocity
			Debug.l("Aiming %s to %s is %s = %s " % [pos, pc, target, tv])
			a.linear_velocity = tv
		if asteroid_clump:
			a.connect("tree_entered", self, "doClump", [a, pos])
		a.angular_velocity = (randf() - 0.5) * asteroid_angular
		out.append(a)
	return out

func doClump(what, towards):
	Debug.l("Clumping asteroid %s towards %s" % [what, towards])
	var pos = CurrentGame.globalCoords(what.position)
	var target = (towards - pos).normalized()
	var tv = target * asteroid_velocity
	what.linear_velocity = tv

func make_shower(pos):
	var out = []
	if include_class_1_asteroids_shower:
		showerAsteroids.append_array(asteroids_1)
	if include_class_2_asteroids_shower:
		showerAsteroids.append_array(asteroids_2)
	if include_class_3_asteroids_shower:
		showerAsteroids.append_array(asteroids_3)
	if include_class_4_asteroids_shower:
		showerAsteroids.append_array(asteroids_4)
	if include_class_5_asteroids_shower:
		showerAsteroids.append_array(asteroids_5)
	var player = CurrentGame.getPlayerShip()
	for i in range(shower_number):
		var bp = showerAsteroids[randi() % showerAsteroids.size()]
		var a = bp.instance()
		var pc = CurrentGame.globalCoords(player.position)
		var target = (pc - pos).normalized()
		var tv = target * shower_velocity + player.linear_velocity + Vector2(randf() - 0.5, randf() - 0.5).normalized() * randf() * shower_random_velocity
		a.asteroidClass = 4
		a.linear_velocity = tv
		a.angular_velocity = (randf() - 0.5) * shower_angular
		out.append(a)
	
	return out
