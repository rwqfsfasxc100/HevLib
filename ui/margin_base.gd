extends Panel

onready var dataDictionary = get_parent().datastring

func _ready():
	parseData()
	handler()

func _process(delta):
	handler()

func parseData():
	var resolution = get_parent().size
	var path = get_path_to(self)
	var make_child = load("res://HevLib/ui/core_scripts/make_child.gd").new()
	for data in dataDictionary:
		var panel_name = data
		var panel = make_child.make_child(dataDictionary.get(data), resolution, path, panel_name)
		add_child(panel)

func handler():
	var vpRect = get_parent().size
	var screenWidth = vpRect.x
	var screenHeight = vpRect.y
	if OS.get_name() == "Windows":
		screenHeight -= 1
	margin_right = screenWidth
	margin_bottom = screenHeight
	margin_left = 0
	margin_top = 0
