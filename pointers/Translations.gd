extends Node

var developer_hint = {
	"__updateTL": [
		"Updates translations from a file in CSV format",
		" -> path - path to the file to fetch translations from",
		" -> delim - the delimiter used for the CSV",
		" -> fullLogging - whether to be verbose and state every translation made, or to display only the number of updated translations"
	]
}

static func __updateTL(path:String, delim:String = ",", fullLogging:bool = true):
	var f = load("res://HevLib/scripts/updateTL.gd")
	f.updateTL(path, delim, fullLogging)
