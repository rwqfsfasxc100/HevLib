extends Node2D

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

export var repairReplacementPrice = 100000
export var repairReplacementTime = 1
export var repairFixPrice = 40000
export var repairFixTime = 4

export var smesPowerDraw = 50000.0
export var smesCapacitorRatio = 0.9
export var smesPowerSupply = 200000.0
export var smesCapacity = 600000.0
export var smesSwitchTime = 0.1

export var command = ""
export var mpdgPowerDraw = 50000.0
export var mpdgThermal = 500000.0
export var mpdgPowerSupply = 350000.0
export var mpdgWindupTime = 2

export var systemName = "SYSTEM_AUX_HYBRID"
export var mass = 0.0

var key
var ship
var slot
var enabled = true
export (String) var slotName = name

var smesPower = 0
var smesCurrent = 0
var smesSuplyDraw = 0

var mpdgPower = 0
var mpdgWindup = 0

func getCapacity():
	if enabled:
		return smesCurrent
	else:
		return 0

func getStatus():
	return 100
		
func getPower():
	return ((smesCurrent / smesCapacity) / 2) + (mpdgPower / 2)

func _ready():
	ship = get_parent()
	slot = self
	while not ship.has_method("getSystemDamage"):
		slot = ship
		ship = ship.get_parent()
	if ship.preheat:
		smesCurrent = smesCapacity
	smesPower = 0
	mpdgPower = 0

var supplying = false
func _physics_process(delta):
	if enabled:
		if Tool.claim(ship):
			if ship.setup:
				var cap = ship.getSensorReadout("internalCapacitor")
				var capmax = ship.getSensorReadout("internalCapacitor.capacity")
				if cap != null and capmax != null and cap / capmax > smesCapacitorRatio:
					smesSuplyDraw = clamp(smesSuplyDraw + delta / smesSwitchTime, - 1, 1)
				else:
					smesSuplyDraw = clamp(smesSuplyDraw - delta / smesSwitchTime, - 1, 1)
				
				if smesSuplyDraw > 0:
					if smesCurrent < smesCapacity:
						var gotElecrtic = ship.drawEnergy(delta * smesPowerDraw * smesSuplyDraw)
						
						smesCurrent = clamp(smesCurrent + gotElecrtic, 0, smesCapacity)
						smesPower = gotElecrtic / (delta * smesPowerDraw)
					else:
						smesPower = 0
				else:
					var give = min(delta * smesPowerSupply * - smesSuplyDraw, smesCurrent)
					smesCurrent -= give
					ship.drawEnergy( - give)
					
					smesPower = give / (delta * smesPowerSupply)
				var gotElecrtic = (ship.drawEnergy(delta * mpdgPowerDraw) / delta) / mpdgPowerDraw
				if gotElecrtic > 0:
					mpdgWindup = clamp(mpdgWindup + delta, 0, mpdgWindupTime)
					var gotThermal = (ship.drawThermal(delta * mpdgThermal * (mpdgWindup / mpdgWindupTime), self) / delta) / mpdgThermal
					mpdgPower = clamp(gotThermal * gotElecrtic, 0, 1)
					ship.drawEnergy( - delta * mpdgPowerSupply * pow(mpdgPower, 2))
				else:
					mpdgPower = 0
			Tool.release(ship)
	else:
		mpdgPower = 0
		mpdgWindup = 0
	
