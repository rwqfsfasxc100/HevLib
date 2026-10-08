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

extends "res://menu/TitleMenu.gd"

var pointers:HevLibPointers

var mm2_titlemenu_uinit : bool = false
func _ready():
	if mm2_titlemenu_uinit:
		OS.kill(OS.get_process_id())
	mm2_titlemenu_uinit = true
	add_child(update_timer)
	update_timer.connect("timeout",self,"update_recheck")
	update_timer.start(30)
	pointers = ModLoader._savedObjects[0]
	var mm2_entry:Dictionary = pointers.ManifestV2.__get_mod_by_id("hev.ModMenu2")
	if mm2_entry:
		var mm2_ver:Array = mm2_entry.get("version_data",{}).get("full_version_array",[0,0,0])
		if not pointers.DataFormat.__compare_versions(mm2_ver[0],mm2_ver[1],mm2_ver[2],1,1,2):
			return
		
		var no_margins:MarginContainer = $NoMargins
		var popups:CenterContainer = $NoMargins/Popups
		
		var btnContainer:HBoxContainer = HBoxContainer.new()
		btnContainer.name = "ModMenuButtonContainer"
		var mmBtn:Button = Button.new()
		mmBtn.text = "HEVLIB_MOD_MENU"
		mmBtn.size_flags_horizontal = Button.SIZE_EXPAND_FILL
		btnContainer.add_child(mmBtn)
		
		var chnglgMenu:Popup = load("res://HevLib/ui/mod_menu/changelogs/ChangelogMenu.tscn").instance()
		chnglgMenu.rect_size = Vector2(1280,720)
		no_margins.add_child(chnglgMenu)
		
		var chnglgBtn:Button = load("res://HevLib/ui/mod_menu/changelogs/ChangelogButton.tscn").instance()
		chnglgBtn.name = "Changelogs"
		chnglgBtn.text = "HEVLIB_CHANGELOGS_NEW"
		chnglgBtn.changelog_menu = NodePath("../../../../../../NoMargins/ChangelogMenu")
		btnContainer.add_child(chnglgBtn)
		
		var notifBtn:Button = load("res://HevLib/ui/mod_menu/ModNotificationButton.tscn").instance()
		btnContainer.add_child(notifBtn)
		$MarginContainer/VBoxContainer/MarginContainer2/GridContainer.add_child(btnContainer)
		
		var mm2:Popup = load("res://HevLib/ui/mod_menu/ModMenu.tscn").instance()
		mmBtn.connect("pressed",mm2,"show_menu")
		no_margins.add_child(mm2)
		
		var restart:Popup = load("res://HevLib/ui/mod_menu/updates/MMRestartDialog.tscn").instance()
		popups.add_child(restart)
		
		var updMenu:Popup = load("res://HevLib/ui/mod_menu/updates/UpdatesMenu.tscn").instance()
		updMenu.restart_dialog_path = NodePath("../Popups/MMRestartDialog")
		updMenu.notifications_button_path = NodePath("../../MarginContainer/VBoxContainer/MarginContainer2/GridContainer/ModMenuButtonContainer/Notifications")
		no_margins.add_child(updMenu)
		
		var updNotifier:Popup = load("res://HevLib/ui/mod_menu/updates/UpdateNotifier.tscn").instance()
		updNotifier.update_menu_path = NodePath("../../UpdatesMenu")
		popups.add_child(updNotifier)
	else:
		var popups:CenterContainer = $NoMargins/Popups
		var restart:Popup = load("res://HevLib/ui/mod_menu/updates/MMRestartDialog.tscn").instance()
		popups.add_child(restart)
		
		var updMenu:Popup = load("res://HevLib/ui/mod_menu/updates/UpdatesMenu.tscn").instance()
		updMenu.restart_dialog_path = NodePath("../Popups/MMRestartDialog")
		$NoMargins.add_child(updMenu)
		
		var updNotifier:Popup = load("res://HevLib/ui/mod_menu/updates/UpdateNotifier.tscn").instance()
		updNotifier.update_menu_path = NodePath("../../UpdatesMenu")
		popups.add_child(updNotifier)
var update_timer:Timer = Timer.new()
func update_recheck():
	pointers.fetch_mod_updates()
	update_timer.start(60)

