extends VBoxContainer

func get_property_value():
	var value = {}
	var string = ""
	for i in get_list():
		var val = i.get_property_value()
		value.merge(val[0])
		var sv :String= val[1]
		if sv.begins_with("{") and sv.ends_with("}"):
			sv = sv.substr(1)
			sv = sv.substr(0,sv.length() - 1)
		if string:
			string += ", " + sv
		else:
			string = sv
	var stv = "{%s}" % string
	return [value,stv]

func set_property_value(property):
	if property is Dictionary:
		for i in LIST:
			i._do_delete()
		for i in property:
			var val = property[i]
			NEWKEY.set_property_value(i)
			NEWVAL.set_property_value(val)
			_add_entry()

var toggle_text = "Dictionary (size %d)"

const dict_container = preload("res://HevLib/development_tools/property_editor/parts/dict_container.tscn")

onready var TOGGLE = $Toggle/Button
onready var COLLAPSABLE = $Collapsable

onready var LIST = $Collapsable/List

onready var SIZEBOX = $Collapsable/Info/VBoxContainer/SIZE
onready var PAGEBOX = $Collapsable/Info/VBoxContainer/PAGE

onready var NEWKEY = $Collapsable/NEW/VBoxContainer/Key/property_editor
onready var NEWVAL = $Collapsable/NEW/VBoxContainer/Value/property_editor
onready var ADDNEW = $Collapsable/NEW/VBoxContainer/H/Add

func _ready():
	COLLAPSABLE.visible = false
	TOGGLE.connect("toggled",self,"_toggle_collapsed")
	TOGGLE.text = toggle_text % 0
	ADDNEW.connect("pressed",self,"_add_entry")
	SIZEBOX.connect("value_changed",self,"_size_value_changed")
	PAGEBOX.connect("value_changed",self,"_page_value_changed")
	recalculate()

func _toggle_collapsed(how:bool):
	var stream = StreamTexture.new()
	if how:stream.load_path = "res://property_editor/icons/expanded.stex"
	else:TOGGLE.icon = "res://property_editor/icons/collapsed.stex"
	TOGGLE.icon = stream
	COLLAPSABLE.visible = how
	recalculate()

func _add_entry():
	var key = NEWKEY.get_property_value()[0]
	var items = []
	for i in get_list():
		items.append(i.get_node("key").get_property_value()[0])
	if key in items:
		return
	var val = NEWVAL.get_property_value()[0]
	var cv = dict_container.instance()
	cv.set_property_value(key,val)
	cv.parent_container = self
	LIST.add_child(cv)
	NEWKEY.set_property_value(null)
	NEWVAL.set_property_value(null)

const page_size = 20
var current_page = 0

func get_list():
	var out = []
	for i in LIST.get_children():
		if is_instance_valid(i) and not i.is_queued_for_deletion():
			out.append(i)
	return out

var objList = []
func recalculate():
	if LIST.is_visible_in_tree():
		objList = get_list()
		for i in objList:
			i.visible = false
		var size = objList.size()
		TOGGLE.text = toggle_text % size
		SIZEBOX.value = size
		
		var offset = (current_page * page_size)
		var max_pages = int(ceil(float(size)/float(page_size))) - 1
		if size > page_size:
			for iv in range(clamp(size - offset,0,page_size)):
				objList[iv + offset].visible = true
			PAGEBOX.visible = true
		else:
			for iv in objList:
				iv.visible = true
			PAGEBOX.visible = false
			current_page = 0
		PAGEBOX.value = current_page
	else:
		current_page = 0

func _size_value_changed(how:float):
	how = int(how)
	var sz = objList.size()
	if how != sz:
		if how < sz and sz > 0:
			objList[sz - 1]._on_delete()
		elif how > sz:
			NEWKEY.set_property_value(null)
			NEWVAL.set_property_value(null)
			_add_entry()
	recalculate()

func _page_value_changed(how:float):
	how = int(how)
	if how != current_page:
		var size = objList.size()
		var offset = (current_page * page_size)
		var max_pages = int(ceil(float(size)/float(page_size))) - 1
		if how < current_page and current_page > 0:
			current_page -= 1
		elif how > current_page:
			if current_page < max_pages:
				current_page += 1
	recalculate()

func _draw():
	recalculate()
