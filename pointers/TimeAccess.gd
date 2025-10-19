extends Node

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
	var isDifferent = false
	var difference = "newer"
	var splitOne = date.split("T")
	var splitTwo = compare_to_this_date.split("T")
	var dateOne = splitOne[0].split("-")
	var dateTwo = splitTwo[0].split("-")
	var timeOne = splitOne[1].split(":")
	var timeTwo = splitTwo[1].split(":")
	var concatOne = [dateOne[0],dateOne[1],dateOne[2],timeOne[0],timeOne[1],timeOne[2]]
	var concatTwo = [dateTwo[0],dateTwo[1],dateTwo[2],timeTwo[0],timeTwo[1],timeTwo[2]]
	var index = 0
	while index < 6:
		var compare1 = concatOne[index]
		var compare2 = concatTwo[index]
		if compare1 > compare2:
			isDifferent = true
			difference = "newer"
		if compare1 < compare2:
			isDifferent = true
			difference = "older"
		if compare1 == compare2:
			isDifferent = false
			difference = "equal"
		
		if isDifferent:
			return difference
		index += 1
	if index >= 6:
		return "equal"

static func __get_time_in_seconds(datetime_dict : Dictionary):
	var time : int = 0
	time += (datetime_dict.get("second",0))
	time += (datetime_dict.get("minute",0) * 60)
	time += (datetime_dict.get("hour",0) * 60 * 60)
	time += (datetime_dict.get("day",0) * 60 * 60 * 24)
	time += (datetime_dict.get("month",0) * 60 * 60 * 24 * 30)
	time += (datetime_dict.get("year",0) * 60 * 60 * 24 * 30 * 12)
	
	
	return time
