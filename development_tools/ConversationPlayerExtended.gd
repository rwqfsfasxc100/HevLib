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

# This script should be used for modified comms nodes and adds extra functionality.
extends "res://comms/ConversationPlayer.gd"

# Used to spawn an event when the conversation is run
export (String) var spawn_event = ""
export (float,0.0,1000.0) var event_delay = 0.0

# Used to check against a config for any succeeding option
# Config must be valid (i.e. not returns null when checked), 
# and all three entries must be filled out to be used
export (String) var config_ID = ""
export (String) var config_section = ""
export (String) var config_setting = ""
# Whether the configuration should prevent the config when true
export (bool) var invert_config_logic = false

# If set, used to define a special name given to the object at the dive summary screen
export (String) var special_name = ""
# Used to decide whether to set a special price and the value of that price at the dive summary screen
export (bool) var set_special_price = false
export (int) var special_price = 0

# If set, only permits the conversation path if the current crew has a specific occupation
export (String) var requires_occupation = ""

# If set, a mod ID that must be present to permit the dialogue option
# Also includes minimum and maximum versions, which if not completely zeroed out, will check for version too
export (String) var requires_mod_id = ""
export (Vector3) var minimum_mod_version = Vector3.ZERO
export (Vector3) var maximum_mod_version = Vector3.ZERO

var pointers

func execute():
	.execute()
	if spawn_event and spawn_event != "":
		if not pointers:
			pointers = ModLoader._savedObjects[0]
		pointers.Events.__spawn_event(spawn_event,get_tree().get_root().get_node_or_null("Game/TheRing"),{},event_delay)
	
	if special_name and "specialName" in origin:
		origin.specialName = special_name
	if set_special_price and "specialPrice" in origin:
		origin.specialPrice = special_price
	
	

func canBeUsed(by) -> bool:
	var how = .canBeUsed(by)
	if how and requires_mod_id:
		if maximum_mod_version != Vector3.ZERO or minimum_mod_version != Vector3.ZERO:
			how = pointers.ManifestV2.__mod_exists({"mod_id":requires_mod_id,"minimum_version":minimum_mod_version,"maximum_version":maximum_mod_version})
		else:
			how = pointers.ManifestV2.__mod_exists(requires_mod_id)
	if how and config_ID and config_section and config_setting:
		if not pointers:
			pointers = ModLoader._savedObjects[0]
		var cfg_opt = pointers.ConfigDriver.__get_value(config_ID,config_section,config_setting)
		if cfg_opt != null:
			if invert_config_logic:
				if cfg_opt:
					return false
			else:
				if !cfg_opt:
					return false
	return how 

func specificTest(ship) -> bool:
	var orig = .specificTest(ship)
	if orig and requires_occupation and requires_occupation != "":
		var member = getAgendaMember()
		if member == null:
			Debug.l("** Requires occupation %s, none on ship" % [requires_occupation])
			return false
		var mo = member.occupation
		if mo != requires_occupation:
			Debug.l("** Needs occupation %s, has %s" % [requires_occupation,mo])
			return false
	return orig


