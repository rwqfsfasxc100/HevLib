# miniz

Allows the reading, writing, and manipulation of ZIP files.

## Description

This class implements a means of reading, creating, or modifying a zip file using the miniz library.

Can be referenced directly or through a helper script (adds proper autocomplete)

```
# Returns a copy of the GDNative plugin
func get_miniz_plugin():
	return load("res://HevLib/scripts/miniz/miniz.gdns").new()

# Returns a copy of the helper script
func get_miniz_helper():
	return load("res://HevLib/scripts/miniz/miniz.gd").new()
```



```
# Create a ZIP archive and stores files using various means.
func write_zip_file():
	var miniz = load("res://HevLib/scripts/miniz/miniz.gdns").new()
	var err = miniz.open_write("user://save.zip")
	if err != OK:
		# Call get_last_error() to get a readable error message.
		# For methods that return data, it can be used to determine an error from empty data if calling get_last_error() does not return an empty string.
		printerr(miniz.get_last_error())
		return err
	
	# Sets the compression level
	# Accepts an integer from 0 through 10, with 0 just storing data and 10 being heavy compression.
	# Defaults to 6. This is a good compromise between speed and file size.
	miniz.compression_level = 6
	
	# Creates a file and stores a string within it
	miniz.add_file_from_string("meta.json", to_json({"v": 1}))
	
	# Creates a file and stores a PoolByteArray within it
	miniz.add_file_from_bytes("data/blob.bin", PoolByteArray([192,168,1,1]))
	
	# Creates a file from a file on disk
	# Date & time metadata is preserved as best as permitted by DOS datetime format
	miniz.add_file("screenshot.png", "user://shot.png")
	
	# Stores an entire folder from disk in the zip
	miniz.add_folder_as("user://logs", "game_logs")
	
	# Closes the file, saving all changes
	# This MUST be called when finished with an open zip file regardless of operation
	miniz.close()
	return OK

# Opens a ZIP archive and fetches data
func read_zip_file():
	var miniz = load("res://HevLib/scripts/miniz/miniz.gdns").new()
	var err = miniz.open_read("user://save.zip")
	if err != OK:
		printerr(miniz.get_last_error())
		return err
	
	# Prints the zip's file list to stdout
	print("File list: ",miniz.list_files())
	
	# Reads a file and outputs it as a string
	var meta:String = miniz.read_file_as_string("meta.json")
	print("Meta data: ",parse_json(meta))
	
	# Reads a file and outputs it as a PoolByteArray
	var bytes: PoolByteArray = miniz.read_file("data/blob.bin")
	
	# Extracts the entire zip archive into a given folder
	miniz.extract_all("user://dump")
	
	miniz.close()

# Opens a ZIP archive and modifies data within it
func modify_zip_file():
	var miniz = load("res://HevLib/scripts/miniz/miniz.gdns").new()
	var err = miniz.open_append("user://save.zip")
	if err != OK:
		printerr(miniz.get_last_error())
		return err
	
	# Modifies a file's content with a string
	# Note the additional boolean argument, this must be true to let a pre-existing file be overwritten
	miniz.add_file_from_string("meta.json", to_json({"v": 2}), true)
	
	# Removes a file
	miniz.remove_file("screenshot.png")
	
	# Removes a folder
	# Any subfolders or files contained are also removed
	miniz.remove_folder("game_logs")
	
	miniz.close()
	return OK
```

## Properties

int	compression_level [default: 6]
	set_compression_level(value)  setter
	get_compression_level()  getter
	
	The compression level used when writing a zip.
	
	Ranges from 0 through 10, with 0 just storing data and 10 being heavy compression.
	
	Defaults to 6. This is a good compromise between speed and file size.


## Methods

  • Error  add_directory(file_path : String)
	
	Creates an empty directory to the zip at file_path.
	
	Zip must be opened with the ability to perform WRITE operations.



  • Error  add_file(file_path : String, src_path : String, overwrite : bool = false)
	
	Stores a file within the zip file at `file_path` from a file on disk located at `src_path`
	
	Modified time is preserved as closely as is supported by the DOS datetime format.
	
	If a file already exists at `file_path`, fails with ERR_ALREADY_EXISTS unless `overwrite` is true, which the existing file is overwritten instead.
	
	Zip must be opened with the ability to perform WRITE operations.



  • Error  add_file_from_bytes(file_path : String, data : PoolByteArray, overwrite : bool = false)
	
	Stores a PoolByteArray buffer within the zip file in a file located at `file_path`.
	
	If a file already exists at `file_path`, fails with ERR_ALREADY_EXISTS unless `overwrite` is true, which the existing file is overwritten instead.
	
	Zip must be opened with the ability to perform WRITE operations.



  • Error  add_file_from_string(file_path : String, text : String, overwrite : bool = false)
	
	Stores a string within the zip file in a file located at `file_path`.
	
	If a file already exists at `file_path`, fails with ERR_ALREADY_EXISTS unless `overwrite` is true, which the existing file is overwritten instead.
	
	Zip must be opened with the ability to perform WRITE operations.



  • Error  add_folder(source_path : String, overwrite : bool = false)
	
	Stores a folder found on disk at `source_path` within the zip file, with the zip file having the same file tree as `source_path`.
	
	If any files that would be added already exists within the zip, the entire operation fails with ERR_ALREADY_EXISTS unless `overwrite` is true, which causes any conflicting files to be overwritten.
	
	Zip must be opened with the ability to perform WRITE operations.



  • Error  add_folder_as(source_path : String, dir_path : String, overwrite : bool = false)
	
	Stores a folder found on disk at `source_path` within the zip file, with the base directory being defined by `dir_path`.
	
	If any files that would be added already exists within the zip, the entire operation fails with ERR_ALREADY_EXISTS unless `overwrite` is true, which causes any conflicting files to be overwritten.
	
	Zip must be opened with the ability to perform WRITE operations.



  • void  close()
	
	Closes the currently open zip file, storing any written data to disk, and prevents subsequent read/write operations. To save without closing the zip, use `flush()`, `flush_to_file()`, or `flush_to_buffer()`
	
	Any data written to buffer is lost. Use `close_buffer()` to return the zip built in memory.



  • PoolByteArray  close_buffer()
	
	Closes a currently open zip buffer.
	
	Only works if the zip had been opened using `open_write_buffer()` or `open_append_buffer()` first.



  • PoolByteArray  compress_zlib(data : PoolByteArray)
	
	Compresses the provided buffer using ZLIB compression.
	
	Uses the compression_level property to alter how much the data is compressed.
	
	This is a standalone method.



  • int  crc32(data : PoolByteArray)
	
	Calculates the 32-bit CRC hash of the provided data.
	
	This is a standalone method.



  • PoolByteArray  decompress_zlib(data : PoolByteArray, max_size : int = 0)
	
	Decompresses the provided buffer using ZLIB.
	
	`max_size` can be used to limit the byte size of the decompressed data by setting it above zero. Returns an empty PoolByteArray if the output size would exceed it.
	
	This is a standalone method.



  • Error  extract_all(dest_dir : String)
	
	Extracts the entire open zip file to disk inside a folder located at `dest_dir`
	
	Will recursively create all directories needed to extract at the expected location.
	
	Zip must be opened with the ability to perform READ operations.



  • Error  extract_file(file_path : String, dest_path : String)
	
	Extracts an individual file from the open zip to disk at `dest_path`
	
	Will recursively create all directories needed to extract at the expected location.
	
	Zip must be opened with the ability to perform READ operations.



  • bool  file_exists(file_path : String)
	
	Checks whether the file exists within the currently open zip file.
	
	Zip must be opened with the ability to perform READ operations.



  • Error  flush()
	
	Saves the current zip to disk without closing it.
	
	Archive must have been opened with open_write() or open_append() to be saved.
	
	Causes zips opened with open_write() or open_write_buffer() to become readable as if they'd been opened with open_append() and open_append_buffer() respectively.



  • PoolByteArray  flush_to_buffer()
	
	Creates a PoolByteArray for the currently open zip file.
	
	Archive must not have been opened with open_read() or open_buffer() to be saved.
	
	Causes zips opened with open_write() or open_write_buffer() to become readable as if they'd been opened with open_append() and open_append_buffer() respectively.



  • Error  flush_to_file(path: String)
	
	Saves the current zip to disk without closing it, saving it to `path`.
	
	Archive must have been opened with open_write() or open_append() to be saved.
	
	Causes zips opened with open_write() or open_write_buffer() to become readable as if they'd been opened with open_append() and open_append_buffer() respectively.



  • int  get_file_count()
	
	Returns the number of files and folders within the open zip.
	
	Zip must be opened with the ability to perform READ operations.



  • Dictionary  get_file_info(file_path : String)
	
	Returns a dictionary containing data regarding the provided entry within the zip.
	
	  String  name -> The file/folder path. Will match the `file_path` argument.
	  int  index -> The position of the entry within the zip file.
	  bool  is_directory -> Whether the entry is a directory within the zip.
	  int  size -> The raw, uncompressed size of the entry.
	  int  compressed_size -> The size of the entry as it exists within the zip.
	  int  crc32 -> The 32-bit CRC hash of the file. Directories do not have a CRC32 and would be zero.
	  int  modified -> The DOS timestamp for the entry.
	  bool  is_encrypted -> Whether the entry is encrypted.
	  bool  is_supported -> Whether miniz can fetch or modify this entry.
	
	If the entry at `file_path` doesn't exist, the dictionary will be empty.
	
	Zip must be opened with the ability to perform READ operations.



  • String  get_last_error()
	
	Returns the stringified error code of the last operation. Only way to determine if a method that returns data (such as get_file_info()) ran into an error or not.
	
	Will return a blank string if the last operation completed successfully.



  • String  get_miniz_version()
	
	Returns the version string of the miniz library.
	
	This is a standalone method.



  • bool  is_open()
	
	Whether a file is currently open.



  • PoolStringArray  list_files()
	
	Lists all files and folders within the zip file.
	
	Directories will have a forward slash suffix.
	
	Zip must be opened with the ability to perform READ operations.



  • Error  open_append(file_path : String)
	
	Opens a zip file in append mode (permits both READ and WRITE operations.)



  • Error  open_append_buffer(data : PoolByteArray)
	
	Opens a zip buffer in append mode (permits both READ and WRITE operations.)



  • Error  open_buffer(data : PoolByteArray)
	
	Opens a zip buffer in read mode (permits only READ operations.)



  • Error  open_read(path : String)
	
	Opens a zip file in read mode (permits only READ operations.)



  • Error  open_write(path : String)
	
	Opens a zip file in write mode (permits only WRITE operations.)



  • Error  open_write_buffer()
	
	Opens a zip buffer in write mode (permits only WRITE operations.)



  • PoolByteArray  read_file(file_path : String)
	
	Fetches and returns the decompressed bytes of the file within the zip at `file_path`
	
	Zip must be opened with the ability to perform READ operations.



  • String  read_file_as_string(file_path : String)
	
	Fetches and returns the stringified data of the file within the zip at `file_path`
	
	Zip must be opened with the ability to perform READ operations.



  • Error  remove_file(file_path : String)
	
	Removes the file within the zip located at `file_path`
	
	Zip must be opened with the ability to perform WRITE operations.



  • Error  remove_files(file_paths : PoolStringArray)
	
	Removes all files within the zip as stated in `file_paths`
	
	This is an all-or-nothing operation. If one file fails to be deleted or does not exist, no files will be deleted.
	
	Zip must be opened with the ability to perform WRITE operations.



  • Error  remove_folder(file_path : String)
	
	Removes a directory from the zip, including all sub-directories and files.
	
	Zip must be opened with the ability to perform WRITE operations.



  • Error  validate()
	
	Performs a check against the CRC32 value of all entries within the zip.
	
	Zip must be opened with the ability to perform READ operations.


