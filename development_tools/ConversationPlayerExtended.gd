# This script should be used for modified comms nodes and adds extra functionality.
extends "res://comms/ConversationPlayer.gd"

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

# Used to spawn an event when the conversation is run
export (String) var spawnEvent = ""

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

var pointers = ModLoader._savedObjects[0]

func execute():
	.execute()
	if spawnEvent and spawnEvent != "":
		pointers.Events.__spawn_event(spawnEvent,get_tree().get_root().get_node_or_null("Game/TheRing"))
	
	if special_name and "specialName" in origin:
		origin.specialName = special_name
	if set_special_price and "specialPrice" in origin:
		origin.specialPrice = special_price
	
	

func canBeUsed(by) -> bool:
	var how = .canBeUsed(by)
	if how and config_ID and config_section and config_setting:
		var cfg_opt = pointers.ConfigDriver.__get_value(config_ID,config_section,config_setting)
		if cfg_opt != null:
			if invert_config_logic:
				if cfg_opt:
					how = false
			else:
				if !cfg_opt:
					how = false
	return how 

func specificTest(ship) -> bool:
	if requires_occupation and requires_occupation != "":
		var member = getAgendaMember()
		if member == null:
			Debug.l("** Requires occupation %s, none on ship" % [requires_occupation])
			return false
		var mo = member.occupation
		if mo != requires_occupation:
			Debug.l("** Needs occupation %s, has %s" % [requires_occupation,mo])
			return false
	
	
	return .specificTest(ship)


