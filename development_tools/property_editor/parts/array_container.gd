extends HBoxContainer

func get_property_value():
	return $value.get_property_value()

func set_property_value(value):
	$value.initialize(value)

var parent_container = null

var initialize_type = ""

var ManifestConsts

func _enter_tree():
	ManifestConsts = load("res://HevLib/development_tools/parts/ManifestConsts.gd")
	if initialize_type and (initialize_type in ManifestConsts.supported_property_types) or (initialize_type == "byte"):
		var v = $value
		var byte_init = false
		if initialize_type == "byte":
			initialize_type = "int"
			byte_init = true
		v.can_edit_type = false
		v.byte_init = byte_init
		v.property_type = initialize_type

func _ready():
	$DELETE.connect("pressed",self,"_on_delete")
	$ConfirmationDialog.connect("confirmed",self,"_do_delete")

func _on_delete():
	$ConfirmationDialog.popup_centered()

func _do_delete():
	queue_free()
	if parent_container:
		parent_container.recalculate()
