tool
extends VBoxContainer

export (String) var property_display_name = ""
export (String,MULTILINE) var property_description = ""

export (String) var section_name = ""

export (Array) var default = Array()

export (bool) var require_unique = false

var mod_box = get_node_or_null(NodePath(".."))

const cfg_section = preload("res://modules/manifests/inputboxes/config_parts/cfg_section.tscn")

onready var LABEL = $Box/TOOLTIP/Label
onready var BUTTON = $Box/Button
onready var ICON = $Box/TextureRect
onready var ADDDIAG = $Box/AddDiag
onready var ADDEDIT = $Box/AddDiag/VBoxContainer/LineEdit
onready var LIST = $List

var toggled = false

onready var add_button = Button.new()
onready var hb = HBoxContainer.new()

func _ready():
	if not default:
		default = []
	if Engine.editor_hint:
		pass
	else:
		hb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var LB = HBoxContainer.new()
		var RB = HBoxContainer.new()
		hb.add_child(LB)
		
		add_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		add_button.text = "Add section"
		add_button.align = Button.ALIGN_CENTER
		add_button.connect("pressed",self,"_show_add_item")
		hb.add_child(add_button)
		hb.add_child(RB)
		LIST.add_child(hb)
		
		LABEL.text = property_display_name
		LABEL.get_parent().hint_tooltip = property_display_name + "\n\n" + property_description
		connect("visibility_changed",self,"_on_visibility_changed")
		BUTTON.connect("pressed",self,"_on_button_pressed")
		$ConfirmationDialog.connect("confirmed",self,"_doDelete")
		ADDDIAG.connect("confirmed",self,"_add_confirmed")
		
		
		
	
var labelRefs : Dictionary = {}

func resort():
	for i in LIST.get_children():
		if not i == hb:
			LIST.remove_child(i)
	for f in labelRefs:
		var i = labelRefs[f]
		if is_instance_valid(i) and not i.is_queued_for_deletion():
			LIST.add_child(i)
	LIST.move_child(hb,LIST.get_child_count())

func _show_add_item():
	ADDEDIT.text = ""
	ADDDIAG.popup_centered()
	ADDEDIT.grab_focus()

func _on_button_pressed():
	toggled = !toggled
	update()

func _draw():
	if LIST:
		LIST.visible = toggled
		ICON.rect_rotation = 180 if toggled else 0
		BUTTON.text = "Config sections: %d" % labelRefs.size()

func _on_visibility_changed():
	if Engine.editor_hint:
		return
	if not mod_box:
		mod_box = get_node_or_null(NodePath(".."))
	update()
	yield(get_tree(),"idle_frame")
	LABEL.rect_size = LABEL.get_parent().rect_size
	LABEL.rect_position = Vector2(0,0)

func add(section:String):
	
	var box = cfg_section.instance()
	box.section_name = section
	labelRefs[section] = box
	LIST.add_child(box)
	resort()

func delete(how:String):
	var c = $ConfirmationDialog
	c.window_title = how
	c.popup_centered()

func _doDelete():
	var c = $ConfirmationDialog
	var how = c.window_title
	var item = labelRefs[how]
	item.queue_free()
	labelRefs.erase(how)
	resort()

func _add_confirmed():
	var txt = ADDEDIT.text
	for i in LIST.get_children():
		if "section_name" in i and i.section_name == txt:
			return
	ADDDIAG.hide()
	add(txt)

func rename(old:String,new:String):
	var obj = labelRefs[old]
	labelRefs.erase(old)
	labelRefs[new] = obj

func export_as():
	var out = {}
	for i in LIST.get_children():
		if i.has_method("export_as"):
			out.merge(i.export_as())
	return [section_name,out]

func import_as(STATE):
	if section_name in STATE:
		var sv = STATE[section_name]
		if sv is Dictionary:
			for i in labelRefs:
				labelRefs[i].queue_free()
			labelRefs.clear()
			
			var kv = sv.keys()
			for i in kv:
				add(i)
				labelRefs[i].import_as(sv[i])
	update()
