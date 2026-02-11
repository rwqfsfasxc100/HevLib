extends Popup

onready var pointers = get_tree().get_root().get_node_or_null("HevLib~Pointers")

onready var keybox = $PanelContainer / MarginContainer / VBoxContainer / CK / Keys

onready var deleteButton = preload("res://menu/DeleteKeybind.tscn")
onready var addPlayer = $PanelContainer / MarginContainer / VBoxContainer / CenterContainer / Add / AnimationPlayer
onready var addButton = $PanelContainer / MarginContainer / VBoxContainer / CenterContainer / Add
var revert

export var button_path = NodePath("")
onready var hbttn = get_node(button_path)

onready var mod = hbttn.get_parent().get_parent().CONFIG_MOD
onready var section = hbttn.get_parent().get_parent().CONFIG_SECTION
onready var action = hbttn.get_parent().get_parent().CONFIG_ENTRY

#var ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")

func _exit_tree():
	deleteButton = null
	
func _ready():
	set_process_input(false)
	get_tree().get_root().connect("size_changed", self, "_on_resize")

func _on_resize():
	if visible:
		var viewportSize = get_parent().rect_size
		var size = rect_size
		rect_position = (viewportSize - size) / 2


func _on_ActionDefining_pressed():
	popup_centered()
	remakeActionButtons()
	
func _remove_key(key):
	
	var n = pointers.ConfigDriver.__get_value(mod,section,action)
	n.erase(key)
	pointers.ConfigDriver.__store_value(mod,section,action,n)
	remakeActionButtons()

func remakeActionButtons():
	for k in keybox.get_children():
		k.queue_free()
		
	var actions = pointers.ConfigDriver.__get_value(mod,section,action)
	
	
	for n in actions:
		var label = Label.new()
		label.text = n
		label.align = label.ALIGN_CENTER
		keybox.add_child(label)
		var rem = deleteButton.instance()
		keybox.add_child(rem)
		rem.connect("pressed", self, "_remove_key", [n])
		addButton.focus_neighbour_top = rem.get_path()
		
	
		
	
	addButton.visible = actions.size() < 5
	$PanelContainer / MarginContainer / VBoxContainer / CenterContainer2 / HBoxContainer / Ok.grab_focus()
		

var store = []
func _on_CaptureKeyDialog_about_to_show():
	lastFocus = get_focus_owner()
	remakeActionButtons()
	store = pointers.ConfigDriver.__get_value(mod,section,action)
var capturing = false

var lastFocus = null
func refocus():
	if lastFocus and lastFocus.has_method("grab_focus"):
		lastFocus.grab_focus()
	else:
		Debug.l("I have no focus to fall back to!")

func _input(event):
	if capturing and event is InputEventJoypadButton and event.button_index == 1:
		pass
	elif event.is_action_pressed("ui_cancel"):
		if capturing:
			stopCapturing()
		else:
			hide()
			refocus()
		get_tree().set_input_as_handled()
		return

	if capturing:
		if (event is InputEventKey or event is InputEventMouseButton) and event.is_pressed():
			get_tree().set_input_as_handled()
			var key = Settings.eventToString(event)
			if event is InputEventKey and event.scancode == KEY_ESCAPE:
				stopCapturing()
			else:
				stopCapturing()
				var ent = pointers.ConfigDriver.__get_value(mod,section,action)
				if not ent.has(key):
					ent.append(key)
					pointers.ConfigDriver.__store_value(mod,section,action,ent)
					remakeActionButtons()
		elif (event is InputEventJoypadButton or event is InputEventJoypadMotion) and event.is_pressed():
			get_tree().set_input_as_handled()
			var key = joyEventToString(event)
			if event is InputEventJoypadButton and event.button_index == JOY_BUTTON_11:
				stopCapturing()
			else:
				stopCapturing()
				var ent = pointers.ConfigDriver.__get_value(mod,section,action)
				if not ent.has(key):
					ent.append(key)
					pointers.ConfigDriver.__store_value(mod,section,action,ent)
					remakeActionButtons()
			

func joyEventToString(event):
	if event is InputEventJoypadButton:
		return "JoyButton %s" % event.button_index
	if event is InputEventJoypadMotion:
		return "JoyAxis %s" % [is_pos_or_neg(event) + str(event.axis)]
	

func is_pos_or_neg(event):
	var val = event.axis_value
	if val >= 0:
		return ""
	else:
		return "-"

func _on_Add_pressed():
	if capturing:
		stopCapturing()
	else:
		
		addPlayer.play("pulsing")
		capturing = true

func stopCapturing():
	addPlayer.stop()
	capturing = false
	addButton.setColor()


func _on_Cancel_pressed():
	stopCapturing()
	pointers.ConfigDriver.__store_value(mod,section,action,store)
	Settings.applySettings()
	hide()
	refocus()
func _on_Ok_pressed():
	
	stopCapturing()
	get_tree().call_group("hevlib_settings_tab","recheck_availability")
	Settings.applySettings()
	hide()
	refocus()

func _on_CaptureKeyDialog_focus_entered():
	remakeActionButtons()


func _on_CaptureKeyDialog_visibility_changed():
	mod = hbttn.mod
	section = hbttn.section
	action = hbttn.action
	
	set_process_input(is_visible_in_tree())
