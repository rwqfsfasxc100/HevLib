extends "res://enceladus/ServiceUI.gd"

export (String, "", "civilian", "pirate", "helper", "secret", "vilcy", "racer", "obonto") var factionBased = ""
export (float, - 100000, 100000, 1000) var fearPrice = 0.0
export (float, - 100000, 100000, 1000) var hostilityPrice = 0.0

export (float, 0, 100000, 1000) var insuranceGain = 0.0

func buy():
	.buy()
	CurrentGame.changeInsurance(insuranceGain)
	if factionBased:
		var disp = Factions.getDispositionTowards(factionBased, "player")
		Factions.adjustFactionDisposition(factionBased, "player", "hostility", - disp.hostility)
		Factions.adjustFactionDisposition(factionBased, "player", "fear", - disp.fear)
	
func getPrice():
	var factionPrice = 0
	if factionBased:
		var disp = Factions.getDispositionTowards(factionBased, "player")
		factionPrice = max(0, disp.hostility * hostilityPrice) + max(0, disp.fear * fearPrice)
	
	return .getPrice() + factionPrice
	
