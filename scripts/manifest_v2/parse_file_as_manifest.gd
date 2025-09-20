extends Node

static func parse_file_as_manifest(file_path: String, format_to_manifest_version: bool = false) -> Dictionary:
	var FileAccess = preload("res://HevLib/pointers/FileAccess.gd")  
	var cfg = FileAccess.__config_parse(file_path)
	var manifest_data : Dictionary = {}
	var manifest_version = 1
#	var fsplit = file_path.split(file_path.split("/")[file_path.split("/").size() - 1])
#	var parent_folder = file_path.split(fsplit)[0]
	if "manifest_definitions" in cfg.keys():
		manifest_version = cfg["manifest_definitions"].get("manifest_version",manifest_version)
		var tpf = typeof(manifest_version)
		if tpf == TYPE_INT or tpf == TYPE_REAL:
			pass
		else:
			manifest_version = 1
	manifest_data = cfg
	if format_to_manifest_version:
		var dict_template = {
			"mod_information":{
				"name":null,
				"id":null,
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
				"manifest_version":1,
				"dependancy_mod_ids":PoolStringArray([]),
				"conflicting_mod_ids":PoolStringArray([]),
				"complementary_mod_ids":PoolStringArray([]),
			}
		}
		match manifest_version:
			1, 1.0:
				dict_template["mod_information"]["id"] = manifest_data["package"].get("id",null)
				dict_template["mod_information"]["name"] = manifest_data["package"].get("name",null)
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
				
			2, 2.0:
				dict_template["mod_information"]["id"] = manifest_data["package"].get("id",null)
				dict_template["mod_information"]["name"] = manifest_data["package"].get("name",null)
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
				if "mod_information" in manifest_data.keys():
					dict_template["mod_information"]["id"] = String(manifest_data["mod_information"].get("id",null))
					dict_template["mod_information"]["name"] = String(manifest_data["mod_information"].get("name",null))
					dict_template["mod_information"]["description"] = String(manifest_data["mod_information"].get("description","HEVLIB_DESCRIPTION_PLACEHOLDER"))
					dict_template["mod_information"]["author"] = String(manifest_data["mod_information"].get("author","Unknown"))
					dict_template["mod_information"]["credits"] = PoolStringArray(manifest_data["mod_information"].get("credits",[]))
				
				# versioning
				if "version" in manifest_data.keys():
					dict_template["version"]["version_major"] = int(manifest_data["version"].get("version_major",1))
					dict_template["version"]["version_minor"] = int(manifest_data["version"].get("version_minor",0))
					dict_template["version"]["version_bugfix"] = int(manifest_data["version"].get("version_bugfix",0))
					dict_template["version"]["version_metadata"] = String(manifest_data["version"].get("version_metadata",""))
				
				# tags
				if "tags" in manifest_data.keys():
					var current_tags = manifest_data["tags"].keys()
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
				if "links" in manifest_data.keys():
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
				if "manifest_definitions" in manifest_data.keys():
					dict_template["manifest_definitions"]["manifest_version"] = float(manifest_data["manifest_definitions"].get("manifest_version",manifest_version))
					dict_template["manifest_definitions"]["dependancy_mod_ids"] = PoolStringArray(manifest_data["manifest_definitions"].get("dependancy_mod_ids",[]))
					dict_template["manifest_definitions"]["conflicting_mod_ids"] = PoolStringArray(manifest_data["manifest_definitions"].get("conflicting_mod_ids",[]))
					dict_template["manifest_definitions"]["complementary_mod_ids"] = PoolStringArray(manifest_data["manifest_definitions"].get("complementary_mod_ids",[]))
			2.2:
				
				if "mod_information" in manifest_data.keys():
					dict_template["mod_information"]["id"] = String(manifest_data["mod_information"].get("id",null))
					dict_template["mod_information"]["name"] = String(manifest_data["mod_information"].get("name",null))
					dict_template["mod_information"]["description"] = String(manifest_data["mod_information"].get("description","HEVLIB_DESCRIPTION_PLACEHOLDER"))
					dict_template["mod_information"]["brief"] = String(manifest_data["mod_information"].get("brief",""))
					dict_template["mod_information"]["author"] = String(manifest_data["mod_information"].get("author","Unknown"))
					dict_template["mod_information"]["credits"] = PoolStringArray(manifest_data["mod_information"].get("credits",[]))
				
				if "version" in manifest_data.keys():
					dict_template["version"]["version_major"] = int(manifest_data["version"].get("version_major",1))
					dict_template["version"]["version_minor"] = int(manifest_data["version"].get("version_minor",0))
					dict_template["version"]["version_bugfix"] = int(manifest_data["version"].get("version_bugfix",0))
					dict_template["version"]["version_metadata"] = String(manifest_data["version"].get("version_metadata",""))
				
				if "manifest_definitions" in manifest_data.keys():
					dict_template["manifest_definitions"]["manifest_version"] = float(manifest_data["manifest_definitions"].get("manifest_version",manifest_version))
					dict_template["manifest_definitions"]["dependancy_mod_ids"] = PoolStringArray(manifest_data["manifest_definitions"].get("dependancy_mod_ids",[]))
					dict_template["manifest_definitions"]["conflicting_mod_ids"] = PoolStringArray(manifest_data["manifest_definitions"].get("conflicting_mod_ids",[]))
					dict_template["manifest_definitions"]["complementary_mod_ids"] = PoolStringArray(manifest_data["manifest_definitions"].get("complementary_mod_ids",[]))
				
				if "links" in manifest_data.keys():
					var links = manifest_data["links"]
					for link in links:
						dict_template["links"].merge({link:links.get(link)})
				if "tags" in manifest_data.keys():
					var tags = manifest_data["tags"]
					for tag in tags:
						dict_template["tags"].merge({tag:tags.get(tag)})
				if "languages" in manifest_data.keys():
					var languages = manifest_data["languages"]
					for language in languages:
						dict_template["languages"].merge({language:languages.get(language)})
				else:
					dict_template["languages"].merge({"en":"100%"})
				if "library" in manifest_data.keys():
					dict_template["library"]["is_library"] = manifest_data["library"].get("is_library",false)
					dict_template["library"]["always_display"] = manifest_data["library"].get("always_display",false)
					
				
				
				
		var version_metadata = dict_template["version"]["version_metadata"]
		var version_string = str(dict_template["version"]["version_major"]) + "." + str(dict_template["version"]["version_minor"]) + "." + str(dict_template["version"]["version_bugfix"])
		if not version_metadata == "":
			version_string = version_string + "-" + version_metadata
		dict_template["version"]["version_string"] = version_string
		
		return dict_template
	return manifest_data
