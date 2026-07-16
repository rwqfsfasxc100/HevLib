extends TextureRect

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
# 4. The source code and the binary form, and any modifications made to them may not be used for the purpose of input data, the training of, or improvment of machine learning algorithms,
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

var count = 0.0

func _ready():
	pointers = ModLoader._savedObjects[0]
	visible = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_chaos_map_overlay")
	

var pointers

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
	visible = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_chaos_map_overlay")
	if visible:
		var minimum = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_chaos_map_min_chaos")
		material.set_shader_param("min_chaos", minimum)
		var opacity = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_chaos_map_opacity")
		material.set_shader_param("opacity", opacity)
		

func _input(event:InputEvent):
	if get_parent().is_visible_in_tree():
		if event.is_action_pressed("toggle_chaos_map_overlay"):
			var current = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_chaos_map_overlay")
			pointers.ConfigDriver.__store_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_chaos_map_overlay",!current)
			handle_vis()
			get_tree().set_input_as_handled()
		if event.is_action_pressed("chaos_map_overlay_step_up"):
			var current = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_chaos_map_min_chaos")
			var new = clamp(current + 0.05,0.0,1.0)
			pointers.ConfigDriver.__store_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_chaos_map_min_chaos",new)
			material.set_shader_param("min_chaos", new)
			get_tree().set_input_as_handled()
		if event.is_action_pressed("chaos_map_overlay_step_down"):
			var current = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_chaos_map_min_chaos")
			var new = clamp(current - 0.05,0.0,1.0)
			pointers.ConfigDriver.__store_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_chaos_map_min_chaos",new)
			material.set_shader_param("min_chaos", new)
			get_tree().set_input_as_handled()
		if event.is_action_pressed("chaos_map_overlay_opacity_up"):
			var current = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_chaos_map_opacity")
			var new = clamp(current + 0.05,0.0,1.0)
			pointers.ConfigDriver.__store_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_chaos_map_opacity",new)
			material.set_shader_param("opacity", new)
			get_tree().set_input_as_handled()
		if event.is_action_pressed("chaos_map_overlay_opacity_down"):
			var current = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_chaos_map_opacity")
			var new = clamp(current - 0.05,0.0,1.0)
			pointers.ConfigDriver.__store_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_chaos_map_opacity",new)
			material.set_shader_param("opacity", new)
			get_tree().set_input_as_handled()
