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

extends VBoxContainer

var path = ""

const header_label = preload("res://HevLib/ui/mod_menu/changelogs/labels/version_label.tscn")
const entry_label = preload("res://HevLib/ui/mod_menu/changelogs/labels/changelog_entry.tscn")
const rich_entry_label = preload("res://HevLib/ui/mod_menu/changelogs/labels/rich_changelog_entry.tscn")
onready var linecontainer = $ScrollContainer/VBoxContainer
var pointers = ModLoader._savedObjects[0]
export (String,"singular","dynamic") var operation = "singular"

onready var LEFT = $PAGES/LEFT
onready var RIGHT = $PAGES/RIGHT

onready var pageBox = $PAGES

func _ready():
	LEFT.connect("pressed",self,"_left_pressed")
	RIGHT.connect("pressed",self,"_right_pressed")
	if operation == "singular" and path != "":
		rect_size = get_parent().rect_size
		linecontainer.rect_min_size = rect_size - Vector2(0,6)
		yield(CurrentGame.get_tree(),"idle_frame")
		parse()

var refs = []

var antispam = true
func _left_pressed():
	if antispam and current_page > 0:
		antispam = false
		current_page -= 1
		clear()
		if clearing:
			yield(self,"cleared")
		parse()
		yield(get_tree().create_timer(0.15),"timeout")
		antispam = true

func _right_pressed():
	if antispam:
		antispam = false
		current_page += 1
		clear()
		if clearing:
			yield(self,"cleared")
		parse()
		yield(get_tree().create_timer(0.15),"timeout")
		antispam = true

var clearing = false

export var page_size = 15
var current_page = 0
func parse():
	if not is_visible_in_tree():
		current_page = 0
	
	var data:Dictionary = pointers.ManifestV2.__parse_changelogs(path)
	
	var size = data.size()
	var offset = (current_page * page_size)
	var max_pages = int(ceil(float(size)/float(page_size))) - 1
	var keys = data.keys()
	LEFT.disabled = current_page < 1
	RIGHT.disabled = current_page > max_pages - 1
	for iv in range(clamp(size - offset,0,page_size)):
		var config = keys[iv + offset]
		var lines = data[config]
		var header = header_label.instance()
		header.text = config
		if not clearing:
			refs.append(header)
		linecontainer.add_child(header)
		for l in lines:
			var label = entry_label.instance()
			var tex = TranslationServer.translate(l)
			label.text = tex
			if not clearing:
				refs.append(label)
			linecontainer.add_child(label)
			yield(CurrentGame.get_tree(),"idle_frame")
		yield(CurrentGame.get_tree(),"idle_frame")

func _visibility_changed():
	yield(CurrentGame.get_tree(),"idle_frame")
	if is_visible_in_tree():
		var size = get_parent().rect_size
		rect_size = size
		$ScrollContainer.rect_min_size = rect_size - Vector2(12,6) - Vector2(0,pageBox.rect_size.y)
		linecontainer.rect_min_size = rect_size - Vector2(12,12) - Vector2(0,pageBox.rect_size.y)
	
signal cleared()
func clear_and_update(new):
	clear()
	if clearing:
		yield(self,"cleared")
	path = new
	
	parse()

func clear():
	if refs:
		clearing = true
		yield(CurrentGame.get_tree().create_timer(0.1),"timeout")
		for i in refs:
			Tool.remove(i)
		yield(CurrentGame.get_tree(),"idle_frame")
	clearing = false
	emit_signal("cleared")
