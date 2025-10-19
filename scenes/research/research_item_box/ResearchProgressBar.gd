extends ProgressBar

var source = ""

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

func _ready():
	match mode:
		"story":
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

const TimeAccess = preload("res://HevLib/pointers/TimeAccess.gd")

func handle_time(datetime_dict : Dictionary):
	var new_time = Time.get_datetime_dict_from_unix_time(CurrentGame.state.time + TimeAccess.__get_time_in_seconds(datetime_dict))
	return new_time


func set_progress():
	var val = getStory(story_flag)
#	breakpoint
	match mode:
		"story":
			value = clamp(val, story_min,story_max)
		"payment":
			pass
		"time":
			pass
		"total":
			pass







func getStory(story):
	return int(CurrentGame.state.story.get(story, -1))
