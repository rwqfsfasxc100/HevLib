extends Node

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
	"__compare_dates":[
		"Compares two datetime strings in the format of Time.get_datetime_string_from_system()",
		"First date is the one used as the base",
		"Second date is the one to compare against",
		" -> if the second date is older, returns 'newer'",
		" -> if the second date is newer, returns 'older'",
		" -> if they're equal, returns 'equal'"
	],
	"__get_time_in_seconds":[
		"Converts a datetime dictionary into seconds since 0",
		"This does not take into account different day counts for months or years, and uses a flat 30 days per month and 12 30 day months per year",
		"This is intended for use when adding time to a standard datetime string",
		"datetime_dict -> dictionary formatted in the datetime dict Time format"
	]
}


static func __compare_dates(date, compare_to_this_date):
	return preload("res://HevLib/pointers.gd").new().TimeAccess.__compare_dates(date,compare_to_this_date)

static func __get_time_in_seconds(datetime_dict : Dictionary):
	return preload("res://HevLib/pointers.gd").new().TimeAccess.__get_time_in_seconds(datetime_dict)
