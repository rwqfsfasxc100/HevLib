extends Node

static func parse_changelogs(file_path):
	var c = ConfigFile.new()
	var changelog = {}
	c.load(file_path)
	var ConfigDriver = load("res://HevLib/pointers/ConfigDriver.gd")
	var versions = c.get_sections()
	var spacing = "  "
	for version in versions:
		changelog.merge({version:[]})
		var keys = c.get_section_keys(version)
		var current_key = 1
		while current_key > 0:
			var key = str(current_key)
			if key in keys:
				var entry = c.get_value(version,key)
				changelog[version].append(entry)
				var current_subkey = 1
				while current_subkey > 0:
					var subkey = key + "." + str(current_subkey)
					if subkey in keys:
						var entry2 = c.get_value(version,subkey)
						entry2 = spacing + entry2
						changelog[version].append(entry2)
						var current_subkey2 = 1
						while current_subkey2 > 0:
							var subkey2 = subkey + "." + str(current_subkey2)
							if subkey2 in keys:
								var entry3 = c.get_value(version,subkey2)
								entry3 = spacing + spacing + entry3
								changelog[version].append(entry3)
								var current_subkey3 = 1
								while current_subkey3 > 0:
									var subkey3 = subkey2 + "." + str(current_subkey3)
									if subkey3 in keys:
										var entry4 = c.get_value(version,subkey3)
										entry4 = spacing + spacing + spacing + entry4
										changelog[version].append(entry4)
										current_subkey3 += 1
									else:
										current_subkey3 = 0
								current_subkey2 += 1
							else:
								current_subkey2 = 0
						current_subkey += 1
					else:
						current_subkey = 0
					
					pass
				
				current_key += 1
			else:
				current_key = 0
		
		pass
	return changelog
