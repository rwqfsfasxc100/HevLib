extends HTTPRequest

var nodeToReturnTo

var filePath = ""

var updating_percent = false
var percent:float = 0
var bytes_downloaded: int = 0
var total_bytes: int = 0

func _ready():
	is_updating(false)

func request(url,custom_headers:PoolStringArray = [],ssl_validate_domain: bool = true, method = 0,request_data:String = ""):
	if nodeToReturnTo and nodeToReturnTo.has_method("_get_github_progress"):
		nodeToReturnTo._get_github_progress("HEVLIB_GITHUB_PROGRESS_ZIP_FOUND_AND_REQUESTING",0,0,0)
		Tool.deferCallInPhysics(self,"is_updating",[true])
	.request(url,custom_headers,ssl_validate_domain,method,request_data)

func _on_zip_request_completed(result, response_code, headers, body):
	var downloadedFile = ""
	var headerSplitter = "Content-Disposition: attachment; filename="
	for m in headers:
		if m.begins_with(headerSplitter):
			downloadedFile = m.split(headerSplitter)[1]
	if not filePath.ends_with("/"):
		filePath = filePath + "/"
	filePath = filePath + downloadedFile
	is_updating(false)
	if nodeToReturnTo.has_method("_get_github_progress"):
		nodeToReturnTo._get_github_progress("HEVLIB_GITHUB_PROGRESS_DOWNLOADED_FILE",0,0,0)
	if nodeToReturnTo.has_method("_downloaded_zip"):
		nodeToReturnTo._downloaded_zip(downloadedFile, filePath)
	else:
		Debug.l("HevLib Github Release Downloader: Error! Function _downloaded_zip does not exist at the target [%s]" % str(nodeToReturnTo))
	
	
#	Tool.deferCallInPhysics(self,"is_updating",[false])
	

func _physics_process(delta):
	if updating_percent:
		total_bytes = get_body_size()
		bytes_downloaded = get_downloaded_bytes()
		var frac = float(bytes_downloaded)/float(total_bytes)
		var f2 = frac * 100
		percent = f2
		if bytes_downloaded > 0.0:
			_handle_downloaded_percent()

func is_updating(how):
	set_physics_process(how)
	updating_percent = how
	if not how:
		percent = 0
		bytes_downloaded = 0
		total_bytes = 0

func _handle_downloaded_percent():
	if nodeToReturnTo and nodeToReturnTo.has_method("_get_github_progress"):
		if total_bytes > 0:
			nodeToReturnTo._get_github_progress("HEVLIB_GITHUB_PROGRESS_DOWNLOADING",percent,bytes_downloaded,total_bytes)
		else:
			nodeToReturnTo._get_github_progress("HEVLIB_GITHUB_PROGRESS_DOWNLOADING_ONLY_BYTES",percent,bytes_downloaded,total_bytes)
		
