extends MarginContainer

export var datastring = ""

var handle_resolution = load("res://HevLib/ui/core_scripts/handle_resolution.gd").new()
var get_panel = load("res://HevLib/ui/core_scripts/get_panel.gd").new()

export (float, 0, 200, 1) var leftSpacePercent = 20.0
export (float, 0, 200, 1) var rightSpacePercent = 20.0
export (float, 0, 200, 1) var topSpacePercent = 20.0
export (float, 0, 200, 1) var bottomSpacePercent = 20.0

export var set_size = Vector2(1280, 720)
export var set_pos = Vector2(0,0)

export (bool) var square = false

export (String) var panelTexturePath = ""

#func _process(delta):
#	handler()

func _ready():
	handler()

func handler():
	var file = File.new()
	if file.open(panelTexturePath, File.READ) == OK:
		file.close()
		var tex = load(panelTexturePath)
		$NinePatchRect.texture = tex
	else:
		file.close()
		var tex = load("res://HevLib/ui/panels/tl_br.stex")
		$NinePatchRect.texture = tex
	
	var make_child = load("res://HevLib/ui/core_scripts/make_child.gd").new()
	var path = get_path_to(self)
	for data in datastring:
		var panel_name = data
		var panel = make_child.make_child(datastring.get(data), set_size, path, panel_name)
		add_child(panel)
	
