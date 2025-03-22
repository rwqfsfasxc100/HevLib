extends Node

static func load_manifest_from_file(manifest):
	Debug.l("HevLib: function 'load_manifest_from_file' instanced on %s" % manifest)
	var manifestConfig = {
	"package":{
		"id":null,
		"name":null,
		"version":"unknown",
		"description":"MODMENU_DESCRIPTION_PLACEHOLDER",
		"group":"",
		"github_homepage":"",
		"github_releases":"",
		"discord_thread":"",
		"nexus_page":"",
		"donations_page":"",
		"wiki_page":"",
		"custom_link":"",
		"custom_link_name":"",
		}
	}
	var manifestFile = ConfigFile.new()
	var error = manifestFile.load(manifest)
	if error != OK:
		Debug.l("HevLib: Error loading settings %s on %s" % [error, manifest])
		return
	for section in manifestConfig:
		var currentManifest = Array(manifestFile.get_section_keys(section))
		for key in manifestFile.get_section_keys(section):
			manifestConfig[section][key] = manifestFile.get_value(section, key)
	Debug.l("HevLib: load_manifest_from_file returning as %s" % manifestConfig)
	return manifestConfig
