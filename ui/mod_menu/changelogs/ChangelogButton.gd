extends Button

export var changelog_menu = NodePath("")
onready var menu = get_node_or_null(changelog_menu)
const MV2 = preload("res://HevLib/pointers/ManifestV2.gd")

func _ready():
	var data = MV2.__have_mods_updated()
	if data.keys().size() > 0 and menu:
		connect("pressed",menu,"show_menu")
		visible = true
		menu.open(data)
	else:
		visible = false
