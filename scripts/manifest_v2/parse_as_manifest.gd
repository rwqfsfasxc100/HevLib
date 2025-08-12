extends Node

static func parse_as_manifest(file_path: String, format_to_manifest_version: bool = false):
  var cfg = FileAccess.__config_parse(file_path)
  var manifest_data = {}
  if "package" in cfg.keys():
    mod_name = cfg["package"].get("name",mod_name)
    legacy_mod_version = cfg["package"].get("version",legacy_mod_version)
    mod_version_major = cfg["package"].get("version_major",mod_version_major)
    mod_version_minor = cfg["package"].get("version_minor",mod_version_minor)
    mod_version_bugfix = cfg["package"].get("version_bugfix",mod_version_bugfix)
    mod_version_metadata = cfg["package"].get("version_metadata",mod_version_metadata)
  if "manifest_definitions" in cfg.keys():
    manifest_version = cfg["manifest_definitions"].get("manifest_version",manifest_version)
  manifest_data = cfg
  if format_to_manifest_version:
    match manifest_version:
      1:
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
        
      2:
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
  return manifest_data
