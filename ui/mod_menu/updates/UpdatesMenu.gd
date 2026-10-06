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
# 4. The source code and the binary form, and any modifications made to them may not be used for the purpose of input data, reference code snippets and/or files, OR used in the training of, or improvement of machine learning algorithms,
# including but not limited to artificial intelligence, natural language processing, or data mining. This condition applies to any derivatives,
# modifications, or updates based on the Software code. Any usage of the source code or the binary form may not be present in any form as data fed, inputted, or provided to an AI, or present in any AI-training dataset is considered a breach of this License.
# 
# 5. Any projects deriving work from this project MUST include a copy of this license and all other license and/or copyright agreements posed within other source material,
# all of which must be followed to its entirety. Failure to follow these licenses prohibit all modification and redistribution of the material until all licensing has been reinstated.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# [/license]

extends Popup

const update_store:String = "user://cache/.Mod_Menu_2_Cache/updates/needs_updates.json"

const offset:Vector2 = Vector2(100,75)

onready var container:Node = $base/VBoxContainer/ScrollContainer/LabelContainer
onready var no_download_popup:Node = $NoDownload

var file = File.new()
var pointers:HevLibPointers = ModLoader._savedObjects[0]
var update_container:PackedScene = load("res://HevLib/ui/mod_menu/updates/ModUpdateContainer.tscn")
var has_updated_store:String = "user://cache/.Mod_Menu_2_Cache/updates/has_updated.txt"

export (NodePath) var restart_dialog_path:NodePath = NodePath("")
onready var restart_dialog:Node = get_node_or_null(restart_dialog_path)

var updating_all:bool = false

func _about_to_show():
	for child in container.get_children():
		Tool.remove(child)
	
	file.open(update_store,File.READ)
	var update_data:Dictionary = JSON.parse(file.get_as_text()).result
	file.close()
	var uKeys:Array = update_data.keys()
	var currently_ignored:Dictionary = pointers.ConfigDriver.__get_value("ModMenu2","datastore","ignored_updates",{})
	for u in currently_ignored.keys():
		if u in uKeys:
			if currently_ignored[u] == "%s.%s.%s" % [update_data[u]["new_version"][0],update_data[u]["new_version"][1],update_data[u]["new_version"][2]]:
				update_data.erase(u)
				uKeys.erase(u)
			else:
				currently_ignored.erase(u)
	pointers.ConfigDriver.__store_value("ModMenu2","datastore","ignored_updates",currently_ignored)
	
	for mod in uKeys:
		var c:Node = update_container.instance()
		var md:Dictionary = update_data[mod]
		var info:Dictionary = pointers.ManifestV2.__get_mod_by_id(mod)
		var display_name:String = md["display"]
		var old_version:Array = md["version"]
		var new_version:Array = md["new_version"]
		c.get_node("ModInfo/Label").text = display_name
		c.mod_id = mod
		c.mod_name = md["name"]
		c.current_version = "%s.%s.%s" % [old_version[0],old_version[1],old_version[2]]
		c.new_version = "%s.%s.%s" % [new_version[0],new_version[1],new_version[2]]
		container.add_child(c)
	yield(get_tree(),"physics_frame")
	match update_data.size():
		0:
			no_mods_available()
		1:
			container.get_child(0).repos()
		_:
			container.get_child(1).repos()
	lastFocus = get_focus_owner()
	_on_resize()

func _visibility_changed():
	_on_resize()

func show_menu():
	popup()
var updates:Dictionary = {}
func _ready():
	restart_dialog.get_node("PanelContainer/VBoxContainer/HBoxContainer/Restart/Button").connect("pressed",self,"_confirmed")
	restart_dialog.get_node("PanelContainer/VBoxContainer/HBoxContainer/Exit/Button").connect("pressed",self,"_custom_action")
	restart_dialog.get_node("PanelContainer/VBoxContainer/HBoxContainer/Cancel/Button").connect("pressed",self,"restart_cancel")
	if notifications_button:
		notifications_button.connect("pressed",self,"notifications_pressed")
	

func _input(event):
	if is_visible_in_tree() and event.is_action_pressed("ui_cancel"):
		cancel()

func restart_cancel():
	restart_dialog.hide()

func cancel():
	file.open(has_updated_store,File.READ)
	var has:String = file.get_as_text()
	file.close()
	if has == "1":
		hide()
		yield(get_tree(),"idle_frame")
		restart_dialog.popup_centered()
	else:
		hide()
		refocus()

var lastFocus = null
func refocus():
	if lastFocus and lastFocus.has_method("grab_focus"):
		lastFocus.grab_focus()
	else:
		Debug.l("I have no focus to fall back to!")

func _on_resize():
	var size:Vector2 = Settings.getViewportSize()
	rect_size = size
	$ColorRect.rect_size = size
	$base.rect_min_size = size - offset
	$base.rect_position = offset/2
	

var mods_to_download:Array = []

var update_all_count:int = 0
var update_all_current:int = 0

func _update_all_pressed():
	updating_all = true
	for mod in container.get_children():
		mods_to_download.append({"name":mod.mod_name,"id":mod.mod_id,"version":mod.new_version,"container":mod})
	start_updates()

func start_updates():
	update_all_count = mods_to_download.size()
	move_to_next_mod()
	$WAIT.popup_centered()

var current_mod_text:String = ""
var download_status:String = ""

func move_to_next_mod():
	if mods_to_download:
		var current = mods_to_download.pop_front()
		update_all_current += 1
		current_mod_text = TranslationServer.translate("HEVLIB_WAIT_TO_UPDATE_ALL") % [update_all_current,update_all_count,current["name"],current["id"],current["version"]]
		current["container"].display_wait_popup = false
		current["container"]._update_confirmed()
		$WAIT/PanelContainer/Button.grab_focus()
	else:
		no_mods_available()

func _process(delta):
	if $WAIT.visible:
		$WAIT/PanelContainer/Button/Label.text = current_mod_text + "\n\n" + download_status

func _confirmed():
	OS.set_restart_on_exit(true,OS.get_cmdline_args())


func _custom_action():
	pointers.NodeAccess.__exit(false,"","")


func _ignore_all_pressed():
	for mod in container.get_children():
		mod._ignore_confirmed()
	
func no_mods_available():
	$WAIT.hide()
	$base/VBoxContainer/ButtonContainer/Cancel/Button.grab_focus()
	$base/VBoxContainer/ButtonContainer/UpdateAll/Button.disabled = true
	$base/VBoxContainer/ButtonContainer/UpdateAll/Button.modulate = Color(0.7,0.7,0.7,1)
	$base/VBoxContainer/ButtonContainer/IgnoreAll/Button.disabled = true
	$base/VBoxContainer/ButtonContainer/IgnoreAll/Button.modulate = Color(0.7,0.7,0.7,1)


func _update_all_desired():
	$UpdatePopup.popup_centered()


func _ignore_all_desired():
	$IgnorePopup.popup_centered()

export var notifications_button_path:NodePath = NodePath("")
onready var notifications_button:Node = get_node_or_null(notifications_button_path)

func notifications_pressed():
	file.open(update_store,File.READ)
	updates = JSON.parse(file.get_as_text()).result
	file.close()
	
	var currently_ignored:Dictionary = pointers.ConfigDriver.__get_value("ModMenu2","datastore","ignored_updates",{})
	var iKeys:Array = currently_ignored.keys()
	for u in updates.keys():
		if u in iKeys:
			if currently_ignored[u] == "%s.%s.%s" % [updates[u]["new_version"][0],updates[u]["new_version"][1],updates[u]["new_version"][2]]:
				updates.erase(u)
			else:
				currently_ignored.erase(u)
				iKeys.erase(u)
	if updates:
		popup()
