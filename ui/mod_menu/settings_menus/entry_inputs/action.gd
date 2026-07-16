extends HBoxContainer

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

var CONFIG_DATA = {}

var CONFIG_ENTRY = ""

var CONFIG_SECTION = ""

var CONFIG_MOD = ""
var pointers = ModLoader._savedObjects[0]

var script_path = ""

func _ready():
	$Label.text = CONFIG_DATA.get("name","ACTION_MISSING_NAME")
	$Label/LABELBUTTON.hint_tooltip = CONFIG_DATA.get("description","")
	script_path = CONFIG_DATA.get("script_path","")
	$ActionNode.set_script(load(script_path))
	$Button.text = CONFIG_DATA.get("button_label","")
	$Button.connect("pressed",$ActionNode,CONFIG_DATA.get("method","_pressed"))
	add_to_group("hevlib_settings_tab",true)

func _pressed():
	get_tree().call_group("hevlib_settings_tab","recheck_availability")

func recheck_availability():
	var requirements = PoolStringArray(CONFIG_DATA.get("requires_bools",[]))
	if requirements.size() >= 1:
		var show = true
		var valid_options = 0
		var true_valids = 0
		var flip = CONFIG_DATA.get("invert_bool_requirement",false)
		for option in requirements:
			
			var split = option.split("/")
			if split.size() == 3:
				var value = pointers.ConfigDriver.__get_value(split[0],split[1],split[2])
				if typeof(value) == TYPE_BOOL:
					valid_options += 1
					if value == true:
						true_valids += 1
		if valid_options >= 1:
			if flip:
				if true_valids >= 1:
					$Button.modulate = Color(0.6,0.6,0.6,1)
					$Button.disabled = true
				else:
					$Button.modulate = Color(1,1,1,1)
					$Button.disabled = false
			else:
				if true_valids >= 1:
					$Button.modulate = Color(1,1,1,1)
					$Button.disabled = false
				else:
					$Button.modulate = Color(0.6,0.6,0.6,1)
					$Button.disabled = true
	else:
		$Button.modulate = Color(1,1,1,1)
		$Button.disabled = false

func _draw():
	
	refocus()

func refocus():
	$Label/LABELBUTTON.rect_size = $Label.rect_size
#	get_tree().call_group("hevlib_settings_tab","recheck_availability")
	
	pointers.ConfigDriver.set_button_focus(self,get_node("Button"))
	

