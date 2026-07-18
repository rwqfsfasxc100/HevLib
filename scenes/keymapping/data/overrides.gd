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

const vanilla_bind_opts = {
	"ui_accept":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"ui_select":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"ui_cancel":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"ui_focus_next":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"ui_focus_prev":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"ui_left":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"ui_right":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"ui_up":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"ui_down":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"ui_page_up":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"ui_page_down":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"ui_home":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"ui_end":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"ship_forward":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"ship_back":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"ship_rot_left":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"ship_rot_right":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"ship_strafe_right":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"ship_strafe_left":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"ship_main_engine":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"ship_weapon_fire":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"autopilot_up":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"autopilot_down":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"autopilot_left":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"autopilot_right":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"ship_excavator":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"autopilot_orient_to_mouse":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"zoom_in":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"zoom_out":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"power_reactor_toggle":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"autopilot_orient_to":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"autopilot_bearing":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"autopilot_bearing_keys":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"pause":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"bullet_time":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"jury_rig":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"debugger":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"autopilot_stop":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"cutscene_ff":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"autopilot_lockon":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"autopilot_lockoff":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"autopilot_lockon_mouse":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"jury_rig_cancel":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"ship_slot_main_toggle":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"ship_slot_left_toggle":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"ship_slot_right_toggle":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"debug_slowdown":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"debug_ai_toggle":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"ship_slot_drone_toggle":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"autopilot_guide_target":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"ship_slot_1":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"ship_slot_2":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"ship_slot_3":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"ship_slot_4":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"debug_slipstream":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"ui_scroll_up":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"ui_scroll_down":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"autopilot_absolute":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"ship_slot_5":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"ship_slot_6":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"ship_slot_7":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"ship_slot_8":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"profiler":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"ship_slot_torch":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"autopilot_strafe_left":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"autopilot_strafe_right":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"ui_scroll_up2":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"ui_scroll_down2":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"debug_overview":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
	"debug_dump":{"allow_extra_keys":true,"order_sensitive":true,"exclusive":false},
}

const actions_ignore = [ # use pointers.Keymapping.__get_built_in_action_list() instead
	"ui_accept",
	"ui_select",
	"ui_cancel",
	"ui_focus_next",
	"ui_focus_prev",
	"ui_left",
	"ui_right",
	"ui_up",
	"ui_down",
	"ui_page_up",
	"ui_page_down",
	"ui_home",
	"ui_end",
#	"zoom_in",
#	"zoom_out",
]
