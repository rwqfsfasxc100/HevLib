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

export var update_menu_path = NodePath("")
onready var update_menu = get_node(update_menu_path)

var update_store = "user://cache/.Mod_Menu_2_Cache/updates/needs_updates.json"
var pointers = ModLoader._savedObjects[0]
var file = File.new()

var max_check = 10
var check_ctr = 0
func _ready():
	check()
	
func check():
	check_ctr += 1
	file.open(update_store,File.READ)
	var updates = JSON.parse(file.get_as_text()).result
	file.close()
	if updates:
		var currently_ignored = pointers.ConfigDriver.__get_value("ModMenu2","datastore","ignored_updates")
		if currently_ignored == null:
			currently_ignored = {}
		for u in currently_ignored:
			if u in updates:
				if currently_ignored[u] == str(updates[u]["new_version"][0]) + "." + str(updates[u]["new_version"][1]) + "." + str(updates[u]["new_version"][2]):
					updates.erase(u)
				else:
					currently_ignored.erase(u)
		$Timer.start()
	elif not check_ctr > max_check:
		$ReTimer.start()

func show_menu():
	
	popup_centered()
	yield(get_tree().create_timer(0.25),"timeout")
	$PanelContainer/VBoxContainer/HBoxContainer/OK/Button.grab_focus()

func cancel():
	hide()
#	refocus()

var lastFocus = null
func refocus():
	if lastFocus and lastFocus.has_method("grab_focus"):
		lastFocus.grab_focus()
	else:
		Debug.l("I have no focus to fall back to!")


func _about_to_show():
	
	lastFocus = get_focus_owner()


func _confirmed():
	update_menu.popup()
	cancel()
	update_menu.lastFocus = lastFocus
