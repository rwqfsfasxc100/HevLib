extends MarginContainer

var handle_resolution = preload("res://HevLib/ui/core_scripts/handle_resolution.gd")

var get_panel = preload("res://HevLib/ui/core_scripts/get_panel.gd")

var calculated_child_nodes = []
onready var dataDictionary = get_parent().get_parent().datastring

func _ready():
	var vpRect = get_viewport_rect().size
	var screenWidth = vpRect.x
	var screenHeight = vpRect.y
	var get_nodes_to_act_on = load("res://HevLib/ui/core_scripts/get_nodes_to_act_on.gd").new()
	calculated_child_nodes = get_nodes_to_act_on.get_nodes_to_act_on(dataDictionary, vpRect)
	
	var panelWidth = Settings.maxScreenScale.x - 2
	var panelHeight = Settings.maxScreenScale.y - 2
	if OS.get_name() == "Windows":
		screenHeight -= 1
	margin_right = screenWidth
	margin_bottom = screenHeight
	margin_left = 0
	margin_top = 0
	parseData()
	

func parseData():
	var resolution = get_viewport_rect().size
	var path = get_path_to(self)
	var make_child = load("res://HevLib/ui/core_scripts/make_child.gd").new()
	for data in dataDictionary:
		var panel_name = data
		var panel = make_child.make_child(dataDictionary.get(data), resolution, path, panel_name)
		add_child(panel)

func _process(delta):
	if self.get_child_count() >= 1:
		resize_children()

func resize_children():
	for item in calculated_child_nodes:
		var path = item[0]
		var size = item[1]
		var pos = item[2]
		var node = get_node(path)
		node.rect_size = size
		node.rect_position = pos


func _on_margin_base_resized():
	
	if self.get_child_count() >= 1:
		resize_children()
