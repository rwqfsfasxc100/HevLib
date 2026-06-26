tool
extends VBoxContainer

export (String) var property_display_name = ""
export (String,MULTILINE) var property_description = ""

export (String) var section_name = ""
export (String) var entry_name = ""

export (Array) var default = Array()

export (bool) var require_unique = false

var data : Array = Array()

var mod_box = get_node_or_null(NodePath(".."))

onready var LABEL = $Box/TOOLTIP/Label
onready var BUTTON = $Box/Button
onready var ICON = $Box/TextureRect
onready var ADDDIAG = $Box/AddDiag
onready var ADDEDIT = $Box/AddDiag/LineEdit
onready var LIST = $List
onready var TOGGLE = $Box/CheckButton

var toggled = false

export (PackedScene) var array_item = preload("res://modules/manifests/inputboxes/parts/ArrayItem.tscn")

onready var add_button = Button.new()

func _ready():
	if not default:
		default = []
	add_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_button.text = "Add item"
	add_button.align = Button.ALIGN_CENTER
	add_button.connect("pressed",self,"_show_add_item")
	LIST.add_child(add_button)
	ADDDIAG.connect("confirmed",self,"_add_confirmed")
	LABEL.text = property_display_name
	TOGGLE.connect("toggled",self,"_on_toggle")
	LABEL.get_parent().hint_tooltip = property_display_name + "\n\n" + property_description
	connect("visibility_changed",self,"_on_visibility_changed")
	BUTTON.connect("pressed",self,"_on_button_pressed")

var is_enabled = false

func _on_toggle(how:bool):
	is_enabled = how
	_on_text_changed(data)

func _show_add_item():
	ADDEDIT.text = ""
	ADDDIAG.popup_centered()
	ADDEDIT.grab_focus()

func _on_button_pressed():
	toggled = !toggled
	update()

func _on_text_changed(how:Array):
	if Engine.editor_hint:
		return
	if is_enabled:
		if not section_name in mod_box.STATE:
			mod_box.STATE[section_name] = {}
		mod_box.STATE[section_name][entry_name] = how
	else:
		mod_box.STATE[section_name].erase(entry_name)

func _on_visibility_changed():
	if Engine.editor_hint:
		return
	if not mod_box:
		mod_box = get_node_or_null(NodePath(".."))
	TOGGLE.pressed = is_enabled
	update()
	yield(get_tree(),"idle_frame")
	LABEL.rect_size = LABEL.get_parent().rect_size
	LABEL.rect_position = Vector2(0,0)


func _draw():
	if LIST:
		LIST.visible = toggled
		ICON.rect_rotation = 180 if toggled else 0
		BUTTON.text = "Array entries: %d" % data.size()

func _add_confirmed():
	var txt = ADDEDIT.text
	if txt and ((not txt in data) if require_unique else true):
		ADDDIAG.hide()
		add(txt)

var labelRefs : Array = []

func resort():
	for i in LIST.get_children():
		if not i == add_button:
			LIST.remove_child(i)
	for i in labelRefs:
		if is_instance_valid(i) and not i.is_queued_for_deletion():
			LIST.add_child(i)
	LIST.move_child(add_button,LIST.get_child_count())


func add(how:String):
	data.append(how)
	var l = array_item.instance()
	l.item_name = how
	labelRefs.append(l)
	resort()

func move(pos:int,direction:int):
	var which = data[pos]
	var label = labelRefs[pos]
	if direction > 0 and pos < (data.size() - 1):
		data.remove(pos)
		data.insert(pos + 1,which)
		labelRefs.remove(pos)
		labelRefs.insert(pos + 1,label)
	elif direction < 0 and pos > 0:
		data.remove(pos)
		data.insert(pos - 1,which)
		labelRefs.remove(pos)
		labelRefs.insert(pos - 1,label)
	resort()

func delete(how:int):
	data.remove(how)
	var item = labelRefs[how]
	item.queue_free()
	labelRefs.remove(how)
	resort()


func export_as():
	breakpoint

func import_as(STATE):
	breakpoint
	update()
