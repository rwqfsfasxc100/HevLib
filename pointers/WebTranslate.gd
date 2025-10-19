extends Node

var developer_hint = {
	"__webtranslate":[
		"Loads translations from a given Gihub repository",
		"Has to be specifically a repository link",
		" -> E.G. https://github.com/rwqfsfasxc100/HevLib",
		"Optional fallback array is a list of files that will be used for translations in the case that WebTranslate can't fetch data after 10 seconds",
		" -> Defaults to an empty array ([])",
		" -> Each entry must be the full res:// path to the file"
	],
	"__webtranslate_reset_by_URL":[
		"Clears the translation cache of a provided URL",
		"Returns true if succeeded, false if it didn't"
	],
	"__webtranslate_timed":[
		"Similar function to __webtranslate, however performs the task repetitively",
		"URL is the same as the URL string for __webtranslate",
		"Optional MINUTES_DELAY integer is the delay between runs of the __webtranslate tool",
		" -> Defaults to 30 minutes if left blank",
		"Optional fallback array is a list of files that will be used for translations in the case that WebTranslate can't fetch data after 10 seconds",
		" -> Defaults to an empty array ([])",
		" -> Each entry must be the full res:// path to the file"
	],
	"__webtranslate_reset_by_file_check":[
		"Similar function to __webtranslate_reset_by_URL, instead resets by the file_check string used in __webtranslate",
		"file_check -> string used as the file check. If found in the cache, resets translations for it"
	]
}
const wt = preload("res://HevLib/webtranslate/webtranslate.gd")
static func __webtranslate(URL: String, fallback: Array = [], file_check: String = ""):
	wt.webtranslate(URL, fallback, file_check)
const wtrbu = preload("res://HevLib/webtranslate/webtranslate_reset.gd")
static func __webtranslate_reset_by_URL(URL: String) -> bool:
	var s = wtrbu.webtranslate_reset(URL)
	return s
const wtrbfc = preload("res://HevLib/webtranslate/webtranslate_reset_by_file_check.gd")
static func __webtranslate_reset_by_file_check(file_check: String) -> bool:
	var s = wtrbfc.webtranslate_reset_by_file_check(file_check)
	return s
const wtt = preload("res://HevLib/webtranslate/webtranslate_timed.gd")
static func __webtranslate_timed(URL: String, MINUTES_DELAY: int = 30, fallback: Array = [], file_check: String = ""):
	var f = wtt.new()
	var s = f.webtranslate_timed(URL, MINUTES_DELAY, fallback, file_check)
