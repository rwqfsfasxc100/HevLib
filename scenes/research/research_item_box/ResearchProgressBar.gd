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

extends MarginContainer

var source = ""

signal storyFlag(flag,val)

export (String, "story", "payment", "time","total") var mode = "story"
export (String) var tooltip_text = ""
export (bool) var reset_on_halt = false

export (String) var story_flag = ""
export (int) var story_min = 0
export (int) var story_max = 1000

export (int) var amount = 100000

export (int) var minutes = 0
export (int) var hours = 0
export (int) var days = 0
export (int) var months = 0
export (int) var years = 0

var parent

var is_total = false

onready var progress_bar = $ProgressBar

func _ready():
	$Button.connect("pressed",self,"_pressed")
	$ProgressBar.connect("value_changed",self,"_on_value_changed")
	$Button.hint_tooltip = tooltip_text
	match mode:
		"story_only":
			progress_bar.min_value = story_min
			progress_bar.max_value = story_max
			progress_bar.step = 1
		"payment":
			progress_bar.min_value = 0
			progress_bar.max_value = amount
			progress_bar.step = 1
		"time":
			progress_bar.min_value = 0
			progress_bar.max_value = Time.get_unix_time_from_datetime_dict(handle_time({"year":years,"month":months,"day":days,"hour":hours,"minute":minutes,"second":0}))
			if minutes:
				progress_bar.step = 60
	
	connect("visibility_changed",self,"vis_changed")
	
	if story_flag == "":
		Tool.remove(self)

func vis_changed():
	if is_visible_in_tree():
		set_progress()
var pointers = ModLoader._savedObjects[0]

func handle_time(datetime_dict : Dictionary):
	var new_time = Time.get_datetime_dict_from_unix_time(CurrentGame.state.time + pointers.TimeAccess.__get_time_in_seconds(datetime_dict))
	return new_time


func set_progress():
	var val = getStory(story_flag)
	match mode:
		"story_only":
			progress_bar.value = clamp(val,story_min,story_max)
			if is_total and val >= story_max:
				parent.mark_for_completion = true
		"payment":
			pass
		"time":
			pass
		"total":
			pass
	

func _on_value_changed(how:float):
	var value = int(clamp(round(how / (story_max - story_min)),0,1) * 100)
	$Button.text = "%d%%" % value





func getStory(story):
	return int(CurrentGame.state.story.get(story, -1))


func _pressed():
	if is_total:
		emit_signal("storyFlag",story_flag,getStory(story_flag))
