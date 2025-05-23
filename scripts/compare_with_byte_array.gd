extends Node

static func compare_with_byte_array(input_string: String, comparison_string: String) -> bool:
	var input_array = input_string.to_utf8()
	var comparison_array = comparison_string.to_utf8()
	var input_size = input_array.size()
	var comparison_size = comparison_array.size()
	if input_size != comparison_size:
		return false
	var isize = input_size
	while isize > 0:
		isize = isize - 1
		if input_array[isize] != comparison_array[isize]:
			return false
	return true
