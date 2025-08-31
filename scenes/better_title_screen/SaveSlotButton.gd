extends "res://SaveSlotButton.gd"

onready var popup_path = get_parent().get_parent().get_parent().get_parent().get_parent().get_node("NoMargins")

onready var menu_path = popup_path.get_node("Popups/SaveSettings")

var password = "FTWOMG"

onready var ship_models = Shipyard.ships.keys()

onready var foolish = $Foolish

var val = 0.0

var first_time = true

var delete_color = Color(1,1,1,1)

var slot_available = true

var display_text = ""

var index = 0

func _ready():
	connect("newGame",CurrentGame,"newGame")
	foolish.visible = false
	disabled = false
	hint_tooltip = ""
	foolish.hint_tooltip = ""
	index = get_index()

func _physics_process(delta):
	val = val + delta
	if val >= 5.0:
		val = 0.0
		checkSave()
#		breakpoint


func checkSave():
	var new_meta = getMetaFromSave(saveSlotFile)
	if new_meta:
		var change = false
		if meta:
			if new_meta.hash() != meta.hash():
				meta = new_meta
				change = true
		else:
			meta = new_meta
			change = true
		if change:
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
			var model_error = TranslationServer.translate("HEVLIB_INCORRECT_SHIP")
			if meta.model in ship_models:
				foolish.visible = false
				hint_tooltip = ""
	#			foolish.hint_tooltip = ""
				disabled = false
			else:
				foolish.visible = true
				hint_tooltip = model_error % meta.model
	#			foolish.hint_tooltip = model_error % meta.model
				disabled = true
	else:
		slot_available = false
		delete_color = Color(1, 1, 1, 0.25)
		text = newText
		if first_time and first:
			grab_focus()
	display_text = text

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
	menu_path.sender = self
	menu_path.display_text = display_text
	menu_path.index = index
	menu_path.popup_container = popup_path
	menu_path.popup_centered()



func getMetaFromSave(file):
	var f = File.new()
	if f.file_exists(file):
		f.open_encrypted_with_pass(file, File.READ, password)
		var sg = f.get_line()
		var savedState = parse_json(sg)
		f.close()
		var transponder = savedState.ship.transponder
		if "shipNames" in savedState:
			var shipName = savedState.shipNames[transponder]
			var model = savedState.ship.model
			return {
				"transponder": transponder, 
				"name": shipName, 
				"gameTime": savedState.time, 
				"time": f.get_modified_time(file),
				"model": model
			}
		else:
			return null
	else:
		return null
