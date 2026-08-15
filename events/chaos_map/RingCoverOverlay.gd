# [license]
# 3-Clause BSD NON-AI License
# 
# Copyright 2026 __hev (Benjamin Buckhurst)
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.
# 
# 4. The source code and the binary form, and any modifications made to them may not be used for the purpose of input data, the training of, or improvement of machine learning algorithms,
# including but not limited to artificial intelligence, natural language processing, or data mining. This condition applies to any derivatives,
# modifications, or updates based on the Software code. Any usage of the source code or the binary form in an AI-training dataset is considered a breach of this License.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# [/license]

extends TextureRect

var count = 0.0

func _ready():
	pointers = ModLoader._savedObjects[0]
	visible = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_map_overlay")
	

var pointers

func _physics_process(delta):
	if visible:
		count += 1.0
	else:
		count += 0.1
	
	if count > 10.0:
		handle_vis()

func handle_vis():
	count = 0.0
	var visibility = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_map_overlay")
	visible = visibility
	if visibility:
		var minimum = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_map_min_value")
		var maximum = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_map_max_value")
		var oob_opacity = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_map_oob_opacity")
		var opacity = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_map_opacity")
		var display_mode = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_map_display_mode")
		var heatmap = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_map_use_heatmap")
		var clamp_heatmap = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_map_heatmap_clamp")
		
		material.set_shader_param("min_val", minimum)
		material.set_shader_param("max_val", maximum)
		material.set_shader_param("opacity", opacity)
		material.set_shader_param("darken_factor", oob_opacity)
		material.set_shader_param("mode", display_mode)
		material.set_shader_param("heatmap", heatmap)
		material.set_shader_param("clamp_heatmap", clamp_heatmap)
		

func _input(event:InputEvent):
	if get_parent().is_visible_in_tree():
		if event.is_action_pressed("hl_toggle_ring_map_overlay"):
			var current = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_map_overlay")
			pointers.ConfigDriver.__store_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_map_overlay",!current)
			handle_vis()
			get_tree().set_input_as_handled()
		if is_visible_in_tree():
			if event.is_action_pressed("hl_ring_map_overlay_min_value_up"):
				var current = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_map_min_value")
				var new = clamp(current + 0.05,0.0,1.0)
				pointers.ConfigDriver.__store_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_map_min_value",new)
				material.set_shader_param("min_val", new)
				get_tree().set_input_as_handled()
			if event.is_action_pressed("hl_ring_map_overlay_min_value_down"):
				var current = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_map_min_value")
				var new = clamp(current - 0.05,0.0,1.0)
				pointers.ConfigDriver.__store_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_map_min_value",new)
				material.set_shader_param("min_val", new)
				get_tree().set_input_as_handled()
			if event.is_action_pressed("hl_ring_map_overlay_opacity_up"):
				var current = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_map_opacity")
				var new = clamp(current + 0.05,0.0,1.0)
				pointers.ConfigDriver.__store_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_map_opacity",new)
				material.set_shader_param("opacity", new)
				get_tree().set_input_as_handled()
			if event.is_action_pressed("hl_ring_map_overlay_opacity_down"):
				var current = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_map_opacity")
				var new = clamp(current - 0.05,0.0,1.0)
				pointers.ConfigDriver.__store_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_map_opacity",new)
				material.set_shader_param("opacity", new)
				get_tree().set_input_as_handled()
			if event.is_action_pressed("hl_toggle_ring_map_use_heatmap"):
				var current = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_map_use_heatmap")
				var new = !current
				pointers.ConfigDriver.__store_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_map_use_heatmap",new)
				material.set_shader_param("heatmap", new)
				get_tree().set_input_as_handled()
			if event.is_action_pressed("hl_toggle_ring_map_heatmap_clamp"):
				var current = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_map_heatmap_clamp")
				var new = !current
				pointers.ConfigDriver.__store_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_map_heatmap_clamp",new)
				material.set_shader_param("clamp_heatmap", new)
				get_tree().set_input_as_handled()
			if event.is_action_pressed("hl_cycle_ring_map_mode"):
				var current = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_map_display_mode")
				var new = current + 1
				if new > 8:
					new = 0
				pointers.ConfigDriver.__store_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_map_display_mode",new)
				material.set_shader_param("mode", new)
				get_tree().set_input_as_handled()
			if event.is_action_pressed("hl_ring_map_overlay_max_value_up"):
				var current = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_map_max_value")
				var new = clamp(current + 0.05,0.0,1.0)
				pointers.ConfigDriver.__store_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_map_max_value",new)
				material.set_shader_param("max_val", new)
				get_tree().set_input_as_handled()
			if event.is_action_pressed("hl_ring_map_overlay_max_value_down"):
				var current = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_map_max_value")
				var new = clamp(current - 0.05,0.0,1.0)
				pointers.ConfigDriver.__store_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_map_max_value",new)
				material.set_shader_param("max_val", new)
				get_tree().set_input_as_handled()
			if event.is_action_pressed("hl_ring_map_overlay_oob_opacity_up"):
				var current = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_map_oob_opacity")
				var new = clamp(current + 0.05,0.0,1.0)
				pointers.ConfigDriver.__store_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_map_oob_opacity",new)
				material.set_shader_param("darken_factor", new)
				get_tree().set_input_as_handled()
			if event.is_action_pressed("hl_ring_map_overlay_oob_opacity_down"):
				var current = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","")
				var new = clamp(current - 0.05,0.0,1.0)
				pointers.ConfigDriver.__store_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","",new)
				material.set_shader_param("darken_factor", new)
				get_tree().set_input_as_handled()
		
		
		
		
		
		
