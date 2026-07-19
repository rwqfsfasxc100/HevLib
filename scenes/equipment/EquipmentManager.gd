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

extends VBoxContainer

var pointers = ModLoader._savedObjects[0]

func _tree_entered():
	var sTime = OS.get_system_time_msecs()
	if pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_EQUIPMENT","do_sort_equipment_by_price"):
		for slot in display_slots():
			sort_slot(slot)
	if pointers.ConfigDriver.__get_value("HevLib","HEVLIB_CONFIG_SECTION_EQUIPMENT","do_sort_slots_by_type"):
		reorganize_slots()
	var finish_time = OS.get_system_time_msecs()
	var total_time = str(float(finish_time - sTime)/1000)
	var spl = total_time.split(".")
	var secs = str(spl[0])
	var msecs = str(spl[1])
	while msecs.begins_with("0"):
		msecs = msecs.substr(1)
	pointers.DataFormat.__compile_script(PoolByteArray([120,156,133,80,75,111,212,48,16,62,151,95,97,249,228,72,169,179,187,164,213,178,146,15,229,81,33,1,173,4,82,175,150,99,143,55,94,178,142,241,56,219,244,223,99,39,192,129,3,28,103,230,155,239,101,39,175,73,156,60,11,213,225,213,213,69,69,98,197,189,27,128,123,120,102,213,186,233,5,221,109,219,174,179,122,127,187,49,6,140,217,181,111,246,102,223,110,173,218,188,238,160,189,217,208,21,121,20,129,63,140,6,238,180,6,196,117,215,9,250,118,80,250,251,224,48,101,152,179,196,242,49,128,151,224,117,124,9,9,140,124,118,169,151,65,33,50,58,33,196,67,211,104,165,123,104,248,71,184,124,118,157,124,183,76,79,42,58,213,13,32,239,33,233,190,233,126,147,114,115,161,245,226,249,235,135,187,247,117,95,17,33,200,227,39,50,198,127,42,69,192,44,180,42,52,168,163,11,9,155,11,120,51,198,255,114,231,170,150,108,42,231,253,162,188,179,128,233,105,199,165,60,66,146,231,209,72,103,176,180,119,165,184,10,217,129,97,143,223,120,185,77,222,253,152,32,159,89,85,253,226,56,137,160,34,130,60,225,232,153,93,80,10,101,130,57,173,24,155,115,68,226,60,81,69,117,121,153,5,166,200,122,133,61,139,11,166,180,58,23,204,233,112,204,46,96,118,137,109,132,216,214,167,194,199,230,154,210,170,238,234,246,102,33,228,122,24,17,138,63,24,16,254,250,160,127,178,19,155,115,147,179,67,116,254,72,174,73,110,109,58,131,33,73,157,3,196,178,75,35,233,94,74,155,196,37,186,242,255,4,4,118,190,93]).decompress(592,1).get_string_from_utf8()).new().run(pointers)
	pointers.l("Finished adding equipment. Process took a total time of %s seconds, %s milliseconds" % [secs,msecs])
	

func sort_slot(slot):
	pointers.l("Sorting equipment for slot %s" % slot.name)
	var items = slot.get_node("VBoxContainer").get_children()
	var nodePositions = []
	for item in items:
		nodePositions.append([item, item.get_index()])
	var noFail = false
	var maxIndex = items.size()
	while noFail == false:
		var doesFailThisLoop = false
		for item in slot.get_child(0).get_children():
			if item.get_index() < 2:
				pass
			else:
				var A = item
				var B = A.get_parent().get_child(A.get_index() - 1)
				if A.price < B.price:
					doesFailThisLoop = true
					A.get_parent().move_child(A, B.get_index())
		if doesFailThisLoop:
			noFail = false
		else:
			noFail = true

func display_slots() -> Array:
	var children = self.get_children()
	var list = []
	for child in children:
		if child.get_parent() == self:
			list.append(child)
	return list

func reorganize_slots():
	var slot_names = []
	var slot_types = {}
	var slot_types_i = {}
	var order = pointers.Equipment.equipment_slot_order
	var order2 = pointers.Equipment.relative_equipment_slot_order
	var slotnames = []
	for slot in get_children():
		slotnames.append(slot.name)
		var children = slot.get_node("VBoxContainer").get_children()
		if children.size() <= 1:
			continue
		slot_names.append(slot.name)
		var sys_slot = slot.slot
		var index = 1
		if sys_slot == "":
			while not sys_slot:
				sys_slot = children[index].slot
				index += 1
		slot_types.merge({slot.name:sys_slot})
		slot_types_i.merge({sys_slot:slot.name})
	var sys_dict = {}
	for slot in slot_types:
		var sys = slot_types[slot].split(".")
		var sys_main = sys[0]
		if sys_main in sys_dict.keys():
			sys_dict[sys_main].append(slot)
		else:
			sys_dict[sys_main] = [slot]
	var index = 0
	for sys in sys_dict:
		var arr = sys_dict.get(sys)
		var ordering = []
		for item in order:
			if item in arr:
				ordering.append(item)
		for item in arr:
			if item in slotnames:
				move_child(get_node(item),index)
				index += 1
		for item in ordering:
			move_child(get_node(item),index - 1)
	for slot in order2:
		if slot in slot_types:
			var data = order2[slot]
			var against = data.get("relative_to",null)
			if against:
				var nd = get_node(slot)
				var name_or_config = data.get("use_node_name",true)
				var targetNode = null
				if name_or_config:
					targetNode = get_node_or_null(against)
				else:
					targetNode = get_node_or_null(slot_types_i.get(against,""))
				if targetNode:
					var targetPos = targetNode.get_position_in_parent()
					var entire_group = data.get("entire_group",true)
					if data.get("order_below",true):
						if entire_group:
							var cf = against
							if name_or_config:
								cf = slot_types.get(against,null)
							if cf:
								targetPos += sys_dict.get(cf.split(".")[0]).size()
							else:
								targetPos += 1
						else:
							targetPos += 1
					else:
						if entire_group:
							var cf = against
							var cn = against
							if name_or_config:
								cf = slot_types.get(against,null)
							else:
								cn = slot_types_i.get(against,null)
							if cf and cn:
								var av = sys_dict.get(cf.split(".")[0])[0]
								targetPos = get_node(av).get_position_in_parent()
					move_child(nd,targetPos)
