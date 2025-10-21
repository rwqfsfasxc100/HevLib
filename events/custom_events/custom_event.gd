extends Node

# Used to determine a failure chance for the event
export (bool) var use_random_chance = false
export (float, 0, 1, 0.01) var randomChance = 1.0
export (float, 0, 1, 0.01) var minimumChance = 0.1

# Used to determine if the event is eligible for the storyteller rotation.
# If true, this event can only be instanced through conversation, astrogation POIs, or other means. 
export  var eventOnly = true

# Used to determine a minimum chaos value for the event to require. 
# 0.65 marks the minimum for the Western Music to play, and is the recommended maximum for this value
export (float, 0, 1, 0.05) var chaosLimit = 0.0

# Used to determine if a specific crew agenda must be onboard for the event to happen
export  var require_crew_agenda = false
export  var agenda = "AGENDA_LOOKING_FOR_SIBLING"

# Used to determine damage performed on ships with the extra_damage tag set to true
# Initial point of damage is calculated with the following equation: Vector2(randf() - 0.5, randf() - 0.5).normalized()
export  var gauss = 2					# The power to set a random value from 0-1. The result of this is used to multiply the initial point of damage value, as well as the extra_kinetic and extra_emp damage values.
export  var extra_kinetic = 100000.0	# Used for a base kinetic damage dealt to be randomly set to, this is multiplied by the previous value's resulting formula. 
export  var extra_emp = 100000.0		# Used for a base EMP damage dealt to be randomly set to, this is multiplied by the previous value's resulting formula.
export  var extra_radius = 100			# Used to multiply the initial point of damage value by itself to provide the resultant damage radius range. Calculated after the gauss equation.






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
