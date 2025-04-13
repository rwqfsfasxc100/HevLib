extends Node

static func format_for_large_numbers(num):
	Debug.l("HevLib: function 'format_for_large_numbers' instanced, making %s readable" % num)
	var length = num.length()
	if length > 3:
		var concat = []
		var times = length/3
		var offset = length % 3
		var count = 0
		if offset > 0:
			var spl = str(num).substr(0, offset)
			concat.append(spl)
		while times > 0:
			var spl = str(num).substr(offset + (count * 3), 3)
			concat.append(spl)
			count += 1
			times -= 1
		var total = ""
		for m in concat:
			if total == "":
				total = m
			else:
				total = total + "," + m
		Debug.l("HevLib: formatted %s to %s" % [num, total])
		return total
	else:
		Debug.l("HevLib: formatting not needed, returning %s" % num)
		return str(num)
