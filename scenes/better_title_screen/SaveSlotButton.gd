extends "res://SaveSlotButton.gd"

onready var menu_path = get_parent().get_parent().get_parent().get_parent().get_parent().get_node("NoMargins/Popups/SaveSettings")

var val = 0.0

var first_time = true

var delete_color = Color(1,1,1,1)

var slot_available = true

func _physics_process(delta):
	val = val + delta
	if val >= 5.0:
		val = 0.0
		checkSave()
#		breakpoint


func checkSave():
	meta = CurrentGame.getMetaFromSave(saveSlotFile)
	if meta:
		var demoLimit = CurrentGame.getGameStartTime() + 24 * 3600 * 30 * 256
		text = "%s %s" % [meta.transponder, meta.name]
		if first_time:
			if CurrentGame.oldestSave < meta.time:
				CurrentGame.oldestSave = meta.time
				if is_visible_in_tree():
					grab_focus()
		if false and (CurrentGame.isDemo() and meta.gameTime > demoLimit):
			disabled = true
			slot_available = false
			delete_color = Color(1, 1, 1, 0.25)
			hint_tooltip = "DEMO_UNLOCK"
			newNode.hint_tooltip = "DEMO_UNLOCK"
		else:
			slot_available = true
			delete_color = Color(1, 1, 1, 1)
	else:
		slot_available = false
		delete_color = Color(1, 1, 1, 0.25)
		text = newText
		if first_time and first:
			grab_focus()
		

func newSave():
	Debug.l("new %s pressed" % saveSlotFile)
	CurrentGame.saveFile = saveSlotFile
	emit_signal("newGame")

func _pressed():
	if meta:
		Debug.l("pressed %s" % saveSlotFile)
		CurrentGame.saveFile = saveSlotFile
		emit_signal("continueGame")
	else:
		newSave()

func _unhandled_input(event):
	if first:
		if event.is_action("ui_accept") or event.is_action("ui_cancel"):
			if get_focus_owner() == null:
				grab_focus()

func _new():
	menu_path.save_slot_file = saveSlotFile
	menu_path.delete_color = delete_color
	menu_path.slot_available = slot_available
	menu_path.popup_centered()
