extends ScrollContainer

export var use_horizontal = true
export var use_vertical = true

# Input control types
export  var scrollWithGamepad = true
export var scrollWithKeyboard = false

# Horizontal control variables
export  var minHorizontalSpeed = 0.1
export  var horizontalScrollSpeed = 800.0
export  var horizontalSmoothScrollSpeed = 5.0
export  var growHorizontalBottom = false
export  var absoluteHorizontalBottom = false
onready var horizontalScrollFloat = float(scroll_horizontal)
var hspeed = 0
onready var hscrollbar = get_h_scrollbar()
onready var hscrollMax = hscrollbar.max_value

# Vertical control variables
export  var minVerticalSpeed = 0.1
export  var verticalScrollSpeed = 800.0
export  var verticalSmoothScrollSpeed = 5.0
export  var growVerticalBottom = false
export  var absoluteVerticalBottom = false
onready var verticalScrollFloat = float(scroll_vertical)
var vspeed = 0
onready var vscrollbar = get_v_scrollbar()
onready var vscrollMax = vscrollbar.max_value

export var left_stick_scroll_enabled = true
export var right_stick_scroll_enabled = true

var supressScroll = false
var smoothScrollToHorizontal = null
var smoothScrollToVertical = null


func skipToEnd():
	# Horizontal handler
	if use_horizontal:
		if growHorizontalBottom:
			if absoluteHorizontalBottom:
				if hscrollbar.max_value != hscrollMax:
					scroll_horizontal = hscrollbar.max_value
					hscrollMax = hscrollbar.max_value
			else:
				var d = hscrollbar.max_value - hscrollMax
				if d > 0:
					scroll_horizontal += d
				hscrollMax = hscrollbar.max_value
	# Vertical handler
	if use_vertical:
		if growVerticalBottom:
			if absoluteVerticalBottom:
				if vscrollbar.max_value != vscrollMax:
					scroll_vertical = vscrollbar.max_value
					vscrollMax = vscrollbar.max_value
			else:
				var d = vscrollbar.max_value - vscrollMax
				if d > 0:
					scroll_vertical += d
				vscrollMax = vscrollbar.max_value
var not_setup = true
func _ready():
	var connected = is_connected("scroll_started", self, "scrollStarted")
	if not connected:
		connect("scroll_started", self, "scrollStarted")
	scroll_horizontal_enabled = use_horizontal
	scroll_vertical_enabled = use_vertical
	
	if use_horizontal:
		horizontalScrollFloat = float(scroll_horizontal)
		hscrollbar = get_h_scrollbar()
		hscrollMax = hscrollbar.max_value
		if not hscrollbar.is_connected("changed", self, "skipToEnd"):
			hscrollbar.connect("changed", self, "skipToEnd")
	if use_vertical:
		verticalScrollFloat = float(scroll_vertical)
		vscrollbar = get_v_scrollbar()
		vscrollMax = vscrollbar.max_value
		if not vscrollbar.is_connected("changed", self, "skipToEnd"):
			vscrollbar.connect("changed", self, "skipToEnd")
	
	not_setup = false
	for i in get_children():
		if i is Container:
			if i.has_signal("newChild"):
				i.connect("newChild", self, "scrollTo")
				break
func _process(delta):
	delta /= Engine.time_scale
	if not_setup:
		return
	# Horizontal
	if use_horizontal:
		if abs(float(scroll_horizontal) - horizontalScrollFloat) > 2:
			horizontalScrollFloat = float(scroll_horizontal)
			set_process(false)
			smoothScrollToHorizontal = null
		else:
			horizontalScrollFloat += hspeed * delta * horizontalScrollSpeed
			if smoothScrollToHorizontal != null:
				horizontalScrollFloat = lerp(horizontalScrollFloat, smoothScrollToHorizontal, clamp(delta * horizontalSmoothScrollSpeed, 0, 1))
				if abs(horizontalScrollFloat - smoothScrollToHorizontal) < 1:
					set_process(false)
					smoothScrollToHorizontal = null
			else:
				if hspeed == 0:
					set_process(false)
			scroll_horizontal = int(horizontalScrollFloat)
	# Vertical
	if use_vertical:
		if abs(float(scroll_vertical) - verticalScrollFloat) > 2:
			verticalScrollFloat = float(scroll_vertical)
			set_process(false)
			smoothScrollToVertical = null
		else:
			verticalScrollFloat += vspeed * delta * verticalScrollSpeed
			if smoothScrollToVertical != null:
				verticalScrollFloat = lerp(verticalScrollFloat, smoothScrollToVertical, clamp(delta * verticalSmoothScrollSpeed, 0, 1))
				if abs(verticalScrollFloat - smoothScrollToVertical) < 1:
					set_process(false)
					smoothScrollToVertical = null
			else:
				if vspeed == 0:
					set_process(false)
			scroll_vertical = int(verticalScrollFloat)

func _input(event):
	# Vertical
	if use_vertical:
		if scrollWithGamepad:
			if Settings.controlScheme == Settings.control.gamepad or Settings.controlScheme == Settings.control.auto:
				var down = 0.0
				if left_stick_scroll_enabled:
					down += Input.get_action_strength("ui_scroll_down", true) 
				if right_stick_scroll_enabled:
					down += Input.get_action_strength("ui_scroll_down2", true)
				var up = 0.0
				if left_stick_scroll_enabled:
					up += Input.get_action_strength("ui_scroll_up", true) 
				if right_stick_scroll_enabled:
					up += Input.get_action_strength("ui_scroll_up2", true)
				vspeed = down - up
				if abs(vspeed) > minHorizontalSpeed and is_visible_in_tree():
					set_process(true)
					smoothScrollToVertical = null
		if scrollWithKeyboard:
			if Settings.controlScheme == Settings.control.keyMouse or Settings.controlScheme == Settings.control.auto:
				var down = Input.get_action_strength("ui_down", true)
				var up = Input.get_action_strength("ui_up", true)
				vspeed = down - up
				if abs(vspeed) > minHorizontalSpeed and is_visible_in_tree():
					set_process(true)
					smoothScrollToVertical = null
	# Horizontal
	if use_horizontal:
		if scrollWithGamepad:
			if Settings.controlScheme == Settings.control.gamepad or Settings.controlScheme == Settings.control.auto:
				var down = 0.0
				if left_stick_scroll_enabled:
					down += Input.get_action_strength("ui_scroll_left", true) 
				if right_stick_scroll_enabled:
					down += Input.get_action_strength("ui_scroll_left2", true)
				var up = 0.0
				if left_stick_scroll_enabled:
					up += Input.get_action_strength("ui_scroll_right", true) 
				if right_stick_scroll_enabled:
					up += Input.get_action_strength("ui_scroll_right2", true)
				hspeed = down - up
				if abs(hspeed) > minVerticalSpeed and is_visible_in_tree():
					set_process(true)
					smoothScrollToHorizontal = null
		if scrollWithKeyboard:
			if Settings.controlScheme == Settings.control.keyMouse or Settings.controlScheme == Settings.control.auto:
				var down = Input.get_action_strength("ui_left", true)
				var up = Input.get_action_strength("ui_right", true)
				hspeed = down - up
				if abs(hspeed) > minVerticalSpeed and is_visible_in_tree():
					set_process(true)
					smoothScrollToHorizontal = null
	if event is InputEventMouseButton:
		supressScroll = event.pressed

func scrollTo(item):
	if not supressScroll:
		follow_focus = false
		var p = item.get_global_transform().origin - get_global_transform().origin
		# Horizontal
		if use_horizontal:
			if item.rect_size.x > 1 and item.rect_size.x < rect_size.x:
				var ys = (rect_size.x - item.rect_size.x) / 2
				smoothScrollToHorizontal = p.x - ys + scroll_horizontal
				if is_visible_in_tree():
					set_process(true)
				else:
					horizontalScrollFloat = smoothScrollToHorizontal
					scroll_horizontal = int(horizontalScrollFloat)
		# Vertical
		if use_vertical:
			if item.rect_size.y > 1 and item.rect_size.y < rect_size.y:
				var ys = (rect_size.y - item.rect_size.y) / 2
				smoothScrollToVertical = p.y - ys + scroll_vertical
				if is_visible_in_tree():
					set_process(true)
				else:
					verticalScrollFloat = smoothScrollToVertical
					scroll_vertical = int(verticalScrollFloat)



