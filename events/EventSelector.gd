extends ScrollContainer

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

onready var ring = get_node("/root/Game/TheRing")
var pointers = ModLoader._savedObjects[0]

var all_events = {}

#func _process(delta):
#	get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().selected_events = all_events
onready var list = $VBoxContainer
onready var enableAllButton = get_node_or_null(NodePath("../HBoxContainer/EnableAll"))
onready var disableAllButton = get_node_or_null(NodePath("../HBoxContainer/DisableAll"))
func _ready():
	enableAllButton.connect("pressed",self,"enableAll")
	disableAllButton.connect("pressed",self,"disableAll")
	
#	var de = ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_EVENTS","disabled_events")
#	if de == null:
#		
	var disabled_events = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_EVENTS","disabled_events")
	if disabled_events == null:
		pointers.ConfigDriver.__store_value("HevLib","HEVLIB_CONFIG_SECTION_EVENTS","disabled_events",[])
		disabled_events = []
	var event_names = []
	for item in ring.get_children():
		event_names.append(item.name)
	var events = event_names
	for evnt in events:
		var does = true
		if evnt in disabled_events:
			does = false
		var edict = {evnt:does}
		all_events.merge(edict)
	var selector_button = load("res://HevLib/events/EventSelector.tscn")
	for event in all_events:
		var btn = selector_button.instance()
		if event in disabled_events:
			btn.pressed = false
		btn.text = event
		btn.name = event
		btn.event = event
		list.add_child(btn)

func enableAll():
	for c in list.get_children():
		c.pressed = true
	pointers.ConfigDriver.__store_value("HevLib","HEVLIB_CONFIG_SECTION_EVENTS","disabled_events",[])
func disableAll():
	var arr = []
	for c in list.get_children():
		c.pressed = false
		arr.append(c.event)
	pointers.ConfigDriver.__store_value("HevLib","HEVLIB_CONFIG_SECTION_EVENTS","disabled_events",arr)
