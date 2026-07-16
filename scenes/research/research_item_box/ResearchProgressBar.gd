extends ProgressBar

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

func _ready():
	$Button.hint_tooltip = tooltip_text
	match mode:
		"story_only":
			min_value = story_min
			max_value = story_max
			step = 1
		"payment":
			min_value = 0
			max_value = amount
			step = 1
		"time":
			min_value = 0
			max_value = Time.get_unix_time_from_datetime_dict(handle_time({"year":years,"month":months,"day":days,"hour":hours,"minute":minutes,"second":0}))
			if minutes:
				step = 60
	
	
	
	if story_flag == "":
		Tool.remove(self)

func _process(delta):
	if is_visible_in_tree():
		set_progress()
var pointers = ModLoader._savedObjects[0]

func handle_time(datetime_dict : Dictionary):
	var new_time = Time.get_datetime_dict_from_unix_time(CurrentGame.state.time + pointers.TimeAccess.__get_time_in_seconds(datetime_dict))
	return new_time


func set_progress():
	var val = getStory(story_flag)
	$Button.rect_size = rect_size - Vector2(4,0)
#	breakpoint
	match mode:
		"story_only":
			value = clamp(val, story_min,story_max)
			if is_total and val >= story_max:
				parent.mark_for_completion = true
		"payment":
			pass
		"time":
			pass
		"total":
			pass







func getStory(story):
	return int(CurrentGame.state.story.get(story, -1))


func _pressed():
	if is_total:
		emit_signal("storyFlag",story_flag,getStory(story_flag))
