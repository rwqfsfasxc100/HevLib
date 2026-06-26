extends VBoxContainer

export (String,"","byte","int","float","string","Vector2","Vector3","Color") var specific_type = ""

func get_property_value():
	var value = []
	var string = ""
	for i in $Collapsable/List.get_children():
		if i.has_method("get_property_value"):
			var ov = i.get_property_value()
			value.append(ov[0])
			if string:
				string += ", " + ov[1]
			else:
				string = ov[1]
	var stv = "[%s]" % string
	return [value,stv]

func set_property_value(property):
	if is_array_type(property):
		for i in $Collapsable/List.get_children():
			i._do_delete()
		for i in property:
			_add_entry(i)

onready var TOGGLE = $Toggle/Button
onready var COLLAPSABLE = $Collapsable

onready var SIZEBOX = $Collapsable/Info/VBoxContainer/SIZE
onready var PAGEBOX = $Collapsable/Info/VBoxContainer/PAGE

onready var ADDNEW = $Collapsable/NEW/H/Add
onready var LIST = $Collapsable/List

const array_container = preload("res://HevLib/development_tools/property_editor/parts/array_container.tscn")

func getToggleText():
	match specific_type:
		"byte":
			return "PoolByteArray (size %d)"
		"int":
			return "PoolIntArray (size %d)"
		"float":
			return "PoolRealArray (size %d)"
		"string":
			return "PoolStringArray (size %d)"
		"Vector2":
			return "PoolVector2Array (size %d)"
		"Vector3":
			return "PoolVector3Array (size %d)"
		"Color":
			return "PoolColorArray (size %d)"
		_:
			return "Array (size %d)"

func is_array_type(property) -> bool:
	if property is Array:
		return true
	if property is PoolByteArray:
		specific_type = "byte"
		return true
	if property is PoolColorArray:
		specific_type = "Color"
		return true
	if property is PoolIntArray:
		specific_type = "int"
		return true
	if property is PoolRealArray:
		specific_type = "float"
		return true
	if property is PoolStringArray:
		specific_type = "string"
		return true
	if property is PoolVector2Array:
		specific_type = "Vector2"
		return true
	if property is PoolVector3Array:
		specific_type = "Vector3"
		return true
	return false

func _ready():
	COLLAPSABLE.visible = false
	TOGGLE.connect("toggled",self,"_toggle_collapsed")
	TOGGLE.text = getToggleText() % 0
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
	

func _add_entry(property = null):
	var ac = array_container.instance()
	ac.parent_container = self
	ac.initialize_type = specific_type
	if property != null:
		ac.set_property_value(property)
	LIST.add_child(ac)

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
	objList = get_list()
	var size = objList.size()
	TOGGLE.text = getToggleText() % size
	if LIST.is_visible_in_tree():
		for i in objList:
			i.visible = false
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
