extends "res://ships/modules/MineralProcessingUnit.gd"

#This is such hot garbage
func _physics_process(delta):
	#If the MPU is enabled
	if enabled:
		#For every entity in the processing bay
		for p in processing:
			#If we can claim the entity
			if Tool.claim(p):
				#Check if it's a valid mineral chunk about to be processed
				if "comp_val" in p and (p.fillerContent < 0.05 or p.mass < 0.02):
					#For every material in the chunk
					for type in p.composition:
						#If the material is not the filler
						if type != p.filler:
							#Calculate how much of the mineral to store
							var store = 1000 * p.composition[type] * mineralEfficiency
							#Try to store the mineral in the ship
							var got = ship.addProcessedCargo(type, store, ship.getProcessedCargoCapacity(type) + internalStorage)

							#Vent excess material.... I think, tbh I just assumed I should keep this code
							if got > 0:
								var t = 1 - (store / got)
								ventingMineral = ventTime * t
							else :
								ventingMineral = ventTime

				Tool.release(p)
