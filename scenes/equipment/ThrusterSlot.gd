extends "res://ships/modules/ThrusterSlot.gd"

var auxslot_save_path = "user://cache/.HevLib_Cache/Dynamic_Equipment_Driver/power/AuxSlot.json"

var file = File.new()
var mpdg = load("res://ships/modules/AuxMpd.tscn")
var smes = load("res://ships/modules/AuxSmes.tscn")
var thruster = load("res://sfx/thruster.tscn")

const torch_base_scale = Vector2(0.939,1.395)
const rcs_base_scale = Vector2(0.2,0.2)
const thruster_base_pos = Vector2(0,-3)

func _ready():
	file.open(auxslot_save_path,File.READ)
	var datastore = JSON.parse(file.get_as_text()).result
	file.close()
	var slotType = type.split(".")[0]
	var currentInstall = ship.getConfig(type)
	if slotType in datastore:
		for data in datastore[slotType]:
			var aux_path = data.get("path","")
			var aux_type = data.get("type","MPDG").to_upper()
			var item
			var sys = data.get("system","SYSTEM_NAME_MISSING")
			if sys == currentInstall:
				match aux_type:
					"MPDG":
						item = mpdg.instance()
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
						
					"SMES":
						item = smes.instance()
						sys = data.get("system","SYSTEM_NAME_MISSING")
						item.name = sys
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
				
				
				
				
				
				
				
				
				
				
				
				
				
				item.name = sys
				
				
				
				
				
				
				
				
				if item:
					add_child(item)
