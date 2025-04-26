extends Node

var developer_hint = {
		"__get_file_content":[
			"Returns the content from a file as a string"
		]
	}

static func __get_file_content(file: String) -> String:
	var f = load("res://HevLib/globals/get_file_content.gd")
	var s = f.get_file_content(file)
	return s
