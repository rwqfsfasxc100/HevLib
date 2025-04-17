extends Node

static func array_to_string(arr: Array) -> String:
	var s = ""
	for i in arr:
		s += String(i)
	Debug.l("HevLib: function 'array_to_string' instanced for %s" % s)
	return s
