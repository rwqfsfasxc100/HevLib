extends Node

static func parse_as_manifest(file_path: String, format_to_manifest_version: bool = false) -> Dictionary:
	var FileAccess = preload("res://HevLib/pointers/FileAccess.gd")  
	var cfg = FileAccess.__config_parse(file_path)
	var manifest_data : Dictionary = {}
	var manifest_version = 1
	if "manifest_definitions" in cfg.keys():
		manifest_version = cfg["manifest_definitions"].get("manifest_version",manifest_version)
		if not manifest_version is float or not manifest_version is int:
			manifest_version = 1
	manifest_data = cfg
	if format_to_manifest_version:
		match manifest_version:
			1, _:
				var package = {}
				var manifest_id = manifest_data["package"].get("id",null)
				package.merge({"id":manifest_id})
				var manifest_name = manifest_data["package"].get("name",null)
				package.merge({"name":manifest_name})
				var version = manifest_data["package"].get("version","unknown")
				package.merge({"version":version})
				var description = manifest_data["package"].get("description","MODMENU_DESCRIPTION_PLACEHOLDER")
				package.merge({"description":description})
				var group = manifest_data["package"].get("group","")
				if not group == "":
					package.merge({"group":group})
				var github_homepage = manifest_data["package"].get("github_homepage","")
				if not github_homepage == "":
					package.merge({"github_homepage":github_homepage})
				var github_releases = manifest_data["package"].get("github_releases","")
				if not github_releases == "":
					package.merge({"github_releases":github_releases})
				var discord_thread = manifest_data["package"].get("discord_thread","")
				if not discord_thread == "":
					package.merge({"discord_thread":discord_thread})
				var nexus_page = manifest_data["package"].get("nexus_page","")
				if not nexus_page == "":
					package.merge({"nexus_page":nexus_page})
				var donations_page = manifest_data["package"].get("donations_page","")
				if not donations_page == "":
					package.merge({"donations_page":donations_page})
				var wiki_page = manifest_data["package"].get("wiki_page","")
				if not wiki_page == "":
					package.merge({"wiki_page":wiki_page})
				var custom_link = manifest_data["package"].get("custom_link","")
				if not custom_link == "":
					package.merge({"custom_link":custom_link})
				var custom_link_name = manifest_data["package"].get("custom_link_name","")
				if not custom_link_name == "":
					package.merge({"custom_link_name":custom_link_name})
				manifest_data = {"package":package,"manifest_definitions":{"manifest_version":manifest_version}}
				
			2, 2.0:
				var package = {}
				var manifest_id = manifest_data["package"].get("id",null)
				package.merge({"id":manifest_id})
				var manifest_name = manifest_data["package"].get("name",null)
				package.merge({"name":manifest_name})
				var version_major = manifest_data["package"].get("version_major",1)
				package.merge({"version_major":version_major})
				var version_minor = manifest_data["package"].get("version_minor",0)
				package.merge({"version_minor":version_minor})
				var version_bugfix = manifest_data["package"].get("version_bugfix",0)
				package.merge({"version_bugfix":version_bugfix})
				var version_metadata = manifest_data["package"].get("version_metadata","")
				if not version_metadata == "":
					package.merge({"version_metadata":version_metadata})
				var description = manifest_data["package"].get("description","HEVLIB_DESCRIPTION_PLACEHOLDER")
				package.merge({"description":description})
				var groups = manifest_data["package"].get("groups",[])
				if not groups == []:
					package.merge({"groups":groups})
				var github = manifest_data["package"].get("github","")
				if not github == "":
					package.merge({"github":github})
				var link_github_releases = manifest_data["package"].get("link_github_releases",false)
				if not github == "":
					package.merge({"link_github_releases":link_github_releases})
				var discord_thread = manifest_data["package"].get("discord_thread","")
				if not discord_thread == "":
					package.merge({"discord_thread":discord_thread})
				var nexus_page = manifest_data["package"].get("nexus_page","")
				if not nexus_page == "":
					package.merge({"nexus_page":nexus_page})
				var donations_page = manifest_data["package"].get("donations_page","")
				if not donations_page == "":
					package.merge({"donations_page":donations_page})
				var wiki_page = manifest_data["package"].get("wiki_page","")
				if not wiki_page == "":
					package.merge({"wiki_page":wiki_page})
				var custom_data = manifest_data["package"].get("custom_data",[])
				if not custom_data == []:
					package.merge({"custom_data":custom_data})
				var author = manifest_data["package"].get("author","Unknown")
				package.merge({"author":author})
				var credits = manifest_data["package"].get("credits",[])
				if not credits == []:
					package.merge({"credits":credits})
				
				manifest_data = {"package":package,"manifest_definitions":{"manifest_version":manifest_version}}
			2.1:
				# information
				var manifest_name = manifest_data["information"].get("name",null)
				var manifest_id = manifest_data["information"].get("manifest_id",null)
				var description = manifest_data["information"].get("description","HEVLIB_DESCRIPTION_PLACEHOLDER")
				var author = manifest_data["information"].get("author","Unknown")
				var credits = manifest_data["information"].get("credits",[])
				
				var information = {"manifest_name":manifest_name,"manifest_id":manifest_id,"description":description,"author":author,"credits":credits}
				
				# versioning
				var version_major = manifest_data["version"].get("version_major",1)
				var version_minor = manifest_data["version"].get("version_minor",0)
				var version_bugfix = manifest_data["version"].get("version_bugfix",0)
				var version_metadata = manifest_data["version"].get("version_metadata","")
				var version_string = str(version_major) + str(version_minor) + str(version_bugfix)
				if not version_metadata == "":
					version_string = version_string + "-" + version_metadata
				
				var version = {"version_major":version_major,"version_minor":version_minor,"version_bugfix":version_bugfix,"version_metadata":version_metadata,"version_string":version_string}
				
				# tags
				var tags : Dictionary = {}
				var allow_achievements = manifest_data["tags"].get("allow_achievements",false)
				var adds_ships = manifest_data["tags"].get("adds_ships",0)
				var adds_equipment = manifest_data["tags"].get("adds_equipment",0)
				var quality_of_life = manifest_data["tags"].get("quality_of_life",false)
				var modding_library = manifest_data["tags"].get("modding_library",false)
				var adds_gameplay_mechanics = manifest_data["tags"].get("adds_gameplay_mechanics",0)
				var uses_hevlib_research = manifest_data["tags"].get("uses_hevlib_research",false)
				var overhaul = manifest_data["tags"].get("overhaul",false)
				var adds_events = manifest_data["tags"].get("adds_events",0)
				
				
	return manifest_data
