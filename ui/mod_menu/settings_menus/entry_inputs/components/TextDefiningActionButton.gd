extends Button


export  var focusColor = Color(2, 2, 2, 1)
export  var mouseColor = Color(0.8, 0.8, 0.8, 1)
export  var normalColor = Color(0.5, 0.5, 0.5, 1)

export  var action = "ship_main_engine"

export var mod = ""
export var section = "input"

var focused = false
var moused = false

onready var initialModulate = modulate

func _ready():
	mod = get_parent().get_parent().CONFIG_MOD
	section = get_parent().get_parent().CONFIG_SECTION
	action = get_parent().get_parent().CONFIG_ENTRY
	connect("focus_entered", self, "_on_focus_entered")
	connect("focus_exited", self, "_on_focus_exited")
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	setColor()
	for c in $Center.get_children():
		if "action" in c:
			c.action = action
	setColor()

func _on_CaptureKeyDialog_popup_hide():
	grab_focus()
func setColor():
	modulate = initialModulate
	if focused:
		self_modulate = focusColor
	else:
		if moused:
			self_modulate = mouseColor
		else:
			self_modulate = normalColor

func _on_focus_entered():
	focused = true
	setColor()

func _on_focus_exited():
	focused = false
	setColor()
	
func _on_mouse_entered():
	moused = true
	setColor()
	
func _on_mouse_exited():
	moused = false
	setColor()


func _visibility_changed():
	mod = get_parent().get_parent().CONFIG_MOD
	section = get_parent().get_parent().CONFIG_SECTION
	action = get_parent().get_parent().CONFIG_ENTRY
