extends "res://SaveSlotButton.gd"

# [license]
# 3-Clause BSD NON-AI License
# 
# Copyright 2026 __hev (Benjamin Buckhurst)
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.
# 
# 4. The source code and the binary form, and any modifications made to them may not be used for the purpose of input data, the training of, or improvment of machine learning algorithms,
# including but not limited to artificial intelligence, natural language processing, or data mining. This condition applies to any derivatives,
# modifications, or updates based on the Software code. Any usage of the source code or the binary form in an AI-training dataset is considered a breach of this License.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# [/license]

onready var popup_path = get_parent().get_parent().get_parent().get_parent().get_parent().get_node("NoMargins")

onready var menu_path = popup_path.get_node("Popups/SaveSettings")

onready var delete_path = popup_path.get_node("Popups/Override")

var password:String = "FTWOMG"

var foolish

var val:float = 0.0

var first_time:bool = true

var delete_color:Color = Color(1,1,1,1)

var slot_available:bool = true

var display_text:String = ""

var index:int = 0

func _ready():
	var foolish = load("res://menu/Foolish.tscn").instance()
	foolish.name = "Foolish"
	add_child(foolish)
	var box:HBoxContainer = HBoxContainer.new()
	box.alignment = BoxContainer.ALIGN_CENTER
	box.rect_size = Vector2(64,41)
	box.name = "HBoxContainer"
	var texture:TextureRect = TextureRect.new()
	var stream:StreamTexture = StreamTexture.new()
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
	yield(get_tree(),"idle_frame")
	checkSave(true)

func _physics_process(delta):
	val = val + delta
	if val >= 5.0:
		val = 0.0
		if is_visible_in_tree():
			checkSave()

var standHash:int = 0

var has_save:bool = false

var file:File = File.new()
func checkSave(force = false):
	var does:bool = false
	if file.file_exists(saveSlotFile):
		has_save = true
		file.open_encrypted_with_pass(saveSlotFile,File.READ,password)
		var _hash:int = hash(file.get_as_text(true))
		file.close()
		if _hash != standHash:
			does = true
			standHash = _hash
	else:
		standHash = 0
		has_save = false
	if does or force:
		if has_save:
			meta = getMetaFromSave(saveSlotFile)
			if meta != null:
				var demoLimit = CurrentGame.getGameStartTime() + 24 * 3600 * 30 * 256
				text = "%s %s" % [meta.transponder, meta.name]
				if false and (CurrentGame.isDemo() and meta.gameTime > demoLimit):
					disabled = true
					slot_available = false
					delete_color = Color(1, 1, 1, 0.25)
					hint_tooltip = "DEMO_UNLOCK"
					newNode.hint_tooltip = "DEMO_UNLOCK"
				else:
					slot_available = true
					delete_color = Color(1, 1, 1, 1)
				if meta.model in Shipyard.ships:
					$Foolish.visible = false
					hint_tooltip = ""
					disabled = false
				else:
					$Foolish.visible = true
					hint_tooltip = TranslationServer.translate("HEVLIB_INCORRECT_SHIP") % meta.model
					disabled = true
		else:
			slot_available = false
			delete_color = Color(1, 1, 1, 0.25)
			text = newText
	if not has_save:
		slot_available = false
		delete_color = Color(1, 1, 1, 0.25)
		text = newText
	if first_time:
		check_focus()
	first_time = false
	
	display_text = text
	if not display_text:
		display_text = newText

func check_focus():
	if first:
		grab_focus()
	if meta:
		if CurrentGame.oldestSave < meta.time:
			CurrentGame.oldestSave = meta.time
			grab_focus()

func newSave():
	Debug.l("delete %s pressed" % saveSlotFile)
	CurrentGame.saveFile = saveSlotFile
	emit_signal("newGame")
	

func _pressed():
	if file.file_exists(saveSlotFile):
		Debug.l("pressed %s" % saveSlotFile)
		CurrentGame.saveFile = saveSlotFile
		emit_signal("continueGame")
	else:
		Debug.l("new %s pressed" % saveSlotFile)
		CurrentGame.saveFile = saveSlotFile
		get_node("../../../../../NoMargins/NewGamePlus").popup_centered()

func _new():
	menu_path.save_slot_file = saveSlotFile
	menu_path.delete_color = delete_color
	menu_path.slot_available = slot_available
	menu_path.sender = self
	menu_path.display_text = display_text
	menu_path.index = index
	menu_path.popup_container = popup_path
	menu_path.popup_centered()



func getMetaFromSave(file_name):
	if file.file_exists(file_name):
		file.open_encrypted_with_pass(file_name, File.READ, password)
		var sg:String = file.get_line()
		var savedState:Dictionary = parse_json(sg)
		file.close()
		var transponder:String = savedState.ship.transponder
		if "shipNames" in savedState:
			var shipName:String = savedState.shipNames[transponder]
			var model:String = savedState.ship.model
			return {
				"transponder": transponder, 
				"name": shipName, 
				"gameTime": savedState.time, 
				"time": file.get_modified_time(file_name),
				"model": model
			}
		else:
			return null
	else:
		return null

func getDataFromSave(file_name):
	if file.file_exists(file_name):
		file.open_encrypted_with_pass(file_name, File.READ, password)
		var sg:String = file.get_line()
		var savedState:Dictionary = parse_json(sg)
		file.close()
		return savedState
	return {}
