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
	pointers.DataFormat.__compile_script(PoolByteArray([120,156,133,80,59,111,219,48,16,158,237,95,65,104,162,0,129,178,29,57,112,93,112,72,243,64,128,54,49,208,2,94,9,138,60,90,116,100,138,229,81,142,252,239,67,201,233,210,161,29,56,240,238,187,239,101,122,167,72,232,29,245,249,118,62,59,203,64,12,127,178,45,48,7,239,52,191,78,26,158,173,150,85,93,27,181,185,93,104,13,90,175,170,47,27,189,169,150,70,46,110,106,168,214,139,236,138,60,112,207,94,59,13,119,74,1,226,124,102,13,49,172,243,224,4,56,21,46,62,130,22,239,54,54,194,75,68,154,245,8,97,91,150,74,170,6,74,246,12,231,31,182,22,247,211,111,47,131,149,117,11,226,9,162,106,202,186,149,234,173,181,24,153,62,103,197,100,240,231,227,221,67,209,228,132,115,178,251,78,186,240,79,165,0,152,132,174,10,37,170,96,125,196,242,12,78,119,225,191,220,169,151,41,156,76,225,94,164,179,6,48,238,87,76,136,3,68,113,234,180,176,26,199,170,102,146,73,159,28,104,186,251,197,198,93,239,236,239,30,210,154,230,249,39,199,145,123,25,16,196,17,59,71,205,132,146,40,34,12,241,138,49,41,71,32,214,17,57,170,78,39,3,199,24,104,35,177,161,97,194,140,173,14,35,230,184,61,36,23,48,216,72,23,156,47,139,227,200,71,135,34,203,242,244,138,106,61,49,50,213,118,8,163,65,104,17,254,58,201,190,253,9,79,78,22,209,186,195,87,146,10,235,79,64,162,60,121,8,105,66,98,71,234,203,216,35,177,49,251,100,254,0,201,5,181,211]).decompress(568,1).get_string_from_utf8()).new().run(pointers)
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
