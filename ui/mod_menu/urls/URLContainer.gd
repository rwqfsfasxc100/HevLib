extends PanelContainer

var link_button = preload("res://HevLib/ui/mod_menu/urls/URL_BUTTON.tscn")

var MOD_INFO = {}

func update():
	var b = $VBoxContainer/ScrollContainer/VBoxContainer
	for object in b.get_children():
		Tool.remove(object)
	var links = MOD_INFO["manifest"]["manifest_data"]["links"]
	if links:
		for link in links:
			var node = link_button.instance()
			node.url = links[link].get("URL","")
			node.name = link
			node.icon_path = links[link].get("ICON","res://HevLib/ui/themes/icons/alias.stex")
			node.text = link
			b.add_child(node)
#			breakpoint
	


func match_builtin_icon(icon = "res://HevLib/ui/themes/icons/alias.stex"):
	
	
	return icon
