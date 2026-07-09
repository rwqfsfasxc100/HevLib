tool
extends HBoxContainer

signal changed()

func get_property_value():
	return $value.get_property_value()

func set_property_value(value):
	$value.initialize(value)

var parent_container = null

var initialize_type = ""



func _enter_tree():
	if initialize_type and (initialize_type in supported_property_types) or (initialize_type == "byte"):
		var v = $value
		if not v.is_connected("changed",self,"_on_changed"):
			v.connect("changed",self,"_on_changed")
		var byte_init = false
		if initialize_type == "byte":
			initialize_type = "int"
			byte_init = true
		v.can_edit_type = false
		v.byte_init = byte_init
		v.property_type = initialize_type

func _on_changed():
	pass
#	emit_signal("changed")

func _ready():
	if not $DELETE.is_connected("pressed",self,"_on_delete"):
		$DELETE.connect("pressed",self,"_on_delete")
	if not $ConfirmationDialog.is_connected("confirmed",self,"_do_delete"):
		$ConfirmationDialog.connect("confirmed",self,"_do_delete")

func _on_delete():
	$ConfirmationDialog.popup_centered()

func _do_delete():
	queue_free()
	if parent_container:
		parent_container.recalculate()

const supported_property_types = [
	"null",
	"bool",
	"int",
	"float",
	"string",
	"Vector2",
	"Rect2",
	"Vector3",
	"Transform2D",
	"Color",
	"Dictionary",
	"Array",
	"PoolByteArray",
	"PoolIntArray",
	"PoolRealArray",
	"PoolStringArray",
	"PoolVector2Array",
	"PoolVector3Array",
	"PoolColorArray",
]
