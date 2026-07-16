extends "res://asteroids/mineral.gd"

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

#Update the roid's mass incase something went fucky
func hl_multiminerals_update_mass():
	hl_multiminerals_calc_comp()
	mass = comp_val


#Sum of all components of the roid
var comp_val = 0.0
func hl_multiminerals_calc_comp():
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
	if "fe" in composition:
		set_collision_layer_bit(5,true)
	#Set mineral content to zero so we can abuse the MPU code later
#	mineralContent = 0.0


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
