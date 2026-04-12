extends ScrollContainer

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
