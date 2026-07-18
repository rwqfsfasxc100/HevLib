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

func clear_event(event : String, ring, clear_related_poi : bool = true,clear_in_cargo : bool = false):
	Debug.n("HevLib EventDriver: clearing oddities %s" % event)
	if event == "" or event == "none":
		var events = ring.all_oddities
		for e in events:
			if Tool.claim(e):
				if e.is_node_ready() and clear_if_cargo(e,clear_in_cargo):
					ring.all_oddities.erase(e)
					Tool.release(e)
					Tool.remove(e)
					
	elif event in ring.group:
		var events = ring.group[event]
		if events.size():
			for e in events:
				if Tool.claim(e):
					if e.is_node_ready() and clear_if_cargo(e,clear_in_cargo):
						if clear_related_poi:
							clear_poi_for(e.global_position,event)
						ring.group[event].erase(e)
						Tool.release(e)
						Tool.remove(e)
						

func clear_if_cargo(object,do):
	if not do:
		var focus = CurrentGame.getPlayerShip()
		if object in focus.cargo:
			return false
	return true

func clear_poi_for(globalPos : Vector2,this_event: String):
#	var focus = CurrentGame.getPlayerShip()
	
	var nearby = CurrentGame.getEventNear(CurrentGame.globalCoords(globalPos))
	
	while nearby and nearby.event == this_event:
		var astro = CurrentGame.state.astrogation
		for event in astro:
			var ev = astro[event]
			if ev.event == nearby.event and Vector2(ev.vector.x,ev.vector.y).distance_to(nearby.vector) < 2000:
				CurrentGame.forgetPoi(event)
		nearby = CurrentGame.getEventNear(CurrentGame.globalCoords(globalPos))
