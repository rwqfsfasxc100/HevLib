extends Popup

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

var pointers = ModLoader._savedObjects[0]
var offset = Vector2(12,12)

var cache_folder : String = "user://cache/.Mod_Menu_2_Cache/"
var filter_cache_file : String = "menu_filter_cache.json"
var file : File = File.new()
func _about_to_show():
	pointers.FolderAccess.__check_folder_exists(cache_folder)
	file.open(cache_folder + filter_cache_file,File.WRITE)
	file.store_string("[]")
	file.close()
	var nodes : Array = $FilterPopup/base/FilterContainer/VBoxContainer/ScrollContainer/VBoxContainer.get_children()
	for node in nodes:
		var c = node.get_node("CheckButton")
		c.pressed = true
	$base/PanelContainer/VBoxContainer/ModContainer/SPLIT/ModList.about_to_show()
	lastFocus = get_focus_owner()
	_on_resize()
	$base/PanelContainer/VBoxContainer/ModContainer/SPLIT/ModList.hide_mods()
	
func _unhandled_input(event):
	if visible and Input.is_action_just_pressed("ui_cancel"):
		if $WAIT.visible:
			Debug.l("Currently downloading a mod update, not closing wait window.")
		elif $ModpacksMenu/WAIT.visible:
			Debug.l("Currently downloading a mod, not closing wait window.")
		elif $FetchGithub/WAIT.visible:
			Debug.l("Currently downloading a mod, not closing wait window.")
		
		
		elif $MMRestartDialog.visible:
			$MMRestartDialog.hide()
		
		elif $ModpacksMenu/OpenPack.visible:
			$ModpacksMenu/OpenPack.hide()
		elif $ModpacksMenu/SavePack.visible:
			$ModpacksMenu/SavePack.hide()
		
		
		elif $FetchGithub.visible:
			$FetchGithub.cancel()
		elif $URLPopup.visible:
			$URLPopup.cancel()
		elif $FilterPopup.visible:
			$FilterPopup.cancel()
		elif $ModSettingsMenu.visible:
			$ModSettingsMenu.cancel()
		elif $ConflictMenu.visible:
			$ConflictMenu.hide()
		elif $DependancyMenu.visible:
			$DependancyMenu.hide()
		elif $UpdateDialog.visible:
			$UpdateDialog.hide()
		elif $ProfilesMenu.visible:
			$ProfilesMenu.cancel()
		elif $MMChangelogMenu.visible:
			$MMChangelogMenu.cancel()
		elif $ModpacksMenu.visible:
			$ModpacksMenu.cancel()
		else:
			cancel()
		get_tree().set_input_as_handled()

func show_menu():
	popup()

func cancel():
	$AnimateAppear.play("hider")

onready var restart_menu : Node = $MMRestartDialog
var has_updated_store : String = "user://cache/.Mod_Menu_2_Cache/updates/has_updated.txt"

func show_restart_menu():
	var valid = true
	var ps = CurrentGame.getPlayerShip()
	if ps and ps.zone == "rings":
		valid = false
	restart_menu.let_restart(valid)
	file.open(has_updated_store,File.READ)
	var has : String = file.get_as_text()
	file.close()
	if has == "1":
		restart_menu.show()
		return true
	return false

func hider():
	if restart_menu.can_restart:
		if not show_restart_menu():
			hide()
			refocus()
		else:
			hide()
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
	var size: Vector2 = Settings.getViewportSize()
	rect_size = size
	$ColorRect.rect_min_size = size
	$ColorRect.rect_size = size
	$base.rect_min_size = size - offset
	$base.rect_size = size - offset
	$base.rect_position = offset/2
	
	
	var bn : Node = $base/PanelContainer/VBoxContainer/ModContainer/SPLIT/ModList/ScrollContainer/VBoxContainer
	if bn:
		if bn.get_children().size() >= 1:
			var buttonnode : Node = bn.get_child(0)
			var children : Array = buttonnode.get_children()
			var names : Array = []
			for child in children:
				names.append(child.name)
			if "ModButton" in names:
				buttonnode.get_node("ModButton").grab_focus()

func _ready():
	get_tree().get_root().connect("size_changed", self, "_on_resize")

func _visibility_changed():
	_on_resize()

