extends Button

export var changelog_menu = NodePath("")
onready var menu = get_node_or_null(changelog_menu)
#const MV2 = preload("res://HevLib/pointers/ManifestV2.gd")
var pointers
func _ready():
	pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	if pointers == null:
		yield(get_tree(),"idle_frame")
		pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	var data = pointers.ManifestV2.__have_mods_updated()
	if data.keys().size() > 0 and menu:
		connect("pressed",menu,"show_menu")
		visible = true
		menu.open(data)
	else:
		visible = false
