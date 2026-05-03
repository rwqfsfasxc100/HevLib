extends Node2D

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
	
