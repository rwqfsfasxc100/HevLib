extends Button

export var changelog_menu = NodePath("")
onready var menu = get_node_or_null(changelog_menu)

var pointers = ModLoader._savedObjects[0]
func _ready():
	var data = pointers.ManifestV2.__have_mods_updated()
	if data.keys().size() > 0 and menu:
		connect("pressed",menu,"show_menu")
		visible = true
		menu.open(data)
	else:
		visible = false
