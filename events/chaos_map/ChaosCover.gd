extends TextureRect

var count = 0.0

func _ready():
	visible = ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_chaos_map_overlay")
	

const ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")

var oldColor = "00ff19"

func _physics_process(delta):
	if visible:
		count += 1.0
	else:
		count += 0.1
	
	if count > 10.0:
		handle_vis()

func handle_vis():
	count = 0.0
	visible = ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_chaos_map_overlay")
	if visible:
		var minimum = ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_chaos_map_min_chaos")
		material.set_shader_param("min_chaos", minimum)
		var opacity = ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_chaos_map_opacity")
		material.set_shader_param("opacity", opacity)
		

func _input(event:InputEvent):
	if get_parent().is_visible_in_tree():
		if event.is_action_pressed("toggle_chaos_map_overlay"):
			var current = ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_chaos_map_overlay")
			ConfigDriver.__store_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_chaos_map_overlay",!current)
			handle_vis()
			get_tree().set_input_as_handled()
		if event.is_action_pressed("chaos_map_overlay_step_up"):
			var current = ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_chaos_map_min_chaos")
			var new = clamp(current + 0.05,0.0,1.0)
			ConfigDriver.__store_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_chaos_map_min_chaos",new)
			material.set_shader_param("min_chaos", new)
			get_tree().set_input_as_handled()
		if event.is_action_pressed("chaos_map_overlay_step_down"):
			var current = ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_chaos_map_min_chaos")
			var new = clamp(current - 0.05,0.0,1.0)
			ConfigDriver.__store_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_chaos_map_min_chaos",new)
			material.set_shader_param("min_chaos", new)
			get_tree().set_input_as_handled()
		if event.is_action_pressed("chaos_map_overlay_opacity_up"):
			var current = ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_chaos_map_opacity")
			var new = clamp(current + 0.05,0.0,1.0)
			ConfigDriver.__store_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_chaos_map_opacity",new)
			material.set_shader_param("opacity", new)
			get_tree().set_input_as_handled()
		if event.is_action_pressed("chaos_map_overlay_opacity_down"):
			var current = ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_chaos_map_opacity")
			var new = clamp(current - 0.05,0.0,1.0)
			ConfigDriver.__store_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_chaos_map_opacity",new)
			material.set_shader_param("opacity", new)
			get_tree().set_input_as_handled()
