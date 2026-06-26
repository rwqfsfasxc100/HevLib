extends Node

const default_version : float = 2.2

const manifest_template = {
	"mod_information":{
		"name":"",
		"id":"",
		"description":"",
		"brief":"",
		"author":"",
		"credits":PoolStringArray([])
	},
	"version":{
		"version_major":1,
		"version_minor":0,
		"version_bugfix":0,
		"version_metadata":"",
		"version_string":"1.0.0"
	},
	"tags":{
		
	},
	"links":{
		
	},
	"configs":{
		
	},
	"languages":{
		
	},
	"library":{
		"is_library":false,
		"always_display":false,
	},
	"manifest_definitions":{
		"manifest_version":1.0,
		"dependancy_mod_ids":PoolStringArray([]),
		"conflicting_mod_ids":PoolStringArray([]),
		"complementary_mod_ids":PoolStringArray([]),
		"manifest_url":"", # EXAMPLE: https://raw.githubusercontent.com/rwqfsfasxc100/HevLib/main/Mod.manifest
		"changelog_path":"", # This is relative to the ModMain.gd file. EXAMPLE: for a file at 'res://Example Mod/data/folder/changelogs.txt', you would put 'data/folder/changelogs.txt'
		"modlet_priority":0, # SPECIFIC TO MODLETS! The order at which the modlet would be loaded. Most modlets load before other mods, but this will affect load order within the list of installed modlets
	}
}

const always_save = {
	"mod_information":{
		"name":"Example Mod",
		"id":"example.mod"
	},
	"version":{
		"version_major":1,
		"version_minor":0,
		"version_bugfix":0,
	},
	"manifest_definitions":{
		"manifest_version":1.0,
	},
}

static func format(manifest_data : Dictionary,filepath : String):
	var dict_template = manifest_template.duplicate(true)
	var manifest_version = manifest_data.get("manifest_definitions",{}).get("manifest_version",default_version)
	match manifest_version:
		1,1.0:
			dict_template["mod_information"]["id"] = manifest_data["package"].get("id","")
			dict_template["mod_information"]["name"] = manifest_data["package"].get("name","")
			var version = manifest_data["package"].get("version","unknown")
			dict_template["mod_information"]["description"] = manifest_data["package"].get("description","MODMENU_DESCRIPTION_PLACEHOLDER")
			
			if typeof(manifest_data["package"].get("github_homepage","")) == TYPE_STRING:
				var url = manifest_data["package"]["github_homepage"]
				if url != "":
					dict_template["links"].merge({"HEVLIB_GITHUB":{"URL":url}})
			var discURL = manifest_data["package"].get("discord","")
			if discURL != "":
				dict_template["links"].merge({"HEVLIB_DISCORD":{"URL":discURL}})
			var nexusURL = manifest_data["package"].get("nexus","")
			if nexusURL != "":
				dict_template["links"].merge({"HEVLIB_NEXUS":{"URL":nexusURL}})
			var donationURL = manifest_data["package"].get("donations","")
			if donationURL != "":
				dict_template["links"].merge({"HEVLIB_DONATIONS":{"URL":donationURL}})
			var wikiURL = manifest_data["package"].get("wiki","")
			if wikiURL != "":
				dict_template["links"].merge({"HEVLIB_WIKI":{"URL":wikiURL}})
		2,2.0:
			dict_template["mod_information"]["id"] = manifest_data["package"].get("id","")
			dict_template["mod_information"]["name"] = manifest_data["package"].get("name","")
			dict_template["version"]["version_major"] = manifest_data["package"].get("version_major",1)
			dict_template["version"]["version_minor"] = manifest_data["package"].get("version_minor",0)
			dict_template["version"]["version_bugfix"] = manifest_data["package"].get("version_bugfix",0)
			dict_template["version"]["version_metadata"] = manifest_data["package"].get("version_metadata","")
			dict_template["mod_information"]["description"] = manifest_data["package"].get("description","HEVLIB_DESCRIPTION_PLACEHOLDER")
			if typeof(manifest_data["package"].get("github","")) == TYPE_DICTIONARY:
				var url = manifest_data["package"]["github"]["link"]
				if url != "":
					dict_template["links"].merge({"HEVLIB_GITHUB":{"URL":url}})
			elif typeof(manifest_data["package"].get("github","")) == TYPE_STRING:
				var url = manifest_data["package"]["github"]
				if url != "":
					dict_template["links"].merge({"HEVLIB_GITHUB":{"URL":url}})
			var discURL = manifest_data["package"].get("discord","")
			if discURL != "":
				dict_template["links"].merge({"HEVLIB_DISCORD":{"URL":discURL}})
			var nexusURL = manifest_data["package"].get("nexus","")
			if nexusURL != "":
				dict_template["links"].merge({"HEVLIB_NEXUS":{"URL":nexusURL}})
			var donationURL = manifest_data["package"].get("donations","")
			if donationURL != "":
				dict_template["links"].merge({"HEVLIB_DONATIONS":{"URL":donationURL}})
			var wikiURL = manifest_data["package"].get("wiki","")
			if wikiURL != "":
				dict_template["links"].merge({"HEVLIB_WIKI":{"URL":wikiURL}})
			dict_template["mod_information"]["author"] = manifest_data["package"].get("author","Unknown")
			dict_template["mod_information"]["credits"] = manifest_data["package"].get("credits",[])
		2.1:
			# information
			if "mod_information" in manifest_data:
				dict_template["mod_information"]["id"] = String(manifest_data["mod_information"].get("id",""))
				dict_template["mod_information"]["name"] = String(manifest_data["mod_information"].get("name",""))
				dict_template["mod_information"]["description"] = String(manifest_data["mod_information"].get("description","HEVLIB_DESCRIPTION_PLACEHOLDER"))
				dict_template["mod_information"]["author"] = String(manifest_data["mod_information"].get("author","Unknown"))
				dict_template["mod_information"]["credits"] = PoolStringArray(manifest_data["mod_information"].get("credits",[]))
			
			# versioning
			if "version" in manifest_data:
				dict_template["version"]["version_major"] = int(manifest_data["version"].get("version_major",1))
				dict_template["version"]["version_minor"] = int(manifest_data["version"].get("version_minor",0))
				dict_template["version"]["version_bugfix"] = int(manifest_data["version"].get("version_bugfix",0))
				dict_template["version"]["version_metadata"] = String(manifest_data["version"].get("version_metadata",""))
			
			# tags
			if "tags" in manifest_data:
				var current_tags = manifest_data["tags"]
				if "allow_achievements" in current_tags:
					dict_template["tags"].merge({"TAG_ALLOW_ACHIEVEMENTS":{"type":"boolean","value":manifest_data["tags"].get("allow_achievements")}})
				if "quality_of_life" in current_tags:
					dict_template["tags"].merge({"TAG_QOL":{"type":"boolean","value":manifest_data["tags"].get("quality_of_life")}})
				if "is_library_mod" in current_tags:
					dict_template["library"]["is_library"] = manifest_data["tags"].get("is_library_mod")
				if "uses_hevlib_research" in current_tags:
					dict_template["tags"].merge({"TAG_USING_HEVLIB_RESEARCH":{"type":"boolean","value":manifest_data["tags"].get("uses_hevlib_research")}})
				if "overhaul" in current_tags:
					dict_template["tags"].merge({"TAG_OVERHAUL":{"type":"bool","value":manifest_data["tags"].get("overhaul")}})
				if "visual" in current_tags:
					dict_template["tags"].merge({"TAG_VISUAL":{"type":"bool","value":manifest_data["tags"].get("visual")}})
				if "fun" in current_tags:
					dict_template["tags"].merge({"TAG_FUN":{"type":"bool","value":manifest_data["tags"].get("fun")}})
				if "user_interface" in current_tags:
					dict_template["tags"].merge({"TAG_UI":{"type":"bool","value":manifest_data["tags"].get("user_interface")}})
				
				if "adds_ships" in current_tags:
					dict_template["tags"].merge({"TAG_ADDS_SHIPS":{"type":"array","value":manifest_data["tags"].get("adds_ships")}})
				if "adds_equipment" in current_tags:
					dict_template["tags"].merge({"TAG_ADDS_EQUIPMENT":{"type":"array","value":manifest_data["tags"].get("adds_equipment")}})
				if "adds_gameplay_mechanics" in current_tags:
					dict_template["tags"].merge({"TAG_ADDS_GAMEPLAY_MECHANICS":{"type":"array","value":manifest_data["tags"].get("adds_gameplay_mechanics")}})
				if "adds_events" in current_tags:
					dict_template["tags"].merge({"TAG_ADDS_EVENTS":{"type":"array","value":manifest_data["tags"].get("adds_events")}})
				
				if "handle_extra_crew" in current_tags:
					dict_template["tags"].merge({"TAG_HANDLE_EXTRA_CREW":{"type":"integer","value":manifest_data["tags"].get("handle_extra_crew")}})
				
			# links
			if "links" in manifest_data:
				if typeof(manifest_data["links"].get("github","")) == TYPE_DICTIONARY:
					var url = manifest_data["links"]["github"]["link"]
					if url != "":
						dict_template["links"].merge({"HEVLIB_GITHUB":{"URL":url}})
				elif typeof(manifest_data["links"].get("github","")) == TYPE_STRING:
					var url = manifest_data["links"]["github"]
					if url != "":
						dict_template["links"].merge({"HEVLIB_GITHUB":{"URL":url}})
				var discURL = manifest_data["links"].get("discord","")
				if discURL != "":
					dict_template["links"].merge({"HEVLIB_DISCORD":{"URL":discURL}})
				var nexusURL = manifest_data["links"].get("nexus","")
				if nexusURL != "":
					dict_template["links"].merge({"HEVLIB_NEXUS":{"URL":nexusURL}})
				var donationURL = manifest_data["links"].get("donations","")
				if donationURL != "":
					dict_template["links"].merge({"HEVLIB_DONATIONS":{"URL":donationURL}})
				var wikiURL = manifest_data["links"].get("wiki","")
				if wikiURL != "":
					dict_template["links"].merge({"HEVLIB_WIKI":{"URL":wikiURL}})
				var bugreportsURL = manifest_data["links"].get("bug_reports","")
				if bugreportsURL != "":
					dict_template["links"].merge({"HEVLIB_BUGREPORTS":{"URL":bugreportsURL}})
			
			# manifest definitions
			if "manifest_definitions" in manifest_data:
				dict_template["manifest_definitions"]["manifest_version"] = float(manifest_data["manifest_definitions"].get("manifest_version",manifest_version))
				dict_template["manifest_definitions"]["dependancy_mod_ids"] = PoolStringArray(manifest_data["manifest_definitions"].get("dependancy_mod_ids",[]))
				dict_template["manifest_definitions"]["conflicting_mod_ids"] = PoolStringArray(manifest_data["manifest_definitions"].get("conflicting_mod_ids",[]))
				dict_template["manifest_definitions"]["complementary_mod_ids"] = PoolStringArray(manifest_data["manifest_definitions"].get("complementary_mod_ids",[]))
		2.2:
			if "mod_information" in manifest_data:
				dict_template["mod_information"]["id"] = String(manifest_data["mod_information"].get("id",""))
				dict_template["mod_information"]["name"] = String(manifest_data["mod_information"].get("name",""))
				dict_template["mod_information"]["description"] = String(manifest_data["mod_information"].get("description","HEVLIB_DESCRIPTION_PLACEHOLDER"))
				dict_template["mod_information"]["brief"] = String(manifest_data["mod_information"].get("brief",""))
				dict_template["mod_information"]["author"] = String(manifest_data["mod_information"].get("author","Unknown"))
				dict_template["mod_information"]["credits"] = PoolStringArray(manifest_data["mod_information"].get("credits",[]))
			
			if "version" in manifest_data:
				dict_template["version"]["version_major"] = int(manifest_data["version"].get("version_major",1))
				dict_template["version"]["version_minor"] = int(manifest_data["version"].get("version_minor",0))
				dict_template["version"]["version_bugfix"] = int(manifest_data["version"].get("version_bugfix",0))
				dict_template["version"]["version_metadata"] = String(manifest_data["version"].get("version_metadata",""))
			
			if "manifest_definitions" in manifest_data:
				dict_template["manifest_definitions"]["manifest_version"] = float(manifest_data["manifest_definitions"].get("manifest_version",manifest_version))
				dict_template["manifest_definitions"]["dependancy_mod_ids"] = PoolStringArray(manifest_data["manifest_definitions"].get("dependancy_mod_ids",[]))
				dict_template["manifest_definitions"]["conflicting_mod_ids"] = PoolStringArray(manifest_data["manifest_definitions"].get("conflicting_mod_ids",[]))
				dict_template["manifest_definitions"]["complementary_mod_ids"] = PoolStringArray(manifest_data["manifest_definitions"].get("complementary_mod_ids",[]))
				dict_template["manifest_definitions"]["manifest_url"] = String(manifest_data["manifest_definitions"].get("manifest_url",""))
				dict_template["manifest_definitions"]["changelog_path"] = String(manifest_data["manifest_definitions"].get("changelog_path",""))
				dict_template["manifest_definitions"]["modlet_priority"] = int(manifest_data["manifest_definitions"].get("modlet_priority",0))
			
			if "links" in manifest_data:
				var links = manifest_data["links"]
				for link in links:
					dict_template["links"].merge({link:links.get(link)})
			if "tags" in manifest_data:
				var tags = manifest_data["tags"]
				for tag in tags:
					dict_template["tags"].merge({tag:tags.get(tag)})
			if "languages" in manifest_data:
				var languages = manifest_data["languages"]
				for language in languages:
					dict_template["languages"].merge({language:languages.get(language)})
			else:
				dict_template["languages"].merge({"en":"100%"})
			if "library" in manifest_data:
				dict_template["library"]["is_library"] = manifest_data["library"].get("is_library",false)
				dict_template["library"]["always_display"] = manifest_data["library"].get("always_display",false)
				
			if "configs" in manifest_data:
				var configs = manifest_data["configs"]
				for cfg in configs:
					dict_template["configs"][cfg] = configs[cfg]
	
	var cfg = ConfigFile.new()
	for section in dict_template:
		var always = always_save.get(section,{})
		for key in dict_template[section]:
			var value = dict_template[section][key]
			if (value != null):
				if (not key in manifest_template[section]) or (hash(value) != hash(manifest_template[section][key])):
					cfg.set_value(section,key,value)
				elif key in always:
					cfg.set_value(section,key,always[key])
	cfg.save(filepath)
	pass

var file = File.new()
func parse(file_path: String) -> Dictionary:
	if not file.file_exists(file_path) and not ResourceLoader.exists(file_path):
		return {}
	var cfg:ConfigFile = ConfigFile.new()
	file.open(file_path,File.READ)
	var txt : String  = file.get_as_text()
	file.close()
	cfg.parse(txt)
	var cfg_sections : Array = cfg.get_sections()
	var cfg_dictionary : Dictionary = {}
	for section in cfg_sections:
		var data : Dictionary = {}
		var keys : Array = cfg.get_section_keys(section)
		for key in keys:
			var item = cfg.get_value(section,key)
			data.merge({key:item})
		cfg_dictionary.merge({section:data})
	return cfg_dictionary
