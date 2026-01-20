extends Popup

var SELECTED_MOD = ""
var SELECTED_MOD_ID = ""

onready var container = $base/TabContainer

var offset = Vector2(12,12)

const mod_tab = preload("res://HevLib/ui/mod_menu/settings_menus/generic_mod_tab.tscn")

func _about_to_show():
	for child in container.get_children():
		Tool.remove(child)
	
	if SELECTED_MOD != "":
		var tab = mod_tab.instance()
		tab.mod = SELECTED_MOD
		tab.mod_id = SELECTED_MOD_ID
		container.add_child(tab)
	
	lastFocus = get_focus_owner()
	
	get_node("base/TabContainer").get_child(0).get_node("MarginContainer/TabContainer").get_child(0).get_node("MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer").get_child(0).get_node("Label/LABELBUTTON").call_deferred("grab_focus")
	
	_on_resize()

func _visibility_changed():
	_on_resize()

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

func _on_resize():
	var size = Settings.getViewportSize()
	rect_size = size
	$ColorRect.rect_size = size
	$base.rect_min_size = size - offset
	$base.rect_position = offset/2
	
