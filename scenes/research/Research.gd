extends MarginContainer

var lastFocus

export var research_button_path = NodePath("")
onready var research_button = get_node(research_button_path)

onready var current_project_management = $TabHintContainer/Tabs/HEVLIB_RESEARCH_CURRENT/CurrentResearchManagement
onready var dormant_project_management = $TabHintContainer/Tabs/HEVLIB_RESEARCH_AVAILABLE/MarginContainer/HBoxContainer/ActivatableProjects

func show():
	if $Shower.is_playing():
		return
	lastFocus = get_focus_owner()
	$Shower.play("show")
	var actives = current_project_management.get_node("VBoxContainer/ScrollContainer/Projects")
	if actives.get_child_count() > 0:
		var first = actives.get_child(0).get_node("Progress/Button")
		first.grab_focus()
	if visible:
		hide()
	
#
#
#	var notif = {
#		"title":{"text":"Title Test"},
#		"body":{"text":"Body Test"},
#		"description":{"text":"Desc Test"},
#		"particles":{"show":true},
#		"transition":{"label":"Label Test","old":"Old Value","new":"New Value"},
#		"scene":{"path":"res://ships/RA-TRTL.tscn","position":Vector2(-25,0),"scale":Vector2(0.5,0.5),"rotation":90,"rotation_speed":180}
#	}
#
#
#	CurrentGame.send_notification(notif)
	
		
func hide():
	if not visible or $Shower.current_animation == "hide":
		return
	$Shower.play("hide")
	if lastFocus:
		lastFocus.grab_focus()
onready var pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")
func _ready():
	visible = false
	get_parent().connect("hidefoka", self, "hide")
	
	var mod_ids = pointers.ManifestV2.__get_mod_ids()
	current_project_management.current_mod_ids = mod_ids
	dormant_project_management.current_mod_ids = mod_ids
	var tag_exists = pointers.ManifestV2.__get_tags()
	if not "TAG_USING_HEVLIB_RESEARCH" in tag_exists:
		Tool.remove(research_button)
	else:
		var state = CurrentGame.state
		if not "hevlib_research" in state:
			CurrentGame.state.merge({"hevlib_research":{}})
		get_research_data()


#const ManifestV2 = preload("res://HevLib/pointers/ManifestV2.gd")

func _input(event):
	if visible and (Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("pause")):
		get_tree().set_input_as_handled()
		hide()
		
#		if lastFocus:
#			lastFocus.grab_focus()

func unfocus():
	if lastFocus and get_focus_owner() == null:
		lastFocus.grab_focus()
		lastFocus = null

func _on_Research_pressed():
	show()

func get_research_data():
	var tags = pointers.ManifestV2.__get_mods_and_tags_from_tag("TAG_USING_HEVLIB_RESEARCH")
	for mod in tags:
		for p in tags[mod]:
			var id = mod + "|" + p.name
			if not "source" in p:
				p.merge({"source":mod})
			if not "state" in CurrentGame.state.hevlib_research:
				var state = {
					"active":false,
					"time_while_active":-1,
					"completed":false,
				}
				p.merge({"state":state})
			CurrentGame.state.hevlib_research.merge({id:p},true)
	current_project_management._initialize()
	dormant_project_management._initialize()
