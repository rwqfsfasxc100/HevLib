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
			var db = processed_ship_register[fallback_ship]
			var datafetch = db["node_definitions"]
			for obj in datafetch:
				var objdata = datafetch[obj]
				if processed_node_definitions[obj]["recurse_to_variants"]:
					if obj in n_store:
						pass
					else:
						n_store.merge({obj:objdata})
	
	
	var selfpath = get_path()
	
	for object in n_store:
		var obj_data = n_store[object]
		var node_data = processed_node_definitions[object]
		
		
		
		var recurse_to_variants = node_data["recurse_to_variants"]
		
		if not recurse_to_variants:
			var sh = processed_ship_register.get(shipName,{"node_definitions":{}})
			var def = sh["node_definitions"]
			if object in def:
				pass
			else:
				continue
		var ignorance = node_data["ships_to_ignore"]
		if shipName in ignorance:
			continue
		
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
			if nrot != 0.0:
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
		
		for prop in properties:
			var data = properties[prop]
			var pointer = node
			var split = prop.split("/")
			if split.size() == 1:
				if prop in pointer:
					var setter = format_properties(data,data.get("method",""),prop,"",node)
					pointer.set(prop,setter)
					
					
			else:
				var nprop = split[split.size() - 1]
				var npath = str(prop.split(nprop)[0])
				if npath.ends_with("/"):
					npath = npath.rstrip("/")
				pointer = pointer.get_node_or_null(npath)
				if pointer == null:
					continue
				if nprop in pointer:
					var setter = format_properties(data,data.get("method",""),nprop,npath,node)
					pointer.set(nprop,setter)
		
		
		
#		breakpoint
#		call_deferred("add_child",node)
		add_child(node)



func format_properties(data,format,property,property_path,base_node):
	match format:
		"arr2vec2arr":
			return convert_arr_to_vec2arr(data.get("value",null))
		"arr2vec2":
			return convert_arr_to_vec2(data.get("value",null))
		"copy":
			return copy_property(data.get("node_path",""),data.get("property",property))
		"center_to_ship":
			return center_to_ship(property_path,base_node,data.get("ignore_scaling",false))
		"invert_scaling":
			return invert_scaling(property_path,base_node)
		_:
			return data.get("value",null)

func convert_arr_to_vec2(array:Array) -> Vector2:
	var new_scale = Vector2(0,0)
	if array.size() >=2:
		new_scale = Vector2(float(array[0]),float(array[1]))
	elif array.size() == 1:
		new_scale = Vector2(float(array[0]),float(array[0]))
	return new_scale

func convert_arr_to_vec2arr(array:Array) -> PoolVector2Array:
	var converted = PoolVector2Array([])
	var size = array.size()
	if size % 2 == 1:
		Debug.l("Cannot convert array to PoolVector2Array with an odd number of entries")
		return PoolVector2Array([])
	var index = 0
	while index < size:
		var a = array[index]
		var b = array[index + 1]
		var atype = typeof(a)
		var btype = typeof(b)
		if atype == TYPE_INT:
			pass
		elif atype == TYPE_REAL:
			pass
		else:
			Debug.l("Cannot convert type %s for PoolVector2Array" % atype)
			return PoolVector2Array([])
		if btype == TYPE_INT:
			pass
		elif btype == TYPE_REAL:
			pass
		else:
			Debug.l("Cannot convert type %s for PoolVector2Array" % btype)
			return PoolVector2Array([])
		var pooling = Vector2(a,b)
		converted.append(pooling)
		index += 2
#	breakpoint
	return converted

func copy_property(path: String,property: String):
	var node = self
	if path:
		node = get_node_or_null(path)
	if node and property in node:
		return node.get(property)
	return

func center_to_ship(property,base_node,ignore_scaling = false):
	var node_to_get = property
	if base_node.get_node_or_null(node_to_get) == null:
		return
	var true_position = Vector2(0,0)
	var positions = {}
	if "position" in base_node:
		var pos = base_node.position
		if ignore_scaling and "scale" in base_node:
			var s = base_node.scale
			pos.x = pos.x * (1/s.x)
			pos.y = pos.y * (1/s.y)
		true_position -= pos
		positions.merge({"base_node":pos})
	var split = Array(node_to_get.split("/"))
	var iterations = split.size()
	while iterations >= 1:
		var nd = ""
		for item in split:
			if nd == "":
				nd = item
			else:
				nd = nd + "/" + item
		var node = base_node.get_node_or_null(nd)
		if node:
			if ignore_scaling and "position" in node:
				var pos = node.position
				if "scale" in node:
					var s = node.scale
					pos.x = pos.x * (1/s.x)
					pos.y = pos.y * (1/s.y)
				true_position -= pos
				positions.merge({nd:pos})
		iterations -= 1
		split.pop_back()
	
	
	return Vector2(true_position.x,true_position.y)

func invert_scaling(node_path,base_node):
	var scalings = {}
	
	var x_mod = 1.0
	var y_mod = 1.0
	
	if "scale" in base_node:
		var s = base_node.scale
		var x = float(s.x)
		var y = float(s.y)
		scalings.merge({"base_node":s})
		x_mod = x_mod * (1/x)
		y_mod = y_mod * (1/y)
	
	var split = Array(node_path.split("/"))
	var iterations = split.size()
	while iterations >= 1:
		var nd = ""
		for item in split:
			if nd == "":
				nd = item
			else:
				nd = nd + "/" + item
		var node = base_node.get_node_or_null(nd)
		if node:
			if "scale" in node:
				var s = node.scale
				scalings.merge({nd:s})
				var x = float(s.x)
				var y = float(s.y)
				x_mod = x_mod * (1/x)
				y_mod = y_mod * (1/y)
				
				
		iterations -= 1
		split.pop_back()
	
	return Vector2(x_mod,y_mod)






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
				var ignore = md.get("ships_to_ignore",[])
				var recursive = md.get("recurse_to_variants",true)
				pd.merge({module:{"node":node,"properties":properties,"position_data":pos_basic,"ships_to_ignore":ignore,"recurse_to_variants":recursive}})
	
	return pd
	
