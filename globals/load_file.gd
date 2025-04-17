extends Node

static func load_file(modDir, zipDir, hasManifest, manifestDirectory, hasIcon, iconDir):
	Debug.l("HevLib: function 'load_file' instanced for %s @ %s. Is working with manifest? [%s] @ [%s]. Is working with mod icon? [%s] @ [%s]" % [modDir, zipDir, hasManifest, manifestDirectory, hasIcon, iconDir])
	var Globals = preload("res://HevLib/Functions.gd").new()
	var manifestName = ""
	var manifestId = ""
	var manifestVersion = ""
	var manifestDescription = ""
	var manifestGroup = ""
	var github_homepage = ""
	var github_releases = ""
	var discord_thread = ""
	var nexus_page = ""
	var donations_page = ""
	var wiki_page = ""
	var custom_link = "MODMENU_CUSTOM_LINK_PLACEHOLDER"
	var custom_link_name = "MODMENU_CUSTOM_LINK_NAME_PLACEHOLDER"
	var dirSplit = zipDir.split("/")
	var dirSplitSize = dirSplit.size()
	var fallbackDir = dirSplit[dirSplitSize - 1]
	var parentFolder = str(dirSplit[dirSplitSize - 2])
	var f = File.new()
	if hasManifest and not parentFolder == "disabled_mod_cache":
		f.open(manifestDirectory, File.READ)
		Debug.l("HevLib: load_file attempting to load manifest @%s" % manifestDirectory)
		var manifestData = Globals.__load_manifest_from_file(manifestDirectory)
		manifestName = manifestData["package"]["name"]
		manifestId = manifestData["package"]["id"]
		manifestVersion = manifestData["package"]["version"]
		manifestDescription = manifestData["package"]["description"]
		manifestGroup = manifestData["package"]["group"]
		github_homepage = manifestData["package"]["github_homepage"]
		github_releases = manifestData["package"]["github_releases"]
		discord_thread = manifestData["package"]["discord_thread"]
		nexus_page = manifestData["package"]["nexus_page"]
		donations_page = manifestData["package"]["donations_page"]
		wiki_page = manifestData["package"]["wiki_page"]
		custom_link = manifestData["package"]["custom_link"]
		custom_link_name = manifestData["package"]["custom_link_name"]
		f.close()
	Debug.l("HevLib: load_file attempting to reload file @%s" % modDir)
	f.open(modDir, File.READ)
	var modFolderSplit = modDir.split("/ModMain.gd")
	var modFolderCount = modFolderSplit.size()
	var separateModFolderDir = modFolderSplit[modFolderCount - 2].split("/")
	var modFolderSecondCount = separateModFolderDir.size()
	var modFolder = separateModFolderDir[modFolderSecondCount - 1]
	var nameCheck = 0
	var modName = ""
	var prioCheck = 0
	var modPrio = 0
	var modVer = ""
	var verCheck = 0
	var content = f.get_as_text(true)
	var modMainLines = content.split("\n")
	for l in modMainLines:
		if not hasManifest or manifestName == "" or manifestName == null:
			var modNameCheck = l.split("const MOD_NAME = ")
			var modNameCheckSize = modNameCheck.size()
			if modNameCheckSize >= 2:
				var splitName = Globals.__array_to_string(modNameCheck[1].split("\""))
				while splitName.begins_with(" "):
					var beginningSpaceRemover = splitName.split(" ")
					splitName = Globals.__array_to_string(beginningSpaceRemover[1])
				while splitName.ends_with(" "):
					var endSpaceRemover = splitName.split(" ")
					splitName = Globals.__array_to_string(endSpaceRemover[0])
				nameCheck = 1
				modName = splitName
		else:
			nameCheck = 1
			modName = manifestName
		var priorityCheck = l.split("const MOD_PRIORITY = ")
		var priorityCheckSize = priorityCheck.size()
		if priorityCheckSize >= 2:
			prioCheck += 1
			modPrio = priorityCheck[1]
		if not nameCheck == 1:
			modName = fallbackDir
		if not prioCheck == 1:
			modPrio = 0
		var versionCheck = l.split("const MOD_VERSION = ")
		var versionCheckSize = versionCheck.size()
		if not manifestVersion == "":
			verCheck = 1
			modVer = manifestVersion
		elif versionCheckSize >= 2 and not manifestVersion == modVer:
			verCheck = 1
			modVer = versionCheck[1]
		else:
			modVer = "unknown"
	var prioStr = String(modPrio)
	var ver = ""
	if verCheck == 1:
		ver = modVer
	else:
		ver = "unknown"
	var verData = String(ver)
	if manifestDescription == null or manifestDescription == "":
		manifestDescription = "MODMENU_DESCRIPTION_PLACEHOLDER"
	if manifestGroup == null or manifestGroup == "":
		manifestGroup = "MODMENU_GROUP_PLACEHOLDER"
	if manifestId == null or manifestId == "":
		manifestId = "MODMENU_ID_PLACEHOLDER"
	if github_homepage == null or github_homepage == "":
		github_homepage = "MODMENU_GITHUB_HOMEPAGE_PLACEHOLDER"
	if github_releases == null or github_releases == "":
		github_releases = "MODMENU_GITHUB_RELEASES_PLACEHOLDER"
	if discord_thread == null or discord_thread == "":
		discord_thread = "MODMENU_DISCORD_PLACEHOLDER"
	if nexus_page == null or nexus_page == "":
		nexus_page = "MODMENU_NEXUS_PLACEHOLDER"
	if donations_page == null or donations_page == "":
		donations_page = "MODMENU_DONATIONS_PLACEHOLDER"
	if wiki_page == null or wiki_page == "":
		wiki_page = "MODMENU_WIKI_PLACEHOLDER"
	if custom_link == null or custom_link == "":
		custom_link = "MODMENU_CUSTOM_LINK_PLACEHOLDER"
	if custom_link_name == null or custom_link_name == "":
		custom_link_name = "MODMENU_CUSTOM_LINK_NAME_PLACEHOLDER"
	if hasIcon:
		iconDir = iconDir
	else:
		iconDir = "empty"
	var compiledData = modName + "\n" + fallbackDir + "\n" + prioStr + "\n" + modFolder + "\n" + verData + "\n" + manifestDescription + "\n" + github_homepage + "\n" + github_releases + "\n" + discord_thread + "\n" + nexus_page + "\n" + donations_page + "\n" + wiki_page + "\n" + custom_link + "\n" + custom_link_name + "\n" + iconDir + "\n" + manifestId
	Debug.l("HevLib: load_file returning as %s" % compiledData)
	return compiledData
