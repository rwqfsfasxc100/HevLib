tool
extends VBoxContainer

export (String) var property_display_name = ""
export (String,MULTILINE) var property_description = ""

export (String) var section_name = ""

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

var toggled = false

export (PackedScene) var link_item = preload("res://modules/manifests/inputboxes/parts/LinkItem.tscn")

onready var add_button = Button.new()
onready var hb = HBoxContainer.new()
func _ready():
	if not default:
		default = []
	
	hb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var LB = HBoxContainer.new()
	var RB = HBoxContainer.new()
	LB.rect_min_size = Vector2(5,0)
	RB.rect_min_size = Vector2(5,0)
	hb.add_child(LB)
	add_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_button.text = "Add item"
	add_button.align = Button.ALIGN_CENTER
	add_button.connect("pressed",self,"_show_add_item")
	hb.add_child(add_button)
	hb.add_child(RB)
	LIST.add_child(hb)
	ADDDIAG.connect("confirmed",self,"_add_confirmed")
	LABEL.text = property_display_name
	LABEL.get_parent().hint_tooltip = property_display_name + "\n\n" + property_description
	connect("visibility_changed",self,"_on_visibility_changed")
	BUTTON.connect("pressed",self,"_on_button_pressed")

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
	if not section_name in mod_box.STATE:
		mod_box.STATE[section_name] = {}
#	mod_box.STATE[section_name][entry_name] = how

func _on_visibility_changed():
	if Engine.editor_hint:
		return
	if not mod_box:
		mod_box = get_node_or_null(NodePath(".."))
	update()
	yield(get_tree(),"idle_frame")
	LABEL.rect_size = LABEL.get_parent().rect_size
	LABEL.rect_position = Vector2(0,0)


func _draw():
	if LIST:
		LIST.visible = toggled
		ICON.rect_rotation = 180 if toggled else 0
		BUTTON.text = "URL entries: %d" % data.size()

func _add_confirmed():
	var txt = ADDEDIT.text
	if txt and ((not txt in data) if require_unique else true):
		ADDDIAG.hide()
		add(txt,{})


var labelRefs : Array = []

func resort():
	for i in LIST.get_children():
		if not i == hb:
			LIST.remove_child(i)
	for i in labelRefs:
		if is_instance_valid(i) and not i.is_queued_for_deletion():
			LIST.add_child(i)
	LIST.move_child(hb,LIST.get_child_count())


func add(this_item_name:String,how:Dictionary):
	data.append(how)
	var l = link_item.instance()
	l.item_name = this_item_name
	labelRefs.append(l)
	resort()

func delete(how:int):
	data.remove(how)
	var item = labelRefs[how]
	item.queue_free()
	labelRefs.remove(how)
	resort()


func export_as():
	var out = {}
	for i in LIST.get_children():
		if "item_name" in i and "item_dict" in i:
			out[i.item_name] = i.item_dict
	return [section_name,out]

func import_as(STATE):
	if section_name in STATE:
		var sv = STATE[section_name]
		if sv is Dictionary:
			for i in labelRefs:
				i.queue_free()
			labelRefs.clear()
			var kv = sv.keys()
			for i in range(kv.size()):
				var vname = kv[i]
				var item = sv[vname]
				add(vname,{})
				var ref = labelRefs[i]
				var RI = {}
				if "URL" in item:
					RI["URL"] = item["URL"]
				if "ICON" in item:
					RI["ICON"] = item["ICON"]
				if "TOOLTIP" in item:
					RI["TOOLTIP"] = item["TOOLTIP"]
				ref.set_this_name(RI,vname)
	update()
