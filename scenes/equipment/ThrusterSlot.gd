extends "res://ships/modules/ThrusterSlot.gd"

var auxslot_save_path = "user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/power/AuxSlot.json"

var file = File.new()
var mpdg = load("res://ships/modules/AuxMpd.tscn")
var smes = load("res://ships/modules/AuxSmes.tscn")

func _ready():
	match type:
		"aux.power":
			file.open(auxslot_save_path,File.READ)
			for data in JSON.parse(file.get_as_text()).result:
				var aux_path = data.get("path","")
				var aux_type = data.get("type","MPDG").to_upper()
				match aux_type:
					"MPDG":
						var item = mpdg.instance()
						var system = data.get("system","SYSTEM_NAME_MISSING")
						item.name = system
						item.repairReplacementPrice = data.get("price",30000)
						item.repairReplacementTime = data.get("repair_time",1)
						item.repairFixPrice = data.get("fix_price",5000)
						item.repairFixTime = data.get("fix_time",4)
						item.command = data.get("command","")
						item.powerDraw = data.get("power_draw",50000.0)
						item.thermal = data.get("thermal",500000.0)
						item.powerSupply = data.get("power_supply",350000.0)
						item.windupTime = data.get("windup_time",2)
						item.mass = data.get("mass",0.0)
						if ship.shipConfig.aux.power == system:
							add_child(item)
						
					"SMES":
						var item = smes.instance()
						var system = data.get("system","SYSTEM_NAME_MISSING")
						item.name = system
						item.repairReplacementPrice = data.get("price",40000)
						item.repairReplacementTime = data.get("repair_time",1)
						item.repairFixPrice = data.get("fix_price",25000)
						item.repairFixTime = data.get("fix_time",4)
						item.capacitorRatio = data.get("capacitor_ratio",0.9)
						item.command = data.get("command","")
						item.powerDraw = data.get("power_draw",50000.0)
						item.capacity = data.get("capacity",600000.0)
						item.powerSupply = data.get("power_supply",200000.0)
						item.switchTime = data.get("switch_time",2)
						item.mass = data.get("mass",0)
						if ship.shipConfig.aux.power == system:
							add_child(item)
						
			
