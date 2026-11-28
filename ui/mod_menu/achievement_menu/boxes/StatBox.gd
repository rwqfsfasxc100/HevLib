extends HBoxContainer

var stat_id : String = ""

onready var button : Button = $MarginContainer/Button
onready var name_label : Label = $MarginContainer/VBoxContainer/NAME
onready var desc_label : Label = $MarginContainer/VBoxContainer/DESC

onready var pointers : HevLibPointers = ModLoader._savedObjects[0]

func _ready() -> void:
	connect("visibility_changed",self,"_vis_changed")

func update_data():
	if stat_id:
		name_label.text = stat_id
		button.text = CurrentGame.formatThousands(pointers.Achievements.__get_stat_data(stat_id))
		pass

func _vis_changed():
	if is_visible_in_tree() and get_position_in_parent() == 0:
		button.get_child(0).call_deferred("scrollTo")
