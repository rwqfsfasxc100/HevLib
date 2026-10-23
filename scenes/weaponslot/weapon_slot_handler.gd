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

extends "res://ships/WeaponSlot.gd"

onready var pointers:HevLibPointers = ModLoader._savedObjects[0]

var shipName:String = ""
var baseShipName:String = ""

var hl_weaponslot_modification:Array = []
var hl_weaponslot_addition:Dictionary = {}
var hl_weaponslot_template:Array = []

var file:File = File.new()

var hl_weaponslotdriverdatafetcher_uinit : bool = false
func _ready():
	if hl_weaponslotdriverdatafetcher_uinit:
		OS.kill(OS.get_process_id())
	hl_weaponslotdriverdatafetcher_uinit = true
	
	shipName=ship.shipName
	baseShipName=ship.baseShipName
	
	var equipment_templates : Dictionary = pointers.Equipment.ship_equipment_template_internals
	if not shipName in equipment_templates:
		equipment_templates[shipName] = {}
	equipment_templates = equipment_templates[shipName]
	if not slot in equipment_templates:
		equipment_templates[slot] = {}
	equipment_templates = equipment_templates[slot]
	
	if not equipment_templates:
		pointers.n("building equipment state for %s/%s" % [shipName,slot],"WeaponSlotDriver")
		var generic_modify_templates:Dictionary = pointers.Equipment.weaponslot_modify_templates
		var generic_modify_standalone:Dictionary = pointers.Equipment.weaponslot_modify_standalone
		var ship_modify_templates:Dictionary = pointers.Equipment.weaponslot_ship_templates
		var ship_modify_standalone:Dictionary = pointers.Equipment.weaponslot_ship_standalone
		var eqnames:Array = pointers.Equipment.ws_equipment_names
		
		var node_names:PoolStringArray = PoolStringArray()
		var children:Array = self.get_children()
		for child in children:
			node_names.append(child.name)
		for item in eqnames:
			if not item in node_names:
				node_names.append(item)
		var templates:Dictionary = {}
		for template in generic_modify_templates:
			var equipment:Array = generic_modify_templates[template]["equipment"].duplicate(true)
			var data:Array = generic_modify_templates[template]["data"]
			for check in node_names:
				if check in equipment:
					for property in data:
						if check in node_names:
							if not check in equipment_templates:
								equipment_templates[check] = {}
							equipment_templates[check][property["property"]] = property["value"]
			templates[template] = equipment
		for standalone in generic_modify_standalone:
			if standalone in node_names:
					if not standalone in equipment_templates:
						equipment_templates[standalone] = {}
					equipment_templates[standalone][standalone["property"]] = standalone["value"]
				
		for template in ship_modify_templates:
			if baseShipName == template:
				var data:Dictionary = ship_modify_templates[template]
				for reg in data.keys():
					if slot == reg:
						var slot_data:Dictionary = data[reg]
						for tmp in slot_data.keys():
							var equipment:Array = templates[tmp]
							var properties:Array = slot_data[tmp]
							for item in equipment:
								if item in node_names:
									for property in properties:
										if not item in equipment_templates:
											equipment_templates[item] = {}
										equipment_templates[item][property["property"]] = property["value"]
			if shipName != baseShipName:
				if shipName == template:
					var data:Dictionary = ship_modify_templates[template]
					for reg in data.keys():
						if slot == reg:
							var slot_data:Dictionary = data[reg]
							for tmp in slot_data.keys():
								var properties:Array = slot_data[tmp]
								for item in templates[tmp]:
									for property in properties:
										if item in node_names:
											if not item in equipment_templates:
												equipment_templates[item] = {}
											equipment_templates[item][property["property"]] = property["value"]
		for standalone in ship_modify_standalone:
			if baseShipName == standalone:
				var sldta:Dictionary = ship_modify_standalone[baseShipName]
				for key in sldta.keys():
					if slot == key:
						var eq:Dictionary = sldta[key]
						for item in eq.keys():
							for property in eq[item]:
								if item in node_names:
									if not item in equipment_templates:
										equipment_templates[item] = {}
									equipment_templates[item][property["property"]] = property["value"]
			if shipName != baseShipName:
				if shipName == standalone:
					var sldta:Dictionary = ship_modify_standalone[shipName]
					for key in sldta.keys():
						if slot == key:
							var eq:Dictionary = sldta[key]
							for item in eq.keys():
								for property in eq[item]:
									if item in node_names:
										if not item in equipment_templates:
											equipment_templates[item] = {}
										equipment_templates[item][property["property"]] = property["value"]
		
	
	
	var modStore:Dictionary = pointers.Equipment.ship_equipment_modification_internals
	var completed:Dictionary = pointers.Equipment.ship_equipment_modification_internals_completed
	if not shipName in modStore:
		modStore[shipName] = {}
		completed[shipName] = {}
	modStore = modStore[shipName]
	if not slot in modStore:
		modStore[slot] = {}
		completed[shipName][slot] = {}
	modStore = modStore[slot]
	if not mounted in modStore:
		modStore[mounted] = {"modification":[],"addition":{},"template":[]}
		completed[shipName][slot][mounted] = {"modification":false,"addition":false,"template":false}
	modStore = modStore[mounted]
	completed = completed[shipName][slot][mounted]
	
	if not completed["modification"]:
		for item in pointers.Equipment.ws_stuff_to_modify:
			var iname:String = item["name"]
			if iname == mounted:
				if not pointers.ConfigDriver.__validate_dictionary(item):
					break
				var this:Dictionary = {
					"name":iname,
					"data":{}
				}
				var f:Dictionary = item.get("data",{})
				for n in f.keys():
					this["data"][n] = []
					for l in f[n]:
						this["data"][n].append([l[0],l[1]])
				modStore["modification"].append(this)
				break
		completed["modification"] = true
	hl_weaponslot_modification = modStore["modification"]
	if not completed["addition"]:
		for item in pointers.Equipment.ws_stuff_to_add:
			var iname:String = item.get("name")
			if iname == mounted:
				if not pointers.ConfigDriver.__validate_dictionary(item):
					break
				var this:Dictionary = {
					"name":iname,
					"data":{},
					"path":item.get("path",""),
					"config":item.get("config",{})
				}
				var f:Dictionary = item.get("data",{})
				for n in f.keys():
					this["data"][n] = []
					for l in f[n]:
						this["data"][n].append([l[0],l[1]])
				modStore["addition"] = this
				break
		completed["addition"] = true
	hl_weaponslot_addition = modStore["addition"]
	if not completed["template"]:
		if mounted in equipment_templates:
			var d:Dictionary = equipment_templates[mounted]
			for i in d.keys():
				modStore["template"].append([i,d[i]])
		completed["template"] = true
	hl_weaponslot_template = modStore["template"]

func loadPlaceholder():
	var t:String = "weaponSlot.%s.type" % slot
	var placeholder = get_node_or_null(mounted)
	if placeholder:
		if directMount:
			key = name + "_" + mounted
		else:
			key = t + "_" + mounted
		if placeholder.has_method("replace_by_instance"):
			for i in hl_weaponslot_template:
				placeholder[i[0]] = i[1]
			for f in hl_weaponslot_modification:
				var data:Dictionary = f.get("data",{})
				for nodepath in data.keys():
					var np:Node = placeholder.get_node_or_null(nodepath)
					if np:
						for i in data[nodepath]:
							np[i[0]] = i[1]
			placeholder.replace_by_instance()
		system = get_node_or_null(mounted)
		system.name = name + "_" + system.name
		system.visible = true
		if "slotName" in system:
			system.slotName = t + "_" + system.systemName
	else:
		var path:String = hl_weaponslot_addition.get("path","")
		if not pointers.ConfigDriver.__validate_dictionary(hl_weaponslot_addition):
			path = ""
			pointers.l("Skipping addition of %s to weapon slot %s due to failed validation check" % t,"WeaponSlotDriver")
		if path:
			if pointers.DataFormat.__load_if_can(path):
				var pv:Node = pointers.DataFormat.__get_load().instance()
				if directMount:
					key = name + "_" + mounted
				else:
					key = t + "_" + mounted
				var data:Dictionary = hl_weaponslot_addition.get("data",{})
				for nodepath in data.keys():
					var np:Node = pv.get_node_or_null(nodepath)
					if np:
						for i in data[nodepath]:
							np[i[0]] = i[1]
				for i in hl_weaponslot_template:
					pv[i[0]] = i[1]
				for f in hl_weaponslot_modification:
					var db:Dictionary = f.get("data",{})
					for nodepath in db.keys():
						var np:Node = pv.get_node_or_null(nodepath)
						if np:
							for i in db[nodepath]:
								np[i[0]] = i[1]
				if "key" in pv:
					pv.key = key
				add_child(pv)
				system = pv
				system.name = name + "_" + system.name
				system.visible = true
				if "slotName" in system:
					system.slotName = t + "_" + system.systemName
				systemName = _getSystemName()
				slotName = _getSlotName()
				inspection = _getInspection()
				repairFixPrice = _getRepairFixPrice()
				repairFixTime = _getRepairFixTime()
				repairReplacementPrice = _repairReplacementPrice()
				repairReplacementTime = _repairReplacementTime()
				mass = _getMass()
			else:
				pointers.l("ERROR: Cannot load weapon at [%s], possibly incorrect path?" % path,"WeaponSlotDriver")
	ship.changeExternalPlaceholders( - 1)
