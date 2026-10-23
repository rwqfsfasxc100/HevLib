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
# 4. The source code and the binary form, and any modifications made to them may not be used for the purpose of input data, reference code snippets and/or files, OR used in the training of, or improvement of machine learning algorithms,
# including but not limited to artificial intelligence, natural language processing, or data mining. This condition applies to any derivatives,
# modifications, or updates based on the Software code. Any usage of the source code or the binary form may not be present in any form as data fed, inputted, or provided to an AI, or present in any AI-training dataset is considered a breach of this License.
# 
# 5. Any projects deriving work from this project MUST include a copy of this license and all other license and/or copyright agreements posed within other source material,
# all of which must be followed to its entirety. Failure to follow these licenses prohibit all modification and redistribution of the material until all licensing has been reinstated.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# [/license]

extends "res://hud/OMS.gd"

onready var geo = $MarginContainer/VBoxContainer/TabHintContainer/TabContainer/CREW_OCCUPATION_GEOLOGIST
onready var mineral = geo.get_node("SystemMineralList")
onready var scroll = load("res://HevLib/development_tools/control_and_ui/scrollbox_helpers/ScrollWithAnalogHorizontal.gd").new()

onready var mechanic = $MarginContainer/VBoxContainer/TabHintContainer/TabContainer/CREW_OCCUPATION_MECHANIC
onready var mlist = mechanic.get_node("ScrollContainer")

var hl_omswidthsliderhandle_uinit : bool = false
func _ready():
	if hl_omswidthsliderhandle_uinit:
		OS.kill(OS.get_process_id())
	hl_omswidthsliderhandle_uinit = true
	scroll.rect_size = geo.rect_size
	scroll.size_flags_vertical = SIZE_EXPAND_FILL
	geo.add_child(scroll)
	geo.remove_child(mineral)
	mineral.size_flags_vertical = SIZE_FILL
	scroll.add_child(mineral)
	
	var cargo = geo.get_node(NodePath("MarginContainer/Cargo Panel"))
	var vb2 = cargo.get_node(NodePath("VBoxContainer2"))
	var rrect = vb2.rect_size
	var hb = HBoxContainer.new()
	cargo.remove_child(vb2)
	cargo.add_child(hb)
	cargo.move_child(hb,0)
	var vb = VBoxContainer.new()
	var l1 = vb2.get_node("Label List")
	var l2 = vb2.get_node("CargoManifest")
	vb2.remove_child(l1)
	vb2.remove_child(l2)
	vb.add_child(l1)
	vb.add_child(l2)
	hb.add_child(vb)
	hb.rect_size = rrect
	hb.size_flags_horizontal = SIZE_EXPAND_FILL
	var splitter = VBoxContainer.new()
	splitter.rect_min_size = Vector2(5,0)
	hb.add_child(splitter)
	hb.add_child(vb2)
	mlist.set_script(load("res://HevLib/development_tools/control_and_ui/scrollbox_helpers/OmniScroll.gd"))
	mlist.follow_focus = true
	mlist.scrollWithGamepad = false
	mlist.horizontalSmoothScrollSpeed = 25
	mlist.verticalSmoothScrollSpeed = 25
	mlist.call("_ready")

func _process(delta):
	if scroll:
		scroll.rect_size.y = mineral.rect_size.y + 20
