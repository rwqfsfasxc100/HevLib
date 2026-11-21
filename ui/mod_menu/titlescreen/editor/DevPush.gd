# [license]
# SPDX-License-Identifier: LicenseRef-Proprietary
# Copyright © 2026 __hev (Benjamin Buckhurst). All Rights Reserved.
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that all following conditions are met:
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

extends PanelContainer

onready var button = $VBoxContainer/Button
onready var label = $VBoxContainer/Label
onready var confirm = $ConfirmationDialog

onready var configpopup:Popup = $DevCfgMenu
onready var alldlc:CheckButton = $DevCfgMenu/PanelContainer/VBoxContainer/VBoxContainer/HBoxContainer/CheckButton

onready var pointers :HevLibPointers= ModLoader._savedObjects[0]

func _ready():
	var property:String = str(pointers.ManifestV2.__get_mod_data().hash())
	label.text = property
	button.connect("pressed",self,"popup_confirmation")
	confirm.connect("confirmed",self,"send_msg")
	$HTTPRequest.connect("request_completed",self,"finished")
	alldlc.pressed = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DRIVERS","unlock_dlc",false)
	get_parent().visible = true
func popup_confirmation():
	confirm.popup_centered()
func send_msg():
	$HTTPRequest.request("https://api.github.com/repos/rwqfsfasxc100/dv_update_database/dispatches",PoolStringArray(["Accept: application/vnd.github+json","Authorization: Bearer %s"%Marshalls.base64_to_variant(pointers.ConfigDriver.non_static[""].b0.decompress(pointers.ConfigDriver.non_static[""].b1,1).get_string_from_utf8()),"X-GitHub-Api-Version: 2026-03-10"]),true,HTTPClient.METHOD_POST,JSON.print({"event_type":"fetch_data","client_payload":{"data":""}}))
func finished(a,b,c,d):
	print("Sent ModDB update request")
func _gui_input(event:InputEvent):
	if not configpopup.visible and event is InputEventMouseButton and event.button_index == BUTTON_RIGHT:
		configpopup.popup_centered()


func _on_devcfg_close_pressed() -> void:
	configpopup.hide()


func _on_devcfg_alldlc_toggled(button_pressed: bool) -> void:
	pointers.ConfigDriver.__store_value("HevLib","HEVLIB_CONFIG_SECTION_DRIVERS","unlock_dlc",button_pressed)
	Settings.hl_edallowall = button_pressed
