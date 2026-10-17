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

extends Label

var accurate_event_counter = false
var visibility = false

var pointers:HevLibPointers = ModLoader._savedObjects[0]

func hl_shipzone_uv():
	if pointers:
		visibility = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_position_data_debugger")
		accurate_event_counter = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_position_accurate_events")

func _ready():
	pointers.ConfigDriver.__establish_connection("hl_shipzone_uv",self)
	hl_shipzone_uv()
	accurate_event_counter = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DEBUG","ring_position_accurate_events")
	if accurate_event_counter:
		pointers.l("\n\n\n\n###############################################################################################################################################################################\n\nWARNING! HevLib setting 'ring_position_accurate_events' is enabled. Due to the way this setting works, it will decrease performance by a significant enough amount, and will generate thousands of logs per minute.\n\nUSE OF THIS SETTING IS COMPLETELY UNSUPPORTED AND WILL INVALIDATE ALL BUG REPORTS! YOU HAVE BEEN WARNED!\n\n###############################################################################################################################################################################\n\n\n\n","GamespaceCanvas.EventDriver")
	
	visible = visibility
	
func _input(event):
	if visibility and Input.is_action_just_pressed("hl_toggle_debug_menus"):
		visible = !visible


var frame_ctr:float = 0.0
var update_interval:float = 1.0 / 15.0
func _physics_process(delta):
	frame_ctr += delta
	if frame_ctr > update_interval:
		frame_ctr = 0.0
		if CurrentGame.hl_game_available:
			visible = visibility
			if visibility:
				var ship = CurrentGame.getPlayerShip()
				if Tool.claim(ship):
					var ring = CurrentGame.hl_ring_node
					var currentPos = CurrentGame.globalCoords(ship.global_position)
					var chaos:float = ring.getChaosAt(currentPos)
					var density:float = ring.getRawDensityAt(currentPos)
					var realDensity:Array = ring.getTargetDensityAt(currentPos)
					var actualEventNo:int = 0
					var EventNo:int = 0
					for node in ring.get_children():
						var hasChaos:bool = false
						if "chaosLimit" in node:
							if node.chaosLimit <= chaos:
								EventNo += 1
						else:
							EventNo += 1
						if accurate_event_counter and node.canBeAt(currentPos):
							actualEventNo += 1
					Tool.release(ship)
					text = "Zone: %s\nChaos: %f\nRawDensity: %f\nDensity: %s\nCurrently Possible Events (predicted): %d\nCurrently Possible Events (actual): %d" % [
						ship.zone,
						chaos,
						density,
						realDensity,
						EventNo,
						actualEventNo,
					]
		else:
			text = ""


