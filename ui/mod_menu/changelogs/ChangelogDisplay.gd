extends VBoxContainer

var path = ""

const header_label = preload("res://HevLib/ui/mod_menu/changelogs/labels/version_label.tscn")
const entry_label = preload("res://HevLib/ui/mod_menu/changelogs/labels/changelog_entry.tscn")
const rich_entry_label = preload("res://HevLib/ui/mod_menu/changelogs/labels/rich_changelog_entry.tscn")
onready var linecontainer = $ScrollContainer/VBoxContainer
var pointers
export (String,"singular","dynamic") var operation = "singular"

onready var LEFT = $PAGES/LEFT
onready var RIGHT = $PAGES/RIGHT

onready var pageBox = $PAGES

func _ready():
	LEFT.connect("pressed",self,"_left_pressed")
	RIGHT.connect("pressed",self,"_right_pressed")
	if operation == "singular" and path != "":
		rect_size = get_parent().rect_size
		linecontainer.rect_min_size = rect_size - Vector2(0,6)
		yield(CurrentGame.get_tree(),"idle_frame")
		parse()
		
		pass

var refs = []

var antispam = true
func _left_pressed():
	if antispam and current_page > 0:
		antispam = false
		current_page -= 1
		clear()
		if clearing:
			yield(self,"cleared")
		parse()
		yield(get_tree().create_timer(0.15),"timeout")
		antispam = true

func _right_pressed():
	if antispam:
		antispam = false
		current_page += 1
		clear()
		if clearing:
			yield(self,"cleared")
		parse()
		yield(get_tree().create_timer(0.15),"timeout")
		antispam = true

var clearing = false

export var page_size = 15
var current_page = 0
func parse():
	if not is_visible_in_tree():
		current_page = 0
	if not pointers:
		yield(CurrentGame.get_tree(),"idle_frame")
	pointers = CurrentGame.get_tree().get_root().get_node_or_null("HevLib~Pointers")
	
	var data:Dictionary = pointers.ManifestV2.__parse_changelogs(path)
	
	var size = data.size()
	var offset = (current_page * page_size)
	var max_pages = int(ceil(float(size)/float(page_size))) - 1
	var keys = data.keys()
	LEFT.disabled = current_page < 1
	RIGHT.disabled = current_page > max_pages - 1
	for iv in range(clamp(size - offset,0,page_size)):
		var config = keys[iv + offset]
		var lines = data[config]
		var header = header_label.instance()
		header.text = config
		if clearing:
			break
		else:
			refs.append(header)
		linecontainer.add_child(header)
		for l in lines:
			var label = entry_label.instance()
			var tex = TranslationServer.translate(l)
			label.text = tex
			if clearing:
				break
			else:
				refs.append(label)
			linecontainer.add_child(label)
			yield(CurrentGame.get_tree(),"idle_frame")
		yield(CurrentGame.get_tree(),"idle_frame")

func _visibility_changed():
	yield(CurrentGame.get_tree(),"idle_frame")
	if is_visible_in_tree():
		var size = get_parent().rect_size
		rect_size = size
		$ScrollContainer.rect_min_size = rect_size - Vector2(12,6) - Vector2(0,pageBox.rect_size.y)
		linecontainer.rect_min_size = rect_size - Vector2(12,12) - Vector2(0,pageBox.rect_size.y)
	
signal cleared()
func clear_and_update(new):
	clear()
	if clearing:
		yield(self,"cleared")
	path = new
	
	parse()

func clear():
	if refs:
		clearing = true
		yield(CurrentGame.get_tree().create_timer(0.1),"timeout")
		for i in refs:
			Tool.remove(i)
		yield(CurrentGame.get_tree(),"idle_frame")
	clearing = false
	emit_signal("cleared")
