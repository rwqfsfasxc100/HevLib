extends PanelContainer

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

var pointers = ModLoader._savedObjects[0]
var filter_box_nd = preload("res://HevLib/ui/mod_menu/filters/FilterBox.tscn")

var tags = pointers.ManifestV2.__get_tags()

var tag_visibility = {}

var mod_visibility = []

var filtering = false

func _ready():
	for tag in tags:
		var node = filter_box_nd.instance()
		node.name = tag
		node.get_node("P/Label").text = tag
		node.get_node("CheckButton").pressed = true
		$VBoxContainer/ScrollContainer/VBoxContainer.add_child(node)
		tag_visibility.merge({tag:false})
	

func update_filters(tag,change):
	tag_visibility[tag] = change
	mod_visibility = []
	var currently_filtering_tags = []
	var has_filters = false
	for t in tag_visibility:
		if tag_visibility[t] == true:
			has_filters = true
			currently_filtering_tags.append(t)
	if has_filters:
		filtering = true
	else:
		filtering = false
	for tag in currently_filtering_tags:
		var mods = tags[tag]
		for mod in mods:
			if mod in mod_visibility:
				pass
			else:
				mod_visibility.append(mod)
