extends PanelContainer

var link_button = preload("res://HevLib/ui/mod_menu/urls/URL_BUTTON.tscn")

var MOD_INFO : Dictionary = {}

var pointers = ModLoader._savedObjects[0]

func update():
	var b : Node = $VBoxContainer/ScrollContainer/VBoxContainer
	for object in b.get_children():
		Tool.remove(object)
	var manifestData = MOD_INFO["manifest"]["manifest_data"]
	var links : Dictionary = {}
	if manifestData:
		links = manifestData["links"]
	var nodes : Array = []
	if links:
		for link in links:
			
			var URL : String = links[link].get("URL","")
			if URL and pointers.DataFormat.__is_valid_url(URL):
				var node : Object = link_button.instance()
				node.url = URL
				node.name = link
				node.icon_path = match_builtin_icon(link,links[link].get("ICON","res://HevLib/ui/themes/icons/alias.stex"))
				node.tooltip = match_builtin_tooltip(link,links[link].get("TOOLTIP",""))
				node.text = link
				nodes.append(node)
#	breakpoint
	for node in nodes:
		b.add_child(node)


func match_builtin_icon(link_name : String,icon : String = "res://HevLib/ui/themes/icons/alias.stex") -> String:
	
	match link_name:
		"HEVLIB_GITHUB":
			return "res://HevLib/ui/themes/icons/github.stex"
		"HEVLIB_DISCORD":
			return "res://HevLib/ui/themes/icons/discord.stex"
		"HEVLIB_NEXUS":
			return "res://HevLib/ui/themes/icons/nexus.stex"
		"HEVLIB_DONATIONS":
			return "res://HevLib/ui/themes/icons/donations.stex"
		"HEVLIB_WIKI":
			return "res://HevLib/ui/themes/icons/wiki.stex"
		"HEVLIB_BUGREPORTS":
			return "res://HevLib/ui/themes/icons/bug.stex"
		_:
			return icon
			
func match_builtin_tooltip(link_name : String,tooltip : String) -> String:
	
	match link_name:
		"HEVLIB_GITHUB":
			return "HEVLIB_GITHUB_TOOLTIP"
		"HEVLIB_DISCORD":
			return "HEVLIB_DISCORD_TOOLTIP"
		"HEVLIB_NEXUS":
			return "HEVLIB_NEXUS_TOOLTIP"
		"HEVLIB_DONATIONS":
			return "HEVLIB_DONATIONS_TOOLTIP"
		"HEVLIB_WIKI":
			return "HEVLIB_WIKI_TOOLTIP"
		"HEVLIB_BUGREPORTS":
			return "HEVLIB_BUGREPORTS_TOOLTIP"
		_:
			return tooltip
