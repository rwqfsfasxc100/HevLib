extends Button

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

export  var focusColor = Color(2, 2, 2, 1)
export  var mouseColor = Color(0.8, 0.8, 0.8, 1)
export  var normalColor = Color(0.5, 0.5, 0.5, 1)

export  var action = "ship_main_engine"

export var mod = ""
export var section = "input"

var focused = false
var moused = false

onready var initialModulate = modulate

var always_binds = [  ]

func _ready():
	var pv = get_parent().get_parent()
	mod = pv.CONFIG_MOD
	section = pv.CONFIG_SECTION
	action = pv.CONFIG_ENTRY
	connect("focus_entered", self, "_on_focus_entered")
	connect("focus_exited", self, "_on_focus_exited")
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	setColor()
	for c in $Center.get_children():
		if "action" in c:
			c.action = action
	setColor()

func _on_CaptureKeyDialog_popup_hide():
	grab_focus()
func setColor():
	modulate = initialModulate
	if focused:
		self_modulate = focusColor
	else:
		if moused:
			self_modulate = mouseColor
		else:
			self_modulate = normalColor

func _on_focus_entered():
	focused = true
	setColor()

func _on_focus_exited():
	focused = false
	setColor()
	
func _on_mouse_entered():
	moused = true
	setColor()
	
func _on_mouse_exited():
	moused = false
	setColor()


func _visibility_changed():
	mod = get_parent().get_parent().CONFIG_MOD
	section = get_parent().get_parent().CONFIG_SECTION
	action = get_parent().get_parent().CONFIG_ENTRY
