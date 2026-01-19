extends Popup

export var offset = Vector2(12,12)
export var tablist = NodePath("")
onready var tabs = get_node_or_null(tablist)

export var mod_tab = preload("res://HevLib/ui/mod_menu/changelogs/ModChangelogTab.tscn")

func open(mods):
	if tabs:
		for i in tabs.get_children():
			tabs.remove_child(i)
		for mod in mods:
			var data = mods[mod]
			if data["changelog"] != "":
				var tab = mod_tab.instance()
				tab.name = data.get("name",mod)
				tab.mod_data = data.duplicate(true)
				tabs.add_child(tab)

func _ready():
	connect("about_to_show",self,"_about_to_show")
	connect("visibility_changed",self,"_on_resize")

func _about_to_show():
	lastFocus = get_focus_owner()

func show_menu():
	popup()

func cancel():
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
	var size = Settings.getViewportSize()
	rect_size = size
	$ColorRect.rect_min_size = size
	$ColorRect.rect_size = size
	$base.rect_min_size = size - offset
	$base.rect_size = size - offset
	$base/PanelContainer.rect_min_size = size - offset
	$base/PanelContainer.rect_size = size - offset
	$base.rect_position = offset/2
