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

extends "res://tools/DLClist.gd"

var pointers

func _ready():
	pointers = ModLoader._savedObjects[0]
	grow_horizontal = Control.GROW_DIRECTION_BEGIN
	if get_child_count() >= 1:
		var p = hl_dlc_make_label("HEVLIB_DLCLIST_DLC_HEADER")
		add_child(p)
		move_child(p,0)
		
		add_child(hl_dlc_make_label("HEVLIB_DLCLIST_MODS_HEADER"))
		
	var mods = pointers.ManifestV2.__get_mod_data()["mods"]
	var labels = []
	var names = []
	var show_always_display_libraries_in_dlclist = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DRIVERS","show_always_display_libraries_in_dlclist")
	var show_all_libraries_in_dlclist = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DRIVERS","show_all_libraries_in_dlclist")
	var dlc_mod_list_sort_order = pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_DRIVERS","dlc_mod_list_sort_order")
	for mod in mods:
		var data = mods[mod]
		if not data["library_information"]["is_library"]:
			labels.append(hl_dlc_make_label(data["name"]))
			names.append(data["name"])
		elif data["library_information"]["always_display"] and show_always_display_libraries_in_dlclist:
			labels.append(hl_dlc_make_label(data["name"]))
			names.append(data["name"])
		elif show_all_libraries_in_dlclist:
			labels.append(hl_dlc_make_label(data["name"]))
			names.append(data["name"])
	match dlc_mod_list_sort_order:
		"alphabetical_ascending":
			descending = true
			labels.sort_custom(self,"hl_dlc_sort_alphabetical")
		"alphabetical_descending":
			descending = false
			labels.sort_custom(self,"hl_dlc_sort_alphabetical")
		"length_ascending":
			descending = true
			labels.sort_custom(self,"hl_dlc_sort_length")
		"length_descending":
			descending = false
			labels.sort_custom(self,"hl_dlc_sort_length")
		_:
			descending = false
	for label in labels:
		add_child(label)



func hl_dlc_make_label(text):
	
	var l = Label.new()
	l.text = text
	l.align = Label.ALIGN_RIGHT
	
	
	return l

var descending:bool = false

func hl_dlc_sort_alphabetical(a, b, index = 0) -> bool: 
	if index >= a.text.length() or index >= b.text.length():
		return descending
	if a.text[index] < b.text[index]: 
		return !descending
	elif a.text[index] == b.text[index]:
		index += 1
		hl_dlc_sort_alphabetical(a,b,index)
	return descending

func hl_dlc_sort_length(a,b) -> bool:
	if a.text.length() > b.text.length():
		return descending
	if a.text.length() < b.text.length(): 
		return !descending
	elif a.text.length() == b.text.length():
		return hl_dlc_sort_alphabetical(a,b,0)
	return descending
