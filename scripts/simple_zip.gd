extends Reference
class_name SimpleZip

# SimpleZip
# ---------
# A pure-GDScript reader/writer for standard .zip archives, for Godot 3.6.
#
# WHY THIS EXISTS
# Godot's ZIPReader / ZIPPacker classes are NOT available in Godot 3.x --
# they were added to the engine in Godot 4.0 (godotengine/godot#65281).
# Since Godot 3.6 has no built-in scripting API for creating or editing
# .zip files, this script implements the zip file format directly --
# including its own DEFLATE encoder/decoder, since Godot's own
# PoolByteArray.compress()/decompress() only speak the zlib container
# format (a 2-byte header + 4-byte Adler-32 trailer), not the raw deflate
# stream a .zip actually stores internally, so they can't be reused for
# zip entries on the read side. On the write side this script does reuse
# Godot's compressor and simply trims that wrapper back off, since raw
# deflate is zlib-minus-wrapper by definition.
#
# ARCHITECTURE: BYTES FIRST, FILES ON TOP
# Every actual zip-format operation - reading, building, inserting into,
# removing from an archive - works on a complete zip held as a
# PoolByteArray. The `_bytes` functions in the PUBLIC API section below
# are that core, directly: hand them (and get back) an in-memory archive,
# with no disk I/O at all, for whenever a zip is already in memory (e.g.
# downloaded, generated, or stored as a blob) rather than sitting in a
# file. The plain-named functions (create_zip, read_file, insert_file,
# etc.) are thin wrappers around the same core that load from / save to
# a path on disk, for convenience when a file is what you've got.
#
# INSERT/REMOVE PERFORMANCE
# insert_file(s)() and remove_file(s)() do NOT decompress and recompress
# every entry the way rebuilding an archive from scratch would. Entries
# that aren't being added, replaced, or removed are copied verbatim -
# same compressed bytes, no touching their content at all - so cost
# scales with what's actually changing, not with the size of the whole
# archive. See _patch_zip_bytes() below for exactly how.
#
# COMPRESSION
# create_zip() / zip_directory() / insert_file(s)() all take an optional
# `compress` flag (default false, for the fastest/simplest option) that
# writes entries with DEFLATE instead of Stored. Reading transparently
# handles both methods either way, including zips made by other programs,
# and archives with a mix of both. A handful of far less common methods
# (bzip2, LZMA, etc.) are still out of scope for entries being newly
# compressed, but are no longer a problem for entries just passing
# through an insert/remove untouched - see above, they're never decoded.
# Archives over ~4 GB or with more than 65535 entries (zip64) aren't
# supported.

const _LOCAL_FILE_SIG  := 0x04034b50
const _CENTRAL_DIR_SIG := 0x02014b50
const _EOCD_SIG        := 0x06054b50
const _VERSION_NEEDED  := 20     # 2.0 - no encryption, no zip64, etc.
const _FLAG_UTF8       := 0x0800 # names/content are UTF-8
const _METHOD_STORED   := 0
const _METHOD_DEFLATE  := 8
const _EOCD_FIXED_SIZE := 22


# --------------------------------------------------------------------
# PUBLIC API - in-memory (PoolByteArray) core
# --------------------------------------------------------------------

# Builds a brand-new zip, entirely in memory, from `files` formatted as
# { "path/inside/zip.txt": <String or PoolByteArray>, ... }. Pass
# compress=true to write entries with DEFLATE instead of Stored.
static func create_zip_bytes(files: Dictionary, compress: bool = false) -> PoolByteArray:
	return _build_zip_bytes(files, compress)


# Returns the list of entry names stored inside an in-memory zip (folders
# included, as Godot's own ZIPReader.get_files() would list them).
static func list_files_bytes(zip_bytes: PoolByteArray) -> Array:
	var names := []
	for entry in _read_central_directory_from_bytes(zip_bytes):
		names.append(entry.name)
	return names


# Returns true if `file_in_zip` is present in an in-memory zip.
static func file_exists_bytes(zip_bytes: PoolByteArray, file_in_zip: String) -> bool:
	for entry in _read_central_directory_from_bytes(zip_bytes):
		if entry.name == file_in_zip:
			return true
	return false


# Reads one file's raw bytes out of an in-memory zip (transparently
# inflating it first if it's Deflate-compressed). Returns an empty
# PoolByteArray (and logs an error) if the entry is missing or uses an
# unsupported compression method.
static func read_file_bytes(zip_bytes: PoolByteArray, file_in_zip: String) -> PoolByteArray:
	for entry in _read_central_directory_from_bytes(zip_bytes):
		if entry.name == file_in_zip:
			return _read_entry_data_from_bytes(zip_bytes, entry)
	push_error("SimpleZip: '%s' not found in the given zip bytes" % file_in_zip)
	return PoolByteArray()


# Convenience wrapper: reads a file from an in-memory zip as a UTF-8 string.
static func read_file_as_text_bytes(zip_bytes: PoolByteArray, file_in_zip: String) -> String:
	return read_file_bytes(zip_bytes, file_in_zip).get_string_from_utf8()


# Adds (or replaces) a single file in an in-memory zip and returns the
# updated archive bytes. See _patch_zip_bytes() for what makes this fast.
static func insert_file_bytes(zip_bytes: PoolByteArray, file_in_zip: String, content, compress: bool = false) -> PoolByteArray:
	return insert_files_bytes(zip_bytes, {file_in_zip: content}, compress)


# Adds/replaces several files at once (one pass instead of one per file)
# and returns the updated archive bytes.
static func insert_files_bytes(zip_bytes: PoolByteArray, files: Dictionary, compress: bool = false) -> PoolByteArray:
	return _patch_zip_bytes(zip_bytes, files, [], compress)


# Removes a single entry from an in-memory zip and returns the updated
# archive bytes.
static func remove_file_bytes(zip_bytes: PoolByteArray, file_in_zip: String, compress: bool = false) -> PoolByteArray:
	return remove_files_bytes(zip_bytes, [file_in_zip], compress)


# Removes several entries at once (one pass instead of one per file) and
# returns the updated archive bytes.
static func remove_files_bytes(zip_bytes: PoolByteArray, names: Array, compress: bool = false) -> PoolByteArray:
	return _patch_zip_bytes(zip_bytes, {}, names, compress)


# Extracts every entry from an in-memory zip onto disk under
# destination_dir, preserving the folder structure stored in the archive.
static func extract_all_bytes(zip_bytes: PoolByteArray, destination_dir: String) -> bool:
	var entries := _read_central_directory_from_bytes(zip_bytes)
	if entries.empty():
		return false

	var dir := Directory.new()
	dir.make_dir_recursive(destination_dir)

	for entry in entries:
		if entry.name.find("..") != -1:
			push_error("SimpleZip: skipping suspicious entry '%s'" % entry.name)
			continue

		if entry.name.ends_with("/"):
			dir.make_dir_recursive(destination_dir.plus_file(entry.name))
			continue

		var out_path := destination_dir.plus_file(entry.name)
		dir.make_dir_recursive(out_path.get_base_dir())

		var out_file := File.new()
		if out_file.open(out_path, File.WRITE) != OK:
			push_error("SimpleZip: could not write '%s'" % out_path)
			continue
		out_file.store_buffer(_read_entry_data_from_bytes(zip_bytes, entry))
		out_file.close()
	return true


# --------------------------------------------------------------------
# PUBLIC API - file-based convenience wrappers
# --------------------------------------------------------------------
# Everything below just loads a path into bytes, calls the in-memory
# core above, and (for anything that changes the archive) saves the
# result back out - no zip-format logic lives down here.

static func create_zip(zip_path: String, files: Dictionary, compress: bool = false) -> bool:
	return _save_bytes_to_file(zip_path, create_zip_bytes(files, compress))


# Zips up an entire directory (recursively) into a new archive.
static func zip_directory(source_dir: String, zip_path: String, compress: bool = false) -> bool:
	var files := {}
	_collect_directory(source_dir, "", files)
	return create_zip(zip_path, files, compress)


# Returns the list of entry names stored in the zip (folders included).
static func list_files(zip_path: String) -> Array:
	return list_files_bytes(_load_bytes_from_file(zip_path))


# Returns true if `file_in_zip` is present in the archive.
static func file_exists(zip_path: String, file_in_zip: String) -> bool:
	return file_exists_bytes(_load_bytes_from_file(zip_path), file_in_zip)


# Reads one file's raw bytes out of the zip.
static func read_file(zip_path: String, file_in_zip: String) -> PoolByteArray:
	return read_file_bytes(_load_bytes_from_file(zip_path), file_in_zip)


# Convenience wrapper: reads a file from the zip as a UTF-8 string.
static func read_file_as_text(zip_path: String, file_in_zip: String) -> String:
	return read_file(zip_path, file_in_zip).get_string_from_utf8()


# Extracts every entry in the zip to disk under destination_dir,
# preserving the folder structure stored in the archive.
static func extract_all(zip_path: String, destination_dir: String) -> bool:
	return extract_all_bytes(_load_bytes_from_file(zip_path), destination_dir)


# Adds (or replaces) a single file inside an existing zip, writing the
# result back to zip_path. Creates zip_path if it doesn't exist yet.
static func insert_file(zip_path: String, file_in_zip: String, content, compress: bool = false) -> bool:
	return insert_files(zip_path, {file_in_zip: content}, compress)


# Adds/replaces several files at once (one pass instead of one per file).
static func insert_files(zip_path: String, files: Dictionary, compress: bool = false) -> bool:
	var zip_bytes := _load_bytes_from_file(zip_path)
	return _save_bytes_to_file(zip_path, _patch_zip_bytes(zip_bytes, files, [], compress))


# Removes a single entry from an existing zip, writing the result back
# to zip_path.
static func remove_file(zip_path: String, file_in_zip: String, compress: bool = false) -> bool:
	return remove_files(zip_path, [file_in_zip], compress)


# Removes several entries at once (one pass instead of one per file).
static func remove_files(zip_path: String, names: Array, compress: bool = false) -> bool:
	var dir := Directory.new()
	if not dir.file_exists(zip_path):
		push_error("SimpleZip: '%s' does not exist" % zip_path)
		return false
	var zip_bytes := _load_bytes_from_file(zip_path)
	return _save_bytes_to_file(zip_path, _patch_zip_bytes(zip_bytes, {}, names, compress))


static func _to_bytes(content) -> PoolByteArray:
	if typeof(content) == TYPE_STRING:
		return content.to_utf8()
	if typeof(content) == TYPE_RAW_ARRAY:
		return content
	push_error("SimpleZip: file content must be a String or PoolByteArray")
	return PoolByteArray()


static func _dos_time_date() -> Dictionary:
	var dt := OS.get_datetime()
	# Dictionary values come back as Variant, and GDScript 3.x can't infer
	# a concrete type for bitwise ops performed directly on them -- pull
	# them into explicitly-typed ints first.
	var year: int = dt.year
	var month: int = dt.month
	var day: int = dt.day
	var hour: int = dt.hour
	var minute: int = dt.minute
	var second: int = dt.second

	var dos_year := int(max(year - 1980, 0)) # max() returns float in 3.x, even for ints
	var dos_time := (hour << 11) | (minute << 5) | int(second / 2.0)
	var dos_date := (dos_year << 9) | (month << 5) | day
	return {"time": dos_time, "date": dos_date}


# Precomputed CRC-32 lookup tables used by _crc32() below, kept in a
# separate file so opening/editing THIS script doesn't require the Godot
# editor to parse thousands of numeric literals - see crc32_tables.gd for
# what's actually in there and why. Both files need to stay together;
# adjust this path if you move them somewhere other than res://.
const _CrcTables = preload("res://HevLib/scripts/crc32_table_cache.gd")


# Standard CRC-32 (same checksum zip/gzip/PNG use), using "slicing-by-32":
# 32 bytes are folded into the running CRC per loop iteration instead of
# one, via 32 precomputed lookup tables XORed together - the same family
# of technique zlib itself uses for its fast path. Tables are hardcoded
# consts rather than computed at load time, both because GDScript 3.x has
# no `static var` to cache a computed table in across calls, and because
# that setup cost measurably matters when writing many small files.
#
# This specific width was chosen by measuring, not guessed: slicing-by-4
# actually loses to the plain single-table version below it (more work per
# iteration than it saves), while 8/16/32 each gave a further real speedup
# in testing (roughly 20%, 30%, 40% faster than the single-table version,
# in that order), and 64 only added a few more percent on top for double
# the table data - so 32 is close to the practical ceiling here without
# the source file size ballooning further for little extra gain.
static func _crc32(data: PoolByteArray) -> int:
	var t0 = _CrcTables.T0
	var t1 = _CrcTables.T1
	var t2 = _CrcTables.T2
	var t3 = _CrcTables.T3
	var t4 = _CrcTables.T4
	var t5 = _CrcTables.T5
	var t6 = _CrcTables.T6
	var t7 = _CrcTables.T7
	var t8 = _CrcTables.T8
	var t9 = _CrcTables.T9
	var t10 = _CrcTables.T10
	var t11 = _CrcTables.T11
	var t12 = _CrcTables.T12
	var t13 = _CrcTables.T13
	var t14 = _CrcTables.T14
	var t15 = _CrcTables.T15
	var t16 = _CrcTables.T16
	var t17 = _CrcTables.T17
	var t18 = _CrcTables.T18
	var t19 = _CrcTables.T19
	var t20 = _CrcTables.T20
	var t21 = _CrcTables.T21
	var t22 = _CrcTables.T22
	var t23 = _CrcTables.T23
	var t24 = _CrcTables.T24
	var t25 = _CrcTables.T25
	var t26 = _CrcTables.T26
	var t27 = _CrcTables.T27
	var t28 = _CrcTables.T28
	var t29 = _CrcTables.T29
	var t30 = _CrcTables.T30
	var t31 = _CrcTables.T31

	var crc := 0xFFFFFFFF
	var size := data.size()
	var groups := int(size / 32.0)
	var i := 0
	for _g in range(groups):
		# The running crc is 4 bytes; XOR each of its bytes with the next
		# 4 data bytes before their lookups. The remaining bytes in the
		# group need no such XOR - by this point crc's influence on the
		# result has already been fully captured by the first four.
		var n0 := (crc & 0xFF) ^ data[i]
		var n1 := ((crc >> 8) & 0xFF) ^ data[i + 1]
		var n2 := ((crc >> 16) & 0xFF) ^ data[i + 2]
		var n3 := ((crc >> 24) & 0xFF) ^ data[i + 3]
		crc = (t31[n0] ^
			t30[n1] ^
			t29[n2] ^
			t28[n3] ^
			t27[data[i + 4]] ^
			t26[data[i + 5]] ^
			t25[data[i + 6]] ^
			t24[data[i + 7]] ^
			t23[data[i + 8]] ^
			t22[data[i + 9]] ^
			t21[data[i + 10]] ^
			t20[data[i + 11]] ^
			t19[data[i + 12]] ^
			t18[data[i + 13]] ^
			t17[data[i + 14]] ^
			t16[data[i + 15]] ^
			t15[data[i + 16]] ^
			t14[data[i + 17]] ^
			t13[data[i + 18]] ^
			t12[data[i + 19]] ^
			t11[data[i + 20]] ^
			t10[data[i + 21]] ^
			t9[data[i + 22]] ^
			t8[data[i + 23]] ^
			t7[data[i + 24]] ^
			t6[data[i + 25]] ^
			t5[data[i + 26]] ^
			t4[data[i + 27]] ^
			t3[data[i + 28]] ^
			t2[data[i + 29]] ^
			t1[data[i + 30]] ^
			t0[data[i + 31]])
		i += 32
	# Tail: 0 to 31 leftover bytes that don't fill a full group,
	# handled the plain single-byte-per-step way.
	while i < size:
		crc = t0[(crc ^ data[i]) & 0xFF] ^ (crc >> 8)
		i += 1
	return crc ^ 0xFFFFFFFF


static func _read_u32_le(bytes: PoolByteArray, at: int) -> int:
	return bytes[at] | (bytes[at + 1] << 8) | (bytes[at + 2] << 16) | (bytes[at + 3] << 24)


static func _read_u16_le(bytes: PoolByteArray, at: int) -> int:
	return bytes[at] | (bytes[at + 1] << 8)


# Compresses data with Godot's built-in zlib-format compressor, then trims
# the 2-byte zlib header and 4-byte Adler-32 trailer off. What's left is a
# raw deflate stream: exactly the payload format a zip's "Deflated" method
# expects, since the zlib container is by definition just that wrapped.
static func _deflate_compress(data: PoolByteArray) -> PoolByteArray:
	var wrapped := data.compress(File.COMPRESSION_DEFLATE)
	return wrapped.subarray(2, wrapped.size() - 5)


# Writes every entry in `files`, then the central directory and
# end-of-central-directory record. `compress` selects Deflate over Stored
# per file, but only where it actually saves space.
# --------------------------------------------------------------------
# INTERNAL HELPERS - file <-> bytes
# --------------------------------------------------------------------

static func _load_bytes_from_file(zip_path: String) -> PoolByteArray:
	var file := File.new()
	if file.open(zip_path, File.READ) != OK:
		return PoolByteArray()
	var data := file.get_buffer(file.get_len())
	file.close()
	return data


static func _save_bytes_to_file(zip_path: String, data: PoolByteArray) -> bool:
	var file := File.new()
	if file.open(zip_path, File.WRITE) != OK:
		push_error("SimpleZip: could not open '%s' for writing" % zip_path)
		return false
	file.store_buffer(data)
	file.close()
	return true


# --------------------------------------------------------------------
# INTERNAL HELPERS - building zip bytes
# --------------------------------------------------------------------
# A note on style: every function here either builds a small, complete
# PoolByteArray from scratch and returns it, or owns a single growing
# buffer as a local variable and calls .append_array() on that local
# directly. Neither pattern ever mutates a PoolByteArray that arrived as
# a function parameter or an object property and expects the caller to
# see the change - that silently does NOT work in GDScript 3.x (Pool*
# Array parameters/properties are value-copied on mutation), which is
# also why the DEFLATE decoder further down uses a plain Array instead.

static func _u16_le(value: int) -> PoolByteArray:
	return PoolByteArray([value & 0xFF, (value >> 8) & 0xFF])


static func _u32_le(value: int) -> PoolByteArray:
	return PoolByteArray([value & 0xFF, (value >> 8) & 0xFF, (value >> 16) & 0xFF, (value >> 24) & 0xFF])


# Builds the complete local file header + (possibly compressed) data for
# one entry. Returns {bytes, record}: `bytes` is what to place directly
# in the archive, `record` is what _build_central_directory_and_eocd()
# needs once the entry's final offset is known.
static func _build_local_entry(name: String, content, compress: bool, mod_time: int, mod_date: int) -> Dictionary:
	var data := _to_bytes(content)
	var name_bytes: PoolByteArray = name.to_utf8()
	var crc := _crc32(data)

	var method := _METHOD_STORED
	var payload := data
	if compress and data.size() > 0:
		var deflated := _deflate_compress(data)
		if deflated.size() < data.size():
			method = _METHOD_DEFLATE
			payload = deflated

	var out := PoolByteArray()
	out.append_array(_u32_le(_LOCAL_FILE_SIG))
	out.append_array(_u16_le(_VERSION_NEEDED))
	out.append_array(_u16_le(_FLAG_UTF8))
	out.append_array(_u16_le(method))
	out.append_array(_u16_le(mod_time))
	out.append_array(_u16_le(mod_date))
	out.append_array(_u32_le(crc))
	out.append_array(_u32_le(payload.size())) # compressed size
	out.append_array(_u32_le(data.size()))    # uncompressed size
	out.append_array(_u16_le(name_bytes.size()))
	out.append_array(_u16_le(0)) # extra field length
	out.append_array(name_bytes)
	out.append_array(payload)

	return {
		"bytes": out,
		"record": {
			"name_bytes": name_bytes,
			"crc": crc,
			"method": method,
			"comp_size": payload.size(),
			"uncomp_size": data.size(),
			"mod_time": mod_time,
			"mod_date": mod_date,
		},
	}


# Builds the central directory (one record per entry) followed by the
# end-of-central-directory record. `central_dir_offset` is where this
# data will sit within the *final* archive, which the caller must know
# (it's just "how much I've written so far"), since the EOCD needs to
# record it as an absolute position.
static func _build_central_directory_and_eocd(records: Array, central_dir_offset: int) -> PoolByteArray:
	var out := PoolByteArray()
	for rec in records:
		out.append_array(_u32_le(_CENTRAL_DIR_SIG))
		out.append_array(_u16_le(_VERSION_NEEDED)) # version made by
		out.append_array(_u16_le(_VERSION_NEEDED)) # version needed to extract
		out.append_array(_u16_le(_FLAG_UTF8))
		out.append_array(_u16_le(rec.method))
		out.append_array(_u16_le(rec.mod_time))
		out.append_array(_u16_le(rec.mod_date))
		out.append_array(_u32_le(rec.crc))
		out.append_array(_u32_le(rec.comp_size))
		out.append_array(_u32_le(rec.uncomp_size))
		out.append_array(_u16_le(rec.name_bytes.size()))
		out.append_array(_u16_le(0)) # extra field length
		out.append_array(_u16_le(0)) # comment length
		out.append_array(_u16_le(0)) # disk number start
		out.append_array(_u16_le(0)) # internal file attributes
		out.append_array(_u32_le(0)) # external file attributes
		out.append_array(_u32_le(rec.offset))
		out.append_array(rec.name_bytes)

	var central_dir_size := out.size()

	out.append_array(_u32_le(_EOCD_SIG))
	out.append_array(_u16_le(0)) # number of this disk
	out.append_array(_u16_le(0)) # disk where central directory starts
	out.append_array(_u16_le(records.size()))
	out.append_array(_u16_le(records.size()))
	out.append_array(_u32_le(central_dir_size))
	out.append_array(_u32_le(central_dir_offset))
	out.append_array(_u16_le(0)) # zip comment length
	return out


# Builds a brand-new zip's complete bytes from `files`.
static func _build_zip_bytes(files: Dictionary, compress: bool) -> PoolByteArray:
	var dt := _dos_time_date()
	var out := PoolByteArray()
	var records := []

	for entry_path in files.keys():
		var built := _build_local_entry(entry_path, files[entry_path], compress, dt.time, dt.date)
		built.record["offset"] = out.size()
		out.append_array(built.bytes)
		records.append(built.record)

	var central_dir_offset := out.size()
	out.append_array(_build_central_directory_and_eocd(records, central_dir_offset))
	return out


# --------------------------------------------------------------------
# INTERNAL HELPERS - reading zip bytes
# --------------------------------------------------------------------

# Locates the end-of-central-directory record, then walks the central
# directory to build a lightweight index of every entry. Returns [] if
# `zip_bytes` isn't a valid zip.
static func _read_central_directory_from_bytes(zip_bytes: PoolByteArray) -> Array:
	var total_len := zip_bytes.size()
	if total_len < _EOCD_FIXED_SIZE:
		return []

	# EOCD sits at the end of the archive; a trailing zip comment (up to
	# 65535 bytes) can follow it, so search backward far enough to allow
	# for the largest possible comment.
	var search_start = max(total_len - _EOCD_FIXED_SIZE - 65536, 0)

	var eocd_pos := -1
	var i := total_len - _EOCD_FIXED_SIZE
	while i >= search_start:
		if zip_bytes[i] == 0x50 and zip_bytes[i + 1] == 0x4b and zip_bytes[i + 2] == 0x05 and zip_bytes[i + 3] == 0x06:
			eocd_pos = i
			break
		i -= 1

	if eocd_pos == -1:
		push_error("SimpleZip: doesn't look like a zip (no End Of Central Directory record found)")
		return []

	var total_entries := _read_u16_le(zip_bytes, eocd_pos + 10)
	var pos := _read_u32_le(zip_bytes, eocd_pos + 16)

	var entries := []
	for _n in range(total_entries):
		if _read_u32_le(zip_bytes, pos) != _CENTRAL_DIR_SIG:
			push_error("SimpleZip: central directory is corrupt")
			break

		var method := _read_u16_le(zip_bytes, pos + 10)
		var mod_time := _read_u16_le(zip_bytes, pos + 12)
		var mod_date := _read_u16_le(zip_bytes, pos + 14)
		var crc := _read_u32_le(zip_bytes, pos + 16)
		var comp_size := _read_u32_le(zip_bytes, pos + 20)
		var uncomp_size := _read_u32_le(zip_bytes, pos + 24)
		var name_len := _read_u16_le(zip_bytes, pos + 28)
		var extra_len := _read_u16_le(zip_bytes, pos + 30)
		var comment_len := _read_u16_le(zip_bytes, pos + 32)
		var local_offset := _read_u32_le(zip_bytes, pos + 42)

		var name := ""
		if name_len > 0:
			name = zip_bytes.subarray(pos + 46, pos + 46 + name_len - 1).get_string_from_utf8()

		entries.append({
			"name": name,
			"method": method,
			"comp_size": comp_size,
			"uncomp_size": uncomp_size,
			"crc": crc,
			"mod_time": mod_time,
			"mod_date": mod_date,
			"local_offset": local_offset,
		})

		pos += 46 + name_len + extra_len + comment_len

	return entries


# Given an entry's local_offset, returns the position where its actual
# (possibly compressed) data begins - i.e. just after its local header,
# name, and extra field. Reads the name/extra lengths fresh from the
# LOCAL header rather than trusting the central directory's copy, since
# the extra field in particular is allowed to differ in length between
# the two.
static func _local_data_offset_bytes(zip_bytes: PoolByteArray, local_offset: int) -> int:
	var name_len := _read_u16_le(zip_bytes, local_offset + 26)
	var extra_len := _read_u16_le(zip_bytes, local_offset + 28)
	return local_offset + 30 + name_len + extra_len


# The file position one past the end of an entry's data - i.e. where the
# next entry (or the central directory, if this is the last entry) would
# start if the archive has no gaps between entries.
static func _entry_extent_end_bytes(zip_bytes: PoolByteArray, entry: Dictionary) -> int:
	return _local_data_offset_bytes(zip_bytes, entry.local_offset) + entry.comp_size


# Reads (and decompresses, if needed) one entry's data, given a record
# from _read_central_directory_from_bytes().
static func _read_entry_data_from_bytes(zip_bytes: PoolByteArray, entry: Dictionary) -> PoolByteArray:
	if entry.method != _METHOD_STORED and entry.method != _METHOD_DEFLATE:
		push_error("SimpleZip: '%s' uses compression method %d, which isn't supported (only Stored/0 and Deflate/8 are)" % [entry.name, entry.method])
		return PoolByteArray()

	var data_start := _local_data_offset_bytes(zip_bytes, entry.local_offset)
	var raw := PoolByteArray()
	if entry.comp_size > 0:
		raw = zip_bytes.subarray(data_start, data_start + entry.comp_size - 1)

	var data: PoolByteArray = _inflate(raw) if entry.method == _METHOD_DEFLATE else raw

	if data.size() != entry.uncomp_size:
		push_error("SimpleZip: '%s' decompressed to %d bytes, expected %d - it may be corrupted" % [entry.name, data.size(), entry.uncomp_size])

	return data


# Turns an existing entry (from _read_central_directory_from_bytes) into
# the record shape _build_central_directory_and_eocd() expects, at
# whatever offset it now lives at.
static func _record_from_entry(entry: Dictionary, new_offset: int) -> Dictionary:
	return {
		"name_bytes": String(entry.name).to_utf8(),
		"crc": entry.crc,
		"method": entry.method,
		"comp_size": entry.comp_size,
		"uncomp_size": entry.uncomp_size,
		"mod_time": entry.mod_time,
		"mod_date": entry.mod_date,
		"offset": new_offset,
	}


# --------------------------------------------------------------------
# INTERNAL HELPERS - efficient insert/replace/remove
# --------------------------------------------------------------------
#
# The key idea: an entry that is neither being added, replaced, nor
# removed doesn't need to be understood at all, just relocated as a
# block of bytes. So this never decompresses or recompresses anything
# except the actual new/changed content the caller provided.
#
#   upsert       {"path/in/zip": content, ...} - files to add or replace
#   remove_names [...]                         - names to delete
#
# Two shapes of update:
#
#  - PURE ADD (nothing in upsert/remove_names matches an existing name):
#    every kept entry's bytes AND offset are left completely untouched -
#    new entries are appended where the old central directory used to
#    sit, followed by a fresh central directory. Nothing existing is
#    ever copied, read, or moved.
#
#  - ANY REPLACE OR REMOVE: since an entry is leaving its slot, the
#    result is assembled fresh - but "assembled" still just means
#    concatenating each kept entry's original bytes verbatim (via
#    subarray, a fast native copy) with the newly-built entries, never
#    decoding a kept entry's content.
static func _patch_zip_bytes(zip_bytes: PoolByteArray, upsert: Dictionary, remove_names: Array, compress: bool) -> PoolByteArray:
	if zip_bytes.empty():
		return _build_zip_bytes(upsert, compress)

	var old_entries := _read_central_directory_from_bytes(zip_bytes)

	var remove_set := {}
	for n in remove_names:
		remove_set[n] = true

	var has_conflict := false
	for entry in old_entries:
		if upsert.has(entry.name) or remove_set.has(entry.name):
			has_conflict = true
			break

	var dt := _dos_time_date()
	var out := PoolByteArray()
	var records := []

	if not has_conflict:
		# Fast path: keep every existing byte exactly where it is. Only
		# the (comparatively tiny) old central directory + EOCD, which
		# sit past the last real entry, get replaced.
		var append_at := 0
		for entry in old_entries:
			append_at = max(append_at, _entry_extent_end_bytes(zip_bytes, entry))
			records.append(_record_from_entry(entry, entry.local_offset))

		out = zip_bytes.subarray(0, append_at - 1) if append_at > 0 else PoolByteArray()
	else:
		# Something is moving: copy every kept entry's bytes verbatim
		# into a fresh buffer, skipping whatever's being replaced/removed.
		for entry in old_entries:
			if upsert.has(entry.name) or remove_set.has(entry.name):
				continue
			var start: int = entry.local_offset
			var end := _entry_extent_end_bytes(zip_bytes, entry)
			records.append(_record_from_entry(entry, out.size()))
			out.append_array(zip_bytes.subarray(start, end - 1))

	for entry_path in upsert.keys():
		var built := _build_local_entry(entry_path, upsert[entry_path], compress, dt.time, dt.date)
		built.record["offset"] = out.size()
		out.append_array(built.bytes)
		records.append(built.record)

	var central_dir_offset := out.size()
	out.append_array(_build_central_directory_and_eocd(records, central_dir_offset))
	return out


static func _collect_directory(disk_dir: String, zip_prefix: String, out_files: Dictionary) -> void:
	var dir := Directory.new()
	if dir.open(disk_dir) != OK:
		push_error("SimpleZip: could not open directory '%s'" % disk_dir)
		return

	dir.list_dir_begin(true, true) # skip navigational + hidden entries
	var entry_name := dir.get_next()
	while entry_name != "":
		var disk_path := disk_dir.plus_file(entry_name)
		var zip_entry_path := entry_name if zip_prefix == "" else zip_prefix + "/" + entry_name

		if dir.current_is_dir():
			_collect_directory(disk_path, zip_entry_path, out_files)
		else:
			var f := File.new()
			if f.open(disk_path, File.READ) == OK:
				out_files[zip_entry_path] = f.get_buffer(f.get_len())
				f.close()

		entry_name = dir.get_next()
	dir.list_dir_end()


# --------------------------------------------------------------------
# INTERNAL HELPERS - a from-scratch RFC 1951 DEFLATE decoder
# --------------------------------------------------------------------
#
# Godot's own PoolByteArray.decompress() can't be reused here (see the
# note at the top of this file), so this is a real, independent INFLATE
# implementation. It's plain and unoptimized on purpose, favoring
# straightforward-to-verify code over speed: expect on the order of a
# second or two per megabyte of decompressed output. For large payloads
# read often, a compiled GDExtension would be far faster; for the
# occasional config/save/data file bundled in a zip, this is fine.

const _LENGTH_BASE  := [3,4,5,6,7,8,9,10,11,13,15,17,19,23,27,31,35,43,51,59,67,83,99,115,131,163,195,227,258]
const _LENGTH_EXTRA := [0,0,0,0,0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,0]
const _DIST_BASE    := [1,2,3,4,5,7,9,13,17,25,33,49,65,97,129,193,257,385,513,769,1025,1537,2049,3073,4097,6145,8193,12289,16385,24577]
const _DIST_EXTRA   := [0,0,0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13]
const _CL_ORDER     := [16,17,18,0,8,7,9,6,10,5,11,4,12,3,13,2,14,1,15]

# Bit-level cursor over the compressed bytes, plus the output built up so
# far. This is an object (not static state) so each inflate() call gets
# its own; note the output buffer is a plain Array, not a PoolByteArray -
# PoolByteArray has value-copy semantics in GDScript 3.x (mutating one
# received as a parameter, or reached through an object property, does
# not affect the original), which silently breaks exactly this kind of
# "helper functions grow a shared buffer" pattern. Array behaves as a
# normal shared/reference container, so it's used internally and only
# converted to a PoolByteArray once, right at the end.
class _InflateState:
	var input: PoolByteArray
	var pos: int = 0
	var bit_buf: int = 0
	var bit_count: int = 0
	var output: Array = []

	func _init(data: PoolByteArray) -> void:
		input = data

	func get_bit() -> int:
		if bit_count == 0:
			if pos >= input.size():
				return 0
			bit_buf = input[pos]
			pos += 1
			bit_count = 8
		var bit := bit_buf & 1
		bit_buf = bit_buf >> 1
		bit_count -= 1
		return bit

	# Fixed-width fields (extra bits, header counts, stored-block length)
	# are packed LSB-first: the first bit read is bit 0 of the value.
	func get_bits(n: int) -> int:
		var value := 0
		for i in range(n):
			value = value | (get_bit() << i)
		return value

	func align_to_byte() -> void:
		bit_buf = 0
		bit_count = 0


# Builds a canonical-Huffman decode table (RFC 1951 3.2.2) from an array
# of code lengths indexed by symbol (0 = symbol unused). Returns
# table[bit_length][code_value] = symbol.
static func _build_huffman_table(lengths: Array) -> Dictionary:
	var max_len := 0
	for l in lengths:
		if l > max_len:
			max_len = l

	var bl_count := []
	bl_count.resize(max_len + 1)
	for i in range(bl_count.size()):
		bl_count[i] = 0
	for l in lengths:
		if l > 0:
			bl_count[l] += 1

	var next_code := []
	next_code.resize(max_len + 1)
	var code := 0
	bl_count[0] = 0
	for n in range(1, max_len + 1):
		code = (code + bl_count[n - 1]) << 1
		next_code[n] = code

	var table := {}
	for symbol in range(lengths.size()):
		var length: int = lengths[symbol]
		if length == 0:
			continue
		if not table.has(length):
			table[length] = {}
		table[length][next_code[length]] = symbol
		next_code[length] += 1

	return table


# Unlike get_bits(), Huffman codes are packed MSB-first, so this builds
# the code bit by bit (shift-and-OR) rather than reading a fixed width.
static func _decode_huffman_symbol(state: _InflateState, table: Dictionary) -> int:
	var code := 0
	var length := 0
	while length <= 15:
		code = (code << 1) | state.get_bit()
		length += 1
		if table.has(length) and table[length].has(code):
			return table[length][code]
	push_error("SimpleZip: invalid Huffman code while inflating (corrupt data?)")
	return -1


static func _fixed_litlen_table() -> Dictionary:
	var lengths := []
	lengths.resize(288)
	for i in range(0, 144):
		lengths[i] = 8
	for i in range(144, 256):
		lengths[i] = 9
	for i in range(256, 280):
		lengths[i] = 7
	for i in range(280, 288):
		lengths[i] = 8
	return _build_huffman_table(lengths)


static func _fixed_dist_table() -> Dictionary:
	var lengths := []
	lengths.resize(30)
	for i in range(30):
		lengths[i] = 5
	return _build_huffman_table(lengths)


# Reads a dynamic block's header (RFC 1951 3.2.7) and returns
# [litlen_table, dist_table] built from the code lengths it describes.
static func _read_dynamic_tables(state: _InflateState) -> Array:
	var hlit := state.get_bits(5) + 257
	var hdist := state.get_bits(5) + 1
	var hclen := state.get_bits(4) + 4

	var cl_lengths := []
	cl_lengths.resize(19)
	for i in range(19):
		cl_lengths[i] = 0
	for i in range(hclen):
		cl_lengths[_CL_ORDER[i]] = state.get_bits(3)
	var cl_table := _build_huffman_table(cl_lengths)

	var all_lengths := []
	var total := hlit + hdist
	while all_lengths.size() < total:
		var sym := _decode_huffman_symbol(state, cl_table)
		if sym < 16:
			all_lengths.append(sym)
		elif sym == 16:
			var repeat := state.get_bits(2) + 3
			var prev = all_lengths[all_lengths.size() - 1]
			for _i in range(repeat):
				all_lengths.append(prev)
		elif sym == 17:
			var repeat := state.get_bits(3) + 3
			for _i in range(repeat):
				all_lengths.append(0)
		else: # 18
			var repeat := state.get_bits(7) + 11
			for _i in range(repeat):
				all_lengths.append(0)

	var litlen_lengths := []
	for i in range(hlit):
		litlen_lengths.append(all_lengths[i])
	var dist_lengths := []
	for i in range(hdist):
		dist_lengths.append(all_lengths[hlit + i])

	return [_build_huffman_table(litlen_lengths), _build_huffman_table(dist_lengths)]


# Decodes literal/length/distance symbols into state.output until the
# block's end-of-block marker (symbol 256).
static func _inflate_huffman_block(state: _InflateState, litlen_table: Dictionary, dist_table: Dictionary) -> void:
	while true:
		var sym := _decode_huffman_symbol(state, litlen_table)
		if sym < 0:
			return
		if sym < 256:
			state.output.append(sym)
		elif sym == 256:
			return
		else:
			var length: int = _LENGTH_BASE[sym - 257] + state.get_bits(_LENGTH_EXTRA[sym - 257])
			var dist_sym := _decode_huffman_symbol(state, dist_table)
			var distance: int = _DIST_BASE[dist_sym] + state.get_bits(_DIST_EXTRA[dist_sym])
			var start: int = state.output.size() - distance
			for i in range(length):
				# Read one byte at a time (not a bulk copy): when distance
				# < length this back-reference deliberately reads bytes
				# this same loop just appended, e.g. distance=1 repeats
				# the previous byte `length` times.
				state.output.append(state.output[start + i])


# Decompresses a raw DEFLATE stream (RFC 1951, no zlib/gzip wrapper) -
# exactly what a zip's "Deflated" entries contain on disk.
static func _inflate(data: PoolByteArray) -> PoolByteArray:
	var state := _InflateState.new(data)
	var fixed_litlen := _fixed_litlen_table()
	var fixed_dist := _fixed_dist_table()

	while true:
		var bfinal := state.get_bit()
		var btype := state.get_bits(2)

		if btype == 0:
			state.align_to_byte()
			var len_lo: int = state.input[state.pos]
			var len_hi: int = state.input[state.pos + 1]
			var length := len_lo | (len_hi << 8)
			state.pos += 4 # skip LEN + one's-complement NLEN
			for i in range(length):
				state.output.append(state.input[state.pos + i])
			state.pos += length
		elif btype == 1:
			_inflate_huffman_block(state, fixed_litlen, fixed_dist)
		elif btype == 2:
			var tables := _read_dynamic_tables(state)
			_inflate_huffman_block(state, tables[0], tables[1])
		else:
			push_error("SimpleZip: reserved/invalid DEFLATE block type (corrupt data?)")
			break

		if bfinal == 1:
			break

	return PoolByteArray(state.output)
