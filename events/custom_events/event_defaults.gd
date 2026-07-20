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


# This file contains constants that match all vanilla event scripts that are currently supported by EVENT_DRIVER.gd
# All values are their defaults. Each event also gets a basic usage blurb and mentions all events related to the
# specific event mechanic type.
# NOTE: All events use an `event_name` and `event_type` to define the node name and event handle respectively
# All events can also make use of a `custom_property_modifications` dictionary, which gives the ability to arbritrarily
# modify any property, useful for modifying properties not exposed through an event type's regular properties, or for 
# modifying any properties added to an event via a mod. It is also the only way to modify properties for a custom event.


# If you want to add a custom event, use the following code.
# Custom events make use of a `script_path` property to define the event's script.
const CUSTOM_EVENT = {
	"event_name":"CustomEvent",
	"event_type":"script",
	"script_path":"res://HevLib/events/custom_events/custom_event.gd",
	"custom_property_modifications":{
		"randomChance":0.5
	}
}

# 
const agenda_specific_derelict = {
	"event_name":"",
	"event_type":"",
	
}

# 
const aiming_asteroid = {
	"event_name":"",
	"event_type":"",
	
}

# 
const aiming_asteroid_shower = {
	"event_name":"",
	"event_type":"",
	
}

# 
const claim_beacon = {
	"event_name":"",
	"event_type":"",
	
}

# 
const claim_beacon_foreign = {
	"event_name":"",
	"event_type":"",
	
}

# 
const dead_body = {
	"event_name":"",
	"event_type":"",
	
}

# 
const flight_for_rescue = {
	"event_name":"",
	"event_type":"",
	
}

# 
const humongous_hollow_rock = {
	"event_name":"",
	"event_type":"",
	
}

# 
const hybrid_hunter = {
	"event_name":"",
	"event_type":"",
	
}

# 
const instance_with_chance = {
	"event_name":"",
	"event_type":"",
	
}

# 
const inter_crew_banter = {
	"event_name":"",
	"event_type":"",
	
}

# 
const lifepod_is_floating = {
	"event_name":"",
	"event_type":"",
	
}

# 
const locust_swarm = {
	"event_name":"",
	"event_type":"",
	
}

# 
const minefield = {
	"event_name":"",
	"event_type":"",
	
}

# 
const miner_mining = {
	"event_name":"",
	"event_type":"",
	
}

# 
const pirate_combat = {
	"event_name":"",
	"event_type":"",
	
}

# 
const pirate_trap = {
	"event_name":"",
	"event_type":"",
	
}

# 
const rescue_operation = {
	"event_name":"",
	"event_type":"",
	
}

# 
const ring_race = {
	"event_name":"",
	"event_type":"",
	
}

# 
const singularity = {
	"event_name":"",
	"event_type":"",
	
}

# 
const tesla_is_floating = {
	"event_name":"",
	"event_type":"",
	
}

# 
const timed_event = {
	"event_name":"",
	"event_type":"",
	
}

# 
const vilcy = {
	"event_name":"",
	"event_type":"",
	
}
