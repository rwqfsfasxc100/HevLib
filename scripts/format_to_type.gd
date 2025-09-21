extends Node

static func format_to_type(data, type : int = TYPE_ARRAY):
	var mtype = typeof(data)
	if mtype == type:
		return data
	match type:
		TYPE_AABB:
			match mtype:
				TYPE_ARRAY, TYPE_INT_ARRAY, TYPE_REAL_ARRAY,TYPE_RAW_ARRAY:
					if data.size() >= 6:
						var a = float(data[0])
						var b = float(data[1])
						var c = float(data[2])
						var d = float(data[3])
						var e = float(data[4])
						var f = float(data[5])
						if a and b and c and d and e and f:
							return AABB(Vector3(a,b,c),Vector3(d,e,f))
				TYPE_VECTOR2_ARRAY:
					if data.size() >= 3:
						var a = float(data[0][0])
						var b = float(data[0][1])
						var c = float(data[1][0])
						var d = float(data[1][1])
						var e = float(data[2][0])
						var f = float(data[2][1])
						if a and b and c and d and e and f:
							return AABB(Vector3(a,b,c),Vector3(d,e,f))
				TYPE_VECTOR3_ARRAY:
					if data.size() >= 2:
						var a = data[0]
						var b = data[1]
						if a and b:
							return AABB(a,b)
		TYPE_ARRAY:
			match mtype:
				TYPE_ARRAY,TYPE_COLOR_ARRAY,TYPE_INT_ARRAY,TYPE_RAW_ARRAY,TYPE_REAL_ARRAY,TYPE_STRING_ARRAY,TYPE_VECTOR2_ARRAY,TYPE_VECTOR3_ARRAY:
					return data
				TYPE_DICTIONARY:
					return data.keys()
				_:
					return [data]
					
		TYPE_BASIS:
			match mtype:
				TYPE_ARRAY, TYPE_INT_ARRAY, TYPE_REAL_ARRAY,TYPE_RAW_ARRAY:
					if data.size() >= 9:
						var a = float(data[0])
						var b = float(data[1])
						var c = float(data[2])
						var d = float(data[3])
						var e = float(data[4])
						var f = float(data[5])
						var g = float(data[6])
						var h = float(data[7])
						var i = float(data[8])
						if a and b and c and d and e and f and g and h and i:
							return Basis(Vector3(a,b,c),Vector3(d,e,f),Vector3(g,h,i))
				TYPE_VECTOR2_ARRAY:
					if data.size() >= 5:
						var a = float(data[0][0])
						var b = float(data[0][1])
						var c = float(data[1][0])
						var d = float(data[1][1])
						var e = float(data[2][0])
						var f = float(data[2][1])
						var g = float(data[3][0])
						var h = float(data[3][1])
						var i = float(data[4][0])
						if a and b and c and d and e and f and g and h and i:
							return Basis(Vector3(a,b,c),Vector3(d,e,f),Vector3(g,h,i))
				TYPE_VECTOR3_ARRAY:
					if data.size() >= 2:
						var a = data[0]
						var b = data[1]
						var c = data[2]
						if a and b and c:
							return Basis(a,b,c)
		TYPE_BOOL:
			if data:
				return true
			else:
				return false
		TYPE_COLOR:
			pass
		TYPE_COLOR_ARRAY:
			pass
		TYPE_DICTIONARY:
			pass
		TYPE_INT:
			pass
		TYPE_INT_ARRAY:
			pass
		TYPE_NIL:
			return null
		TYPE_NODE_PATH:
			pass
		TYPE_PLANE:
			pass
		TYPE_QUAT:
			pass
		TYPE_RAW_ARRAY:
			pass
		TYPE_REAL:
			pass
		TYPE_REAL_ARRAY:
			pass
		TYPE_RECT2:
			pass
		TYPE_STRING:
			pass
		TYPE_STRING_ARRAY:
			pass
		TYPE_TRANSFORM:
			pass
		TYPE_TRANSFORM2D:
			pass
		TYPE_VECTOR2:
			pass
		TYPE_VECTOR2_ARRAY:
			pass
		TYPE_VECTOR3:
			pass
		TYPE_VECTOR3_ARRAY:
			pass
		
	Debug.l("HevLib format_to_type: Cannot convert variable type. Please handle this manually.")
	return null
