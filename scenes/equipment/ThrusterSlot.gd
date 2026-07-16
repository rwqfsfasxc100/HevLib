extends "res://ships/modules/ThrusterSlot.gd"

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

var exhaust_cache_path = "user://cache/.HevLib_Cache/AuxAndThrusterDriver/"
var flare
var mpdg = "res://ships/modules/AuxMpd.tscn"
var smes = "res://ships/modules/AuxSmes.tscn"
var aux_hybrid = "res://HevLib/scenes/equipment/custom_equipment/AuxHybrid.tscn"
var thruster = "res://sfx/thruster.tscn"
var exhaust = "res://sfx/exhaust.tscn"
var exhaust_fusion = "res://sfx/exhaust-fusion.tscn"
var nozzle = "res://ships/modules/nozzle-conventonal.tscn"

const torch_base_scale = [0.939,1.395]
const rcs_base_scale = [0.2,0.2]
const thruster_base_pos = [0,-3]

var timerObject
var fco

var shipName
var baseShipName

var itsPointers

const nozzle_template = {
	"cool_time":4,
	"heat_time":0.25,
	"texture":"res://ships/modules/nozzle-cd.png",
	"normal":"res://ships/modules/nozzle-n.png",
	"heat":"res://ships/modules/nozzle-cl.png",
	"heat_normal":null,
	"region_enabled":false,
	"region_rect":[0,0,0,0],
	"region_filter_clip":false,
	"position":[0,0],
	"rotation":0,
	"scale":[1,1],
	"heat_region_enabled":false,
	"heat_region_rect":[0,0,0,0],
	"heat_region_filter_clip":false,
	"heat_position":[0,0],
	"heat_rotation":0,
	"heat_scale":[1,1],
}
var aux_type
func loadPlaceholder():
	itsPointers = ModLoader._savedObjects[0]
	hl_thrusterslot_modify()
	.loadPlaceholder()
#	yield(get_tree(),"idle_frame")
func hl_thrusterslot_modify():
	var datastore = itsPointers.Equipment.auxslot_data
	shipName = ship.shipName
	baseShipName = ship.baseShipName
	var slotType = type.split(".")[0]
	var currentInstall = ship.getConfig(type)
	if slotType in datastore:
		for data in datastore[slotType]:
			var aux_path = data.get("path","")
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
				if aux_path != "":
					if itsPointers.DataFormat.__load_if_can(aux_path):
						valid_scene = true
						item = itsPointers.DataFormat.__get_load().instance()
				
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
								item = load(thruster).instance()
				
#				var sysn = name + "_" + sys
				item.name = sys
#				system = item
				
#				item.name = sys\
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
#					var savepath = "user://thrusterTest.tscn"
#					var pc = PackedScene.new()
#					pc.pack(item)
#					ResourceSaver.save(savepath,pc)
#					breakpoint
#					add_child(item)

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
		timerObject = Timer.new()
		timerObject.wait_time = 0.5
		timerObject.one_shot = true
		timerObject.connect("timeout",self,"hl_thrusterslot_recolor")
		CurrentGame.get_tree().get_root().add_child(timerObject)
		timerObject.call_deferred("start")

func hl_thrusterslot_convert_to_nozzle(noz):
	var nozzle = nozzle_template.duplicate(true)
	for i in nozzle:
		if i in noz and typeof(nozzle[i]) == typeof(noz[i]):
			nozzle[i] = noz[i]
	return nozzle

func hl_thrusterslot_recolor():
	if not flare:
		for node in get_children():
			if node.name.begins_with(name + "_"):
				flare = node.get_node_or_null("Flare")
	if flare and fco:
		flare.color = fco
	Tool.remove(timerObject)

func hl_thrusterslot_modify_nozzle(nozzleA,nd):
	if nozzleA:
		if aux_type != "NOT_A_THRUSTER":
			nozzleA.coolTime = nd.cool_time
			nozzleA.heatTime = nd.heat_time
		var tr
		if itsPointers.DataFormat.__load_if_can(nd.texture):
			tr = itsPointers.DataFormat.__get_load()
		else:
			tr = load("res://ships/modules/nozzle-cd.png")
		nozzleA.texture = tr
		var tl
		if itsPointers.DataFormat.__load_if_can(nd.normal):
			tr = itsPointers.DataFormat.__get_load()
		else:
			tl = load("res://ships/modules/nozzle-n.png")
		nozzleA.normal_map = tl
		var heat = nozzleA.get_node_or_null("heat")
		if heat:
			var h
			if itsPointers.DataFormat.__load_if_can(nd.heat):
				h = itsPointers.DataFormat.__get_load()
			else:
				h = load("res://ships/modules/nozzle-cl.png")
			heat.texture = h
			var thn = null
			if itsPointers.DataFormat.__load_if_can(nd.heat_normal):
				thn = itsPointers.DataFormat.__get_load()
			if thn:
				heat.normal_map = thn
			heat.region_enabled = nd.heat_region_enabled
		
			var rr = nd.heat_region_rect
			if rr.size() >= 4:
				heat.region_rect = Rect2(rr[0],rr[1],rr[2],rr[3])
			heat.region_filter_clip = nd.heat_region_filter_clip
			var rp = nd.heat_position
			if rp.size() >= 2:
				heat.position = Vector2(rp[0],rp[1])
			heat.set("rotation",deg2rad(nd.heat_rotation))
#			heat.set_deferred("rotation",deg2rad(nd.heat_rotation))
			var rs = nd.heat_scale
			if rs.size() >= 2:
				heat.scale = Vector2(rs[0],rs[1])
		nozzleA.region_enabled = nd.region_enabled
		
		var rr = nd.region_rect
		if rr.size() >= 4:
			nozzleA.region_rect = Rect2(rr[0],rr[1],rr[2],rr[3])
		nozzleA.region_filter_clip = nd.region_filter_clip
		var rp = nd.position
		if rp.size() >= 2:
			nozzleA.position = Vector2(rp[0],rp[1])
		nozzleA.set("rotation",deg2rad(nd.rotation))
#		nozzleA.set_deferred("rotation",deg2rad(nd.rotation))
		var rs = nd.scale
		if rs.size() >= 2:
			nozzleA.scale = Vector2(rs[0],rs[1])

func hl_thrusterslot_get_colors():
	
	var color_data = ModLoader._savedObjects[0].Equipment.ship_thruster_colors
	
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
