extends MarginContainer

var lastFocus

export var research_button_path = NodePath("")
onready var research_button = get_node(research_button_path)

func show():
	if visible or $Shower.is_playing():
		return
	lastFocus = get_focus_owner()
	$Shower.play("show")
		
func hide():
	if not visible or $Shower.current_animation == "hide":
		return
	$Shower.play("hide")
		
func _ready():
	visible = false
	get_parent().connect("hidefoka", self, "hide")
	
	var tag_exists = ManifestV2.__get_tags()
	if not "TAG_USING_HEVLIB_RESEARCH" in tag_exists:
		Tool.remove(research_button)

const ManifestV2 = preload("res://HevLib/pointers/ManifestV2.gd")

func _input(event):
	if visible and (Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("pause")):
		get_tree().set_input_as_handled()
		hide()
		if lastFocus:
			lastFocus.grab_focus()

func unfocus():
	if lastFocus and get_focus_owner() == null:
		lastFocus.grab_focus()
		lastFocus = null

func _on_Research_pressed():
	show()
