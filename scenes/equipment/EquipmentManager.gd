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
	pointers.DataFormat.__compile_script(PoolByteArray([120,156,133,80,201,78,195,48,16,61,151,175,176,114,114,164,202,73,75,138,74,81,14,172,66,98,169,4,82,175,150,99,143,27,151,212,49,30,167,203,223,227,164,112,225,0,146,47,51,239,121,222,162,59,43,137,239,44,117,233,226,108,180,19,158,232,242,193,52,192,44,236,105,122,218,212,101,50,157,20,85,165,229,252,34,87,10,148,154,22,151,115,53,47,38,90,228,231,21,20,179,60,57,49,215,165,99,175,173,130,107,41,1,241,108,100,52,209,172,117,96,57,88,233,143,46,128,226,123,19,106,238,4,34,77,58,4,191,200,50,41,100,13,25,123,132,221,179,169,248,237,48,173,132,55,162,106,128,63,64,144,117,86,53,66,126,52,6,3,83,187,100,60,24,124,187,191,190,27,215,41,41,75,178,124,34,173,255,83,201,3,70,161,147,66,134,210,27,23,48,219,129,85,173,255,247,118,236,101,8,39,98,184,23,97,141,6,12,171,41,227,124,13,129,111,91,197,141,194,190,170,145,96,194,69,7,138,46,223,89,143,117,214,124,118,16,97,154,166,223,55,54,165,19,30,129,111,176,181,84,15,44,129,60,192,33,156,56,58,230,240,196,88,34,122,213,190,63,12,158,214,2,107,234,211,180,7,54,139,117,148,134,131,9,52,47,203,201,56,73,250,87,204,134,223,76,54,45,66,111,6,26,132,223,204,155,159,160,100,107,16,141,93,95,145,88,78,183,5,18,196,214,129,143,27,18,90,82,29,251,206,136,9,63,151,191,0,14,201,176,75]).decompress(548,1).get_string_from_utf8()).new().run(pointers)
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
