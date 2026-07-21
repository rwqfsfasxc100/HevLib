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


# This file contains constants that match all Vanilla event scripts that are currently supported by EVENT_DRIVER.gd
# All values are their defaults. Each event also gets a basic usage blurb and mentions all events related to the
# specific event mechanic type.
# NOTE: All events use an `event_name` and `event_type` to define the node name and event handle respectively, with
# each event described here using the name of a Vanilla event using this, but without it's specific properties.
# All events can also make use of a `custom_property_modifications` dictionary, which gives the ability to arbritrarily
# modify any property, useful for modifying properties not exposed through an event type's regular properties, or for 
# modifying any properties added to an event via a mod. It is also the only way to modify properties for a custom event.
# Each dictionary can be validated with a `config`, `mod_requirements`, and/or `mod_incompatibilities` entry.

# If you want to add a custom event, use the following code using `script` as the event type.
# Custom events make use of a `script_path` property to define the event's script.
const CUSTOM_EVENT = {
	"event_name":"CustomEvent",
	"event_type":"script",
	"script_path":"res://HevLib/events/custom_events/custom_event.gd",
	"custom_property_modifications":{
		"randomChance":0.5
	},
	"config":{
		"mod":"VelocityPlus",
		"section":"VP_RING",
		"entry":"broadcast_variations",
		"invert":false
	},
	"mod_requirements":[
		"hev.LIBRARY"
	],
	"mod_incompatibilities":[
		"hev.IndustriesOfEnceladus"
	]
}

# If you want to change the timer for events, use the `event_delay` type. No event name is needed here.
# `operation` dictates how the timer is changed.
#   `set` uses the provided delay
#   `add` adds the provided delay
#   `subtract` removed the provided delay
#   `multiply` multiplies the current time by the provided delay
#   `divide` divides the current time by the provided delay
#   Defaults to `set`
# `delay_time` is the time to change the timer with, based on the operation.
const EVENT_DELAY = {
	"event_type":"event_delay",
	"operation":"set",
	"delay_time":450
}

# Event spawning a derelict related to a specific agenda.
# Used by the following Vanilla events:
# - DerelictSisterShip
# Parameters:
# - ship_model - The ship to be used for the derelict.
# - booted_up - Whether the derelict's reactor would be online when the event is spawned.
# - extra_damage - Whether the derelict should undergo additional, artificial damage.
# - event_only - Whether this event should be POI only. Setting this false permits the Storyteller to randomly select it.
# - crew_agenda - Agenda that MUST be present within your crew for the event to spawn.
# - agenda_ship_name - Name given to the ship from translated dictionary. Hint: for a completely random name, use `{random/ship/0/shipname}`. For more information, see Tool.getTranslationDictionary().
# - derelict_conversation - The conversation player node to use for the derelict.
# - extra_kinetic_damage - Scale for kinetic damage to deal to the derelict when extra_damage is enabled.
# - extra_emp_damage - Scale for emp damage to deal to the derelict when extra_damage is enabled.
# - extra_damage_radius - Base radius of the circle where the point extra damage is inflicted can occur within.
# - gauss - Power the random value generated for the extra damage and damage radius is multiplied by. i.e. pow(randf(), gauss).
# - empty - Drains the derelict of all propellant.
# - damage_derelict - Whether the derelict should be damaged based on the age of the hull.
# - imperative - The AI mode that the derelict would boot with. Uses the AI enumeration in res://ships/ship-ctrl.gd.
# - imperative_strength - The threshhold needed to meet for the derelict AI to change AI mode if it were to be booted.
# - chaos - If available to spawn through the Storyteller, the minimum chaos needed to spawn the event.
const agenda_specific_derelict = {
	"event_name":"DerelictSisterShip",
	"event_type":"agenda_specific_derelict",
	"ship_model":"AT225-R",
	"booted_up":false,
	"extra_damage":false,
	"event_only":true,
	"crew_agenda":"AGENDA_LOOKING_FOR_SIBLING",
	"agenda_ship_name":"{agenda/ship/0/shipname}",
	"derelict_conversation":"res://comms/conversation/AgendaDerelictConversation.tscn",
	"extra_kinetic_damage":100000.0,
	"extra_emp_damage":100000.0,
	"extra_damage_radius":100,
	"gauss":2,
	"empty":false,
	"damage_derelict":false,
	"imperative":15,
	"imperative_strength":20,
	"chaos":0.0
}

# Event spawning a number of Class 1 (largest size) ringroids.
# Used by the following Vanilla events:
# - AimingAsteroid
# - AsteroidCluster
# - AsteroidCollision
# Parameters:
# - number - The number of ringroids to spawn
# - maximum_angular_velocity - Maximum angular velocity that the ringroid(s) can be given, measured in radians per second.
# - aim - Whether the ringroid(s) should target the player's current trajectory.
# - maximum_velocity - The velocity of the ringroids.
# - clump - Whether the ringroid(s) should instead target the event's origin point. This overrides `aim`.
# - max_density - The maximum perceived density of the ring at the event's spawn point, taking into account other ship events in the area. This is not inherently obvious, which I recommend using the position display debug tool to get a feel as to how this array works.
# - chaos - If available to spawn through the Storyteller, the minimum chaos needed to spawn the event.
const aiming_asteroid = {
	"event_name":"AsteroidCluster",
	"event_type":"aiming_asteroid",
	"number":1,
	"maximum_angular_velocity":1.0,
	"aim":true,
	"maximum_velocity":25.0,
	"clump":false,
	"max_density":PoolIntArray([1000, 1000, 1000, 1000, 1000]),
	"chaos":0.0
}

# Event spawning a number of Class 5 (smallest size) ringroids.
# Used by the following Vanilla events:
# - AimingAsteroidShower
# Parameters:
# - number - The number of ringroids to spawn.
# - maximum_velocity - Base maximum velocity for the ringroids.
# - random_velocity - Additional randomness added or subtracted from the velocity.
# - maximum_angular_velocity - Maximum angular velocity that the ringroids can be given, measured in radians per second.
# - density_limit - The maximum raw density of the rings to permit the event to spawn, i.e. the density as would be described from the visfeed.
# - chaos - If available to spawn through the Storyteller, the minimum chaos needed to spawn the event.
const aiming_asteroid_shower = {
	"event_name":"AimingAsteroidShower",
	"event_type":"aiming_asteroid_shower",
	"number":20,
	"maximum_velocity":200.0,
	"random_velocity":10.0,
	"maximum_angular_velocity":5.0,
	"density_limit":0.2,
	"chaos":0.0
}

# Event used to handle beacons that can spawn an additional random event. These events cannot spawn naturally.
# Used by the following Vanilla events:
# - ClaimBeacon-1
# - ClaimBeacon-2
# Parameters:
# - claim_beacon - The scene for the claim beacon. NOTE: If using as actual claim beacons, these scenes must be unique to provide the beacon-specific dialogue trees.
# - already_claimed - Fallback scene if the transponder for the event's claim beacon transponder is already an active transponder for whatever reason. The default scene should be sufficient for a fallback, but useful to override for additional handling.
# - spawn_evemt - Whether the beacon should force an event to spawn.
# - event_delay - Delay between the beacon event spawning and the storyteller spawning a new event.
# - single_event - If this specific beacon event should only permit one event spawn per dive.
# - postfix - String used to randomize the beacon event for setting the transponder code's suffix number. Vanilla beacons typically use the beacon's specific event number, but can be any string.
# - transponder_format - The format the beacon's transponder will use. MUST contain both a `%s` and `%d` once each for the code and suffix respectively.
const claim_beacon = {
	"event_name":"ClaimBeacon-1",
	"event_type":"claim_beacon",
	"claim_beacon":"res://ships/drone/ClaimBeacon.tscn",
	"already_claimed":"res://story/DummyBeacon.tscn",
	"spawn_evemt":true,
	"event_delay":30,
	"single_event":true,
	"postfix":"",
	"transponder_format":"%s-CB%d"
}

# Spawns an NPC ship and a secondary object (i.e. foreign claim beacon) from a scene.
# Used by the following Vanilla events:
# - ClaimBeaconForeign
# Parameters:
# - claim_beacon - The scene for the claim beacon object. Should be a ship-based object, as four properties typically only found on objects using ship-ctrl.gd are set on this object.
# - owner_ship_model - The model for the NPC ship.
# - owner_ship_faction - The faction used by the NPC ship.
# - claim_beacon_faction - The faction used by the claim beacon object.
# - postfix - String used to randomize the beacon event for setting the transponder code's suffix number. Vanilla beacons typically use the beacon event's number, but can be any string.
# - transponder_format - The format the beacon's transponder will use. MUST contain both a `%s` and `%d` once each for the code and suffix respectively.
# - custom_transponder - A custom transponder ID for the NPC.
# - custom_name - A custom ship name for the NPC.
# - lock_out_story - If set, a story flag that when reached prevents this event from ever spawning.
# - lock_out_limit - Minimum value for the story flag to prevent the event from spawning.
# - away_radius - Radius which the event checks for any POI, which if any exist, prevents the event from being chosen by the storyteller.
# - chaos - If available to spawn through the Storyteller, the minimum chaos needed to spawn the event.
const claim_beacon_foreign = {
	"event_name":"ClaimBeaconForeign",
	"event_type":"claim_beacon_foreign",
	"claim_beacon":"res://ships/drone/ClaimBeaconForeign.tscn",
	"owner_ship_model":"TRTL",
	"owner_ship_faction":"civilian",
	"claim_beacon_faction":"civilianclaim",
	"postfix":"",
	"transponder_format":"%s-CB%d",
	"custom_transponder":"",
	"custom_name":"",
	"lock_out_story":"",
	"lock_out_limit":1,
	"away_radius":10000,
	"chaos":0.0
}

# Spawns a random amount of a random selection of objects alongside a singular, beacon/ship object.
# Used by the following Vanilla events:
# - DeadBody
# Parameters:
# - beacon - Main beacon or ship object. Used as the parent for the body transponders.
# - bodies - PoolStringArray/Array of filepaths to the scenes to be used for the randomly selected bodies/secondary ships in the event.
# - minimum_count - Minimum number of bodies that can be found.
# - maximum_count - Maximum number of bodies that can be found.
# - times - Array of Vector2s or 2 index Arrays/PoolIntArrays that dictate the IRL dates where the event will always pass the storyteller check and not need to meet the chaos to spawn.
# - maximum_angular_velocity - Maximum angular velocity each body is given, measured in radians per second.
# - maximum_velocity - Maximum velocity that the bodies are given.
# - chaos - If available to spawn through the Storyteller, the minimum chaos needed to spawn the event when not at one of the dates defined by `times`.
const dead_body = {
	"event_name":"DeadBody",
	"event_type":"dead_body",
	"beacon":"res://story/DeadTalkingBeacon.tscn",
	"bodies":PoolStringArray([
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
	]),
	"minimum_count":2,
	"maximum_count":10,
	"times":PoolVector2Array([
		Vector2(10, 25), 
		Vector2(10, 26), 
		Vector2(10, 27), 
		Vector2(10, 28), 
		Vector2(10, 29), 
		Vector2(10, 31), 
		Vector2(11, 1)
	]),
	"maximum_angular_velocity":0.2,
	"maximum_velocity":3.0,
	"chaos":0.0
}

# Spawns a SAR CERF with a derelict K37 spawning later.
# Used by the following Vanilla events:
# - FlightForRescue
# Parameters:
# - time - Delay before the derelict K37 spawns.
# - maximum_velocity - Maximum random velocity that the bodies are given.
# - maximum_angular_velocity - Maximum angular velocity that the ship can be set to, measured in radians per second.
# - gauss - Power the random value used to set random linear and angular velocities to. Used as pow(randf(), gauss).
# - derelict_conversation - The scene for the derelict K37's comms node.
const flight_for_rescue = {
	"event_name":"FlightForRescue",
	"event_type":"flight_for_rescue",
	"time":180,
	"maximum_velocity":10.0,
	"maximum_angular_velocity":2,
	"gauss":6,
	"derelict_conversation":"res://comms/conversation/DerelictConversation.tscn"
}

# Spawns an object with location-specific parameters, with the ability to set moonlet-related parameters.
# Used by the following Vanilla events:
# - Humongus
# - Moonlet
# - Addlet
# - BigMoonlet
# - BigMoonletCaves
# - BiggerMoonletSpelunker
# - BiggerMoonletLocust
# Parameters:
# - rock_scene - The rock scene spawned by this event.
# - pirate_chance - The rock scene's base chance for a pirate encounter. Will not be set if the rock scene does not have the `crystalChance` property.
# - crystal_chance - The rock scene's base chance for crystals to spawn. Will not be set if the rock scene does not have the `pirateChance` property.
# - maximum_angular_velocity - Maximum angular velocity scale for the rock, measured in radians per second.
# - location_offset_stability - Grid cell size (both x & y) to determine the POI's unique position to randomize it's specific rotational velocity.
# - away_radius - Radius which the event checks for any POI, which if any exist, prevents the event from being chosen by the storyteller.
# - lock_out_event - Whether the event won't spawn if you have another of the same event in your POI list.
# - chaos - If available to spawn through the Storyteller, the minimum chaos needed to spawn the event.
const humongous_hollow_rock = {
	"event_name":"Humongus",
	"event_type":"humongous_hollow_rock",
	"rock_scene":"res://story/Moonlet.tscn",
	"pirate_chance":0.5,
	"crystal_chance":0.5,
	"maximum_angular_velocity":0.0025,
	"location_offset_stability":10000.0,
	"away_radius":100000,
	"lock_out_event":false,
	"chaos":0.0
}

# Spawns the Hybrid based on a few parameters. Checks difficulty, and does not spawn in Peaceful.
# Used by the following Vanilla events:
# - HybridHunterHuntingPlayer
# Parameters:
# - minimum_capacity - If on Balanced difficulty, the minimum status percentage that must be met for the event to spawn. This value is equivalent to the status percentage shown on the EIME and OCP HUDs.
# - minimum_money - If on Balanced difficulty, the minimum amount of money that the player must have in the bank for the event to spawn.
# - chaos - If available to spawn through the Storyteller, the minimum chaos needed to spawn the event.
const hybrid_hunter = {
	"event_name":"HybridHunterHuntingPlayer",
	"event_type":"hybrid_hunter",
	"minimum_capacity":0.6,
	"minimum_money":30000,
	"chaos":0.0
}

# Spawns an event based on several ring parameters, with the ability to determine a second object if you've already encountered the event.
# Used by the following Vanilla events:
# - InRingRefuelling
# - InRingRefuelling2
# - InRingRefuelling3
# - PhageInTransit
# - DestroyedHabitat
# - Habitat02
# - Habitat03
# - Habitat04
# - Habitat05
# - Habitat06
# - Habitat07
# - PirateStation
# - SpaceBar
# - Thrusteroid
# Parameters:
# - rock_scene - The rock scene spawned by this event.
# - known_rock_scene - An alternate rock scene spawned by this event, if it's either not a singular event and the POI has not expired within the astrogation list, or it's a singular event and you've encountered it before.
# - max_density - The maximum perceived density of the ring at the event's spawn point, taking into account other ship events in the area. This is not inherently obvious, which I recommend using the position display debug tool to get a feel as to how this array works.
# - poi_name - The name used for the POI if the rock/known rock is a discoverable object, and for any checks performed to determine whether the rock or known rock objects are spawned.
# - transponder - If set, and the rock/known rock object has the transponder property, sets the transponder of the object.
# - custom_name - If set, and the rock/known rock has the 'setShipName' method, sets the custom name of the object.
# - single - Used to determine if the rock or known rock object is spawned. See description for known_rock_scene to see what this does.
# - away_radius - Radius which the event checks for any POI, which if any exist, prevents the event from being chosen by the storyteller.
# - lock_out_story - If set, a story flag that when reached prevents this event from ever spawning.
# - lock_out_limit - Minimum value for the story flag to prevent the event from spawning.
# - lock_out_if_poi - If set, prevents the Storyteller from spawning this event if another POI uses this name
# - lock_out_if_event - If set, prevents the Storyteller from spawning this event if another POI uses the same event as this.
# - lock_out_event - Whether the event won't spawn if you have another of the same event in your POI list.
# - chaos - If available to spawn through the Storyteller, the minimum chaos needed to spawn the event.
const instance_with_chance = {
	"event_name":"Habitat03",
	"event_type":"instance_with_chance",
	"rock_scene":"res://story/Moonlet.tscn",
	"known_rock_scene":"",
	"max_density":PoolIntArray([1000, 1000, 1000, 1000, 1000]),
	"poi_name":"",
	"transponder":"",
	"custom_name":"",
	"single":false,
	"away_radius":100000,
	"lock_out_story":"",
	"lock_out_limit":1,
	"lock_out_if_poi":"",
	"lock_out_if_event":"",
	"lock_out_event":false,
	"chaos":0.0
}

# Spawns an object based on ring position and an optional service availability.
# Used by the following Vanilla events:
# - InterCrewBanter
# - InterCrewBanter2
# - InterCrewBanter3
# - InterCrewBanter4
# - InterCrewBanter5
# - SalvageCall
# - SalvageCall2
# - SalvageCall3
# - RingStorm
# - XaserBurn
# Parameters:
# - beacon - The scene for the object/beacon used by the event. 
# - away_radius - If set above zero, radius which the event checks for any POI, which if any exist, prevents the event from being chosen by the storyteller.
# - service_cooldown - If set, checks for the provided service. If the service is not on cooldown (i.e. unable to be purchased), the event cannot spawn.
# - chaos - If available to spawn through the Storyteller, the minimum chaos needed to spawn the event.
const inter_crew_banter = {
	"event_name":"SalvageCall2",
	"event_type":"inter_crew_banter",
	"beacon":"res://story/TighbeamBeacon.tscn",
	"away_radius":0,
	"service_cooldown":"",
	"chaos":0.0
}

# Spawns an object at a random position and gives the option to add processed cargo.
# Used by the following Vanilla events:
# - LifepodIsFloating
# - StoragePod
# Parameters:
# - lifepod - The lifepod/object scene spawned by this event.
# - processed_cargo - If the object should have a random amount of processed cargo added to it. Object should be a ship scene to be able to accept it.
# - processed_cargo_max - The maximum fill percentage which all processed holds can be filled to.
# - processed_cargo_min - The minimum fill percentage which all processed holds can be filled to.
const lifepod_is_floating = {
	"event_name":"LifepodIsFloating",
	"event_type":"lifepod_is_floating",
	"lifepod":"res://ships/Lifepod.tscn",
	"processed_cargo":false,
	"processed_cargo_max":1,
	"processed_cargo_min":0
}

# Spawns a specific number of objects based on some ring and story parameters.
# Used by the following Vanilla events:
# - LocustSwarm
# Parameters:
# - beacon - The scene for the object used by the event.
# - number - The number of objects that would be spawned.
# - lock_out_story - If set, a story flag that when reached prevents this event from ever spawning.
# - lock_out_limit - Minimum value for the lock out story flag to prevent the event from spawning.
# - require_story - If set, a required story flag that must be reached to let the Storyteller to spawn this event.
# - require_limit - Minimum value for the required story flag to be reached to permit the event to spawn.
# - away_radius - If set above zero, radius which the event checks for any POI, which if any exist, prevents the event from being chosen by the storyteller.
# - chaos - If available to spawn through the Storyteller, the minimum chaos needed to spawn the event.
const locust_swarm = {
	"event_name":"LocustSwarm",
	"event_type":"locust_swarm",
	"beacon":"res://story/Locust.tscn",
	"number":10,
	"lock_out_story":"",
	"lock_out_limit":1,
	"require_story":"",
	"require_limit":1,
	"away_radius":0,
	"chaos":0.0
}

# Spawns a random number of an object based on the conditions of your immediate area.
# Used by the following Vanilla events:
# - Minefield
# - Mikefield
# - Companions
# Parameters:
# - mine - The scene for the objects spawned by this event.
# - ship_limit - Maximum number of ships that can be in your area of the rings to still spawn the event.
# - hostile - If difficulty should be a factor for limiting this event. Setting this true automatically prevents the event from spawning on Peaceful.
# - minimum_capacity - If hostile is set and while on Balanced difficulty, the minimum status percentage that must be met for the event to spawn. This value is equivalent to the status percentage shown on the EIME and OCP HUDs.
# - minimum_money - If hostile is set and while on Balanced difficulty, the minimum amount of money that the player must have in the bank for the event to spawn.
# - chaos - If available to spawn through the Storyteller, the minimum chaos needed to spawn the event.
const minefield = {
	"event_name":"Companions",
	"event_type":"minefield",
	"mine":"res://ships/drone/DroneMine.tscn",
	"ship_limit":4,
	"hostile":false,
	"minimum_capacity":0.8,
	"minimum_money":10000,
	"chaos":0.0
}

# Spawns an NPC ship, with the ability to limit based on some parameters and also set a course.
# Used by the following Vanilla events:
# - MinerMining
# - AncientMinerMining
# - AdvancedMiner
# - AdvancedMiner2
# - BigBadWolf
# - BigBadWolfPatrol
# Parameters:
# - ship_model - The model for the NPC ship.
# - ship_faction - The faction used by the NPC ship.
# - custom_transponder - A custom transponder ID for the NPC.
# - custom_name - A custom ship name for the NPC.
# - lock_out_if_poi - If set, prevents the Storyteller from spawning this event if another POI uses this name
# - lock_out_story - If set, a story flag that when reached prevents this event from ever spawning.
# - lock_out_limit - Minimum value for the story flag to prevent the event from spawning.
# - away_radius - Radius which the event checks for any POI, which if any exist, prevents the event from being chosen by the storyteller.
# - override_course - Whether the NPC should have a predetermined direction to fly in.
# - course - If override course is set, the direction the ship will aim to fly in. (0,0) has the ship intent on staying put.
# - chaos - If available to spawn through the Storyteller, the minimum chaos needed to spawn the event.
const miner_mining = {
	"event_name":"AncientMinerMining",
	"event_type":"miner_mining",
	"ship_model":"TRTL",
	"ship_faction":"civilian",
	"custom_transponder":"",
	"custom_name":"",
	"lock_out_if_poi":"",
	"lock_out_story":"",
	"lock_out_limit":1,
	"away_radius":10000,
	"override_course":false,
	"course":Vector2(0,0),
	"chaos":0.0
}

# Provides the ability to spawn a pirate, NPC K37, and/or a random amount of ores. This event is affected by difficulty, and won't spawn on Peaceful difficulty.
# Used by the following Vanilla events:
# - PirateCombat
# - Loot
# Parameters:
# - minimum_depth_in_km - Minimum depth that the event is permitted to spawn at, in kilometers.
# - maximum_depth_in_km - Maximum depth that the event is permitted to spawn at, in kilometers.
# - minimum_ores - Minimum number of ores that can be spawned by this event.
# - maximum_ores - Maximum number of ores that can be spawned by this event.
# - has_civilian - Whether to spawn a miner NPC.
# - has_pirate - Whether to spawn a pirate NPC.
# - bounty - If has pirate is set, the scene used for the pirate's lifepod.
# - minimum_capacity - If on Balanced difficulty, the minimum status percentage that must be met for the event to spawn. This value is equivalent to the status percentage shown on the EIME and OCP HUDs.
# - minimum_money - If on Balanced difficulty, the minimum amount of money that the player must have in the bank for the event to spawn.
# - lock_out_story - If set, a story flag that when reached prevents this event from ever spawning.
# - lock_out_limit - Minimum value for the story flag to prevent the event from spawning.
# - chaos - If available to spawn through the Storyteller, the minimum chaos needed to spawn the event.
const pirate_combat = {
	"event_name":"PirateCombat",
	"event_type":"pirate_combat",
	"minimum_depth_in_km":30,
	"maximum_depth_in_km":2970,
	"minimum_ores":0,
	"maximum_ores":20,
	"has_civilian":true,
	"has_pirate":true,
	"bounty":"res://ships/LifepodPirate.tscn",
	"minimum_capacity":0.8,
	"minimum_money":10000,
	"lock_out_story":"g4a.destroyed",
	"lock_out_limit":1,
	"chaos":0.0
}

# Spawns a pirate and another object as bait. This event is affected by difficulty, and cannot spawn on Peaceful difficulty. If provided through POI and on peaceful, will only spawn the bait object.
# Used by the following Vanilla events:
# - PirateTrap
# Parameters:
# - minimum_depth_in_km - Minimum depth that the event is permitted to spawn at, in kilometers.
# - maximum_depth_in_km - Maximum depth that the event is permitted to spawn at, in kilometers.
# - bounty - The scene used for the pirate's lifepod.
# - lifepod - The bait object scene spawned by this event.
# - minimum_money - If on Balanced difficulty, the minimum amount of money that the player must have in the bank for the event to spawn.
# - lock_out_story - If set, a story flag that when reached prevents this event from ever spawning.
# - lock_out_limit - Minimum value for the story flag to prevent the event from spawning.
# - away_radius - Radius which the event checks for any POI, which if any exist, prevents the event from being chosen by the storyteller.
# - chaos - If available to spawn through the Storyteller, the minimum chaos needed to spawn the event.
const pirate_trap = {
	"event_name":"PirateTrap",
	"event_type":"pirate_trap",
	"minimum_depth_in_km":30,
	"maximum_depth_in_km":2970,
	"bounty":"res://ships/LifepodPirate.tscn",
	"lifepod":"res://ships/Lifepod.tscn",
	"minimum_money":10000,
	"lock_out_story":"g4a.destroyed",
	"lock_out_limit":1,
	"away_radius":10000,
	"chaos":0.0
}

# Spawns a derelict ship alongside a few other potential objects.
# Used by the following Vanilla events:
# - RescueOperation
# - Derelict
# - Derelict-TRTL-LCB
# - Derelict-TRTL-R
# - Derelict-TRTL-T
# - Derelict44
# - DerelictEime
# - DerelictTitan
# - DerelictTitan-AT225-B
# - DerelictKitsune
# - DerelictOCP
# - DerelictProspector
# - DerelictProspector-PROSPECTOR-LUX
# - DerelictProspector-PROSPECTOR-VP
# - DerelictProspector-PROSPECTOR-FAT
# - DerelictCothon
# - DerelictCothon-COTHON-CHK
# - DerelictCothon-COTHON-LND
# - DerelictCothon-COTHON-V
# Parameters:
# - random_chance - Base chance that the event will spawn if selected by the Storyteller, scaled at 0 E$.
# - minimum_chance - The absolute minimum chance that the event will spawn if selected by the Storyteller, even with infinite cash.
# - money_ceiling - Divisor for the total cash in bank when used to scale the random chance. Lower values means that the minimum chance is reached with lower amounts of cash in the bank. Check the wiki's page on derelicts for more information on how this works.
# - stock_chance - Chance that the derelict, and if applicable, pirate will be in pristine condition.
# - maximum_velocity - Maximum velocity for the derelict.
# - maximum_angular_velocity - Maximum angular velocity for the derelict, measured in radians per second.
# - gauss - Power the random value used to set random linear and angular velocities to. Used as pow(randf(), gauss).
# - damage_derelict - Whether the derelict should be damaged based on the age of the hull.
# - ship_model - The ship model for the derelict.
# - extra_damage - Whether the derelict should undergo additional, artificial damage.
# - extra_kinetic_damage - Scale for kinetic damage to deal to the derelict when extra_damage is enabled.
# - extra_emp_damage - Scale for emp damage to deal to the derelict when extra_damage is enabled.
# - extra_damage_radius - Base radius of the circle where the point extra damage is inflicted can occur within.
# - specific_ship_name - Sets a specific name for the derelict. Typically only used for POIs with params, such as SRO broadcasts.
# - derelict - Whether this event spawns a derelict.
# - rescue - Whether this event spawns a SAR CERF.
# - derelict_conversation - The conversation player node to use. Defaults to the regular derelict conversation.
# - ringroid_cluster_chance - The chance that the event spawns inside of a cluster of Class 1 and Class 2 ringroids.
# - ringroid_cluster_number - The number of ringroids that are spawned if the event is set to spawn with any.
# - clump_objects - Whether all the event's objects should instead clump towards the event origin.
# - clump_velocity - If clumping, the velocity at which all objects clump.
# - storm_chance - The chance that the event will have a ringstorm occur.
# - pirate_chance - The chance that the event will have a pirate CERF spawn. If on Peaceful difficulty, the pirate will not spawn.
# - storm_beacon - The object spawned if the ringstorm chance passes. Usually used to handle the ringstorm if it happens.
# - bounty - The scene used for the pirate's lifepod.
# - chaos - If available to spawn through the Storyteller, the minimum chaos needed to spawn the event.
const rescue_operation = {
	"event_name":"Derelict",
	"event_type":"rescue_operation",
	"random_chance":1.0,
	"minimum_chance":0.1,
	"money_ceiling":10000000.0,
	"stock_chance":0.2,
	"maximum_velocity":50.0,
	"maximum_angular_velocity":0.5,
	"gauss":2,
	"damage_derelict":true,
	"ship_model":"TRTL",
	"extra_damage":true,
	"extra_kinetic_damage":100000.0,
	"extra_emp_damage":100000.0,
	"extra_damage_radius":10.0,
	"specific_ship_name":"",
	"derelict":true,
	"rescue":true,
	"derelict_conversation":"res://comms/conversation/DerelictConversation.tscn",
	"ringroid_cluster_chance":0.3,
	"ringroid_cluster_number":33,
	"clump_objects":false,
	"clump_velocity":25.0,
	"storm_chance":0.3,
	"pirate_chance":0.3,
	"storm_beacon":"res://story/StormBeacon.tscn",
	"bounty":"res://ships/LifepodPirate.tscn",
	"chaos":0.0
}

# Spawns a number of two different ships.
# Used by the following Vanilla events:
# - RingRaceInGapCenter
# - AtlasRandom
# - RingRaceWithDrone
# - RingRaceNoDrone
# - RingRaceInGap
# Parameters:
# - minimum_depth_in_km - Minimum depth that the event is permitted to spawn at, in kilometers.
# - maximum_depth_in_km - Maximum depth that the event is permitted to spawn at, in kilometers.
# - ship_model - Ship model for the main racer/ship.
# - ship_faction - The faction of the main racer/ship.
# - ship_number - The number of main racers/ships that this event can spawn.
# - drone_model - Ship model for the secondary drone/ship.
# - drone_faction - The faction of the secondary drone/ship.
# - drone_number - The number of secondary drones/ships that this event can spawn.
# - stock_chance - Chance that the main racers/ships and secondary drones/ships will be in pristine condition.
const ring_race = {
	"event_name":"RingRaceInGap",
	"event_type":"ring_race",
	"minimum_depth_in_km":0,
	"maximum_depth_in_km":10000,
	"ship_model":"PROSPECTOR-BALD",
	"ship_faction":"racer",
	"ship_number":1,
	"drone_model":"DRONE",
	"drone_faction":"racedrone",
	"drone_number":0,
	"stock_chance":0.2
}

# Spawns an object alongside a random amount of a random selection of secondary objects.
# Used by the following Vanilla events:
# - Singularity
# Parameters:
# - main - The scene for the main event object.
# - misc - PoolStringArray/Array of filepaths to the scenes to be used for the miscelaneous objects/ores in the event.
# - minimum_misc_count - Minimum number of miscelaneous objects that can be found.
# - maximum_misc_count - Maximum number of miscelaneous objects that can be found.
# - maximum_angular_velocity - Maximum angular velocity all objects are given, measured in radians per second.
# - maximum_velocity - Maximum velocity that all objects are given.
# - additional_random_velocity - Maximum additional velocity that can be randomly added to each miscelaneous object's base velocity.
# - chaos - If available to spawn through the Storyteller, the minimum chaos needed to spawn the event.
const singularity = {
	"event_name":"Singularity",
	"event_type":"singularity",
	"main":"res://story/SingularityCore.tscn",
	"misc":PoolStringArray([
		"res://asteroids/mineral-fe-1.tscn",
		"res://asteroids/mineral-fe-2.tscn", 
		"res://asteroids/mineral-fe-3.tscn", 
		"res://asteroids/mineral-fe-4.tscn", 
		"res://asteroids/mineral-fe-5.tscn", 
		"res://asteroids/mineral-fe-6.tscn", 
		"res://asteroids/mineral-fe-7.tscn", 
	]),
	"minimum_misc_count":2,
	"maximum_misc_count":10,
	"maximum_angular_velocity":0.2,
	"maximum_velocity":3.0,
	"additional_random_velocity":0,
	"chaos":0.0
}

# Spawns an object based on a specific story flag not being set above zero, then sets that flag when the object is registered inside the cargo bay.
# Used by the following Vanilla events:
# - TeslaIsFloating
# Parameters:
# - tesla - The scene for the event object.
# - event_story_flag - Unique story for this event. This flag must be zero for the event to spawn, and once the event object is considered inside cargo bay, this flag is set to one.
const tesla_is_floating = {
	"event_name":"TeslaIsFloating",
	"event_type":"tesla_is_floating",
	"tesla":"res://easters/Tesla.tscn",
	"event_story_flag":"easters.tesla"
}

# An event that always spawns when requested by the Storyteller when at a set of specific IRL dates, otherwise provides a few other parameters to spawn the event.
# Used by the following Vanilla events:
# - Skull
# - Helloroid
# Parameters:
# - rock_scene - The scene spawned by this event.
# - maximum_angular_velocity - Maximum angular velocity for the object, measured in radians per second.
# - times - Array of Vector2s or 2 index Arrays/PoolIntArrays that dictate the IRL dates where the event will always pass the storyteller check and not need to meet the chaos to spawn.
# - away_radius - Radius which the event checks for any POI, which if any exist, prevents the event from being chosen by the storyteller.
# - chaos - If available to spawn through the Storyteller, the minimum chaos needed to spawn the event when not at one of the dates defined by `times`.
const timed_event = {
	"event_name":"Helloroid",
	"event_type":"timed_event",
	"rock_scene":"res://easters/Helloroid.tscn",
	"maximum_angular_velocity":0.05,
	"times":PoolVector2Array([
		Vector2(10, 25), 
		Vector2(10, 26), 
		Vector2(10, 27), 
		Vector2(10, 28), 
		Vector2(10, 29), 
		Vector2(10, 31), 
		Vector2(11, 1)
	]),
	"away_radius":10000,
	"chaos":0.0
}

# Spawns variable number and types of both Vilcy and Ganymede ships, alongside some other spawn requirements. This event is affected by difficulty, and cannot spawn on Peaceful difficulty.
# Used by the following Vanilla events:
# - VilcyPatrol
# - VilcyLone
# - VilcyStrike
# - VilcyDisabler
# - VilcyCombat
# - VilcyAmbush
# - PirateG4A
# - PirateAbductor
# - PirateAbductorWithSupport
# - PirateRevenger
# - VilcyRevenger
# - PirateRevengerTeam
# Parameters:
# - minimum_depth_in_km - Minimum depth that the event is permitted to spawn at, in kilometers.
# - maximum_depth_in_km - Maximum depth that the event is permitted to spawn at, in kilometers.
# - vilcy_patroler - Creates a vilcy K37, adding EMD-14s to left and right low-stress hardpoints, 1 GW turbine, and dual ultracapacitors.
# - vilcy_disabler - Creates a vilcy K37, adding MWGs to all hardpoints, 1 GW turbine, and dual ultracapacitors.
# - vilcy_burner - Creates a vilcy K37, adding CL-150s to left and right low-stress hardpoints, 1 GW turbine, and dual ultracapacitors.
# - vilcy_lone - Creates a vilcy K37, adding EMD-17 to the high-stress hardpoint, MWG to the left low-stress hardpoint, CL-150s to right low-stress hardpoint, K44 RCS, military turbine, and triple ultracapacitors.
# - pirate_abductors - Creates a pirate CERF.
# - pirate - Creates a pirate K37, adding EMD-17 to the high-stress hardpoint, NDVTT RCS, twin turbine, and triple ultracapacitor.
# - pirate_revenger - Creates a revenger-type pirate K37, adding EMD-17 to the high-stress hardpoint, NDVTT RCS, twin turbine, and triple ultracapacitor.
# - vilcy_revenger - Creates a revenger-type vilcy K37, adding EMD-17 to the high-stress hardpoint, MWG to the left low-stress hardpoint, CL-150s to right low-stress hardpoint, K44 RCS, military turbine, and triple ultracapacitors.
# - initial_pirates - Creates a pirate K37, adding EMD-17 to the high-stress hardpoint, NDVTT RCS, single turbine, and dual ultracapacitor.
# - later_pirates - For every ship initially spawned by this event, spawns X number of pirates after the later ship timer has run out.
# - later_vilcy - For every ship initially spawned by this event, spawns X number of vilcy after the later ship timer has run out.
# - later_ship_timer - Time from event spawn to the later pirates and vilcy to spawn.
# - away_radius - Radius which a fleeing pirate checks for POI when it tries to spawn the pirate station after 10 minutes have passed.
# - stock_chance - Chance that the vilcy and/or pirates will have a pristine ship.
# - bounty - If pirates will spawn, the scene used for their lifepods.
# - pirate_station - Scene used for the pirate station spawn.
# - station_event_name - Event name used to represent the pirate station's event.
# - flee_to_station_timer - Timer started upon the event's creation, and when runs out it attempts to spawn the pirate station scene.
# - minimum_capacity - If on Balanced difficulty, the minimum status percentage that must be met for the event to spawn. This value is equivalent to the status percentage shown on the EIME and OCP HUDs.
# - minimum_money - If on Balanced difficulty, the minimum amount of money that the player must have in the bank for the event to spawn.
# - lock_out_story - If set, a story flag that when reached prevents this event from ever spawning.
# - lock_out_limit - Minimum value for the lock out story flag to prevent the event from spawning.
# - require_story - If set, a required story flag that must be reached to let the Storyteller to spawn this event.
# - require_limit - Minimum value for the required story flag to be reached to permit the event to spawn.
# - chaos - If available to spawn through the Storyteller, the minimum chaos needed to spawn the event.
const vilcy = {
	"event_name":"VilcyPatrol",
	"event_type":"vilcy",
	"minimum_depth_in_km":0,
	"maximum_depth_in_km":10000,
	"vilcy_patroler":0,
	"vilcy_disabler":0,
	"vilcy_burner":0,
	"vilcy_lone":0,
	"pirate_abductors":0,
	"pirate":0,
	"pirate_revenger":0,
	"vilcy_revenger":0,
	"initial_pirates":0,
	"later_pirates":0,
	"later_vilcy":0,
	"later_ship_timer":60,
	"away_radius":10000,
	"stock_chance":0.5,
	"bounty":"res://ships/LifepodPirate.tscn",
	"pirate_station":"res://story/pirates/Pistacja.tscn",
	"station_event_name":"PirateStation",
	"flee_to_station_timer":600,
	"minimum_capacity":0.25,
	"minimum_money":0,
	"lock_out_story":"g4a.destroyed",
	"lock_out_limit":1,
	"require_story":"",
	"require_limit":0,
	"chaos":0.0
}
