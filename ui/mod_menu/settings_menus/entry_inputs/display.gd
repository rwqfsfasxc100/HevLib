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

extends HBoxContainer

var CONFIG_DATA = {}

var CONFIG_ENTRY = ""

var CONFIG_SECTION = ""

var CONFIG_MOD = ""
var pointers = ModLoader._savedObjects[0]

var loaded_scene = null

func _ready():
	var path = CONFIG_DATA.get("scene_path","")
	if pointers.DataFormat.__load_if_can(path):
		var scene:PackedScene = pointers.DataFormat.__get_load()
		if scene and scene.can_instance():
			loaded_scene = scene.instance()
			if "display_container" in loaded_scene:
				loaded_scene.display_container = self
			$LMARGIN.rect_min_size.x = CONFIG_DATA.get("left_margin",15)
			$RMARGIN.rect_min_size.x = CONFIG_DATA.get("right_margin",15)
			$MarginContainer.add_child(loaded_scene)
		else:
			var logErr = "ERROR: Display panel cannot instance scene from file [%]" % path
			printerr(logErr)
			pointers.l(logErr,"Mod Menu 2 Settings Panel")
			get_parent().remove_child(self)
			Tool.remove(self)
	add_to_group("hevlib_settings_tab",true)

func get_focusable(direction = 0):
	if loaded_scene and loaded_scene.has_method("get_focusable"):
		return loaded_scene.get_focusable(direction)
	if direction == 0:
		printerr("Focusable fetch direction for [%s] is zero, and it shouldn't be" % ("%s|%s" % [str(self),get_path()]))
	else:
		var pos = get_position_in_parent()
		var repos = clamp(pos + direction,0,get_parent().get_child_count() - 1)
		if repos == 0:
			var change = get_parent().get_child(clamp(pos - direction,0,get_parent().get_child_count() - 1))
			if change and not change == self and change.has_method("get_focusable"):
				return change.get_focusable(direction)
		else:
			var change = get_parent().get_child(repos)
			if change and not change == self and change.has_method("get_focusable"):
				return change.get_focusable(direction)
	return

func get_label(direction = 0):
	if loaded_scene and loaded_scene.has_method("get_label"):
		return loaded_scene.get_label(direction)
	if direction == 0:
		printerr("Label fetch direction for [%s] is zero, and it shouldn't be" % ("%s|%s" % [str(self),get_path()]))
	else:
		var pos = get_position_in_parent()
		var repos = clamp(pos + direction,0,get_parent().get_child_count() - 1)
		if repos == 0:
			var change = get_parent().get_child(clamp(pos - direction,0,get_parent().get_child_count() - 1))
			if change and not change == self and change.has_method("get_label"):
				return change.get_label(direction)
		else:
			var change = get_parent().get_child(repos)
			if change and not change == self and change.has_method("get_label"):
				return change.get_label(direction)
	return

func get_reset(direction = 0):
	if loaded_scene and loaded_scene.has_method("get_reset"):
		return loaded_scene.get_reset(direction)
	if direction == 0:
		printerr("Reset fetch direction for [%s] is zero, and it shouldn't be" % ("%s|%s" % [str(self),get_path()]))
	else:
		var pos = get_position_in_parent()
		var repos = clamp(pos + direction,0,get_parent().get_child_count() - 1)
		if repos == 0:
			var change = get_parent().get_child(clamp(pos - direction,0,get_parent().get_child_count() - 1))
			if change and not change == self and change.has_method("get_reset"):
				return change.get_reset(direction)
		else:
			var change = get_parent().get_child(repos)
			if change and not change == self and change.has_method("get_reset"):
				return change.get_reset(direction)
	return
