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
onready var ADDEDIT = $Box/AddDiag/VBoxContainer/LineEdit
onready var ADDOPTS = $Box/AddDiag/VBoxContainer/OptionButton
onready var ADDTAGTYPE = $Box/AddDiag/VBoxContainer/TagType
onready var LIST = $List

var toggled = false

export (PackedScene) var tag_item = preload("res://modules/manifests/inputboxes/parts/TagItem.tscn")

onready var add_button = Button.new()
onready var hb = HBoxContainer.new()

func _ready():
	if not default:
		default = []
	if Engine.editor_hint:
		pass
	else:
		for i in ManifestConsts.supported_property_types:
			ADDTAGTYPE.add_item(i)
		opts_available_presets = ManifestConsts.BUILTIN_TAGS.keys()
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
		ADDOPTS.connect("item_selected",self,"_on_preset_selected")
		LABEL.text = property_display_name
		LABEL.get_parent().hint_tooltip = property_display_name + "\n\n" + property_description
		connect("visibility_changed",self,"_on_visibility_changed")
		BUTTON.connect("pressed",self,"_on_button_pressed")
		$ConfirmationDialog.connect("confirmed",self,"_doDelete")

var opts_available_presets:Array = []

func _show_add_item():
	ADDEDIT.text = ""
	ADDOPTS.clear()
	get_available_options()
	ADDOPTS.add_item("",0)
	for i in opts_available_presets:
		ADDOPTS.add_item(i)
	ADDDIAG.popup_centered()
	ADDEDIT.grab_focus()

func _on_preset_selected(idx:int):
	if idx > 0:
		var optname = opts_available_presets[idx - 1]
		var opttype = ManifestConsts.BUILTIN_TAGS[optname][0]
		var optdesc = ManifestConsts.BUILTIN_TAGS[optname][2]
		var optindex = ManifestConsts.supported_property_types.find(opttype)
		ADDEDIT.text = optname
		ADDTAGTYPE.select(optindex)
		ADDOPTS.hint_tooltip = optname + "\n\n" + optdesc

func get_available_options():
	var available_presets = ManifestConsts.BUILTIN_TAGS.keys()
	for i in LIST.get_children():
		if "item_name" in i and i.item_name in ManifestConsts.BUILTIN_TAGS:
			available_presets.erase(i.item_name)
	opts_available_presets = available_presets

func _on_button_pressed():
	toggled = !toggled
	update()

func _on_text_changed(how:Array):
	if Engine.editor_hint:
		return
	if not section_name in mod_box.STATE:
		mod_box.STATE[section_name] = {}

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
		BUTTON.text = "Tag entries: %d" % data.size()

func _add_confirmed():
	var txt = ADDEDIT.text
	if txt and ((not txt in data) if require_unique else true):
		ADDDIAG.hide()
		add(txt,{},ManifestConsts.supported_property_types[ADDTAGTYPE.selected])


var labelRefs : Array = []

func resort():
	for i in LIST.get_children():
		if not i == hb:
			LIST.remove_child(i)
	for i in labelRefs:
		if is_instance_valid(i) and not i.is_queued_for_deletion():
			LIST.add_child(i)
	LIST.move_child(hb,LIST.get_child_count())


func add(this_item_name:String,how:Dictionary,type:String):
	data.append(how)
	var l = tag_item.instance()
	l.item_type = type
	l.item_name = this_item_name
	labelRefs.append(l)
	resort()

func delete(how:int):
	var c = $ConfirmationDialog
	c.window_title = str(how)
	c.popup_centered()
func _doDelete():
	var how = int($ConfirmationDialog.window_title)
	data.remove(how)
	var item = labelRefs[how]
	item.queue_free()
	labelRefs.remove(how)
	resort()


func export_as():
	var out = {}
	for i in LIST.get_children():
		if i.has_method("export_as"):
			out.merge(i.export_as())
	return [section_name,out]

func import_as(STATE):
	if section_name in STATE:
		var sv = STATE[section_name]
		labelRefs.clear()
		for i in LIST.get_children():
			if "item_name" in i:
				i.queue_free()
		
		var kv = sv.keys()
		for i in range(kv.size()):
			var vname = kv[i]
			var entry = sv[vname]
			add(vname,{},entry.type)
			var ref = labelRefs[i]
			ref.import_as(entry.value)
	update()
