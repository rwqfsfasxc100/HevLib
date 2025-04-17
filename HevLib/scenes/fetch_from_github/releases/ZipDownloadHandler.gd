extends HTTPRequest

var nodeToReturnTo

var filePath = ""

func _on_zip_request_completed(result, response_code, headers, body):
	var downloadedFile = ""
	var headerSplitter = "Content-Disposition: attachment; filename="
	for m in headers:
		if m.begins_with(headerSplitter):
			downloadedFile = m.split(headerSplitter)[1]
	if not filePath.ends_with("/"):
		filePath = filePath + "/"
	filePath = filePath + downloadedFile
	if not nodeToReturnTo == null:
		nodeToReturnTo._downloaded_zip(downloadedFile, filePath)
	
	
	
	
	
	
	
