extends Node

static func convert_arr_to_vec2arr(array: Array) -> PoolVector2Array:
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
	return converted
