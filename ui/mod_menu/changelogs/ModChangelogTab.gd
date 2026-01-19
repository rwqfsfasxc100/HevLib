extends Tabs

export var changelog_display = preload("res://HevLib/ui/mod_menu/changelogs/ChangelogDisplay.tscn")

var mod_data = {}

func _ready():
	var menu = changelog_display.instance()
	var changelog = mod_data.get("changelog")
	var path = mod_data.get("path")
	var modpath = path.split(path.split("/")[path.split("/").size() - 1])[0]
	menu.path = modpath + changelog
	add_child(menu)
