extends VBoxContainer

var section_name = ""

onready var LABEL = $Box/TOOLTIP/TEXTLABEL
onready var BUTTON = $Box/TOOLTIP
onready var ICON = $Box/TextureRect
onready var EDIT = $Box/EDIT
onready var EDITDIAG = $Box/EditDiag
onready var EDITDIAGLINE = $Box/EditDiag/LineEdit
onready var DELETE = $Box/DELETE
onready var LIST = $List
onready var ADDDIAG = $Box/AddDiag
onready var ADDEDIT = $Box/AddDiag/VBoxContainer/LineEdit
onready var ADDOPTS = $Box/AddDiag/VBoxContainer/OptionButton

onready var parent = get_node_or_null(NodePath("../.."))

onready var add_button = Button.new()
onready var hb = HBoxContainer.new()

func _ready():
	connect("visibility_changed",self,"_on_visibility_changed")
	BUTTON.connect("pressed",self,"_on_toggle")
	EDIT.connect("pressed",self,"_on_edit_pressed")
	DELETE.connect("pressed",self,"_on_delete")
	EDITDIAG.connect("confirmed",self,"_on_name_change")
	set_this_name(section_name)
	
	if Engine.editor_hint:
		pass
	else:
		hb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var LB = HBoxContainer.new()
		var RB = HBoxContainer.new()
		LB.rect_min_size = Vector2(5,0)
		RB.rect_min_size = Vector2(5,0)
		hb.add_child(LB)
		ADDOPTS.clear()
		for i in ManifestConsts.CONFIG_NAMES:
			ADDOPTS.add_item(i)
		add_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		add_button.text = "Add entry"
		add_button.align = Button.ALIGN_CENTER
		add_button.connect("pressed",self,"_show_add_item")
		hb.add_child(add_button)
		hb.add_child(RB)
		LIST.add_child(hb)
		ADDDIAG.connect("confirmed",self,"_add_confirmed")
		LABEL.text = section_name
		$ConfirmationDialog.connect("confirmed",self,"_doDelete")

var toggled = false

func _on_toggle():
	toggled = !toggled
	update()

func _draw():
	if ICON:
		ICON.rect_rotation = 180 if toggled else 0
		$List.visible = toggled
		BUTTON.text = "Config entries: %d" % labelRefs.size()

var allow_change = true

func set_this_name(vn:String):
	var oldSectionName = section_name
	section_name = vn
	allow_change = false
	LABEL.text = vn
	allow_change = true
	if oldSectionName != vn:
		parent.rename(oldSectionName,vn)

func _on_visibility_changed():
	if Engine.editor_hint:
		return
	
	
	yield(get_tree(),"idle_frame")
	LABEL.rect_size = LABEL.get_parent().rect_size
	LABEL.rect_position = Vector2(0,0)

func _on_edit_pressed():
	EDITDIAGLINE.text = section_name
	EDITDIAG.popup_centered()
	EDITDIAGLINE.grab_focus()
	EDITDIAGLINE.caret_position = EDITDIAGLINE.text.length()

func _on_name_change():
	set_this_name(EDITDIAGLINE.text)

func _on_delete():
	if parent:
		parent.delete(section_name)

func _show_add_item():
	ADDOPTS.select(0)
	ADDDIAG.popup_centered()
	ADDEDIT.text = ""
	ADDEDIT.grab_focus()

var labelRefs = {
	
}

func _add_confirmed():
	var tname = ADDEDIT.text
	if tname and not tname in labelRefs:
		var type = ManifestConsts.CONFIG_NAMES[ADDOPTS.selected]
		var node = ManifestConsts.CONFIG_NODES[type].instance()
		node.config_name = tname
		labelRefs[tname] = node
		LIST.add_child(node)
		ADDDIAG.hide()
		resort()

func resort():
	for i in LIST.get_children():
		if i != hb:
			LIST.remove_child(i)
	for f in labelRefs:
		var i = labelRefs[f]
		if is_instance_valid(i) and not i.is_queued_for_deletion():
			LIST.add_child(i)
	LIST.move_child(hb,LIST.get_child_count())

func rename(old:String,new:String):
	var obj = labelRefs[old]
	labelRefs.erase(old)
	labelRefs[new] = obj

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

func export_as():
	var out = {}
	for i in $List.get_children():
		if "config_name" in i and "config_type" in i:
			var cfgname = i.config_name
			var config = {}
			for r in i.COLLAPSIBLE.get_children():
				var vname = r.name
				config[vname] = r.get_node(vname).get_property_value()[0]
			config["type"] = i.config_type
			out[cfgname] = config
	return {section_name:out}

func import_as(STATE):
	if STATE is Dictionary:
		for i in labelRefs:
			labelRefs[i].queue_free()
		labelRefs.clear()
		
		for cv in STATE:
			var config = STATE[cv]
			if "type" in config:
				var ct = config.type.to_lower()
				match ct:
					"boolean":
						ct = "bool"
					"integer":
						ct = "int"
					"real":
						ct = "float"
					"str":
						ct = "string"
					"option","option_button":
						ct = "optionbutton"
				
				var typeIndex = ManifestConsts.CONFIG_NAMES.find(ct)
				if typeIndex > -1:
					ADDOPTS.select(typeIndex)
					ADDEDIT.text = cv
					_add_confirmed()
					var ref = labelRefs[cv]
					for i in ref.get_node("Collapsible").get_children():
						var iname = i.name
						if iname in config:
							var prop = i.get_node(iname)
							prop.set_property_value(config[iname])
	update()
