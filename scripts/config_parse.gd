extends Node

static func config_parse(file):
	var f2 = File.new()
	f2.open(file,File.READ)
	var txt = f2.get_as_text()
	f2.close()
	var cfg = ConfigFile.new()
	cfg.parse(txt)
	var cfg_sections = cfg.get_sections()
	var cfg_dictionary = {}
	for section in cfg_sections:
		var data = {}
		var keys = cfg.get_section_keys(section)
		for key in keys:
			var item = cfg.get_value(section,key)
			data.merge({key:item})
		cfg_dictionary.merge({section:data})
	return cfg_dictionary
