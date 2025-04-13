extends Node

var developer_hint = {
	"__webtranslate":[
		"Loads translations from a given Gihub repository",
		"Has to be specifically a repository link",
		" -> E.G. https://github.com/rwqfsfasxc100/HevLib"
	],
	"__webtranslate_reset":[
		"Clears the translation cache of a provided URL",
		"Returns true if succeeded, false if it didn't"
	],
	"__webtranslate_timed":[
		"Similar function to __webtranslate, however performs the task repetitively",
		"URL is the same as the URL string for __webtranslate",
		"Optional MINUTES_DELAY integer is the delay between runs of the __webtranslate tool",
		" -> Defaults to 30 minutes if left blank"
	]
}

static func __webtranslate(URL: String):
	var f = load("res://HevLib/webtranslate/webtranslate.gd")
	f.webtranslate(URL)

static func __webtranslate_reset(URL: String) -> bool:
	var f = load("res://HevLib/webtranslate/webtranslate_reset.gd")
	var s = f.webtranslate_reset(URL)
	return s

static func __webtranslate_timed(URL: String, MINUTES_DELAY: int = 30):
	var f = load("res://HevLib/webtranslate/webtranslate_timed.gd").new()
	var s = f.webtranslate_timed(URL, MINUTES_DELAY)
