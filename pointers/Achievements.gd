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

var developer_hint = {
	"__get_achievement_data":[
		"Gets the data of a provided achievement by it's ID",
		"Returns a dictionary with 7 keys:",
		"name = the achievement's ID for convenience",
		"isUnlocked = boolean for whether the achievement is unlocked or not",
		"stat = associated stat name, w/o the stat: prefix",
		"limit = the stat's unlocking threshhold",
		"data = any additional data that might be useful to provide. ",
		" -> currently only provides the ship/equipment names of playtime achievements in untranslated form",
		"rare = based on whether the game considers an achievement rare",
		"spoiler = whether the achievement is considered a spoilered achievement on steam.",
		" -> manually inputted data, so may be missing data in the days following an update that adds achievements"
		],
	"__get_stat_data":[
		"Gets the numerical value of the provided stat"
		]
}

static func __get_achievement_data(achievementID: String) -> Dictionary:
	return preload("res://HevLib/pointers.gd").new().Achievements.__get_achievement_data(achievementID)

static func __get_stat_data(stat: String) -> float:
	return preload("res://HevLib/pointers.gd").new().Achievements.__get_stat_data(stat)
