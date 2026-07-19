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
						node.shipNameAgenda = event.get("agenda_ship_name","{agenda/ship/0/shipname}") # Ship name that would be consistently given based on the specific crew agenda
						var derelictConversation = event.get("derelict_conversation_node_path","res://comms/conversation/AgendaDerelictConversation.tscn") # The conversation player node to use. Defaults to the missing sibling conversation.
						if pointers.DataFormat.__file_exists(derelictConversation):
							node.derelictConversation = load(derelictConversation)
						else:
							node.derelictConversation = load("res://comms/conversation/AgendaDerelictConversation.tscn")
						node.extraKinetic = event.get("extra_kinetic_damage",100000.0)				# Scale for kinetic damage to deal to the ship when extra_damage is enabled
						node.extraEmp = event.get("extra_emp_damage",100000.0)						# Scale for emp damage to deal to the ship when extra_damage is enabled
						node.extraRadius = event.get("extra_damage_radius",100)						# Base radius of the circle where the point extra damage is inflicted can occur within. Measured 1 unit is 10cm
						node.gauss = event.get("gauss",2)											# Power the random value generated for the extra damage and damage radius is multiplied by. i.e. pow(randf(), gauss)
						node.empty = event.get("empty",false)										# Drains the ship of all propellant
						node.damageDerelict = event.get("damage_derelict",false)					# Whether the ship should be damaged based on the age of the hull.
						node.imperative = event.get("imperative",10)								# The AI mode that the ship would boot with. Uses the AI enumeration in res://ships/ship-ctrl.gd
						node.imperativeStrength = event.get("imperative_strength",20)				# The threshhold needed to meet for the ship AI to change AI mode.
						node.chaosLimit = clamp(event.get("chaos",0),0,1)							# If available to spawn through the Storyteller, the minimum chaos needed to spawn the event.
					"aiming_asteroid":
						
						pass
					
					
			
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
