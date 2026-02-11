extends ProgressBar

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
onready var pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")
#const TimeAccess = preload("res://HevLib/pointers/TimeAccess.gd")

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
