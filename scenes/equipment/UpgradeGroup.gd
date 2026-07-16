extends "res://enceladus/UpgradeGroup.gd"

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

# Ship limiting code was ported from IoE
# Thanks Space! The modding community misses you!

export (Array) var limit_ships = []
export (Array) var prevent_ships = []

# REMEMBER TO ADD SUPPORT FOR THESE IN EQUIPMENT DRIVER

# Variables used to tag equipment
export (bool) var add_vanilla_equipment = false
export (String) var slot_type = "HARDPOINT"
export (String) var hardpoint_type = ""
export (String) var alignment = ""
export (String) var restriction = ""
export (Array) var override_additive = []
export (Array) var override_subtractive = []
export (String) var restrict_hold_type = ""

export (String) var config_id = ""
export (String) var config_section = ""
export (String) var config_setting = ""
export (bool) var invert_config = false

# Internal variable used to more easily assign equipment
# Should improve efficiency over the previous version, which calculated it on the fly
var allowed_equipment := []

var data_dictionary = ""

var pointers
var cv = null
func _ready():
	pointers = ModLoader._savedObjects[0]
	connect("visibility_changed",self,"hl_ug_recheck_this_visibility")

func hl_ug_recheck_this_visibility():
	if pointers:
		cv = pointers.ConfigDriver.__get_value(config_id,config_section,config_setting)

func reexamine():	
	var ship = CurrentGame.getPlayerShip()
	var shipname = ship.shipName
	if limit_ships:
		visible = (shipname in limit_ships)
	if prevent_ships:
		visible = not (shipname in prevent_ships)
	.reexamine()
	if config_id and config_section and config_setting:
		if cv != null and cv is bool:
			if invert_config:
				visible = cv
			else:
				visible = !cv
	if visible:
		if restrict_hold_type:
			visible = (restrict_hold_type.to_upper() == ship.base_storage_type.to_upper())
