extends Button

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

var file = File.new()
var update_store = "user://cache/.Mod_Menu_2_Cache/updates/needs_updates.json"
func _ready():
	check()
	$Timer.start()
	visible = false
var visibility = false

var dependancies_store = "user://cache/.Mod_Menu_2_Cache/dependancies/dependancies.json"
var conflicts_store = "user://cache/.Mod_Menu_2_Cache/conflicts/conflicts.json"
var complementary_store = "user://cache/.Mod_Menu_2_Cache/complementary/complementary.json"

func check():
	file.open(update_store,File.READ)
	var update_data = JSON.parse(file.get_as_text()).result
	file.close()
	var height = 50
	if update_data:
		visibility = true
		height += 50
		$NotificationBox/VBoxContainer/Updates.visible = true
		$NotificationBox/VBoxContainer/Updates/Label.text = TranslationServer.translate("HEVLIB_UPDATE_COUNT") % update_data.size()
	else:
		$NotificationBox/VBoxContainer/Updates.visible = false
	file.open(conflicts_store,File.READ)
	var conflicts = JSON.parse(file.get_as_text()).result
	file.close()
	file.open(dependancies_store,File.READ)
	var dependancies = JSON.parse(file.get_as_text()).result
	file.close()
	if conflicts.keys().size() == 0:
		$NotificationBox/VBoxContainer/Conflicts.visible = false
	else:
		visibility = true
		height += 50
		$NotificationBox/VBoxContainer/Conflicts.visible = true
		$NotificationBox/VBoxContainer/Conflicts/Label.text = TranslationServer.translate("HEVLIB_CONFLICT_COUNT") % conflicts.keys().size()
	if dependancies.keys().size() == 0:
		$NotificationBox/VBoxContainer/Dependancies.visible = false
	else:
		visibility = true
		height += 50
		$NotificationBox/VBoxContainer/Dependancies.visible = true
		$NotificationBox/VBoxContainer/Dependancies/Label.text = TranslationServer.translate("HEVLIB_DEPENDANCY_COUNT") % dependancies.keys().size()
	$NotificationBox.rect_size.y = height
	$NotificationBox.rect_position.y = -height

func _process(delta):
#	if mouse_focus:
#		focused = true
#	elif key_focus:
#		focused = true
#	else:
#		focused = false
#	if focused:
#		$NotificationBox.visible = true
	if mouse_focus or key_focus:
		$NotificationBox.visible = true
	else:
		$NotificationBox.visible = false
	visible = visibility

func _timeout():
	check()
var focused = false
var key_focus = false
var mouse_focus = false


func _focus_entered():
	key_focus = true


func _focus_exited():
	key_focus = false


func _mouse_entered():
	mouse_focus = true


func _mouse_exited():
	mouse_focus = false
