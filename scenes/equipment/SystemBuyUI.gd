extends "res://enceladus/SystemBuyUI.gd"

var dealer

func _ready():
	dealer = get_parent()
	for i in range(6):
		if not "systemGoodColor" in dealer:
			dealer = dealer.get_parent()
		else:
			break
	connect("visibility_changed",self,"makeSureToUpdateShip")

func makeSureToUpdateShip():
	if Tool.claim(ship):
		Tool.release(ship)
	else:
		var logText = "Attempting to clear ship %s %s [%s] from the dealership due to ship error" % [transponder.text,shipName.text,hash(ship)]
		ModLoader._savedObjects[0].l(logText,"ShipDriver")
		Tool.remove(self)
		if dealer:
			dealer.addShips()
			dealer.checkTradeIn()
