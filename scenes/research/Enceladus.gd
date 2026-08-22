extends "res://enceladus/Enceladus.gd"

func _ready():
	var buttonList = get_node_or_null("EnceladusMenu/MenuContainer/MarginContainer/HBoxContainer/Options")
	var researchButton = Button.new()
	researchButton.name = "Research"
	researchButton.text = "HEVLIB_RESEARCH"
	buttonList.add_child(researchButton)
	buttonList.move_child(researchButton,5)
	var research_panel = load("res://HevLib/scenes/research/Research.tscn").instance()
	menusContainer.add_child(research_panel)
	menusContainer.move_child(research_panel,5)
	research_panel.research_button = researchButton
	researchButton.connect("pressed",research_panel,"_on_Research_pressed")
