extends CanvasLayer

export var richLabel = preload("res://HevLib/logging/ConsoleRichText.tscn")

export var max_lines = 255

onready var list = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer

var currentNodeRes = Vector2(1280,720)

func _ready():
	for i in range(max_lines):
		var label = richLabel.instance()
		label.name = "line_" + str(i)
		list.add_child(label)
		clearLabel(label)

func _process(delta):
	if $MarginContainer.is_visible_in_tree():
		currentNodeRes = Settings.getViewportSize()
		$MarginContainer.rect_size = currentNodeRes

func _input(event):
	if event.is_action_pressed("open_console"):
		visible = !visible

func clearLabel(label):
	yield(get_tree(),"idle_frame")
	label.clear()










func clear_lines():
	pass




