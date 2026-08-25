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

extends Button

export var URL = "https://example.com"

export var static_link = true

export var icon_path = NodePath("icon")

export (float) var scale_factor = 1.0

export (String, "github", "discord","nexus","donations","wiki","bug_reports","custom_links")var dynamic_mode = "github" 

func _ready():
	var ic = get_node(icon_path)
	transform(ic)

func transform(ic):
	ic.rect_size = self.rect_size
	ic.expand = true
	ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var size = ic.rect_size
	var newsize = size * scale_factor
	
	var ox = size.x
	var nx = newsize.x
	var oy = size.y
	var ny = newsize.y
	
	var xpos = ox-nx
	var ypos = oy-ny
	ic.rect_size = Vector2(nx,ny)
	ic.rect_position = Vector2(xpos/2,ypos/2)

func _visibility_changed():
	var ic = get_node(icon_path)
	var tex = StreamTexture.new()
	var fp = ""
	match dynamic_mode:
		"github":
			fp = "res://HevLib/ui/themes/icons/github.stex"
		"discord":
			fp = "res://HevLib/ui/themes/icons/discord.stex"
		"nexus":
			fp = "res://HevLib/ui/themes/icons/nexus.stex"
		"donations":
			fp = "res://HevLib/ui/themes/icons/donations.stex"
		"wiki":
			fp = "res://HevLib/ui/themes/icons/wiki.stex"
		"bug_reports":
			fp = ""
		"custom_links":
			fp = "res://HevLib/ui/themes/icons/custom.stex"
	if fp == "":
		fp = "res://HevLib/ui/themes/icons/file.stex"
	tex.load_path = fp
	ic.texture = tex
	transform(ic)
	$AnimationPlayer.play("draw")

func _pressed():
	if not static_link:
		pass
	
	
	OS.shell_open(URL)
