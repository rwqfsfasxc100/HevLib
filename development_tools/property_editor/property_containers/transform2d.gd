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

tool
extends VBoxContainer

var emit_update_signal = false setget set_update_signal

func set_update_signal(how):
	$X/vec2.emit_update_signal = how
	$Y/vec2.emit_update_signal = how
	$ORIGIN/vec2.emit_update_signal = how
	emit_update_signal = how


signal changed()

func get_property_value():
	var X = $X/vec2.get_property_value()
	var Y = $Y/vec2.get_property_value()
	var O = $ORIGIN/vec2.get_property_value()
	var string = "Transform2D( %s , %s , %s )" % [X[1],Y[1],O[1]]
	return [Transform2D(X[0],Y[0],O[0]),string]

func set_property_value(property):
	if property is Transform2D:
		$X/vec2.set_property_value(property.x)
		$Y/vec2.set_property_value(property.y)
		$ORIGIN/vec2.set_property_value(property.origin)

func _ready():
	if not $ORIGIN/vec2.is_connected("changed",self,"_on_changed"):
		$ORIGIN/vec2.connect("changed",self,"_on_changed")
	if not $X/vec2.is_connected("changed",self,"_on_changed"):
		$X/vec2.connect("changed",self,"_on_changed")
	if not $Y/vec2.is_connected("changed",self,"_on_changed"):
		$Y/vec2.connect("changed",self,"_on_changed")

func _on_changed():
	if emit_update_signal:
		emit_signal("changed")
