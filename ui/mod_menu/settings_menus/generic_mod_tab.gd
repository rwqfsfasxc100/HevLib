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

extends Tabs

export var mod = ""
export var mod_id = ""
var pointers = ModLoader._savedObjects[0]

const tab_base = preload("res://HevLib/ui/mod_menu/settings_menus/generic_section_tab.tscn")

onready var container = $MarginContainer/TabContainer

func _ready():
	name = mod
	var data = pointers.ConfigDriver.__get_config(mod)
	var mdata = pointers.ManifestV2.__get_mod_by_id(mod_id)["manifest"]["manifest_data"].get("configs",{})
	
	for section in mdata:
		var sec_data = mdata[section]
		var tab = tab_base.instance()
		tab.name = section
		tab.section_info = sec_data
		tab.section_values = data[section]
		tab.mod = mod
		container.add_child(tab)
		yield(get_tree(),"idle_frame")
		pass
	
#func _process(_delta):
func _draw():
	$MarginContainer.rect_size = rect_size
	
	name = mod

#func _gui_input(event):
#	var this_pos = get_position_in_parent()
#	if get_parent().current_tab == this_pos:
#		if event.is_action_pressed("ui_page_up"):
#			var subtab_count = container.get_child_count()
#			if current_tab != 0:
#				current_tab -= 1
#			else:
#				if not this_pos == 0:
#					get_parent().current_tab -= 1
#
#		if event.is_action_pressed("ui_page_down"):
#			var subtab_count = container.get_child_count()
#			if current_tab != subtab_count - 1:
#				current_tab += 1
#			else:
#				if not this_pos == get_parent().get_child_count() - 1:
#					get_parent().current_tab += 1
	
