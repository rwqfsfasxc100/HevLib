extends Node

static func get_mods_and_tags_from_tag(tag_name: String) -> Dictionary:
	var ManifestV2 = preload("res://HevLib/pointers/ManifestV2.gd")
	var alldata = ManifestV2.__get_tags()
	var data = alldata.get(tag_name,{})
	var ex_data = {}
	var keys = data.keys()
	if keys.size() >=1:
		for mod in keys:
			match tag_name:
				"adds_equipment","adds_events","adds_gameplay_mechanics","adds_ships":
					var k = data.get(mod,[])
					var num = k.size()
					if num >= 1:
						var equip = []
						for lang in k:
							equip.append(lang)
						ex_data[mod] = equip
#						if k in tag_dict:
#							pass
#						else:
#							tag_dict[tag_name].append(k)
				"handle_extra_crew":
					var k = data.get(mod,24)
					if k >= 25:
						ex_data[mod] = k
#					if k > tag_dict[tag_name]:
#						tag_dict[tag_name] = k
				"language":
					var k = data.get(mod,["en"])
					if k.size() >= 1:
						var languages = []
						for lang in k:
							languages.append(lang)
						ex_data[mod] = languages
				_:
					var k = data.get(mod,false)
					ex_data[mod] = k
#					tag_dict[tag_name] = k
	
	return ex_data
