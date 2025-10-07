extends Node

const ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")

const not_random_seeds = PoolIntArray([1861,2531,1337,1776,2014,1384,2684,842,2802,1597,2116,755,1596,2661,1928,-1861,-2531,-1337,-1776,-2014,-1384,-2684,-842,-2802,-1597,-2116,-755,-1596,-2661,-1928,1861,-2531,1337,-1776,2014,-1384,2684,-842,2802,-1597,2116,-755,1596,-2661,1928,1861,-2531,1337,-1776,2014,-1384,2684,-842,2802,-1597,2116,-755,1596,-2661,1928])

static func make_ring_modifications():
	
	var p = CurrentGame.traceMinerals
	var s = p.size()
	var m = (s / 4) + 1
	var do_randomize = ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DRIVERS","randomize_minerals")
	
	var seeds = []
	
	if do_randomize:
		seeds.append(not_random_seeds[0])
		seeds.append(not_random_seeds[1])
		for i in m - 2:
			var num = (randi() % 2250) + 750
			seeds.append(num)
	
	else:
		for i in range(0,m):
			if i >= not_random_seeds.size():
				var f = i%not_random_seeds.size()
				seeds.append(not_random_seeds[f])
			else:
				seeds.append(not_random_seeds[i])
	
	
	var ring_header = "extends \"res://TheRing.gd\"\n\nfunc getVeinAt(pos)->String:\n\n"
	var neg_var = false
	var variable_statements = ring_header
	for i in range(seeds.size()):
		var sd = seeds[i]
		if neg_var:
			sd = -sd
		neg_var = !neg_var
		var statement = "\tvar p%s = getVeinPixelAt(pos / %s.0)\n" % [i + 1,sd]
		variable_statements = variable_statements + statement
	
	var v_arr = []
	for i in range(seeds.size()):
		var item = "p%s" % (i+1)
		v_arr.append_array([item + ".r",item + ".g",item + ".b",item + ".a"])
	variable_statements = variable_statements + "\n\n\tvar values = " + str(v_arr) + "\n\n"
	
	var footer = "\tvar total = 0\n\tfor n in range(CurrentGame.traceMinerals.size()):\n\t\tvar tm = CurrentGame.traceMinerals[n]\n\t\tvalues[n] = pow(values[n] / pow(CurrentGame.mineralPrices.get(tm, 1), 0.2), 4)\n\t\ttotal += values[n]\n\tvar rnd = randf() * total\n\tvar nr = 0\n\tfor n in values:\n\t\trnd -= n\n\t\tif rnd < 0:\n\t\t\treturn CurrentGame.traceMinerals[nr]\n\t\tnr += 1\n\n\treturn CurrentGame.traceMinerals[0]"
	var total = variable_statements + footer
	var f = File.new()
	f.open("user://cache/.HevLib_Cache/Minerals/TheRing.gd",File.WRITE)
	f.store_string(total)
	f.close()
