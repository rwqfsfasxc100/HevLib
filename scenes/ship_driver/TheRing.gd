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
# 4. The source code and the binary form, and any modifications made to them may not be used for the purpose of input data, the training of, or improvment of machine learning algorithms,
# including but not limited to artificial intelligence, natural language processing, or data mining. This condition applies to any derivatives,
# modifications, or updates based on the Software code. Any usage of the source code or the binary form in an AI-training dataset is considered a breach of this License.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# [/license]

extends "res://TheRing.gd"

func _ready():
	var pointers = ModLoader._savedObjects[0]
	var data = pointers.Equipment.add_ships_store
	var ro = load("res://story/RescueOperation.gd")
	for ship in data:
		if "name" in ship:
			var derelict_data = ship.get("derelict",{})
			var model = ship.get("name","TRTL")
			var dname = ship.get("specific_derelict_name","ModdedDerelict_" + model)
			var node = ro.new()
			node.name = dname
			var newname = node.name
			node.randomChance = 0.0
			node.minimumChance = 0.0
			node.chaosLimit = 3.0
			
			node.model = model
			
			node.reEncouterChance = clamp(1.0 - derelict_data.get("stock_chance",0.2),0,1)
			node.damageDerelict = derelict_data.get("allow_damage",true)
			node.extraDamage = derelict_data.get("cause_extra_damage",true)
			node.denseClusterChance = derelict_data.get("rock_cluster_chance",0.3)
			node.denseClusterNumber = derelict_data.get("rock_cluster_count",33)
			node.clump = derelict_data.get("clump",false)
			node.clumpVelocity = derelict_data.get("clump_velocity",25)
			node.stormChance = derelict_data.get("ring_storm_chance",0.3)
			node.pirateChance = derelict_data.get("pirate_chance",0.3)
			node.rescue = derelict_data.get("rescue",false)
			
			add_child(node)
	var add_events = pointers.Equipment.event_driver_event_entries
	for event in add_events:
		var event_name:String = event.get("event_name","")
		if event_name:
			var do_add = true
			var event_type:String = event.get("event_type","")
			var custom_property_modifications:Dictionary = event.get("custom_property_modifications",{})
			var node = Node.new()
			node.name = event_name
			if event_type == "script":
				var script_path = event.get("script_path","")
				if script_path and pointers.DataFormat.__file_exists(script_path):
					node.set_script(load(script_path))
				else:
					do_add = false
			elif event_type in script_references:
				var script_path = script_references[event_type]
				if script_path and pointers.DataFormat.__file_exists(script_path):
					node.set_script(load(script_path))
				else:
					do_add = false
			if do_add and event_type in script_references:
				match event_type:
					"agenda_specific_derelict":
						node.model = event.get("ship_model","AT225-R")								# Ship model used for this event.
						node.bootedUp = event.get("booted_up",false)								# Whether the ship would be booted up when the event is spawned.
						node.extraDamage = event.get("extra_damage",false)							# Whether the ship should undergo additional, artificial damage.
						node.eventOnly = event.get("event_only",true)								# Whether this event should be POI only. Setting this false permits the Storyteller to randomly select it.
						node.agenda = event.get("crew_agenda","AGENDA_LOOKING_FOR_SIBLING")			# Agenda that MUST be present within your crew for the event to spawn.
						node.shipNameAgenda = event.get("agenda_ship_name","{agenda/ship/0/shipname}") # Ship name that would be consistently given based on the specific crew agenda.
						var derelictConversation = event.get("derelict_conversation_node_path","res://comms/conversation/AgendaDerelictConversation.tscn") # The conversation player node to use. Defaults to the missing sibling conversation.
						if pointers.DataFormat.__file_exists(derelictConversation):
							node.derelictConversation = load(derelictConversation)
						else:
							node.derelictConversation = load("res://comms/conversation/AgendaDerelictConversation.tscn")
						node.extraKinetic = event.get("extra_kinetic_damage",100000.0)				# Scale for kinetic damage to deal to the ship when extra_damage is enabled.
						node.extraEmp = event.get("extra_emp_damage",100000.0)						# Scale for emp damage to deal to the ship when extra_damage is enabled.
						node.extraRadius = event.get("extra_damage_radius",100)						# Base radius of the circle where the point extra damage is inflicted can occur within. Measured with 1 unit = 100cm.
						node.gauss = event.get("gauss",2)											# Power the random value generated for the extra damage and damage radius is multiplied by. i.e. pow(randf(), gauss).
						node.empty = event.get("empty",false)										# Drains the ship of all propellant.
						node.damageDerelict = event.get("damage_derelict",false)					# Whether the ship should be damaged based on the age of the hull.
						node.imperative = event.get("imperative",10)								# The AI mode that the ship would boot with. Uses the AI enumeration in res://ships/ship-ctrl.gd.
						node.imperativeStrength = event.get("imperative_strength",20)				# The threshhold needed to meet for the ship AI to change AI mode.
						node.chaosLimit = clamp(event.get("chaos",0.0),0,1)							# If available to spawn through the Storyteller, the minimum chaos needed to spawn the event.
					"aiming_asteroid":
						node.number = event.get("number",1)											# The number of class 1 ringroids to spawn. Class 1 are the largest sized ringroids.
						node.angular = event.get("angular",1.0)										# The scale of the random amount of angular velocity that the ringroid(s) are given.
						node.aim = event.get("aim",true)											# Whether the ringroid(s) should target the player's current trajectory.
						node.velocity = event.get("velocity",250)									# The velocity of the ringroids, measured with 1 unit = 100 cm.
						node.clump = event.get("clump",false)										# Whether the ringroid(s) should instead target the event's origin point. This overrides `aim`.
						node.chaosLimit = clamp(event.get("chaos",0.0),0,1)							# The minimum chaos needed to spawn the event.
						var maxDensity = event.get("maxDensity",PoolIntArray([1000, 1000, 1000, 1000, 1000])) # The maximum perceived density of the ring at the event's spawn point, taking into account other ship events in the area. I recommend using the position display debug tool to get a feel as to how this array works.
						var md:PoolIntArray = PoolIntArray([1000, 1000, 1000, 1000, 1000])
						var mdSize = maxDensity.size() - 1
						for i in range(5):
							if i > mdSize:
								md[i] = 1000
							else:
								md[i] = int(maxDensity[i])
						node.maxDensity = md
					"aiming_asteroid_shower":
						node.number = event.get("number",20)										# The number of class 5 ringroids to spawn. Class 5 are the smallest suzed rubgriuds.
						node.velocity = event.get("velocity",2000)									# Base velocity for the ringroids, measured with 1 unit = 100 cm.
						node.randomVelocity = event.get("random_velocity",100)						# Additional randomness added or subtracted from the velocity, measured with 1 unit = 100 cm.
						node.angular = event.get("angular",5.0)										# The scale of the random amount of angular velocity that the ringroids are given.
						node.chaosLimit = clamp(event.get("chaos",0.0),0,1)							# The minimum chaos needed to spawn the event.
						node.densityLimit = clamp(event.get("density_limit",0.2),0,1)				# The maximum raw density of the rings to permit the event to spawn, i.e. the density as would be described from the visfeed.
					"claim_beacon":
						var claim = event.get("claim_beacon","res://ships/drone/ClaimBeacon.tscn")	# The scene for the claim beacon. NOTE: If using as actual claim beacons, these scenes must be unique to provide the beacon-specific dialogue trees.
						if pointers.DataFormat.__file_exists(claim):
							node.claim = load(claim)
						else:
							node.claim = load("res://ships/drone/ClaimBeacon.tscn")
						var alreadyClaimed = event.get("already_claimed","res://story/DummyBeacon.tscn") # Fallback scene if the transponder for the event's claim beacon is already an active transponder for whatever reason. The default scene should be sufficient for a fallback, but useful to override for additional handling.
						if pointers.DataFormat.__file_exists(alreadyClaimed):
							node.alreadyClaimed = load(alreadyClaimed)
						else:
							node.alreadyClaimed = load("res://story/DummyBeacon.tscn")
						node.immediateEvent = event.get("spawn_evemt",true)							# Whether the beacon should force an event to spawn.
						node.eventDelay = event.get("event_delay",30)								# Delay between the beacon event spawning and the storyteller spawning a new event.
						node.singleEvent = event.get("single_event",true)							# If this specific beacon event should only permit one event spawn per dive.
						node.postfix = event.get("postfix","")										# String used to randomize the beacon event for setting the transponder code's suffix number. Vanilla beacons typically use the beacon event's number, but can be any string.
						node.transponderFormat = event.get("transponder_format","%s-CB%d")			# The format the beacon's transponder will use. MUST contain both a `%s` and `%d` once each for the code and suffix respectively.
					"claim_beacon_foreign":
						var claim = event.get("claim_beacon","res://ships/drone/ClaimBeaconForeign.tscn") # The scene for the claim beacon object. NOTE: If using as actual claim beacons, these scenes must be unique to provide the beacon-specific dialogue trees.
						if pointers.DataFormat.__file_exists(claim):
							node.claim = load(claim)
						else:
							node.claim = load("res://ships/drone/ClaimBeaconForeign.tscn")
						node.ship = event.get("owner_ship_model","TRTL")							# The model for the NPC ship.
						node.faction = event.get("faction","civilian")								# The faction used by the NPC ship.
						node.claimFaction = event.get("claim_beacon_faction","civilianclaim")		# The faction used by the claim beacon.
						node.postfix = event.get("postfix","")										# String used to randomize the beacon event for setting the transponder code's suffix number. Vanilla beacons typically use the beacon event's number, but can be any string.
						node.transponderFormat = event.get("transponder_format","%s-CB%d")			# The format the beacon's transponder will use. MUST contain both a `%s` and `%d` once each for the code and suffix respectively.
						node.customTransponder = event.get("custom_transponder","")					# A custom transponder ID for the NPC.
						node.customName = event.get("customName","")								# A custom ship name for the NPC.
						node.lockOutStory = event.get("lock_out_story","")							# If set, a story flag that when reached prevents this event from ever spawning.
						node.lockOutLimit = event.get("lock_out_limit",1)							# Minimum value for the story flag to prevent the event from spawning.
						node.awayRadius = event.get("away_radius",10000)							# Radius which the event checks for any POI, which if any exist, prevents the event from being chosen by the storyteller.
						node.chaosLimit = clamp(event.get("chaos",0.0),0,1)							# The minimum chaos needed to spawn the event.
					"dead_body":
						var beacon = event.get("claim_beacon","res://story/DeadTalkingBeacon.tscn") # The scene for the comms beacon used by the event. 
						if pointers.DataFormat.__file_exists(beacon):
							node.beacon = load(beacon)
						else:
							node.beacon = load("res://story/DeadTalkingBeacon.tscn")
						var bodies = event.get("bodies",PoolStringArray([							# PoolStringArray/Array of filepaths to the scenes to be used for the bodies in the event.
							"res://story/body1.tscn",
							"res://story/body2.tscn", 
							"res://story/body3.tscn", 
							"res://story/body4.tscn", 
							"res://story/body5.tscn", 
							"res://story/body6.tscn", 
							"res://story/body7.tscn", 
							"res://story/body8.tscn", 
							"res://story/body9.tscn", 
							"res://story/body10.tscn"
						]))
						var bd:Array = []
						for body in bodies:
							if pointers.DataFormat.__file_exists(body):
								bd.append(load(body))
						node.bodies = bd
						node.nrMin = event.get("minimum_count")										# Minimum number of bodies that can be found.
						node.nrMax = event.get("maximum_count")										# Maximum number of bodies that can be found.
						var times = event.get("times",PoolVector2Array([							# Array of Arrays/Vector2s that dictate the IRL dates where the event will always pass the storyteller check and not need to meet the chaos to spawn.
							Vector2(10, 25), 
							Vector2(10, 26), 
							Vector2(10, 27), 
							Vector2(10, 28), 
							Vector2(10, 29), 
							Vector2(10, 31), 
							Vector2(11, 1)
						]))
						var otimes = PoolVector2Array()
						for i in times:
							match typeof(i):
								TYPE_ARRAY:
									if i.size() > 1:
										otimes.append(Vector2(float(i[0]),float(i[1])))
								TYPE_VECTOR2:
									otimes.append(i)
						node.times = otimes
						node.rotationVelocity = event.get("rotation_velocity")						# Scale for the random amount of rotational velocity each body is given.
						node.commonRandomVectorVelocity = event.get("common_random_vector_velocity")# Maximum random velocity that the bodies are given, measured with 1 unit = 100 cm.
						node.chaosLimit = clamp(event.get("chaos",0.0),0,1)							# The minimum chaos needed to spawn the event.
					"flight_for_rescue":
						node.time = max(event.get("time",180),0)
						node.maxLinear = event.get("maximum_velocity",100)							# Maximum random velocity that the bodies are given, measured with 1 unit = 100 cm.
						node.maxAngular = event.get("angular_velocity_scale",2)						# Scale the random angular velocity is set to.
						node.gauss = event.get("gauss",6)											# Power the random value used to set random linear and angular velocities to. Used as pow(randf(), gauss).
						var derelictConversation = event.get("derelict_conversation","res://comms/conversation/DerelictConversation.tscn") # The scene for the derelict K37's comms node.
						if pointers.DataFormat.__file_exists(derelictConversation):
							node.derelictConversation = load(derelictConversation)
						else:
							node.derelictConversation = load("res://comms/conversation/DerelictConversation.tscn")
					"humongous_hollow_rock":
						var rock = event.get("rock_scene","res://story/Moonlet.tscn")				# The rock scene for the derelict K37's comms node.
						if pointers.DataFormat.__file_exists(rock):
							node.rock = load(rock)
						else:
							node.rock = load("res://story/Moonlet.tscn")
						node.pirateChance = clamp(event.get("pirate_chance",0.5),0,1)				# The rock scene's base chance for a pirate encounter
						node.crystalChance = clamp(event.get("crystal_chance",0.5),0,1)				# The rock scene's base chance for crystals to spawn
						node.angular = event.get("angular",0.0025)									# Base angular velocity scale for the rock.
						node.locationOffsetStability = event.get("location_offset_stability",100000)# Grid cell size (both x & y) to determine the POI's unique identifier, measured with 1 unit = 100 cm. 
						node.awayRadius = event.get("away_radius",100000)							# Radius which the event checks for any POI, which if any exist, prevents the event from being chosen by the storyteller.
						node.lockOutMyEvent = event.get("lock_out_event",false)						# Whether the event won't spawn if you have another of the same event in your POI list.
						node.chaosLimit = clamp(event.get("chaos",0.0),0,1)							# The minimum chaos needed to spawn the event.
					
					
					
					
					
					
					
			
			if do_add:
				for i in custom_property_modifications:
					if i in node:
						node.set(i,custom_property_modifications[i])
			if do_add:
				add_child(node)
			else:
				Tool.remove(node)

const script_references = {
	"agenda_specific_derelict":"res://story/AgendaSpecificDerelict.gd",
	"aiming_asteroid":"res://story/AimingAsteroid.gd",
	"aiming_asteroid_shower":"res://story/AimingAsteroidShower.gd",
	"claim_beacon":"res://story/ClaimBeacon-1.gd",
	"claim_beacon_foreign":"res://story/ClaimBeaconForeign.gd",
	"dead_body":"res://story/DeadBody.gd",
	"flight_for_rescue":"res://story/FlightForRescue.gd",
	"humongous_hollow_rock":"res://story/HumongousHollowRock.gd",
	"hybrid_hunter":"res://story/HybridHunter.gd",
	"instance_with_chance":"res://story/InstanceWithChance.gd",
	"inter_crew_banter":"res://story/InterCrewBanter.gd",
	"lifepod_is_floating":"res://story/LifepodIsFloating.gd",
	"locust_swarm":"res://story/LocustSwarm.gd",
	"minefield":"res://story/Minefield.gd",
	"miner_mining":"res://story/MinerMining.gd",
	"pirate_combat":"res://story/PirateCombat.gd",
	"pirate_trap":"res://story/PirateTrap.gd",
	"rescue_operation":"res://story/RescueOperation.gd",
	"ring_race":"res://story/RingRace.gd",
	"singularity":"res://story/Singularity.gd",
	"tesla_is_floating":"res://story/TeslaIsFloating.gd",
	"timed_event":"res://story/TimedEvent.gd",
	"vilcy":"res://story/Vilcy.gd",
}
