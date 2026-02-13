extends VBoxContainer

var path = ""
#const MV2 = preload("res://HevLib/pointers/ManifestV2.gd")
const header_label = preload("res://HevLib/ui/mod_menu/changelogs/labels/version_label.tscn")
const entry_label = preload("res://HevLib/ui/mod_menu/changelogs/labels/changelog_entry.tscn")
onready var linecontainer = $ScrollContainer/VBoxContainer
var pointers
export (String,"singular","dynamic") var operation = "singular"

func _ready():
	pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")
	if operation == "singular" and path != "":
		rect_size = get_parent().rect_size
		linecontainer.rect_min_size = rect_size - Vector2(0,6)
		parse()
		
		pass

var refs = []

func parse():
	var data = pointers.ManifestV2.__parse_changelog(path)
	var index = 1
	for config in data:
		var lines = data[config]
		var header = header_label.instance()
		header.text = config
		refs.append(header)
		linecontainer.add_child(header)
		for l in lines:
			var label = entry_label.instance()
			label.text = l
			refs.append(label)
			linecontainer.add_child(label)
			yield(get_tree(),"idle_frame")
			
		yield(get_tree(),"idle_frame")

func _visibility_changed():
	yield(get_tree(),"idle_frame")
	rect_size = get_parent().rect_size
	$ScrollContainer.rect_min_size = rect_size
	linecontainer.rect_min_size = rect_size - Vector2(0,6)

func clear_and_update(new):
	clear()
	path = new
	
	parse()

func clear():
	for i in refs:
		Tool.remove(i)
