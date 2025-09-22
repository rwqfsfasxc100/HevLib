extends "res://ships/ship-ctrl.gd"

var ship_register_file = "user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/ships/ship_node_register.json"
var node_definitons_file = "user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/ships/node_definitions.json"

var processed_node_definitions = {}
var processed_ship_register = {}

var file = File.new()
var NodeAccess = preload("res://HevLib/pointers/NodeAccess.gd")
var DF = preload("res://HevLib/pointers/DataFormat.gd")

func _ready():
	processed_node_definitions = process_node_definitons()
	processed_ship_register = process_ship_register()
	
	
	var n_store = {}
	
	var get_base_ship_fallback = true
	var fallback_ship = baseShipName
	
	if shipName in processed_ship_register:
		var datafetch = processed_ship_register[shipName]["node_definitions"]
		get_base_ship_fallback = datafetch.get("fallback_to_base_ship",true)
		fallback_ship = datafetch.get("fallback_override",baseShipName)
		n_store = datafetch
	if get_base_ship_fallback:
		if fallback_ship in processed_ship_register:
			var datafetch = processed_ship_register[fallback_ship]["node_definitions"]
			for obj in datafetch:
				if obj in n_store:
					pass
				else:
					n_store.merge({obj:datafetch[obj]})
	
	
	var selfpath = get_path()
	
	for object in n_store:
		var obj_data = n_store[object]
		var node_data = processed_node_definitions[object]
		var childNames = []
		for c in get_children():
			childNames.append(c.name)
		if object in childNames:
			continue
		var properties = {}
		var position_data = {}
		for p in obj_data.get("properties",{}):
			if p in properties:
				pass
			else:
				properties.merge({p:obj_data["properties"][p]})
		for p in obj_data.get("position_data",{}):
			if p in position_data:
				pass
			else:
				position_data.merge({p:obj_data["position_data"][p]})
		
		for p in node_data.get("properties",{}):
			if p in properties:
				pass
			else:
				properties.merge({p:node_data["properties"][p]})
		for p in node_data.get("position_data",{}):
			if p in position_data:
				pass
			else:
				position_data.merge({p:node_data["position_data"][p]})
		
		var nodeset = node_data["node"]
		
		var node = nodeset.instance()
		node.name = object
		if "position" in node:
			var npos = position_data.get("position")
			var new_pos = Vector2(0,0)
			match typeof(npos):
				TYPE_VECTOR2:
					new_pos = npos
					node.set("position",new_pos)
				TYPE_VECTOR2_ARRAY:
					if npos.size() >= 1:
						new_pos = npos[0]
						node.set("position",new_pos)
				TYPE_ARRAY, TYPE_INT_ARRAY, TYPE_REAL_ARRAY:
					var scan = DF.__convert_arr_to_vec2arr(npos)
					if scan.size() >= 1:
						new_pos = scan[0]
						node.set("position",new_pos)
		if "rotation" in node:
			var nrot = position_data.get("rotation")
			var new_rot = 0.0
			match typeof(nrot):
				TYPE_INT:
					var rot = deg2rad(nrot)
					node.set("rotation",rot)
				TYPE_REAL:
					var rot = deg2rad(nrot)
					node.set("rotation",rot)
		if "scale" in node:
			var nscale = position_data.get("scale")
			var new_scale = Vector2(1,1)
			match typeof(nscale):
				TYPE_ARRAY, TYPE_RAW_ARRAY, TYPE_REAL_ARRAY, TYPE_INT_ARRAY:
					if nscale.size() >=2:
						new_scale = Vector2(nscale[0],nscale[1])
					elif nscale.size() == 1:
						new_scale = Vector2(nscale[0],nscale[0])
					node.set("scale",new_scale)
				TYPE_INT, TYPE_REAL:
					new_scale = Vector2(nscale,nscale)
					node.set("scale",new_scale)
				TYPE_VECTOR2:
					new_scale = nscale
					node.set("scale",new_scale)
				TYPE_VECTOR2_ARRAY:
					if nscale.size() >= 1:
						new_scale = nscale[0]
						node.set("scale",new_scale)
		
		var prop_bin = {}
		
		for prop in properties:
			breakpoint
		
		
		
#		breakpoint
		call_deferred("add_child",node)
		
		
		
		
		
		
		
		












func process_ship_register():
	var pd = {}
	file.open(ship_register_file,File.READ)
	var data = JSON.parse(file.get_as_text()).result
	file.close()
	
	for object in data:
		var obj_ship_name = object.get("ship_name","")
		if obj_ship_name != "":
			var obj_fallback_to_base_ship = object.get("fallback_to_base_ship",true)
			var obj_fallback_override = object.get("fallback_override",baseShipName)
			var obj_node_definitions = object.get("node_definitions",{})
			
			if obj_ship_name in pd.keys():
				for definition in obj_node_definitions:
					if definition in processed_node_definitions:
						var def = obj_node_definitions[definition]
						pd[obj_ship_name]["node_definitions"].merge({definition:def})
			else:
				var dictionary = {}
				for definition in obj_node_definitions:
					if definition in processed_node_definitions:
							var def = obj_node_definitions[definition]
							dictionary.merge({definition:def})
				var dict = {
					obj_ship_name:{
						"fallback_to_base_ship":obj_fallback_to_base_ship,
						"fallback_override":obj_fallback_override,
						"node_definitions":dictionary
					}
				}
				
				pd.merge(dict)
			
	return pd




func process_node_definitons():
	var pd = {}
	file.open(node_definitons_file,File.READ)
	var data = JSON.parse(file.get_as_text()).result
	file.close()
	
	for module in data:
		var md = data[module]
		if "path" in md:
			var filepath = md["path"]
			var exists = file.file_exists(filepath)
			if exists:
				var node = load(filepath)
				var properties = md.get("properties",{})
				var pos = md.get("position",[0,0])
				var scl = md.get("scale",[1])
				var rot = md.get("rotation",0)
				var pos_basic = {"position":pos,"scale":scl,"rotation":rot}
				pd.merge({module:{"node":node,"properties":properties,"position_data":pos_basic}})
	
	return pd
	
