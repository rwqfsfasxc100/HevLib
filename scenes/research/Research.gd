extends MarginContainer

var lastFocus

export var research_button_path = NodePath("")
onready var research_button = get_node(research_button_path)

onready var current_project_management = $TabHintContainer/Tabs/HEVLIB_RESEARCH_CURRENT/CurrentResearchManagement
onready var dormant_project_management = $TabHintContainer/Tabs/HEVLIB_RESEARCH_AVAILABLE/MarginContainer/HBoxContainer/ActivatableProjects

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
	else:
		var state = CurrentGame.state
		if not "hevlib_research" in state:
			CurrentGame.state.merge({"hevlib_research":{}})
		get_research_data()

var research_state = {}

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

func get_research_data():
	research_state = CurrentGame.state.hevlib_research
	var tags = ManifestV2.__get_mods_and_tags_from_tag("TAG_USING_HEVLIB_RESEARCH")
	for mod in tags:
		for p in tags[mod]:
			var id = mod + "_" + p.name
			p.merge({"source":mod})
			if not id in research_state:
				var state = {
					"active":false,
					"time_while_active":-1,
				}
				p.merge({"state":state})
			research_state.merge({id:p},true)
	current_project_management._initialize()
	dormant_project_management._initialize()
