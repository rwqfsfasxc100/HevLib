# [license]
# SPDX-License-Identifier: LicenseRef-Proprietary
# Copyright © 2026 __hev (Benjamin Buckhurst). All Rights Reserved.
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that all following conditions are met:
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

extends "res://ships/modules/ThrusterSlot.gd"

var exhaust_cache_path:String = "user://cache/AuxAndThrusterDriver/"
var flare
var mpdg:String = "res://ships/modules/AuxMpd.tscn"
var smes:String = "res://ships/modules/AuxSmes.tscn"
var aux_hybrid:String = "res://HevLib/scenes/equipment/custom_equipment/AuxHybrid.tscn"
var thruster:String = "res://sfx/thruster.tscn"

var fco:Color = Color.white
var change_color:bool = false

var shipName:String = ""
var baseShipName:String = ""

onready var itsPointers:HevLibPointers = ModLoader._savedObjects[0]

var aux_type : String = "MPDG"
func loadPlaceholder():
	hl_thrusterslot_modify()
	.loadPlaceholder()
var thruster_item:Node = null

func hl_thrusterslot_modify():
	var datastore:Dictionary = itsPointers.Equipment.auxslot_data
	shipName = ship.shipName
	baseShipName = ship.baseShipName
	var slotType:String = type.split(".")[0]
	var currentInstall:String = ship.getConfig(type,default)
	if slotType in datastore:
		for data in datastore[slotType]:
			var aux_path:String = data.get("path","")
			aux_type = data.get("type","MPDG").to_upper()
			match aux_type:
				"THRUSTER":
					aux_type = "RCS"
				"MAIN_PROPULSION":
					aux_type = "TORCH"
				"HYBRID":
					aux_type = "AUX_HYBRID"
			if currentInstall == data.get("system","SYSTEM_NAME_MISSING"):
				if itsPointers:
					if not itsPointers.ConfigDriver.__validate_dictionary(data):
						return
				var valid_scene:bool = false
				if aux_path:
					if itsPointers.DataFormat.__load_if_can(aux_path):
						valid_scene = true
						thruster_item = itsPointers.DataFormat.__get_load().instance()
					else:
						itsPointers.l("ERROR: Failed to load custom thruster/aux scene at [%s], falling back to default of unit type (if possible)" % aux_path,"ThrusterSlotDriver")
				if not valid_scene:
					match aux_type:
						"MPDG":
							thruster_item = load(mpdg).instance()
						"SMES":
							thruster_item = load(smes).instance()
						"AUX_HYBRID":
							thruster_item = load(aux_hybrid).instance()
						"RCS","TORCH":
							var thrusterScene:String = exhaust_cache_path + aux_type + "/" + currentInstall + "_thruster.tscn"
							if itsPointers.DataFormat.__load_if_can(thrusterScene):
								thruster_item = itsPointers.DataFormat.__get_load().instance()
							else:
								itsPointers.l("ERROR: Failed to load thruster at [%s], falling back to default thruster scene" % thrusterScene,"ThrusterSlotDriver")
								thruster_item = load(thruster).instance()
				
				thruster_item.name = currentInstall
				if not valid_scene:
					thruster_item.command = data.get("command","m" if aux_type == "TORCH" else "")
					thruster_item.systemName = currentInstall
					thruster_item.mass = data.get("mass",0)
					
					match aux_type:
						"MPDG":
							thruster_item.repairReplacementPrice = data.get("price",30000)
							thruster_item.repairReplacementTime = data.get("repair_time",1)
							thruster_item.repairFixPrice = data.get("fix_price",5000)
							thruster_item.repairFixTime = data.get("fix_time",4)
							thruster_item.thermal = data.get("thermal",500000.0)
							thruster_item.windupTime = data.get("windup_time",2)
							
							thruster_item.powerSupply = data.get("power_supply",350000.0)
							thruster_item.powerDraw = data.get("power_draw",50000.0)
						"SMES":
							
							thruster_item.capacitorRatio = data.get("capacitor_ratio",0.9)
							thruster_item.capacity = data.get("capacity",600000.0)
							thruster_item.switchTime = data.get("switch_time",2)
							
							thruster_item.powerSupply = data.get("power_supply",200000.0)
							thruster_item.powerDraw = data.get("power_draw",50000.0)
							thruster_item.repairReplacementPrice = data.get("price",40000)
							thruster_item.repairReplacementTime = data.get("repair_time",1)
							thruster_item.repairFixPrice = data.get("fix_price",25000)
							thruster_item.repairFixTime = data.get("fix_time",4)
							
						"AUX_HYBRID":
							thruster_item.repairReplacementPrice = data.get("price",30000)
							thruster_item.repairReplacementTime = data.get("repair_time",1)
							thruster_item.repairFixPrice = data.get("fix_price",5000)
							thruster_item.repairFixTime = data.get("fix_time",4)
							
							thruster_item.smesPowerSupply = data.get("smes_power_supply",200000.0)
							thruster_item.smesPowerDraw = data.get("smes_power_draw",50000.0)
							thruster_item.smesCapacitorRatio = data.get("smes_capacitor_ratio",0.9)
							thruster_item.smesCapacity = data.get("smes_capacity",600000.0)
							thruster_item.smesSwitchTime = data.get("smes_switch_time",0.1)
							
							thruster_item.mpdgThermal = data.get("mpdg_thermal",500000.0)
							thruster_item.mpdgWindupTime = data.get("mpdg_windup_time",2)
							thruster_item.mpdgPowerSupply = data.get("mpdg_power_supply",350000.0)
							thruster_item.mpdgPowerDraw = data.get("mpdg_power_draw",50000.0)
						

				match aux_type:
					"RCS","TORCH":
						# KEEP THIS CODE AND MAKE IT ALWAYS AVAILABLE
						var color_override = data.get("flare_override_color","")
						if color_override:
							fco = Color(color_override)
							change_color = true
						hl_thrusterslot_get_colors()
				
				if thruster_item:
					key = name + "_" + mounted
					add_child(thruster_item)
					systemName = _getSystemName()
					slotName = type
					repairFixPrice = _getRepairFixPrice()
					repairFixTime = _getRepairFixTime()
					repairReplacementPrice = _repairReplacementPrice()
					repairReplacementTime = _repairReplacementTime()
					mass = _getMass()
	

func hl_thrusterslot_get_colors():
	var color_data:Dictionary = itsPointers.Equipment.ship_thruster_colors
	for i in color_data:
		var d:Dictionary = color_data[i]
		if not itsPointers.ConfigDriver.__validate_dictionary(d):
			continue
		
		if i == baseShipName and d.get("recurse_to_variants",false):
			hl_thrusterslot_modify_colors(d)
		if i == shipName:
			hl_thrusterslot_modify_colors(d)
	if change_color:
		thruster_item.hl_exhaust_color_modification = fco

func hl_thrusterslot_modify_colors(data):
	if "type" in data:
		var c = data["type"]
		if type in c:
			var color = c[type]
			fco = color
			change_color = true
	if "node" in data:
		var c = data["node"]
		if name in c:
			var color = c[name]
			fco = color
			change_color = true
	
