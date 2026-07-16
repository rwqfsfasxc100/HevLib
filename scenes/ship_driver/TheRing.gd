extends "res://TheRing.gd"

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

func _ready():
	var pointers = ModLoader._savedObjects[0]
	var data = pointers.Equipment.add_ships_store
	var ro = load("res://story/RescueOperation.gd")
	for i in range(data.size()):
		var ship = data[i]
		if "name" in ship:
			var derelict_data = ship.get("derelict",{})
			var model = ship.get("name","TRTL")
			var dname = ship.get("specific_derelict_name","ModdedDerelict_" + model)
			var node = ro.new()
			node.name = dname
			var newname = node.name
			node.randomChance = 0.0
			node.minimumChance = 0.0
			node.chaosLimit = 3.0
			
			node.model = model
			
			node.reEncouterChance = clamp(1.0 - derelict_data.get("stock_chance",0.2),0,1)
			node.damageDerelict = derelict_data.get("allow_damage",true)
			node.extraDamage = derelict_data.get("cause_extra_damage",true)
			node.denseClusterChance = derelict_data.get("rock_cluster_chance",0.3)
			node.denseClusterNumber = derelict_data.get("rock_cluster_count",33)
			node.clump = derelict_data.get("clump",false)
			node.clumpVelocity = derelict_data.get("clump_velocity",25)
			node.stormChance = derelict_data.get("ring_storm_chance",0.3)
			node.pirateChance = derelict_data.get("pirate_chance",0.3)
			node.rescue = derelict_data.get("rescue",false)
			
			add_child(node)
