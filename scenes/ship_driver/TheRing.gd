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
						var derelictConversation = event.get("derelict_conversation","res://comms/conversation/AgendaDerelictConversation.tscn") # The conversation player node to use. Defaults to the missing sibling conversation.
						if pointers.DataFormat.__file_exists(derelictConversation):
							node.derelictConversation = load(derelictConversation)
						else:
							node.derelictConversation = load("res://comms/conversation/AgendaDerelictConversation.tscn")
						node.extraKinetic = max(event.get("extra_kinetic_damage",100000.0),0)		# Scale for kinetic damage to deal to the ship when extra_damage is enabled.
						node.extraEmp = max(event.get("extra_emp_damage",100000.0),0)				# Scale for emp damage to deal to the ship when extra_damage is enabled.
						node.extraRadius = max(event.get("extra_damage_radius",100),0)				# Base radius of the circle where the point extra damage is inflicted can occur within. Measured with 1 unit = 100cm.
						node.gauss = event.get("gauss",2)											# Power the random value generated for the extra damage and damage radius is multiplied by. i.e. pow(randf(), gauss).
						node.empty = event.get("empty",false)										# Drains the ship of all propellant.
						node.damageDerelict = event.get("damage_derelict",false)					# Whether the ship should be damaged based on the age of the hull.
						node.imperative = max(event.get("imperative",10),0)							# The AI mode that the ship would boot with. Uses the AI enumeration in res://ships/ship-ctrl.gd.
						node.imperativeStrength = max(event.get("imperative_strength",20),0)		# The threshhold needed to meet for the ship AI to change AI mode.
						node.chaosLimit = clamp(event.get("chaos",0.0),0,1)							# If available to spawn through the Storyteller, the minimum chaos needed to spawn the event.
					"aiming_asteroid":
						node.number = max(event.get("number",1),0)									# The number of class 1 ringroids to spawn. Class 1 are the largest sized ringroids.
						node.angular = event.get("maximum_angular_velocity",1.0)					# Maximum angular velocity that the ringroid(s) can be given, measured in radians per second.
						node.aim = event.get("aim",true)											# Whether the ringroid(s) should target the player's current trajectory.
						node.velocity = event.get("maximum_velocity",250)							# The velocity of the ringroids, measured with 1 unit = 100 cm.
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
						node.number = max(event.get("number",20),0)									# The number of class 5 ringroids to spawn. Class 5 are the smallest suzed rubgriuds.
						node.velocity = event.get("maximum_velocity",2000)							# Base maximum velocity for the ringroids, measured with 1 unit = 100 cm.
						node.randomVelocity = event.get("random_velocity",100)						# Additional randomness added or subtracted from the velocity, measured with 1 unit = 100 cm.
						node.angular = event.get("maximum_angular_velocity",5.0)					# Maximum angular velocity that the ringroids can be given, measured in radians per second.
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
						node.eventDelay = max(event.get("event_delay",30),1)						# Delay between the beacon event spawning and the storyteller spawning a new event.
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
						node.faction = event.get("owner_ship_faction","civilian")					# The faction used by the NPC ship.
						node.claimFaction = event.get("claim_beacon_faction","civilianclaim")		# The faction used by the claim beacon.
						node.postfix = event.get("postfix","")										# String used to randomize the beacon event for setting the transponder code's suffix number. Vanilla beacons typically use the beacon event's number, but can be any string.
						node.transponderFormat = event.get("transponder_format","%s-CB%d")			# The format the beacon's transponder will use. MUST contain both a `%s` and `%d` once each for the code and suffix respectively.
						node.customTransponder = event.get("custom_transponder","")					# A custom transponder ID for the NPC.
						node.customName = event.get("customName","")								# A custom ship name for the NPC.
						node.lockOutStory = event.get("lock_out_story","")							# If set, a story flag that when reached prevents this event from ever spawning.
						node.lockOutLimit = max(event.get("lock_out_limit",1),0)					# Minimum value for the story flag to prevent the event from spawning.
						node.awayRadius = max(event.get("away_radius",10000),0)						# Radius which the event checks for any POI, which if any exist, prevents the event from being chosen by the storyteller.
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
						node.nrMin = max(event.get("minimum_count",2),0)							# Minimum number of bodies that can be found.
						node.nrMax = max(event.get("maximum_count",10),0)							# Maximum number of bodies that can be found.
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
						node.rotationVelocity = event.get("maximum_angular_velocity",0.2)			# Maximum angular velocity each body is given, measured in radians per second.
						node.commonRandomVectorVelocity = event.get("maximum_velocity",30.0)		# Maximum velocity that the bodies are given, measured with 1 unit = 100 cm.
						node.chaosLimit = clamp(event.get("chaos",0.0),0,1)							# The minimum chaos needed to spawn the event.
					"flight_for_rescue":
						node.time = max(event.get("time",180),0)
						node.maxLinear = event.get("maximum_velocity",100)							# Maximum random velocity that the bodies are given, measured with 1 unit = 100 cm.
						node.maxAngular = event.get("maximum_angular_velocity",2)					# Maximum angular velocity that the ship can be set to, measured in radians per second.
						node.gauss = max(event.get("gauss",6),0)									# Power the random value used to set random linear and angular velocities to. Used as pow(randf(), gauss).
						var derelictConversation = event.get("derelict_conversation","res://comms/conversation/DerelictConversation.tscn") # The scene for the derelict K37's comms node.
						if pointers.DataFormat.__file_exists(derelictConversation):
							node.derelictConversation = load(derelictConversation)
						else:
							node.derelictConversation = load("res://comms/conversation/DerelictConversation.tscn")
					"humongous_hollow_rock":
						var rock = event.get("rock_scene","res://story/Moonlet.tscn")				# The rock scene spawned by this event.
						if pointers.DataFormat.__file_exists(rock):
							node.rock = load(rock)
						else:
							node.rock = load("res://story/Moonlet.tscn")
						node.pirateChance = clamp(event.get("pirate_chance",0.5),0,1)				# The rock scene's base chance for a pirate encounter
						node.crystalChance = clamp(event.get("crystal_chance",0.5),0,1)				# The rock scene's base chance for crystals to spawn
						node.angular = max(event.get("maximum_angular_velocity",0.0025),0)			# Maximum angular velocity scale for the rock, measured in radians per second.
						node.locationOffsetStability = max(event.get("location_offset_stability",100000),0) # Grid cell size (both x & y) to determine the POI's unique identifier, measured with 1 unit = 100 cm. 
						node.awayRadius = max(event.get("away_radius",100000),0)					# Radius which the event checks for any POI, which if any exist, prevents the event from being chosen by the storyteller.
						node.lockOutMyEvent = event.get("lock_out_event",false)						# Whether the event won't spawn if you have another of the same event in your POI list.
						node.chaosLimit = clamp(event.get("chaos",0.0),0,1)							# The minimum chaos needed to spawn the event.
					"hybrid_hunter":
						node.minCapacity = clamp(event.get("minimum_capacity",0.6),0,1)				# If on Balanced difficulty, the minimum status percentage that must be met for the event to spawn. This value is equivalent to the status percentage shown on the EIME and OCP HUDs.
						node.minMoney = max(event.get("minimum_money",30000),0)						# If on Balanced difficulty, the minimum amount of money that the player must have in the bank for the event to spawn.
						node.chaosLimit = clamp(event.get("chaos",0.0),0,1)							# The minimum chaos needed to spawn the event.
					"instance_with_chance":
						var rock = event.get("rock_scene","res://story/Moonlet.tscn")				# The rock scene spawned by this event.
						if pointers.DataFormat.__file_exists(rock):
							node.rock = load(rock)
						else:
							node.rock = load("res://story/Moonlet.tscn")
						var knownRock = event.get("known_rock_scene","")							# The rock scene spawned by this event, either it's not a singular event and the POI has not expired within the astrogation list, or it's a singular event and you've encountered it before.
						if pointers.DataFormat.__file_exists(knownRock):
							node.knownRock = load(knownRock)
						else:
							node.knownRock = load("res://story/Moonlet.tscn")
						var maxDensity = event.get("maxDensity",PoolIntArray([1000, 1000, 1000, 1000, 1000])) # The maximum perceived density of the ring at the event's spawn point, taking into account other ship events in the area. I recommend using the position display debug tool to get a feel as to how this array works.
						var md:PoolIntArray = PoolIntArray([1000, 1000, 1000, 1000, 1000])
						var mdSize = maxDensity.size() - 1
						for i in range(5):
							if i > mdSize:
								md[i] = 1000
							else:
								md[i] = max(int(maxDensity[i]),0)
						node.maxDensity = md
						node.poi = event.get("poi_name","")											# The name used for the POI if the rock/known rock is a discoverable object, and for any checks performed to determine whether the rock or known rock objects are spawned
						node.transponder = event.get("transponder","")								# If set, and the rock/known rock object has the transponder property, sets the transponder of the object.
						node.customName = event.get("custom_name","")								# If set, and the rock/known rock has the 'setShipName' method, sets the custom name of the object.
						node.single = event.get("single",false)										# Used to determine if the rock or known rock object is spawned. See description for known_rock to see what this does.
						node.awayRadius = max(event.get("away_radius",100000),0)					# Radius which the event checks for any POI, which if any exist, prevents the event from being chosen by the storyteller.
						node.lockOutStory = event.get("lock_out_story","")							# If set, a story flag that when reached prevents this event from ever spawning.
						node.lockOutLimit = max(event.get("lock_out_limit",1),0)					# Minimum value for the story flag to prevent the event from spawning.
						node.lockoutPoi = event.get("lock_out_if_poi","")							# If set, prevents the Storyteller from spawning this event if another POI uses this name
						node.lockOutEvent = event.get("lock_out_if_event","")						# If set, prevents the Storyteller from spawning this event if another POI uses the same event as this
						node.lockOutMyEvent = event.get("lock_out_event",false)						# Whether the event won't spawn if you have another of the same event in your POI list.
						node.chaosLimit = clamp(event.get("chaos",0.0),0,1)							# The minimum chaos needed to spawn the event.
					"inter_crew_banter":
						var beacon = event.get("beacon","res://story/TighbeamBeacon.tscn")			# The scene for the comms beacon used by the event. 
						if pointers.DataFormat.__file_exists(beacon):
							node.beacon = load(beacon)
						else:
							node.beacon = load("res://story/TighbeamBeacon.tscn")
						node.awayRadius = max(event.get("away_radius",0),0)							# If set above zero, radius which the event checks for any POI, which if any exist, prevents the event from being chosen by the storyteller.
						node.serviceCooldown = event.get("service_cooldown","")						# If set, checks for the provided service. If the service is not on cooldown (i.e. unable to be purchased), the event cannot spawn.
						node.chaosLimit = clamp(event.get("chaos",0.0),0,1)							# The minimum chaos needed to spawn the event.
					"lifepod_is_floating":
						var lifepod = event.get("lifepod","res://ships/Lifepod.tscn")				# The lifepod/ship scene spawned by this event.
						if pointers.DataFormat.__file_exists(lifepod):
							node.lifepod = load(lifepod)
						else:
							node.lifepod = load("res://ships/Lifepod.tscn")
						node.processedCargo = event.get("processed_cargo",false)					# If the ship node should have a random amount of processed cargo added to it.
						node.processedCargoMax = clamp(event.get("processed_cargo_max",1),0,1)		# The maximum fill percentage which all processed holds can be filled to
						node.processedCargoMin = clamp(event.get("processed_cargo_min",0),0,1)		# The minimum fill percentage which all processed holds can be filled to
					"locust_swarm":
						var beacon = event.get("beacon","res://story/Locust.tscn")					# The scene for the comms beacon used by the event. 
						if pointers.DataFormat.__file_exists(beacon):
							node.beacon = load(beacon)
						else:
							node.beacon = load("res://story/Locust.tscn")
						node.number = max(event.get("number",10),0)									# The number of beacons that would be spawned.
						node.lockOutStory = event.get("lock_out_story","")							# If set, a story flag that when reached prevents this event from ever spawning.
						node.lockOutLimit = max(event.get("lock_out_limit",1),0)					# Minimum value for the lock out story flag to prevent the event from spawning.
						node.requireStory = event.get("require_story","")							# If set, a required story flag that must be reached to let the Storyteller to spawn this event.
						node.requireMin = max(event.get("require_limit",1),0)						# Minimum value for the required story flag to be reached to permit the event to spawn.
						node.awayRadius = max(event.get("away_radius",0),0)							# If set above zero, radius which the event checks for any POI, which if any exist, prevents the event from being chosen by the storyteller.
						node.chaosLimit = clamp(event.get("chaos",0.0),0,1)							# The minimum chaos needed to spawn the event.
					"minefield":
						var mine = event.get("mine","res://ships/drone/DroneMine.tscn")				# The scene for the ships/mines spawned by this event.
						if pointers.DataFormat.__file_exists(mine):
							node.mine = load(mine)
						else:
							node.mine = load("res://ships/drone/DroneMine.tscn")
						node.shipLimit = event.get("ship_limit",4)									# Maximum number of ships that can be in the rings to still spawn the event
						node.hostile = event.get("hostile",false)									# If difficulty should be a factor for limiting this event
						node.minCapacity = clamp(event.get("minimum_capacity",0.8),0,1)				# If hostile is set and while on Balanced difficulty, the minimum status percentage that must be met for the event to spawn. This value is equivalent to the status percentage shown on the EIME and OCP HUDs.
						node.minMoney = max(event.get("minimum_money",10000),0)						# If hostile is set and while on Balanced difficulty, the minimum amount of money that the player must have in the bank for the event to spawn.
						node.chaosLimit = clamp(event.get("chaos",0.0),0,1)							# The minimum chaos needed to spawn the event.
					"miner_mining":
						node.ship = event.get("ship_model","TRTL")									# The model for the NPC ship.
						node.faction = event.get("ship_faction","civilian")							# The faction used by the NPC ship.
						node.customTransponder = event.get("custom_transponder","")					# A custom transponder ID for the NPC.
						node.customName = event.get("customName","")								# A custom ship name for the NPC.
						node.lockoutPoi = event.get("lock_out_if_poi","")							# If set, prevents the Storyteller from spawning this event if another POI uses this name
						node.lockOutStory = event.get("lock_out_story","")							# If set, a story flag that when reached prevents this event from ever spawning.
						node.lockOutLimit = max(event.get("lock_out_limit",1),0)					# Minimum value for the story flag to prevent the event from spawning.
						node.awayRadius = max(event.get("away_radius",10000),0)						# Radius which the event checks for any POI, which if any exist, prevents the event from being chosen by the storyteller.
						node.overrideCourse = event.get("override_course",false)					# Whether the NPC should have a predetermined direction to fly in.
						node.course = event.get("course",Vector2(0,0))								# If override course is set, the direction the ship will aim to fly in. (0,0) has the ship intent on staying put.
						node.chaosLimit = clamp(event.get("chaos",0.0),0,1)							# The minimum chaos needed to spawn the event.
					"pirate_combat":
						node.depthMinKm = max(event.get("minimum_depth_in_km",30),0)				# Minimum depth that the event is permitted to spawn at, in kilometers.
						node.depthMaxKm = max(event.get("maximum_depth_in_km",2970),0)				# Maximum depth that the event is permitted to spawn at, in kilometers.
						node.lootMin = max(event.get("minimum_ores",0),0)							# Minimum number of ores that can be spawned by this event.
						node.lootMax = max(event.get("maximum_ores",20),0)							# Maximum number of ores that can be spawned by this event.
						node.hasCivilian = event.get("has_civilian",true)							# Whether to spawn a miner NPC
						node.hasPirate = event.get("has_pirate",true)								# Whether to spawn a pirate NPC
						var bounty = event.get("bounty","res://ships/LifepodPirate.tscn")			# If has pirate is set, the scene used for the pirate's lifepod.
						if pointers.DataFormat.__file_exists(bounty):
							node.bounty = load(bounty)
						else:
							node.bounty = load("res://ships/LifepodPirate.tscn")
						node.minCapacity = clamp(event.get("minimum_capacity",0.8),0,1)				# If on Balanced difficulty, the minimum status percentage that must be met for the event to spawn. This value is equivalent to the status percentage shown on the EIME and OCP HUDs.
						node.minMoney = max(event.get("minimum_money",10000),0)						# If on Balanced difficulty, the minimum amount of money that the player must have in the bank for the event to spawn.
						node.lockOutStory = event.get("lock_out_story","g4a.destroyed")				# If set, a story flag that when reached prevents this event from ever spawning.
						node.lockOutLimit = max(event.get("lock_out_limit",1),0)					# Minimum value for the story flag to prevent the event from spawning.
						node.chaosLimit = clamp(event.get("chaos",0.0),0,1)							# The minimum chaos needed to spawn the event.
					"pirate_trap":
						node.depthMinKm = max(event.get("minimum_depth_in_km",30),0)				# Minimum depth that the event is permitted to spawn at, in kilometers.
						node.depthMaxKm = max(event.get("maximum_depth_in_km",2970),0)				# Maximum depth that the event is permitted to spawn at, in kilometers.
						var bounty = event.get("bounty","res://ships/LifepodPirate.tscn")			# The scene used for the pirate's lifepod.
						if pointers.DataFormat.__file_exists(bounty):
							node.bounty = load(bounty)
						else:
							node.bounty = load("res://ships/LifepodPirate.tscn")
						var lifepod = event.get("lifepod","res://ships/Lifepod.tscn")				# The lifepod/ship scene spawned by this event.
						if pointers.DataFormat.__file_exists(lifepod):
							node.lifepod = load(lifepod)
						else:
							node.lifepod = load("res://ships/Lifepod.tscn")
						node.minMoney = max(event.get("minimum_money",10000),0)						# If on Balanced difficulty, the minimum amount of money that the player must have in the bank for the event to spawn.
						node.lockOutStory = event.get("lock_out_story","g4a.destroyed")				# If set, a story flag that when reached prevents this event from ever spawning.
						node.lockOutLimit = max(event.get("lock_out_limit",1),0)					# Minimum value for the story flag to prevent the event from spawning.
						node.awayRadius = max(event.get("away_radius",10000),0)						# Radius which the event checks for any POI, which if any exist, prevents the event from being chosen by the storyteller.
						node.chaosLimit = clamp(event.get("chaos",0.0),0,1)							# The minimum chaos needed to spawn the event.
					"rescue_operation":
						node.randomChance = clamp(event.get("random_chance",1.0),0,1)				# Base chance that the event will spawn, scaled at 0 E$
						node.minimumChance = clamp(event.get("minimum_chance",1.0),0,1)				# The absolute minimum chance that the event will spawn, even with infinite cash.
						node.moneyCeiling = max(event.get("money_ceiling",10000000.0),100000.0)		# Divisor for the total cash in bank when used to scale the random chance. Lower values means that the minimum chance is reached with lower amounts of cash in the bank.
						node.reEncouterChance = clamp(1.0 - event.get("stock_chance",0.2),0,1)		# Chance that the derelict, and if applicable, pirate will be in pristine condition.
						node.maxLinear = event.get("maximum_velocity",500.0)						# Maximum velocity for the derelict, measured with 1 unit = 100 cm.
						node.maxAngular = event.get("maximum_angular_velocity",0.5)					# Maximum angular velocity for the derelict, measured in radians per second.
						node.gauss = max(event.get("gauss",2),0)									# Power the random value used to set random linear and angular velocities to. Used as pow(randf(), gauss).
						node.damageDerelict = event.get("damage_derelict",true)						# Whether the derelict should be damaged based on the age of the hull.
						node.model = event.get("ship_model","TRTL")									# The ship model for the derelict.
						node.extraDamage = event.get("extra_damage",true)
						node.extraKinetic = max(event.get("extra_kinetic_damage",100000.0),0)		# Scale for kinetic damage to deal to the derelict when extra_damage is enabled.
						node.extraEmp = max(event.get("extra_emp_damage",100000.0),0)				# Scale for emp damage to deal to the derelict when extra_damage is enabled.
						node.extraRadius = max(event.get("extra_damage_radius",100),0)				# Base radius of the circle where the point extra damage is inflicted can occur within. Measured with 1 unit = 100cm.
						node.specificShipName = event.get("specific_ship_name","")					# Sets a specific name for the derelict. Typically only used for POIs with params, such as SRO broadcasts.
						node.wreck = event.get("derelict",true)										# Whether this event spawns a derelict.
						node.rescue = event.get("rescue",true)										# Whether this event spawns a SAR CERF.
						var derelictConversation = event.get("derelict_conversation","res://comms/conversation/DerelictConversation.tscn") # The conversation player node to use. Defaults to the missing sibling conversation.
						if pointers.DataFormat.__file_exists(derelictConversation):
							node.derelictConversation = load(derelictConversation)
						else:
							node.derelictConversation = load("res://comms/conversation/DerelictConversation.tscn")
						node.denseClusterChance = clamp(event.get("ringroid_cluster_chance",0.3),0,1) # The chance that the event spawns inside of a cluster of Class 1 and Class 2 ringroids.
						node.denseClusterNumber = max(event.get("ringroid_cluster_number",33),0)	# The number of ringroids that are spawned if the event is set to spawn with any.
						node.clump = event.get("clump_objects",false)								# Whether all the event's objects should instead clump towards the event origin.
						node.clumpVelocity = event.get("clump_velocity",250)						# If clumping, the velocity at which all objects clump, measured with 1 unit = 100 cm.
						node.stormChance = clamp(event.get("storm_chance",0.3),0,1)					# The chance that the event will have a ringstorm occur.
						node.pirateChance = clamp(event.get("pirate_chance",0.3),0,1)				# The chance that the event will have a pirate CERF spawn.
						var stormBeacon = event.get("storm_beacon","res://story/StormBeacon.tscn") 	# The storm beacon node. Used to handle the ringstorm if it happens.
						if pointers.DataFormat.__file_exists(stormBeacon):
							node.stormBeacon = load(stormBeacon)
						else:
							node.stormBeacon = load("res://story/StormBeacon.tscn")
						var bounty = event.get("bounty","res://ships/LifepodPirate.tscn")			# The scene used for the pirate's lifepod.
						if pointers.DataFormat.__file_exists(bounty):
							node.bounty = load(bounty)
						else:
							node.bounty = load("res://ships/LifepodPirate.tscn")
						node.chaosLimit = clamp(event.get("chaos",0.0),0,1)							# The minimum chaos needed to spawn the event.
					"ring_race":
						node.depthMinKm = max(event.get("minimum_depth_in_km",0),0)					# Minimum depth that the event is permitted to spawn at, in kilometers.
						node.depthMaxKm = max(event.get("maximum_depth_in_km",10000),0)				# Maximum depth that the event is permitted to spawn at, in kilometers.
						node.racerModel = event.get("ship_model","PROSPECTOR-BALD")					# Ship model for the main racer/ship.
						node.faction = event.get("ship_faction","racer")							# The faction of the main racer/ship.
						node.racerNumber = max(event.get("ship_number",1),0)						# The number of main racers/ships that this event can spawn.
						node.droneModel = event.get("drone_model","DRONE")							# Ship model for the drone ship.
						node.droneFaction = event.get("drone_faction","racedrone")					# The faction of the drone ship.
						node.droneNumber = max(event.get("drone_number",0),0)						# The number of drone ships that this event can spawn.
						node.reEncouterChance = clamp(1.0 - event.get("stock_chance",0.2),0,1)		# Chance that the racers/ships and drones will be in pristine condition.
					"singularity":
						var misc = event.get("misc",PoolStringArray([								# PoolStringArray/Array of filepaths to the scenes to be used for the miscelaneous objects/ores in the event.
							"res://asteroids/mineral-fe-1.tscn",
							"res://asteroids/mineral-fe-2.tscn", 
							"res://asteroids/mineral-fe-3.tscn", 
							"res://asteroids/mineral-fe-4.tscn", 
							"res://asteroids/mineral-fe-5.tscn", 
							"res://asteroids/mineral-fe-6.tscn", 
							"res://asteroids/mineral-fe-7.tscn", 
						]))
						var bd:Array = []
						for body in misc:
							if pointers.DataFormat.__file_exists(body):
								bd.append(load(body))
						node.misc = bd
						var main = event.get("main","res://story/SingularityCore.tscn") 			# The scene for the main event object.
						if pointers.DataFormat.__file_exists(main):
							node.main = load(main)
						else:
							node.main = load("res://story/SingularityCore.tscn")
						node.nrMin = max(event.get("minimum_count",2),0)							# Minimum number of miscelaneous objects that can be found.
						node.nrMax = max(event.get("maximum_count",10),0)							# Maximum number of miscelaneous objects that can be found.
						node.rotationVelocity = event.get("maximum_angular_velocity",0.2)			# Maximum angular velocity each body is given, measured in radians per second.
						node.commonRandomVectorVelocity = event.get("maximum_velocity",30.0)		# Maximum velocity that the bodies are given, measured with 1 unit = 100 cm.
						node.miscRandomVelocity = event.get("additional_random_velocity",0)			# Maximum additional velocity that can be randomly added to each object's base velocity.
						node.chaosLimit = clamp(event.get("chaos",0.0),0,1)							# The minimum chaos needed to spawn the event.
					"tesla_is_floating":
						var tesla = event.get("tesla","res://easters/Tesla.tscn")	 				# The scene for the event object.
						if pointers.DataFormat.__file_exists(tesla):
							node.tesla = load(tesla)
						else:
							node.tesla = load("res://easters/Tesla.tscn")
						node.myLine = event.get("event_story_flag","easters.tesla")					# Unique story for this event. This flag must be zero for the event to spawn, and once the event object is considered inside cargo bay, this flag is set to one.
					"timed_event":
						var rock = event.get("rock_scene","res://easters/Helloroid.tscn")			# The rock scene spawned by this event.
						if pointers.DataFormat.__file_exists(rock):
							node.rock = load(rock)
						else:
							node.rock = load("res://easters/Helloroid.tscn")
						node.angularVelocity = event.get("maximum_angular_velocity",0.05)			# Maximum angular velocity for the derelict, measured in radians per second.
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
						node.awayRadius = max(event.get("away_radius",10000),0)						# Radius which the event checks for any POI, which if any exist, prevents the event from being chosen by the storyteller.
						node.chaosLimit = clamp(event.get("chaos",0.0),0,1)							# The minimum chaos needed to spawn the event.
					"vilcy":
						node.depthMinKm = max(event.get("minimum_depth_in_km",0),0)					# Minimum depth that the event is permitted to spawn at, in kilometers.
						node.depthMaxKm = max(event.get("maximum_depth_in_km",10000),0)				# Maximum depth that the event is permitted to spawn at, in kilometers.
						node.vilcyPatroler = max(event.get("vilcyPatroler",0),0)					# 
						node.vilcyDisabler = max(event.get("vilcyDisabler",0),0)					# 
						node.vilcyBurner = max(event.get("vilcyBurner",0),0)						# 
						node.vilcyLone = max(event.get("vilcyLone",0),0)							# 
						node.initialPirates = max(event.get("initialPirates",0),0)					# 
						node.laterPirates = max(event.get("laterPirates",0),0)						# 
						node.pirateAbductors = max(event.get("pirateAbductors",0),0)				# 
						node.pirateg4a = max(event.get("pirateg4a",0),0)							# 
						node.pirateRevenger = max(event.get("pirateRevenger",0),0)					# 
						node.vilcyRevenger = max(event.get("vilcyRevenger",0),0)					# 
						node.loneSupport = max(event.get("loneSupport",0),0)						# 
			
			if do_add:
				var custom_property_modifications:Dictionary = event.get("custom_property_modifications",{})
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
