extends Popup

export var offset = Vector2(12,12)

func clear():
	$base/PanelContainer/VBoxContainer/VBoxContainer/ChangelogDisplay.clear()

func update_this(path):
	$base/PanelContainer/VBoxContainer/VBoxContainer/ChangelogDisplay.clear_and_update(path)

func _ready():
	connect("about_to_show",self,"_about_to_show")
	connect("visibility_changed",self,"_on_resize")

func _about_to_show():
	lastFocus = get_focus_owner()
	$base/PanelContainer/VBoxContainer/FooterButtons/Close.grab_focus()

func show_menu():
	popup()

func cancel():
	$AnimateAppear.play("hider")
func hider():
	hide()
	refocus()

var lastFocus = null
func refocus():
	if lastFocus and lastFocus.has_method("grab_focus"):
		lastFocus.grab_focus()
	else:
		Debug.l("I have no focus to fall back to!")

func _unhandled_input(event):
	if visible and Input.is_action_just_pressed("ui_cancel"):
		cancel()
		get_tree().set_input_as_handled()

func _on_resize():
	if is_visible_in_tree():
		var size = Settings.getViewportSize()
		var offsetSize = size - offset
		var vbsize = offsetSize - Vector2(10,10)
		rect_size = size
#		$ColorRect.rect_min_size = size
		$ColorRect.rect_size = size
#		$base.rect_min_size = offsetSize
		$base.rect_size = offsetSize
		$base.rect_position = offset/2
		$base/PanelContainer.rect_size = offsetSize
		$base/PanelContainer/VBoxContainer.rect_position = Vector2(5,5)
		$base/PanelContainer/VBoxContainer.rect_size = vbsize
		
	
