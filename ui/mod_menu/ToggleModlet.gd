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

extends CheckButton

var pointers = ModLoader._savedObjects[0]

var current_modlet = null
var current_modlet_path : String = ""

var can_toggle = false

var file = File.new()
var modlet_toggle_restart_path = "user://cache/.Mod_Menu_2_Cache/updates/modlet_restart_requests.json"
var updateCacheDir = "user://cache/.Mod_Menu_2_Cache/updates/has_updated.txt"

func _toggled(button_pressed):
	if can_toggle:
		var all_modlets = pointers.ManifestV2.__get_all_modlets(false)
		all_modlets[current_modlet_path] = button_pressed
		file.open(modlet_toggle_restart_path,File.READ)
		var restarting = JSON.parse(file.get_as_text()).result
		file.close()
		if not current_modlet_path in restarting:
			restarting.append(current_modlet_path)
		current_modlet.needs_restart_from_toggling = true
		file.open(modlet_toggle_restart_path,File.WRITE)
		file.store_string(JSON.print(restarting))
		file.close()
		file.open(updateCacheDir,File.WRITE)
		file.store_string("1")
		file.close()
		pointers.ConfigDriver.__store_value("HevLib","modlets","seen_modlets",all_modlets)
		yield(CurrentGame.get_tree(),"idle_frame")
		current_modlet.update()

func change_modlet_to(modlet,modlet_path:String):
	can_toggle = false
	current_modlet = modlet
	current_modlet_path = modlet_path
	if modlet and modlet_path:
		if modlet_path == "res://ModMenu2/Mod.manifest":
			disabled = true
			hint_tooltip = "HEVLIB_MODMENU_MODLET_TOGGLE_MM2FALLBACK"
		else:
			disabled = false
			hint_tooltip = "HEVLIB_MODMENU_MODLET_TOGGLE_TOOLTIP"
		var all_modlets = pointers.ManifestV2.__get_all_modlets(false)
		var enabled = all_modlets[modlet_path]
		pressed = enabled
		yield(CurrentGame.get_tree(),"physics_frame")
		can_toggle = true
