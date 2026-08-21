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
# 4. The source code and the binary form, and any modifications made to them may not be used for the purpose of input data, the training of, or improvement of machine learning algorithms,
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

extends "res://ships/modules/ThrusterSlot.gd"

var exhaust_cache_path = "user://cache/.HevLib_Cache/AuxAndThrusterDriver/"
var flare
var mpdg = "res://ships/modules/AuxMpd.tscn"
var smes = "res://ships/modules/AuxSmes.tscn"
var aux_hybrid = "res://HevLib/scenes/equipment/custom_equipment/AuxHybrid.tscn"
var thruster = "res://sfx/thruster.tscn"

var timerObject:Timer = Timer.new()
var fco:Color = Color.white

var shipName:String = ""
var baseShipName:String = ""

var itsPointers

var aux_type : String = "MPDG"
func loadPlaceholder():
	itsPointers = ModLoader._savedObjects[0]
	hl_thrusterslot_modify()
	.loadPlaceholder()

func hl_thrusterslot_modify():
	var datastore = itsPointers.Equipment.auxslot_data
	shipName = ship.shipName
	baseShipName = ship.baseShipName
	var slotType = type.split(".")[0]
	var currentInstall = ship.getConfig(type)
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
			var item
			var sys = data.get("system","SYSTEM_NAME_MISSING")
			if sys == currentInstall:
				if itsPointers:
					if not itsPointers.ConfigDriver.__validate_dictionary(data):
						return
				var valid_scene = false
				if aux_path:
					if itsPointers.DataFormat.__load_if_can(aux_path):
						valid_scene = true
						item = itsPointers.DataFormat.__get_load().instance()
					else:
						itsPointers.l("ERROR: Failed to load custom thruster/aux scene at [%s], falling back to default of unit type (if possible)" % aux_path,"ThrusterSlotDriver")
				if not valid_scene:
					match aux_type:
						"MPDG":
							item = load(mpdg).instance()
						"SMES":
							item = load(smes).instance()
						"AUX_HYBRID":
							item = load(aux_hybrid).instance()
						"RCS","TORCH":
							var thrusterScene = exhaust_cache_path + aux_type + "/" + sys + "_thruster.tscn"
							if itsPointers.DataFormat.__load_if_can(thrusterScene):
								item = itsPointers.DataFormat.__get_load().instance()
							else:
								itsPointers.l("ERROR: Failed to load thruster at [%s], falling back to default thruster scene" % thrusterScene,"ThrusterSlotDriver")
								item = load(thruster).instance()
				
				item.name = sys
				if not valid_scene:
					item.command = data.get("command","m" if aux_type == "TORCH" else "")
					item.systemName = sys
					item.mass = data.get("mass",0)
					
					match aux_type:
						"MPDG":
							item.repairReplacementPrice = data.get("price",30000)
							item.repairReplacementTime = data.get("repair_time",1)
							item.repairFixPrice = data.get("fix_price",5000)
							item.repairFixTime = data.get("fix_time",4)
							item.thermal = data.get("thermal",500000.0)
							item.windupTime = data.get("windup_time",2)
							
							item.powerSupply = data.get("power_supply",350000.0)
							item.powerDraw = data.get("power_draw",50000.0)
						"SMES":
							
							item.capacitorRatio = data.get("capacitor_ratio",0.9)
							item.capacity = data.get("capacity",600000.0)
							item.switchTime = data.get("switch_time",2)
							
							item.powerSupply = data.get("power_supply",200000.0)
							item.powerDraw = data.get("power_draw",50000.0)
							item.repairReplacementPrice = data.get("price",40000)
							item.repairReplacementTime = data.get("repair_time",1)
							item.repairFixPrice = data.get("fix_price",25000)
							item.repairFixTime = data.get("fix_time",4)
							
						"AUX_HYBRID":
							item.repairReplacementPrice = data.get("price",30000)
							item.repairReplacementTime = data.get("repair_time",1)
							item.repairFixPrice = data.get("fix_price",5000)
							item.repairFixTime = data.get("fix_time",4)
							
							item.smesPowerSupply = data.get("smes_power_supply",200000.0)
							item.smesPowerDraw = data.get("smes_power_draw",50000.0)
							item.smesCapacitorRatio = data.get("smes_capacitor_ratio",0.9)
							item.smesCapacity = data.get("smes_capacity",600000.0)
							item.smesSwitchTime = data.get("smes_switch_time",0.1)
							
							item.mpdgThermal = data.get("mpdg_thermal",500000.0)
							item.mpdgWindupTime = data.get("mpdg_windup_time",2)
							item.mpdgPowerSupply = data.get("mpdg_power_supply",350000.0)
							item.mpdgPowerDraw = data.get("mpdg_power_draw",50000.0)
						

				match aux_type:
					"RCS","TORCH":
						# KEEP THIS CODE AND MAKE IT ALWAYS AVAILABLE
						flare = item.get_node_or_null("Flare")
						if flare:
							var color_override = data.get("flare_override_color","")
							if color_override:
								fco = Color(color_override)
								hl_thrusterslot_make_timer()
				
				if item:
					key = name + "_" + mounted
					add_child(item)
					systemName = _getSystemName()
					slotName = type
					repairFixPrice = _getRepairFixPrice()
					repairFixTime = _getRepairFixTime()
					repairReplacementPrice = _repairReplacementPrice()
					repairReplacementTime = _repairReplacementTime()
					mass = _getMass()
	hl_thrusterslot_get_colors()


func hl_thrusterslot_make_timer():
	if timerObject == null:
		timerObject.wait_time = 0.5
		timerObject.one_shot = true
		timerObject.connect("timeout",self,"hl_thrusterslot_recolor")
		CurrentGame.get_tree().get_root().add_child(timerObject)
		timerObject.call_deferred("start")

func hl_thrusterslot_recolor():
	if not flare:
		for node in get_children():
			if node.name.begins_with(name + "_"):
				flare = node.get_node_or_null("Flare")
	if flare and fco:
		flare.color = fco
	Tool.remove(timerObject)

func hl_thrusterslot_get_colors():
	var color_data = itsPointers.Equipment.ship_thruster_colors
	for i in color_data:
		var d = color_data[i]
		if not itsPointers.ConfigDriver.__validate_dictionary(d):
			continue
		
		if i == shipName:
			hl_thrusterslot_modify_colors(d)
		if i == baseShipName and d.get("recurse_to_variants",false):
			hl_thrusterslot_modify_colors(d)
		

func hl_thrusterslot_modify_colors(data):
	var change = false
	if "type" in data:
		var c = data["type"]
		if type in c:
			var color = c[type]
			fco = color
			change = true
	if "node" in data:
		var c = data["node"]
		if name in c:
			var color = c[name]
			fco = color
			change = true
	if change:
		hl_thrusterslot_make_timer()
