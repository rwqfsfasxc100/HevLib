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

# Spawns a 
# Used by the following Vanilla events:
# - ClaimBeaconForeign
# Parameters:
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
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

# 
# Used by the following Vanilla events:
# - DeadBody
# Parameters:
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - chaos - If available to spawn through the Storyteller, the minimum chaos needed to spawn the event.
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

# 
# Used by the following Vanilla events:
# - FlightForRescue
# Parameters:
# - 
# - 
# - 
# - 
# - 
const flight_for_rescue = {
	"event_name":"FlightForRescue",
	"event_type":"flight_for_rescue",
	"time":180,
	"maximum_velocity":10.0,
	"maximum_angular_velocity":2,
	"gauss":6,
	"derelict_conversation":"res://comms/conversation/DerelictConversation.tscn"
}

# 
# Used by the following Vanilla events:
# - Humongus
# - Moonlet
# - Addlet
# - BigMoonlet
# - BigMoonletCaves
# - BiggerMoonletSpelunker
# - BiggerMoonletLocust
# Parameters:
# - 
# - 
# - 
# - 
# - 
# - 
# - 
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

# 
# Used by the following Vanilla events:
# - HybridHunterHuntingPlayer
# Parameters:
# - 
# - 
# - chaos - If available to spawn through the Storyteller, the minimum chaos needed to spawn the event.
const hybrid_hunter = {
	"event_name":"HybridHunterHuntingPlayer",
	"event_type":"hybrid_hunter",
	"minimum_capacity":0.6,
	"minimum_money":30000,
	"chaos":0.0
}

# 
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
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
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

# 
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
# - 
# - 
# - 
# - chaos - If available to spawn through the Storyteller, the minimum chaos needed to spawn the event.
const inter_crew_banter = {
	"event_name":"SalvageCall2",
	"event_type":"inter_crew_banter",
	"beacon":"res://story/TighbeamBeacon.tscn",
	"away_radius":0,
	"service_cooldown":"",
	"chaos":0.0
}

# 
# Used by the following Vanilla events:
# - LifepodIsFloating
# - StoragePod
# Parameters:
# - 
# - 
# - 
# - 
const lifepod_is_floating = {
	"event_name":"LifepodIsFloating",
	"event_type":"lifepod_is_floating",
	"lifepod":"res://ships/Lifepod.tscn",
	"processed_cargo":false,
	"processed_cargo_max":1,
	"processed_cargo_min":0
}

# 
# Used by the following Vanilla events:
# - LocustSwarm
# Parameters:
# - 
# - 
# - 
# - 
# - 
# - 
# - 
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

# 
# Used by the following Vanilla events:
# - Minefield
# - Mikefield
# - Companions
# Parameters:
# - 
# - 
# - 
# - 
# - 
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

# 
# Used by the following Vanilla events:
# - MinerMining
# - AncientMinerMining
# - AdvancedMiner
# - AdvancedMiner2
# - BigBadWolf
# - BigBadWolfPatrol
# Parameters:
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
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

# 
# Used by the following Vanilla events:
# - PirateCombat
# - Loot
# Parameters:
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
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

# 
# Used by the following Vanilla events:
# - PirateTrap
# Parameters:
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
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

# 
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
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
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

# 
# Used by the following Vanilla events:
# - RingRaceInGapCenter
# - AtlasRandom
# - RingRaceWithDrone
# - RingRaceNoDrone
# - RingRaceInGap
# Parameters:
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
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

# 
# Used by the following Vanilla events:
# - Singularity
# Parameters:
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - chaos - If available to spawn through the Storyteller, the minimum chaos needed to spawn the event.
const singularity = {
	"event_name":"Singularity",
	"event_type":"singularity",
	"misc":PoolStringArray([
		"res://asteroids/mineral-fe-1.tscn",
		"res://asteroids/mineral-fe-2.tscn", 
		"res://asteroids/mineral-fe-3.tscn", 
		"res://asteroids/mineral-fe-4.tscn", 
		"res://asteroids/mineral-fe-5.tscn", 
		"res://asteroids/mineral-fe-6.tscn", 
		"res://asteroids/mineral-fe-7.tscn", 
	]),
	"main":"res://story/SingularityCore.tscn",
	"minimum_misc_count":2,
	"maximum_misc_count":10,
	"maximum_angular_velocity":0.2,
	"maximum_velocity":3.0,
	"additional_random_velocity":0,
	"chaos":0.0
}

# 
# Used by the following Vanilla events:
# - TeslaIsFloating
# Parameters:
# - 
# - 
const tesla_is_floating = {
	"event_name":"TeslaIsFloating",
	"event_type":"tesla_is_floating",
	"tesla":"res://easters/Tesla.tscn",
	"event_story_flag":"easters.tesla"
}

# 
# Used by the following Vanilla events:
# - Skull
# - Helloroid
# Parameters:
# - 
# - 
# - 
# - 
# - chaos - If available to spawn through the Storyteller, the minimum chaos needed to spawn the event.
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

# 
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
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
# - 
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
