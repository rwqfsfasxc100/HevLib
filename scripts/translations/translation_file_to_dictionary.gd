extends Node

static func translation_file_to_dictionary(path : String, delimiter : String = "|") -> Dictionary:
	var log_header = "HevLib Translations: "
#	Debug.l(log_header + "__translation_file_to_dictionary started for file at [%s] using CSV delimiter as [%s]" % [path, delimiter])
	var exists = Directory.new().file_exists(path)
	if not exists:
#		Debug.l(log_header + "file at [%s] does not exist, returning empty dictionary" % path)
		return {}
	var dictionary = {}
	var file = File.new()
	file.open(path,File.READ)
	var lines = file.get_as_text(true).split("\n")
	file.close()
	
	var lang_data = lines[0]
	var language_lines = lang_data.split(delimiter)
	if not language_lines[0] == "locale":
#		Debug.l(log_header + "improper localization header for [%s], exiting with empty dictionary" % path)
		return {}
	if language_lines.size() <= 1:
#		Debug.l(log_header + "no languages specified at [%s], exiting with empty dictionary" % path)
		return {}
	var languages = []
	var lsize = language_lines.size()
	var lindex = 1
	while lindex < lsize:
		languages.append(language_lines[lindex])
		lindex += 1
	
	for lang in languages:
		var smdc = {lang:{}}
		dictionary.merge(smdc)
	var translation_count = 0
	var size = lines.size()
	var index = 1
	while index < size:
		var line = lines[index]
		if line == "":
			index += 1
			continue
		var line_split = line.split(delimiter)
		var split_size = line_split.size() - 1
		if split_size + 1 == 1:
			index += 1
			continue
		if split_size < languages.size():
			index += 1
			continue
		var translation_string = line_split[0]
		var tlindex = 0
		while tlindex < languages.size():
			var lang = languages[tlindex]
			dictionary[lang].merge({translation_string:line_split[tlindex + 1]})
			tlindex += 1
		index += 1
		translation_count += 1
#	Debug.l(log_header + "fetched translations from [%s], which contains [%s] languages and [%s] translations" % [path,languages.size(),translation_count])
	return dictionary
