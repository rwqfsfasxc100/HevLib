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

const pointers = preload("res://HevLib/pointers.gd")


static func __compare_dates(date, compare_to_this_date):
	return pointers.new().TimeAccess.__compare_dates(date,compare_to_this_date)

static func __get_time_in_seconds(datetime_dict : Dictionary):
	return pointers.new().TimeAccess.__get_time_in_seconds(datetime_dict)
