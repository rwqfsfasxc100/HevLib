extends Node

static func parse_as_manifest(file_path: String, format_to_manifest_version: bool = false, collect_legacy_values: bool = false) -> Dictionary:
	var FileAccess = preload("res://HevLib/pointers/FileAccess.gd")  
	var cfg = FileAccess.__config_parse(file_path)
	var manifest_data : Dictionary = {}
	var manifest_version = 1
#	var fsplit = file_path.split(file_path.split("/")[file_path.split("/").size() - 1])
#	var parent_folder = file_path.split(fsplit)[0]
	if "manifest_definitions" in cfg.keys():
		manifest_version = cfg["manifest_definitions"].get("manifest_version",manifest_version)
		if not manifest_version is float or not manifest_version is int:
			manifest_version = 1
	manifest_data = cfg
	if format_to_manifest_version:
		var dict_template = {
			"mod_information":{
				"name":null,
				"id":null,
				"description":"",
				"author":"",
				"credits":[]
			},
			"version":{
				"version_major":1,
				"version_minor":0,
				"version_bugfix":0,
				"version_metadata":"",
				"version_string":"1.0.0"
			},
			"tags":{
				"adds_equipment":[],
				"adds_events":[],
				"adds_gameplay_mechanics":[],
				"adds_ships":[],
				"allow_achievements":false,
				"fun":false,
				"handle_extra_crew":24,
				"is_library_mod":false,
				"library_hidden_by_default":true,
				"overhaul":false,
				"quality_of_life":false,
				"uses_hevlib_research":false,
				"visual":false
			},
			"links":{
				"github":{"link":"","has_releases":false},
				"discord":"",
				"nexus":"",
				"donations":"",
				"wiki":"",
				"custom_links":{}
			}
		}
		match manifest_version:
			1, 1.0, _:
				dict_template["mod_information"]["id"] = manifest_data["package"].get("id",null)
				dict_template["mod_information"]["name"] = manifest_data["package"].get("name",null)
				var version = manifest_data["package"].get("version","unknown")
				dict_template["mod_information"]["description"] = manifest_data["package"].get("description","MODMENU_DESCRIPTION_PLACEHOLDER")
				var group = manifest_data["package"].get("group","")
				var github_releases = manifest_data["package"].get("github_releases","")
				
				var d = false
				if not github_releases == "":
					d = true
				dict_template["links"]["github"] = {"link":manifest_data["package"].get("github_homepage",""),"has_releases":d}
				
				dict_template["links"]["discord"] = manifest_data["package"].get("discord_thread","")
				dict_template["links"]["nexus"] = manifest_data["package"].get("nexus_page","")
				dict_template["links"]["donations"] = manifest_data["package"].get("donations_page","")
				dict_template["links"]["wiki"] = manifest_data["package"].get("wiki_page","")
				var custom_link = manifest_data["package"].get("custom_link","")
				var custom_link_name = manifest_data["package"].get("custom_link_name","")
				
				if collect_legacy_values:
					var dict = {"legacy":{"manifest_version":1,"version":version,"group":group,"github_releases":github_releases,"custom_link":custom_link,"custom_link_name":custom_link_name}}
					dict_template.merge(dict)
			2, 2.0:
				dict_template["mod_information"]["id"] = manifest_data["package"].get("id",null)
				dict_template["mod_information"]["name"] = manifest_data["package"].get("name",null)
				dict_template["version"]["version_major"] = manifest_data["package"].get("version_major",1)
				dict_template["version"]["version_minor"] = manifest_data["package"].get("version_minor",0)
				dict_template["version"]["version_bugfix"] = manifest_data["package"].get("version_bugfix",0)
				dict_template["version"]["version_metadata"] = manifest_data["package"].get("version_metadata","")
				dict_template["mod_information"]["description"] = manifest_data["package"].get("description","HEVLIB_DESCRIPTION_PLACEHOLDER")
				var groups = manifest_data["package"].get("groups",[])
				dict_template["links"]["github"] = {"link":manifest_data["package"].get("github",""),"has_releases":manifest_data["package"].get("link_github_releases",false)}
				dict_template["links"]["discord"] = manifest_data["package"].get("discord_thread","")
				dict_template["links"]["nexus"] = manifest_data["package"].get("nexus_page","")
				dict_template["links"]["donations"] = manifest_data["package"].get("donations_page","")
				dict_template["links"]["wiki"] = manifest_data["package"].get("wiki_page","")
				var custom_data = manifest_data["package"].get("custom_data",[])
				dict_template["mod_information"]["author"] = manifest_data["package"].get("author","Unknown")
				dict_template["mod_information"]["credits"] = manifest_data["package"].get("credits",[])
				
				if collect_legacy_values:
					var dict = {"legacy":{"manifest_version":2,"groups":groups,"custom_data":custom_data}}
					dict_template.merge(dict)
			2.1:
				# information
				dict_template["mod_information"]["id"] = manifest_data["mod_information"].get("manifest_id",null)
				dict_template["mod_information"]["name"] = manifest_data["mod_information"].get("name",null)
				dict_template["mod_information"]["description"] = manifest_data["mod_information"].get("description","HEVLIB_DESCRIPTION_PLACEHOLDER")
				dict_template["mod_information"]["author"] = manifest_data["mod_information"].get("author","Unknown")
				dict_template["mod_information"]["credits"] = manifest_data["mod_information"].get("credits",[])
				
				# versioning
				dict_template["version"]["version_major"] = manifest_data["version"].get("version_major",1)
				dict_template["version"]["version_minor"] = manifest_data["version"].get("version_minor",0)
				dict_template["version"]["version_bugfix"] = manifest_data["version"].get("version_bugfix",0)
				dict_template["version"]["version_metadata"] = manifest_data["version"].get("version_metadata","")
				
				# tags
				dict_template["tags"]["allow_achievements"] = manifest_data["tags"].get("allow_achievements",false)
				dict_template["tags"]["adds_ships"] = manifest_data["tags"].get("adds_ships",[])
				dict_template["tags"]["adds_equipment"] = manifest_data["tags"].get("adds_equipment",[])
				dict_template["tags"]["quality_of_life"] = manifest_data["tags"].get("quality_of_life",false)
				dict_template["tags"]["is_library_mod"] = manifest_data["tags"].get("is_library_mod",false)
				dict_template["tags"]["adds_gameplay_mechanics"] = manifest_data["tags"].get("adds_gameplay_mechanics",[])
				dict_template["tags"]["uses_hevlib_research"] = manifest_data["tags"].get("uses_hevlib_research",false)
				dict_template["tags"]["overhaul"] = manifest_data["tags"].get("overhaul",false)
				dict_template["tags"]["adds_events"] = manifest_data["tags"].get("adds_events",[])
				dict_template["tags"]["handle_extra_crew"] = manifest_data["tags"].get("handle_extra_crew",24)
				dict_template["tags"]["visual"] = manifest_data["tags"].get("visual",false)
				dict_template["tags"]["fun"] = manifest_data["tags"].get("fun",false)
				dict_template["tags"]["language"] = manifest_data["tags"].get("language","en")
				
				# links
				dict_template["links"]["github"] = manifest_data["links"].get("github",{"link":"","has_releases":false})
				dict_template["links"]["discord"] = manifest_data["links"].get("discord","")
				dict_template["links"]["nexus"] = manifest_data["links"].get("nexus","")
				dict_template["links"]["donations"] = manifest_data["links"].get("donations","")
				dict_template["links"]["wiki"] = manifest_data["links"].get("wiki","")
				dict_template["links"]["custom_links"] = manifest_data["links"].get("custom_links",{})
				
		var version_metadata = dict_template["version"]["version_metadata"]
		var version_string = dict_template["version"]["version_major"] + "." + dict_template["version"]["version_minor"] + "." + dict_template["version"]["version_bugfix"]
		if not version_metadata == "":
			version_string = version_string + "-" + version_metadata
		dict_template["version"]["version_string"] = version_string
		
		return dict_template
	return manifest_data
