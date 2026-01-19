extends "res://AsteroidSpawner.gd"


func spawnAsteroidByClass(oc, spot, chaos, spawnPointRandomness = 0.0, initialLinearVelocity = Vector2(0, 0), initialAngularVelocity = 0.0, tries = 1, spawned = true):
	#Generate the asteroid normally
	var i = .spawnAsteroidByClass(oc, spot, chaos, spawnPointRandomness, initialLinearVelocity, initialAngularVelocity, tries, spawned)
	
	
	#If it's a class 5 roid, it's a mineral chunk
	if oc == 5 and i:
		var pure : float
		var impure : float

		#How many minerals are possible
		var sm : int = randi() % 3

		#If there are sub-minerals possible
		if sm > 0:
			#How much of the mineral should remain its base type
			pure = i.composition[i.mineral] * range_lerp(i.purity, 0.0, 1.0, 0.5, 0.9) #maps the purity to between 0.5 and 0.9
			#How much of the mineral should become a different mineral
			impure = i.composition[i.mineral] - pure
			#Set the mineral to its new quantity
			i.composition[i.mineral] = pure

		#While we have uncalculated sub-minerals AND 1kg of impurity remaining
		while sm > 0 and impure > 0.001:
			#Remove 1 sub-mineral from the count
			sm -= 1
			#Get mineral vein
			var m : String = getVeinAt(CurrentGame.globalCoords(spot))

			#Quantity of mineral
			var q : float
			#While there is more than one sub-mineral remaining
			if sm > 0:
				#Choose how much of the impurity should be the new mineral
				q = rand_range(0, impure)
				#Reduce the impurity left by that amount
				impure -= q
			#If this is the last sub-mineral
			else:
				#The remaining quantity should be this mineral
				q = impure
				impure = 0
			
			# Checks for the mineral in an array of mineral entries
			# Fix for one bug in the preexisting mod
			var doesContainMineral = false
			var comp = i.composition.keys()
			for t in comp:
				if t == m:
					doesContainMineral = true
			if not m == null:
				#If the roid already has that mineral
				if doesContainMineral:
					#Add it to the existing amount
					i.composition[m] += q
				#If the roid does not have that mineral
				else:
					var mergeDict = {m:q}
					#Add it to the roid
					i.composition.merge(mergeDict)
		if i.has_method("update_mass"):
			i.update_mass()
		else:
			var ps = update_mass(i)
			i = ps
		
	return i
#Update the roid's mass incase something went fucky
func update_mass(i):
	calc_comp(i)
	i.mass = comp_val
	return i

#Sum of all components of the roid
var comp_val = 0.0
func calc_comp(i):
#	print(composition)
	comp_val = 0.0
	#For every material in the roid
	for type in i.composition:
		#If that material actually exists 
		if i.composition[type] >= 0.001:
			#Add it to our sum
			comp_val += i.composition[type]
		#If the material does not exist
		else:
			#Remove the stray atoms
			i.composition.erase(type)


	return i
