extends "res://SaveSlotButton.gd"

onready var popup_path = get_parent().get_parent().get_parent().get_parent().get_parent().get_node("NoMargins")

onready var menu_path = popup_path.get_node("Popups/SaveSettings")

onready var delete_path = popup_path.get_node("Popups/Override")

var password = "FTWOMG"

onready var ship_models = Shipyard.ships.keys()

var foolish

var val = 0.0

var first_time = true

var delete_color = Color(1,1,1,1)

var slot_available = true

var display_text = ""

var index = 0

func _ready():
	var foolish = load("res://menu/Foolish.tscn").instance()
	foolish.name = "Foolish"
	add_child(foolish)
	var box = HBoxContainer.new()
	box.alignment = BoxContainer.ALIGN_CENTER
	box.rect_size = Vector2(64,41)
	box.name = "HBoxContainer"
	var texture = TextureRect.new()
	var stream = StreamTexture.new()
	stream.load_path = "res://HevLib/ui/themes/icons/config_icon.stex"
	stream.flags = 4
	texture.texture = stream
	texture.expand = true
	texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture.margin_right = 64.0
	texture.margin_bottom = 41.0
	texture.size_flags_horizontal = 3
	texture.name = "TextureRect"
	box.add_child(texture)
	var delete = get_node(accompanyingDelete)
	delete.icon = null
	delete.rect_min_size = Vector2(64,41)
	delete.add_child(box)
	
	foolish = $Foolish
	
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

var standHash = 0

var has_save = false

var file = File.new()
func checkSave():
#	var mpm = getDataFromSave(saveSlotFile)
	var does = false
	
	var check = file.file_exists(saveSlotFile)
	if check:
		has_save = true
		file.open_encrypted_with_pass(saveSlotFile,File.READ,password)
		var _hash = file.get_as_text(true).hash()
		file.close()
		if _hash != standHash:
			does = true
			standHash = _hash
	else:
		standHash = 0
		has_save = false
	if does:
		if has_save:
			meta = getMetaFromSave(saveSlotFile)
			
			if true:
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
					$Foolish.visible = false
					hint_tooltip = ""
		#			foolish.hint_tooltip = ""
					disabled = false
				else:
					$Foolish.visible = true
					hint_tooltip = model_error % meta.model
		#			foolish.hint_tooltip = model_error % meta.model
					disabled = true
		else:
			slot_available = false
			delete_color = Color(1, 1, 1, 0.25)
			text = newText
			if first_time and first:
				grab_focus()
	if not has_save:
		slot_available = false
		delete_color = Color(1, 1, 1, 0.25)
		text = newText
		if first_time and first:
			grab_focus()
	first_time = false

	display_text = text
	if display_text == "":
		display_text = newText

func newSave():
	Debug.l("delete %s pressed" % saveSlotFile)
	CurrentGame.saveFile = saveSlotFile
	emit_signal("newGame")
	

func _pressed():
	var exists = file.file_exists(saveSlotFile)
	if exists:
		Debug.l("pressed %s" % saveSlotFile)
		CurrentGame.saveFile = saveSlotFile
		emit_signal("continueGame")
	else:
		Debug.l("new %s pressed" % saveSlotFile)
		CurrentGame.saveFile = saveSlotFile
		get_node("../../../../../NoMargins/NewGamePlus").popup_centered()

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

func getDataFromSave(file):
	var f = File.new()
	if f.file_exists(file):
		f.open_encrypted_with_pass(file, File.READ, password)
		var sg = f.get_line()
		var savedState = parse_json(sg)
		f.close()
		return savedState
	return {}
