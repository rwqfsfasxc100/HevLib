extends "res://asteroids/mineral.gd"


#Update the roid's mass incase something went fucky
func update_mass():
	calc_comp()
	mass = comp_val


#Sum of all components of the roid
var comp_val = 0.0
func calc_comp():
#	print(composition)
	comp_val = 0.0
	#For every material in the roid
	for type in composition:
		#If that material actually exists 
		if composition[type] >= 0.001:
			#Add it to our sum
			comp_val += composition[type]
		#If the material does not exist
		else:
			#Remove the stray atoms
			composition.erase(type)

	#Set mineral content to zero so we can abuse the MPU code later
	mineralContent = 0.0


#Func to let scanners detect all minerals
func getScan():
	#Get our scan value
	var scan : float = rand_range(0, comp_val)
	#For every material in the roid
	var cm = composition.duplicate(true)
	if "H2O" in cm:
		cm.erase("H2O")
	for type in cm:
		#If the scan value is less then the material value
		if scan < cm[type]:
			#Detect that meterial
			return type
		#Otherwise, reduce the scan value and try the next material
		scan -= cm[type]

	#If nothing was detected for some reason, default to the filler
	return filler
