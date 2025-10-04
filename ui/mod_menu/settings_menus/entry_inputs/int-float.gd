extends HBoxContainer

var CONFIG_DATA = {}

var CONFIG_ENTRY = ""

var CONFIG_SECTION = ""

var CONFIG_MOD = ""

const ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")

export (String,"slider","spinbox") var style = "slider"

export (String,"int","float") var val_type = "int"

onready var slider = $slider
onready var label = $Label
onready var spinbox = $spinbox
onready var SliderLabel = $SliderLabel

func _ready():
	var value = ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
	if value == null:
		Tool.remove(self)
	label.text = CONFIG_DATA.get("name","BOOL_MISSING_NAME")
	
	style = CONFIG_DATA.get("style","slider")
	var minimum = float(CONFIG_DATA.get("min",0.0))
	var maximum = float(CONFIG_DATA.get("max",10.0))
	var step = float(CONFIG_DATA.get("step",1.0))
	slider.min_value = minimum
	slider.max_value = maximum
	slider.step = step
	spinbox.min_value = minimum
	spinbox.max_value = maximum
	spinbox.step = step
	match val_type:
		"int":
			slider.rounded = true
			spinbox.rounded = true
			value = round(value)
		"float":
			slider.rounded = false
			spinbox.rounded = false
	
	if style == "slider":
		spinbox.visible = false
		slider.visible = true
		SliderLabel.visible = true
	elif style == "spinbox":
		spinbox.visible = true
		slider.visible = false
		SliderLabel.visible = false
	slider.value = value
	spinbox.value = value
	SliderLabel.text = str(value)
	$Label/LABELBUTTON.hint_tooltip = CONFIG_DATA.get("description","")

func _reset_pressed():
	var val = CONFIG_DATA.get("default",10.0)
	slider.value = val
	spinbox.value = val
	SliderLabel.text = str(val)
	ConfigDriver.__store_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY,val)
	match style:
		"slider":
			slider.grab_focus()
		"spinbox":
			spinbox.grab_focus()
func _draw():
	
	refocus()

func refocus():
	$Label/LABELBUTTON.rect_size = $Label.rect_size
	if style == "slider":
		spinbox.visible = false
		slider.visible = true
		SliderLabel.visible = true
	elif style == "spinbox":
		spinbox.visible = true
		slider.visible = false
		SliderLabel.visible = false
	ConfigDriver.__set_button_focus(self,get_node(style))
	

func _value_changed(value):
	ConfigDriver.__store_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY,value)
	SliderLabel.text = str(value)
	refocus()


func _visibility_changed():
	refocus()



func _process(_delta):
	var v = ConfigDriver.__get_value(CONFIG_MOD,CONFIG_SECTION,CONFIG_ENTRY)
	slider.set("value" , float(v))
	SliderLabel.text = str(v)
	spinbox.set("value" , float(v))
	if v != CONFIG_DATA.get("default",10.0):
		$reset.visible = true
	else:
		$reset.visible = false
	var requirements = PoolStringArray(CONFIG_DATA.get("requires_bools",[]))
	if requirements.size() >= 1:
		var show = true
		var valid_options = 0
		var true_valids = 0
		var flip = CONFIG_DATA.get("invert_bool_requirement",false)
		for option in requirements:
			
			var split = option.split("/")
			if split.size() == 3:
				var value = ConfigDriver.__get_value(split[0],split[1],split[2])
				if typeof(value) == TYPE_BOOL:
					valid_options += 1
					if value == true:
						true_valids += 1
		if valid_options >= 1:
			if flip:
				if true_valids >= 1:
					$reset.modulate = Color(0.6,0.6,0.6,1)
					$reset.disabled = true
					slider.modulate = Color(0.6,0.6,0.6,1)
					SliderLabel.modulate = Color(0.6,0.6,0.6,1)
					slider.editable = false
					spinbox.modulate = Color(0.6,0.6,0.6,1)
					spinbox.editable = false
				else:
					$reset.modulate = Color(1,1,1,1)
					$reset.disabled = false
					slider.modulate = Color(1,1,1,1)
					SliderLabel.modulate = Color(1,1,1,1)
					slider.editable = true
					spinbox.modulate = Color(1,1,1,1)
					spinbox.editable = true
			else:
				if true_valids >= 1:
					$reset.modulate = Color(1,1,1,1)
					$reset.disabled = false
					slider.modulate = Color(1,1,1,1)
					SliderLabel.modulate = Color(1,1,1,1)
					slider.editable = true
					spinbox.modulate = Color(1,1,1,1)
					spinbox.editable = true
				else:
					$reset.modulate = Color(0.6,0.6,0.6,1)
					$reset.disabled = true
					slider.modulate = Color(0.6,0.6,0.6,1)
					SliderLabel.modulate = Color(0.6,0.6,0.6,1)
					slider.editable = false
					spinbox.modulate = Color(0.6,0.6,0.6,1)
					spinbox.editable = false
	else:
		$reset.modulate = Color(1,1,1,1)
		$reset.disabled = false
		slider.modulate = Color(1,1,1,1)
		SliderLabel.modulate = Color(1,1,1,1)
		slider.editable = true
		spinbox.modulate = Color(1,1,1,1)
		spinbox.editable = true

func _input(event):
	if slider.has_focus():
		var action_passed = false
		var val = 0
		var step = 0
		match val_type:
			"int":
				val = round(slider.value)
				step = round(slider.step)
			"float":
				val = float(slider.value)
				step = float(slider.step)
		if event.is_action_pressed("ui_left"):
			if not slider.allow_lesser:
				if val > slider.min_value:
					slider.value = val - step
					action_passed = true
			else:
				slider.value = val - step
				action_passed = true
		if event.is_action_pressed("ui_right"):
			if not slider.allow_greater:
				if val < slider.max_value:
					slider.value = val + step
					action_passed = true
			else:
				slider.value = val + step
				action_passed = true
		if action_passed:
			get_viewport().set_input_as_handled()
			$Timer.start()


func _timeout():
	slider.grab_focus()
