# [license]
# 3-Clause BSD NON-AI License
# 
# Copyright 2026 __hev (Benjamin Buckhurst)
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.
# 
# 4. The source code and the binary form, and any modifications made to them may not be used for the purpose of input data, reference code snippets and/or files, OR used in the training of, or improvement of machine learning algorithms,
# including but not limited to artificial intelligence, natural language processing, or data mining. This condition applies to any derivatives,
# modifications, or updates based on the Software code. Any usage of the source code or the binary form may not be present in any form as data fed, inputted, or provided to an AI, or present in any AI-training dataset is considered a breach of this License.
# 
# 5. Any projects deriving work from this project MUST include a copy of this license and all other license and/or copyright agreements posed within other source material,
# all of which must be followed to its entirety. Failure to follow these licenses prohibit all modification and redistribution of the material until all licensing has been reinstated.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# [/license]

extends Reference

func compress_data(files:Dictionary,file_path:String) -> String:
	var datetime:Dictionary=Time.get_datetime_dict_from_system()
	var dos_time:int=(datetime.hour<<11)|(datetime.minute<<5)|int(datetime.second/2.0)
	var dos_date:int=(int(max(datetime.year-1980,0))<<9)|(datetime.month<<5)|datetime.day
	var dt1:int=dos_time&0xFF
	var dt2:int=(dos_time>>8)&0xFF
	var dt3:int=dos_date&0xFF
	var dt4:int=(dos_date>>8)&0xFF
	var buffer:PoolByteArray=PoolByteArray()
	var central_records:Array=Array()
	central_records.resize(files.size())
	var entry_idx:int=0
	for entry_path in files.keys():
		var data:PoolByteArray=files[entry_path]
		var offset:int=buffer.size()
		var uncompressed_size:int=data.size()
		var name_bytes:PoolByteArray=entry_path.to_utf8()
		var crc:int=get_crc_32(data)
		var name_size:int=name_bytes.size()
		var uc1:int=uncompressed_size&0xFF
		var uc2:int=(uncompressed_size>>8)&0xFF
		var uc3:int=(uncompressed_size>>16)&0xFF
		var uc4:int=(uncompressed_size>>24)&0xFF
		buffer.resize(offset+30)
		buffer[offset]=80;buffer[offset+1]=75;buffer[offset+2]=3;buffer[offset+3]=4 # Local entry magic number
		buffer[offset+4]=20;buffer[offset+5]=0 # Version to extract
		buffer[offset+6]=0;buffer[offset+7]=8 # General purpose flag, marks use of UTF8
		buffer[offset+8]=0;buffer[offset+9]=0 # Compression (none)
		buffer[offset+10]=dt1;buffer[offset+11]=dt2 # Time
		buffer[offset+12]=dt3;buffer[offset+13]=dt4 # Date
		buffer[offset+14]=crc&0xFF;buffer[offset+15]=(crc>>8)&0xFF;buffer[offset+16]=(crc>>16)&0xFF;buffer[offset+17]=(crc>>24)&0xFF # CRC32
		buffer[offset+18]=uc1;buffer[offset+19]=uc2;buffer[offset+20]=uc3;buffer[offset+21]=uc4 # Compressed size
		buffer[offset+22]=uc1;buffer[offset+23]=uc2;buffer[offset+24]=uc3;buffer[offset+25]=uc4 # Uncompressed size
		buffer[offset+26]=name_size&0xFF;buffer[offset+27]=(name_size>>8)&0xFF # Filename length
		buffer[offset+28]=0;buffer[offset+29]=0 # Extra field length
		buffer.append_array(name_bytes)
		buffer.append_array(data)
		central_records[entry_idx]={"name_bytes":name_bytes,"crc":crc,"uncomp_size":uncompressed_size,"offset":offset}
		entry_idx+=1
	var cdr:int=buffer.size()
	for rec in central_records:
		var name_bytes:PoolByteArray=rec.name_bytes
		var name_size:int=name_bytes.size()
		var uncomp_size:int=rec.uncomp_size
		var uc1:int=uncomp_size&0xFF
		var uc2:int=(uncomp_size>>8)&0xFF
		var uc3:int=(uncomp_size>>16)&0xFF
		var uc4:int=(uncomp_size>>24)&0xFF
		var crc:int=rec.crc
		var offset:int=rec.offset
		var bsize:int=buffer.size()
		buffer.resize(bsize+46)
		buffer[bsize]=80;buffer[bsize+1]=75;buffer[bsize+2]=1;buffer[bsize+3]=2 # Central dir magic number
		buffer[bsize+4]=20;buffer[bsize+5]=0 # Version created
		buffer[bsize+6]=20;buffer[bsize+7]=0 # Version to decompress to
		buffer[bsize+8]=0;buffer[bsize+9]=8 # General flag, marks use of UTF8
		buffer[bsize+10]=0;buffer[bsize+11]=0 # Store method (none)
		buffer[bsize+12]=dt1;buffer[bsize+13]=dt2 # Time
		buffer[bsize+14]=dt3;buffer[bsize+15]=dt4 # Date
		buffer[bsize+16]=crc&0xFF;buffer[bsize+17]=(crc>>8)&0xFF;buffer[bsize+18]=(crc>>16)&0xFF;buffer[bsize+19]=(crc>>24)&0xFF # CRC32
		buffer[bsize+20]=uc1;buffer[bsize+21]=uc2;buffer[bsize+22]=uc3;buffer[bsize+23]=uc4 # Compressed size
		buffer[bsize+24]=uc1;buffer[bsize+25]=uc2;buffer[bsize+26]=uc3;buffer[bsize+27]=uc4 # Uncompressed size
		buffer[bsize+28]=name_size&0xFF;buffer[bsize+29]=(name_size>>8)&0xFF # Name length
		buffer[bsize+30]=0;buffer[bsize+31]=0 # Extra field length
		buffer[bsize+32]=0;buffer[bsize+33]=0 # Comment length
		buffer[bsize+34]=0;buffer[bsize+35]=0 # Disk
		buffer[bsize+36]=0;buffer[bsize+37]=0 # File attributes
		buffer[bsize+38]=0;buffer[bsize+39]=0;buffer[bsize+40]=0;buffer[bsize+41]=0 # External file attributes
		buffer[bsize+42]=offset&0xFF;buffer[bsize+43]=(offset>>8)&0xFF;buffer[bsize+44]=(offset>>16)&0xFF;buffer[bsize+45]=(offset>>24)&0xFF # CD offset
		buffer.append_array(name_bytes) # File name bytes
	var cdrs:int=buffer.size()-cdr
	var crs:int=central_records.size()
	var cr1:int=crs
	var cr2:int=(crs>>8)&0xFF
	var offset:int=buffer.size()
	buffer.resize(offset+22)
	buffer[offset]=80;buffer[offset+1]=75;buffer[offset+2]=5;buffer[offset+3]=6 # EOCD magic number
	buffer[offset+4]=0;buffer[offset+5]=0;buffer[offset+6]=0;buffer[offset+7]=0 # Disk
	buffer[offset+8]=cr1;buffer[offset+9]=cr2;buffer[offset+10]=cr1;buffer[offset+11]=cr2 # Size
	buffer[offset+12]=cdrs&0xFF;buffer[offset+13]=(cdrs&0xFF00)>>8;buffer[offset+14]=(cdrs&0xFF0000)>>16;buffer[offset+15]=(cdrs&0xFF000000)>>24 # CD size
	buffer[offset+16]=cdr&0xFF;buffer[offset+17]=(cdr&0xFF00)>>8;buffer[offset+18]=(cdr&0xFF0000)>>16;buffer[offset+19]=(cdr&0xFF000000)>>24 # CD offset
	buffer[offset+20]=0;buffer[offset+21]=0 # Comment length
	var file:File=File.new()
	file.open(file_path,File.WRITE)
	file.store_buffer(buffer)
	file.close()
	return file_path

var crcTables:Reference=load(get_script().resource_path.get_base_dir()+"/crc32_table_cache.gd")
var crc_table_0:Array=crcTables.T0;var crc_table_1:Array=crcTables.T1;var crc_table_2:Array=crcTables.T2;var crc_table_3:Array=crcTables.T3
var crc_table_4:Array=crcTables.T4;var crc_table_5:Array=crcTables.T5;var crc_table_6:Array=crcTables.T6;var crc_table_7:Array=crcTables.T7
var crc_table_8:Array=crcTables.T8;var crc_table_9:Array=crcTables.T9;var crc_table_10:Array=crcTables.T10;var crc_table_11:Array=crcTables.T11
var crc_table_12:Array=crcTables.T12;var crc_table_13:Array=crcTables.T13;var crc_table_14:Array=crcTables.T14;var crc_table_15:Array=crcTables.T15
var crc_table_16:Array=crcTables.T16;var crc_table_17:Array=crcTables.T17;var crc_table_18:Array=crcTables.T18;var crc_table_19:Array=crcTables.T19
var crc_table_20:Array=crcTables.T20;var crc_table_21:Array=crcTables.T21;var crc_table_22:Array=crcTables.T22;var crc_table_23:Array=crcTables.T23
var crc_table_24:Array=crcTables.T24;var crc_table_25:Array=crcTables.T25;var crc_table_26:Array=crcTables.T26;var crc_table_27:Array=crcTables.T27
var crc_table_28:Array=crcTables.T28;var crc_table_29:Array=crcTables.T29;var crc_table_30:Array=crcTables.T30;var crc_table_31:Array=crcTables.T31
func get_crc_32(bytes:PoolByteArray)->int:
	var crc:int=0xFFFFFFFF
	var size:int=bytes.size()
	var groups:float=floor(size/32.0)
	var i:int=0
	for g in groups:
		# Rare me splitting a variable that isn't an array or dictionary between lines.
		# Impossible to read and work on otherwise so enjoy the readable code while you can:P
		crc=(
			crc_table_31[(crc&0xFF)^bytes[i]]^
			crc_table_30[((crc>>8)&0xFF)^bytes[i+1]]^
			crc_table_29[((crc>>16)&0xFF)^bytes[i+2]]^
			crc_table_28[((crc>>24)&0xFF)^bytes[i+3]]^
			crc_table_27[bytes[i+4]]^
			crc_table_26[bytes[i+5]]^
			crc_table_25[bytes[i+6]]^
			crc_table_24[bytes[i+7]]^
			crc_table_23[bytes[i+8]]^
			crc_table_22[bytes[i+9]]^
			crc_table_21[bytes[i+10]]^
			crc_table_20[bytes[i+11]]^
			crc_table_19[bytes[i+12]]^
			crc_table_18[bytes[i+13]]^
			crc_table_17[bytes[i+14]]^
			crc_table_16[bytes[i+15]]^
			crc_table_15[bytes[i+16]]^
			crc_table_14[bytes[i+17]]^
			crc_table_13[bytes[i+18]]^
			crc_table_12[bytes[i+19]]^
			crc_table_11[bytes[i+20]]^
			crc_table_10[bytes[i+21]]^
			crc_table_9[bytes[i+22]]^
			crc_table_8[bytes[i+23]]^
			crc_table_7[bytes[i+24]]^
			crc_table_6[bytes[i+25]]^
			crc_table_5[bytes[i+26]]^
			crc_table_4[bytes[i+27]]^
			crc_table_3[bytes[i+28]]^
			crc_table_2[bytes[i+29]]^
			crc_table_1[bytes[i+30]]^
			crc_table_0[bytes[i+31]]
		)
		i+=32
	while i<size:
		crc=crc_table_0[(crc^bytes[i])&0xFF]^(crc>>8)
		i+=1
	return crc^0xFFFFFFFF

