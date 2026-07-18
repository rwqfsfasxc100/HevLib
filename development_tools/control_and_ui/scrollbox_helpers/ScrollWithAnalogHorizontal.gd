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

extends ScrollContainer

# Horizontal equivalent to "res://enceladus/ScrollWithAnalog.gd"

export  var minSpeed = 0.1
export  var scrollSpeed = 800.0
export  var smoothScrollSpeed = 5.0
var smoothScrollTo = null
var speed = 0
var supressScroll = false
onready var scrollFloat = float(scroll_horizontal)
export  var growBottom = false
export  var absoluteBottom = false

onready var scrollbar = get_h_scrollbar()
onready var scrollMax = scrollbar.max_value
export  var scrollWithGamepad = true

func skipToEnd():
	if growBottom:
		if absoluteBottom:
			if scrollbar.max_value != scrollMax:
				scroll_horizontal = scrollbar.max_value
				scrollMax = scrollbar.max_value
		else:
			var d = scrollbar.max_value - scrollMax
			if d > 0:
				scroll_horizontal += d
			scrollMax = scrollbar.max_value

func _ready():
	connect("scroll_started", self, "scrollStarted")
	scrollbar.connect("changed", self, "skipToEnd")
	
	for i in get_children():
		if i is Container:
			if i.has_signal("newChild"):
				i.connect("newChild", self, "scrollTo")
				break

func _process(delta):
	delta /= Engine.time_scale
	if abs(float(scroll_horizontal) - scrollFloat) > 2:
		scrollFloat = float(scroll_horizontal)
		set_process(false)
		smoothScrollTo = null
	else:
		scrollFloat += speed * delta * scrollSpeed
		if smoothScrollTo != null:
			scrollFloat = lerp(scrollFloat, smoothScrollTo, clamp(delta * smoothScrollSpeed, 0, 1))
			if abs(scrollFloat - smoothScrollTo) < 1:
				set_process(false)
				smoothScrollTo = null
		else:
			if speed == 0:
				set_process(false)
		scroll_horizontal = int(scrollFloat)
		

func _input(event):
	if scrollWithGamepad:
		if Settings.controlScheme == Settings.control.gamepad or Settings.controlScheme == Settings.control.auto:
			var up = Input.get_action_strength("ui_scroll_left", true) + Input.get_action_strength("ui_scroll_left2", true)
			var down = Input.get_action_strength("ui_scroll_right", true) + Input.get_action_strength("ui_scroll_right2", true)
			speed = down - up
			if abs(speed) > minSpeed and is_visible_in_tree():
				set_process(true)
				smoothScrollTo = null
	if event is InputEventMouseButton:
		supressScroll = event.pressed
	

func scrollTo(item):
	if not supressScroll:
		follow_focus = false
		var p = item.get_global_transform().origin - get_global_transform().origin
		if item.rect_size.x > 1 and item.rect_size.x < rect_size.x:
			var ys = (rect_size.x - item.rect_size.x) / 2
			smoothScrollTo = p.x - ys + scroll_horizontal
			if is_visible_in_tree():
				set_process(true)
			else:
				scrollFloat = smoothScrollTo
				scroll_horizontal = int(scrollFloat)
