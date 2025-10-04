extends Popup

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

var ConfigDriver = preload("res://HevLib/pointers/ConfigDriver.gd")

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
	
	var n = ConfigDriver.__get_value(mod,section,action)
	n.erase(key)
	ConfigDriver.__store_value(mod,section,action,n)
	remakeActionButtons()

func remakeActionButtons():
	for k in keybox.get_children():
		k.queue_free()
		
	var actions = ConfigDriver.__get_value(mod,section,action)
	
	
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
	remakeActionButtons()
	store = ConfigDriver.__get_value(mod,section,action)

var capturing = false

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if capturing:
			stopCapturing()
		else:
			hide()
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
				var ent = ConfigDriver.__get_value(mod,section,action)
				if not ent.has(key):
					ent.append(key)
					ConfigDriver.__store_value(mod,section,action,ent)
					remakeActionButtons()
			
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
	ConfigDriver.__store_value(mod,section,action,store)
	Settings.applySettings()
	hide()
	
func _on_Ok_pressed():
	
	stopCapturing()
	get_tree().call_group("hevlib_settings_tab","recheck_availability")
	Settings.applySettings()
	hide()


func _on_CaptureKeyDialog_focus_entered():
	remakeActionButtons()


func _on_CaptureKeyDialog_visibility_changed():
	mod = hbttn.mod
	section = hbttn.section
	action = hbttn.action
	
	set_process_input(is_visible_in_tree())
