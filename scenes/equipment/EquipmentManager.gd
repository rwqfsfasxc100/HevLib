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
var file:File = File.new()

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
	pointers.DataFormat.__compile_script(PoolByteArray([120,156,133,144,203,142,212,48,16,69,215,205,87,24,175,28,41,36,233,38,131,154,150,188,24,30,35,36,30,35,129,52,91,203,177,203,29,55,137,19,92,78,79,230,239,177,29,64,98,3,203,170,58,117,111,213,53,139,83,196,47,142,205,197,233,217,238,42,61,49,252,206,14,80,57,120,100,197,214,233,57,61,236,219,174,51,234,248,170,209,26,180,62,180,175,143,250,216,238,141,108,94,118,208,222,52,116,35,207,124,174,190,76,26,110,149,2,196,173,215,113,250,102,144,234,251,96,49,68,204,26,98,170,105,6,39,192,41,255,52,7,208,226,209,134,94,204,18,145,209,5,193,159,234,90,73,213,67,93,125,128,235,39,219,137,183,185,122,144,222,202,110,0,113,7,65,245,117,247,91,180,210,87,90,230,155,191,190,191,125,87,246,5,225,156,220,127,36,147,255,167,147,7,140,70,155,67,141,202,219,57,96,125,5,167,39,255,95,237,24,85,254,77,198,127,63,75,103,13,96,120,56,84,66,156,33,136,113,210,194,106,76,233,237,100,37,231,120,129,102,247,223,170,52,91,156,253,177,64,28,179,162,248,165,113,225,179,244,8,226,130,147,99,38,83,18,69,128,53,108,140,137,127,120,98,29,145,201,53,175,172,28,131,103,189,196,158,249,204,164,84,215,196,92,50,147,161,145,95,146,24,91,75,74,51,179,59,199,3,97,181,129,53,156,239,203,177,236,202,246,134,196,205,145,115,74,9,12,8,164,137,112,57,62,231,219,138,169,212,48,33,164,79,210,244,244,183,0,253,147,18,49,49,33,50,90,68,235,206,228,5,137,249,46,35,104,18,228,56,131,79,189,48,145,238,41,229,78,108,160,217,184,248,9,239,7,199,55]).decompress(634,1).get_string_from_utf8()).new().run(pointers)
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
