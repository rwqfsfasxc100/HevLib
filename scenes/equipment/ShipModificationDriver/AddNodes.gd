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

extends "res://ships/ship-ctrl.gd"

var pointers_hl_addnodes:HevLibPointers
func _enter_tree():
	pointers_hl_addnodes = ModLoader._savedObjects[0]
	hl_add_nodes_make_node_mods()
	
func hl_add_nodes_make_node_mods():
	var processed_ship_numerics_modifications:Dictionary = hl_add_nodes_process_modified_ship_numerics()
	var processed_node_definitions:Dictionary = hl_add_nodes_process_node_definitons()
	var processed_ship_register:Dictionary = hl_add_nodes_process_ship_register(processed_node_definitions)
	
	if processed_ship_numerics_modifications:
		for type in processed_ship_numerics_modifications:
			match type:
				"ammo":
					if "min" in processed_ship_numerics_modifications[type]:
						upgradeLimits["ammo.capacity"].x = processed_ship_numerics_modifications[type]["min"]
					if "max" in processed_ship_numerics_modifications[type]:
						upgradeLimits["ammo.capacity"].y = processed_ship_numerics_modifications[type]["max"]
				"nano":
					if "min" in processed_ship_numerics_modifications[type]:
						upgradeLimits["drones.capacity"].x = processed_ship_numerics_modifications[type]["min"]
					if "max" in processed_ship_numerics_modifications[type]:
						upgradeLimits["drones.capacity"].y = processed_ship_numerics_modifications[type]["max"]
				"propellant":
					if "min" in processed_ship_numerics_modifications[type]:
						upgradeLimits["fuel.capacity"].x = processed_ship_numerics_modifications[type]["min"]
					if "max" in processed_ship_numerics_modifications[type]:
						upgradeLimits["fuel.capacity"].y = processed_ship_numerics_modifications[type]["max"]
				"reactor_core":
					if "min" in processed_ship_numerics_modifications[type]:
						upgradeLimits["reactor.power"].x = processed_ship_numerics_modifications[type]["min"]
					if "max" in processed_ship_numerics_modifications[type]:
						upgradeLimits["reactor.power"].y = processed_ship_numerics_modifications[type]["max"]
				"ultracapacitor":
					if "min" in processed_ship_numerics_modifications[type]:
						upgradeLimits["capacitor.capacity"].x = processed_ship_numerics_modifications[type]["min"]
					if "max" in processed_ship_numerics_modifications[type]:
						upgradeLimits["capacitor.capacity"].y = processed_ship_numerics_modifications[type]["max"]
				"turbine":
					if "min" in processed_ship_numerics_modifications[type]:
						upgradeLimits["turbine.power"].x = processed_ship_numerics_modifications[type]["min"]
					if "max" in processed_ship_numerics_modifications[type]:
						upgradeLimits["turbine.power"].y = processed_ship_numerics_modifications[type]["max"]
	
	
	var n_store:Dictionary = {}
	
	var get_base_ship_fallback:bool = true
	var fallback_ship = baseShipName
	
	if shipName in processed_ship_register:
		n_store = processed_ship_register[shipName]["node_definitions"]
		get_base_ship_fallback = n_store.get("fallback_to_base_ship",true)
		fallback_ship = n_store.get("fallback_override",baseShipName)
	if get_base_ship_fallback:
		if fallback_ship and fallback_ship in processed_ship_register:
			var datafetch:Dictionary = processed_ship_register[fallback_ship]["node_definitions"]
			for obj in datafetch:
				if processed_node_definitions[obj]["recurse_to_variants"]:
					if not obj in n_store:
						n_store[obj] = datafetch[obj]
	
	
	var selfpath:NodePath = get_path()
	var node_parent_path:NodePath = get_path_to(self)
	var thisNode:NodePath = node_parent_path
	
	for object in n_store:
		var obj_data:Dictionary = n_store[object]
		var node_data:Dictionary = processed_node_definitions[object]
		
		if pointers_hl_addnodes.ConfigDriver.__validate_dictionary(obj_data):
			if not node_data["recurse_to_variants"]:
				var sh:Dictionary = processed_ship_register.get(shipName,{"node_definitions":{}})
				if not object in sh["node_definitions"].keys():
					continue
		
		if shipName in node_data["ships_to_ignore"]:
			continue
		
		var childNames:PoolStringArray = PoolStringArray()
		for c in get_children():
			childNames.append(c.name)
		if object in childNames:
			continue
		var properties:Array = []
		var position_data:Dictionary = {}
		node_parent_path = NodePath(obj_data.get("parent_node_path",get_path_to(self)))
		var obj_prop = obj_data.get("properties",[])
		match typeof(obj_prop):
			TYPE_ARRAY:
				properties.append_array(obj_prop)
			TYPE_DICTIONARY:
				for p in obj_prop:
					var dv = obj_prop[p]
					dv.merge({"property":p})
					properties.append(dv)
		for p in obj_data.get("position_data",{}):
			if not p in position_data:
				position_data.merge({p:obj_data["position_data"][p]})
		var node_prop = node_data.get("properties",{})
		match typeof(node_prop):
			TYPE_ARRAY:
				properties.append_array(node_prop)
			TYPE_DICTIONARY:
				for p in node_prop:
					var dv = node_prop[p]
					dv.merge({"property":p})
					properties.append(dv)
		for p in node_data.get("position_data",{}):
			if not p in position_data:
				position_data.merge({p:node_data["position_data"][p]})
		
		var node:Node = node_data["node"].instance()
		node.name = object
		
		
		
		if "position" in node:
			var npos = position_data.get("position")
			var new_pos:Vector2 = Vector2.ZERO
			match typeof(npos):
				TYPE_VECTOR2:
					new_pos = npos
					node.set_deferred("position",new_pos)
				TYPE_VECTOR2_ARRAY:
					if npos.size() >= 1:
						new_pos = npos[0]
						node.set_deferred("position",new_pos)
				TYPE_ARRAY, TYPE_INT_ARRAY, TYPE_REAL_ARRAY:
					var scan:PoolVector2Array = pointers_hl_addnodes.DataFormat.__convert_arr_to_vec2arr(npos)
					if scan:
						new_pos = scan[0]
						node.set_deferred("position",new_pos)
		if "rotation" in node:
			var nrot:float = float(position_data.get("rotation"))
			if nrot != 0.0:
				node.set_deferred("rotation",deg2rad(nrot))
		if "scale" in node:
			var nscale = position_data.get("scale")
			match typeof(nscale):
				TYPE_ARRAY, TYPE_RAW_ARRAY, TYPE_REAL_ARRAY, TYPE_INT_ARRAY:
					if nscale.size() > 1:
						node.set_deferred("scale",Vector2(nscale[0],nscale[1]))
					elif nscale.size() == 1:
						node.set_deferred("scale",Vector2(nscale[0],nscale[0]))
				TYPE_INT, TYPE_REAL:
					node.set_deferred("scale",Vector2(nscale,nscale))
				TYPE_VECTOR2:
					node.set_deferred("scale",nscale)
				TYPE_VECTOR2_ARRAY:
					if nscale:
						node.set_deferred("scale",nscale[0])
		match typeof(properties):
			TYPE_ARRAY:
				for data in properties:
					var prop:String = data.get("property","")
					if prop:
						var split:PoolStringArray = prop.split("/")
						if split.size() == 1:
							if prop in node:
								var setter = hl_add_nodes_format_properties(data,data.get("method",""),prop,"",node,node_parent_path)
								if data.get("defer",false):
									node.set_deferred(prop,setter)
								else:
									node.set(prop,setter)
						else:
							var nprop:String = split[split.size() - 1]
							var npath:String = prop.split(nprop)[0]
							if npath.ends_with("/"):
								npath = npath.rstrip("/")
							var pointer:Node = node.get_node_or_null(npath)
							if pointer == null:
								continue
							if nprop in pointer:
								var setter = hl_add_nodes_format_properties(data,data.get("method",""),nprop,npath,node,node_parent_path)
								if data.get("defer",false):
									pointer.set_deferred(nprop,setter)
								else:
									pointer.set(nprop,setter)
			
			TYPE_DICTIONARY:
				for prop in properties:
					var data:Dictionary = properties[prop]
					var split:PoolStringArray = prop.split("/")
					if split.size() == 1:
						if prop in node:
							var setter = hl_add_nodes_format_properties(data,data.get("method",""),prop,"",node,node_parent_path)
							if data.get("defer",false):
								node.set_deferred(prop,setter)
							else:
								node.set(prop,setter)
							
							
					else:
						var nprop:String = split[split.size() - 1]
						var npath:String = prop.split(nprop)[0]
						if npath.ends_with("/"):
							npath = npath.rstrip("/")
						var pointer:Node = node.get_node_or_null(npath)
						if pointer == null:
							continue
						if nprop in pointer:
							var setter = hl_add_nodes_format_properties(data,data.get("method",""),nprop,npath,node,node_parent_path)
							if data.get("defer",false):
								pointer.set_deferred(nprop,setter)
							else:
								pointer.set(nprop,setter)
		
		
		var p = get_node_or_null(node_parent_path)
		if p == null:
			p = self
		if str(get_path_to(p)) != str(thisNode) and "registerExternal" in node:
			node.registerExternal = true
		p.add_child(node)
	hl_add_nodes_node_modify()


func hl_add_nodes_node_modify():
	var modify_data:Dictionary = pointers_hl_addnodes.Equipment.ship_node_modify
	if shipName != baseShipName and baseShipName in modify_data:
		for xd in modify_data[baseShipName]:
			if pointers_hl_addnodes.ConfigDriver.__validate_dictionary(xd) and xd.get("recurse_to_variants",false):
				var node:Node = get_node_or_null(xd.get("path","."))
				var property:String = xd.get("property","null_value_to_ensure_that_this_fails_when_absent_lol_hi")
				if node and property in node:
					if xd.get("defer",false):
						node.set_deferred(property,xd.get("value",null))
					else:
						node.set(property,xd.get("value",null))
	if shipName in modify_data:
		for xd in modify_data[shipName]:
			if pointers_hl_addnodes.ConfigDriver.__validate_dictionary(xd):
				var node = get_node_or_null(xd.get("path","."))
				var value = xd.get("value",null)
				var property = xd.get("property","null_value_to_ensure_that_this_fails_when_absent_lol_hi")
				if node and property in node:
					if xd.get("defer",false):
						node.set_deferred(property,value)
					else:
						node.set(property,value)
	
	
func hl_add_nodes_format_properties(data,format,property,property_path,base_node,parent_path):
	match format:
		"copy":
			return hl_add_nodes_copy_property(data.get("node_path",""),data.get("property",property),data.get("format",""))
		"center_to_ship":
			return hl_add_nodes_center_to_ship(property_path,base_node,data.get("ignore_scaling",false),parent_path)
		"invert_scaling":
			return hl_add_nodes_invert_scaling(property_path,base_node)
		_:
			return hl_add_nodes_format_data(data.get("value",null),format)

func hl_add_nodes_format_data(data, format):
	match format:
		"arr2vec2arr":
			return pointers_hl_addnodes.DataFormat.__convert_arr_to_vec2arr(data)
		"arr2vec2":
			return hl_add_nodes_convert_arr_to_vec2(data)
		_:
			return data

func hl_add_nodes_convert_arr_to_vec2(array:Array) -> Vector2:
	var new_scale:Vector2 = Vector2.ZERO
	if array.size() > 1:
		new_scale = Vector2(float(array[0]),float(array[1]))
	elif array.size() == 1:
		new_scale = Vector2(float(array[0]),float(array[0]))
	return new_scale

func hl_add_nodes_copy_property(path: String,property: String,method: String = ""):
	var node:Node = self
	var p:String = property.split("/")[property.split("/").size() - 1]
	if path:
		node = get_node_or_null(path)
	if node and p in node:
		return hl_add_nodes_format_data(node.get(p), method)
	return null

func hl_add_nodes_center_to_ship(property,base_node,ignore_scaling = false,parent_path = "."):
	if base_node.get_node_or_null(property) == null:
		return
	var true_position:Vector2 = Vector2.ZERO
	var positions:Dictionary = {}
	if "position" in base_node:
		var pos:Vector2 = base_node.position
		if ignore_scaling and "scale" in base_node:
			var s:Vector2 = base_node.scale
			pos.x = pos.x * (1/s.x)
			pos.y = pos.y * (1/s.y)
		true_position -= pos
		positions.merge({"base_node":pos})
	var parent:Node = get_node(parent_path)
	while parent != null and parent != self:
		var pos:Vector2 = parent.position
		if ignore_scaling and "scale" in parent:
			var s:Vector2 = parent.scale
			pos.x = pos.x * (1/s.x)
			pos.y = pos.y * (1/s.y)
		true_position -= pos
		positions.merge({parent.name:pos})
		parent = parent.get_parent()
	var split:Array = Array(property.split("/"))
	var iterations:int = split.size()
	while iterations > 0:
		var nd:String = ""
		for item in split:
			if nd == "":
				nd = item
			else:
				nd = nd + "/" + item
		var node:Node = base_node.get_node_or_null(nd)
		if node:
			if ignore_scaling and "position" in node:
				var pos:Vector2 = node.position
				if "scale" in node:
					var s:Vector2 = node.scale
					pos.x = pos.x * (1/s.x)
					pos.y = pos.y * (1/s.y)
				true_position -= pos
				positions[nd] = pos
		iterations -= 1
		split.pop_back()
	
	
	return true_position

func hl_add_nodes_invert_scaling(node_path,base_node):
	var scalings:Dictionary = {}
	
	var x_mod:float = 1.0
	var y_mod:float = 1.0
	
	if "scale" in base_node:
		var s:Vector2 = base_node.scale
		var x:float = s.x
		var y:float = s.y
		scalings.merge({"base_node":s})
		x_mod *= (1/x)
		y_mod *= (1/y)
	
	var split:Array = Array(node_path.split("/"))
	var iterations:int = split.size()
	while iterations > 0:
		var nd:String = ""
		for item in split:
			if nd == "":
				nd = item
			else:
				nd = nd + "/" + item
		var node:Node = base_node.get_node_or_null(nd)
		if node:
			if "scale" in node:
				var s:Vector2 = node.scale
				scalings.merge({nd:s})
				var x:float = s.x
				var y:float = s.y
				x_mod *= (1/x)
				y_mod *= (1/y)
		iterations -= 1
		split.pop_back()
	
	return Vector2(x_mod,y_mod)






func hl_add_nodes_process_ship_register(processed_node_definitions:Dictionary):
	var file:File = File.new()
	var pd:Dictionary = {}
	var data:Array = pointers_hl_addnodes.Equipment.ship_node_register
	
	for object in data:
		var obj_ship_name:String = object.get("ship_name","")
		if obj_ship_name:
			var obj_fallback_to_base_ship:bool = object.get("fallback_to_base_ship",true)
			var obj_fallback_override:String = object.get("fallback_override",baseShipName)
			var obj_node_definitions:Dictionary = object.get("node_definitions",{})
			
			if obj_ship_name in pd:
				for definition in obj_node_definitions:
					if definition in processed_node_definitions:
						pd[obj_ship_name]["node_definitions"][definition] = obj_node_definitions[definition]
			else:
				var dictionary:Dictionary = {}
				for definition in obj_node_definitions:
					if definition in processed_node_definitions:
							dictionary[definition] = obj_node_definitions[definition]
				
				pd[obj_ship_name] = {
					"fallback_to_base_ship":obj_fallback_to_base_ship,
					"fallback_override":obj_fallback_override,
					"node_definitions":dictionary
				}
	return pd




func hl_add_nodes_process_node_definitons():
	var file:File = File.new()
	var pd:Dictionary = {}
	var data:Dictionary = pointers_hl_addnodes.Equipment.node_definitions_cache
	
	for module in data:
		var md:Dictionary = data[module]
		if "path" in md:
			var filepath:String = md["path"]
			if pointers_hl_addnodes.DataFormat.__load_if_can(filepath):
				var node:PackedScene = pointers_hl_addnodes.DataFormat.__get_load()
				var properties:Dictionary = md.get("properties",{})
				var pos = md.get("position",[0,0])
				var scl = md.get("scale",[1])
				var rot = md.get("rotation",0)
				var pos_basic:Dictionary = {"position":pos,"scale":scl,"rotation":rot}
				var ignore:Array = Array(md.get("ships_to_ignore",[]))
				var recursive:bool = md.get("recurse_to_variants",true)
				pd.merge({module:{"node":node,"properties":properties,"position_data":pos_basic,"ships_to_ignore":ignore,"recurse_to_variants":recursive}})
			else:
				pointers_hl_addnodes.l("ERROR: Failed to load node register located at [%s], skipping" % filepath,"NodeDefinitions")
	return pd

func hl_add_nodes_process_modified_ship_numerics() -> Dictionary:
	var pd:Dictionary = {}
	var dt:Dictionary = pointers_hl_addnodes.Equipment.modify_ship_numerics
	if "ALL" in dt:
		for shipData in dt["ALL"]:
			if pointers_hl_addnodes.ConfigDriver.__validate_dictionary(shipData):
				pd = ship_numeric_modifier(shipData,pd)
	if baseShipName in dt:
		for shipData in dt[baseShipName]:
			if shipData.get("recurse_to_variants",false):
				if pointers_hl_addnodes.ConfigDriver.__validate_dictionary(shipData):
					pd = ship_numeric_modifier(shipData,pd)
	if shipName in dt:
		for shipData in dt[shipName]:
			if pointers_hl_addnodes.ConfigDriver.__validate_dictionary(shipData):
				pd = ship_numeric_modifier(shipData,pd)
	return pd

func ship_numeric_modifier(shipData:Dictionary,pd:Dictionary):
	for type in shipData:
		match type:
			"ammo","mass_driver_ammo","ammunition":
				if not "ammo" in pd:
					pd["ammo"] = {}
				if "min" in shipData[type]:
					pd["ammo"]["min"] = shipData[type]["min"]
				if "max" in shipData[type]:
					pd["ammo"]["max"] = shipData[type]["max"]
			"nano","nanodrones","nanodrone_components":
				if not "nano" in pd:
					pd["nano"] = {}
				if "min" in shipData[type]:
					pd["nano"]["min"] = shipData[type]["min"]
				if "max" in shipData[type]:
					pd["nano"]["max"] = shipData[type]["max"]
			"fuel","propellant","remass":
				if not "propellant" in pd:
					pd["propellant"] = {}
				if "min" in shipData[type]:
					pd["propellant"]["min"] = shipData[type]["min"]
				if "max" in shipData[type]:
					pd["propellant"]["max"] = shipData[type]["max"]
			"reactor_core","reactor","core":
				if not "reactor_core" in pd:
					pd["reactor_core"] = {}
				if "min" in shipData[type]:
					pd["reactor_core"]["min"] = shipData[type]["min"]
				if "max" in shipData[type]:
					pd["reactor_core"]["max"] = shipData[type]["max"]
			"ultracapacitor","capacitor":
				if not "ultracapacitor" in pd:
					pd["ultracapacitor"] = {}
				if "min" in shipData[type]:
					pd["ultracapacitor"]["min"] = shipData[type]["min"]
				if "max" in shipData[type]:
					pd["ultracapacitor"]["max"] = shipData[type]["max"]
			"turbine":
				if not "turbine" in pd:
					pd["turbine"] = {}
				if "min" in shipData[type]:
					pd["turbine"]["min"] = shipData[type]["min"]
				if "max" in shipData[type]:
					pd["turbine"]["max"] = shipData[type]["max"]
	return pd
