extends Node

# PKWare DCL "implode/explode" compression format, reimplemented in GDScript from Julius's zip.c
# ----- this is NOT the standard DEFLATE (ZIP) format!! -----

enum Codes {
	PK_SUCCESS = 0,
	PK_INVALID_WINDOWSIZE = 1,
	PK_LITERAL_ENCODING_UNSUPPORTED = 2,
	PK_TOO_FEW_INPUT_BYTES = 3,
	PK_ERROR_DECODING = 4,
	PK_EOF = 773,
	PK_ERROR_VALUE = 774
}

# lookup tables for copy offset encoding
const COPY_OFFSET_BITS = [
	2, 4, 4, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6,
	6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
	7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
	8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
]
const COPY_OFFSET_CODE = [
	0x03, 0x0D, 0x05, 0x19, 0x09, 0x11, 0x01, 0x3E,
	0x1E, 0x2E, 0x0E, 0x36, 0x16, 0x26, 0x06, 0x3A,
	0x1A, 0x2A, 0x0A, 0x32, 0x12, 0x22, 0x42, 0x02,
	0x7C, 0x3C, 0x5C, 0x1C, 0x6C, 0x2C, 0x4C, 0x0C,
	0x74, 0x34, 0x54, 0x14, 0x64, 0x24, 0x44, 0x04,
	0x78, 0x38, 0x58, 0x18, 0x68, 0x28, 0x48, 0x08,
	0xF0, 0x70, 0xB0, 0x30, 0xD0, 0x50, 0x90, 0x10,
	0xE0, 0x60, 0xA0, 0x20, 0xC0, 0x40, 0x80, 0x00,
]

# lookup tables for copy length encoding
const COPY_LENGTH_BASE_BITS = [3, 2, 3, 3, 4, 4, 4, 5, 5, 5, 5, 6, 6, 6, 7, 7]
const COPY_LENGTH_BASE_VALUE = [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x0A, 0x0E, 0x16, 0x26, 0x46, 0x86, 0x106]
const COPY_LENGTH_BASE_CODE = [0x05, 0x03, 0x01, 0x06, 0x0A, 0x02, 0x0C, 0x14, 0x04, 0x18, 0x08, 0x30, 0x10, 0x20, 0x40, 0x00]
const COPY_LENGTH_EXTRA_BITS = [0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 5, 6, 7, 8]

var d_copy_offset_jump_table: Array # 256 <-- these need to be Array to be passed by reference in funcs
var d_copy_length_jump_table: Array # 256
func _ready():
	d_copy_offset_jump_table = []
	d_copy_offset_jump_table.resize(256)
	d_copy_offset_jump_table.fill(0)
	d_copy_length_jump_table = []
	d_copy_length_jump_table.resize(256)
	d_copy_length_jump_table.fill(0)
	_construct_jump_table(16, COPY_LENGTH_BASE_BITS, COPY_LENGTH_BASE_CODE, d_copy_length_jump_table)
	_construct_jump_table(64, COPY_OFFSET_BITS, COPY_OFFSET_CODE, d_copy_offset_jump_table)

# ================= decomp buffer / token
var token_stop: bool
var token_input_ptr: int
var token_input_length: int
var token_output_ptr: int
var token_output_length: int

var d_window_size: int
var d_dictionary_size: int
var d_current_input_byte: int
var d_current_input_bits_available: int

var d_input_buffer_ptr: int
var d_input_buffer_end: int
var d_output_buffer_ptr: int
var d_input_buffer: PoolByteArray # 2048
var d_output_buffer: PoolByteArray # 8708 --- 2x 4096 (max dict size) + 516 for copying


var r_input_data # <------------- REAL input data!
var r_output_data # <------------ REAL output buffer!

func print_debug_stuff(token, __rounds):
	
	print("\n\n\n")
	print("d_input_buffer_ptr = ", d_input_buffer_ptr)
	print("d_output_buffer_ptr = ", d_output_buffer_ptr)
	print("token_input_ptr = ", token_input_ptr)
	print("token_output_ptr = ", token_output_ptr)
	print("token = ", token)
	print("__rounds = ", __rounds)
	print("d_current_input_byte = ", d_current_input_byte)
	print("d_current_input_bits_available = ", d_current_input_bits_available)
	
	
	pass

func _cleanup():
	token_stop = false
	token_input_ptr = 0
	token_input_length = 0
	token_output_ptr = 0
	token_output_length = 0
	
#	d_window_size = 0
#	d_dictionary_size = 0
	d_current_input_byte = 0
	d_current_input_bits_available = 0
	
	d_input_buffer = PoolByteArray()
	d_input_buffer.resize(2048)
	d_input_buffer.fill(0)
	d_output_buffer = PoolByteArray()
	d_output_buffer.resize(8708)
	d_output_buffer.fill(0)
func _construct_jump_table(size: int, bits: Array, codes: Array, jump: Array) -> void:
	for i in range(size - 1, -1, -1):
		var bit = bits[i]
		var code = codes[i]
		while code < 0x100:
			jump[code] = i
			code += 1 << bit

func _input_func(length) -> int:
	if token_stop:
		return 0
	if token_input_ptr >= token_input_length:
		return 0
	length = min(length, token_input_length - token_input_ptr)
	for i in range(length):
		d_input_buffer[i] = r_input_data[token_input_ptr + i]
	token_input_ptr += length
	return length
func _output_func(length):
	if !token_stop:
		if token_output_ptr >= token_output_length:
			Log.error(self, GlobalScope.Error.ERR_OUT_OF_MEMORY, "COMP2 out of buffer space")
			token_stop = true
		else:
			if token_output_length - token_output_ptr < length:
				Log.error(self, GlobalScope.Error.ERR_FILE_CORRUPT, "COMP1 corrupt")
				token_stop = true
			else:
				for i in range(length):
					r_output_data[token_output_ptr + i] = d_output_buffer[length + i]
				token_output_ptr += length
func _set_bits_used(num_bits: int) -> bool:
	if d_current_input_bits_available >= num_bits:
		d_current_input_bits_available -= num_bits
		d_current_input_byte = d_current_input_byte >> num_bits
		return false
	d_current_input_byte = d_current_input_byte >> d_current_input_bits_available
	
	# need to read more bytes
	if d_input_buffer_ptr == d_input_buffer_end:
		
		d_input_buffer_ptr = 2048
		d_input_buffer_end = 2048
		d_input_buffer_end = _input_func(2048)
		if d_input_buffer_end == 0:
			return true
		d_input_buffer_ptr = 0

	d_current_input_byte |= d_input_buffer[d_input_buffer_ptr] << 8
	d_input_buffer_ptr += 1
	d_current_input_byte = d_current_input_byte >> (num_bits - d_current_input_bits_available)
	d_current_input_bits_available += 8 - num_bits
	return false
func _get_copy_offset(copy_length: int) -> int:
	var index = d_copy_offset_jump_table[d_current_input_byte & 0xFF]
	if _set_bits_used(COPY_OFFSET_BITS[index]):
		return 0
	var offset
	if copy_length == 2:
		offset = (d_current_input_byte & 3) | (index << 2)
		if _set_bits_used(2):
			return 0
	else:
		offset = (d_current_input_byte & d_dictionary_size) | (index << d_window_size)
		if _set_bits_used(d_window_size):
			return 0
	return offset + 1
func decompress(compressed_data: PoolByteArray, expected_size: int):
	_cleanup()
	r_input_data = compressed_data
	r_output_data = PoolByteArray()
	r_output_data.resize(expected_size)
	r_output_data.fill(0)
	token_input_length = compressed_data.size()
	token_output_length = expected_size
	
	# read initial buffer
	d_input_buffer_end = _input_func(2048)
	if d_input_buffer_end <= 4:
		return Log.error(self, GlobalScope.Error.ERR_INVALID_DATA, "compressed data too small")
	d_output_buffer_ptr = 4096;

	# fetch header params
	var has_literal_encoding = d_input_buffer[0]
	d_window_size = d_input_buffer[1]
	d_current_input_byte = d_input_buffer[2]
	d_input_buffer_ptr = 3
	if d_window_size < 4 || d_window_size > 6:
		return Log.error(self, GlobalScope.Error.ERR_INVALID_PARAMETER, "invalid window size '%s'" % [d_window_size])
	d_dictionary_size = 0xFFFF >> (16 - d_window_size)
	if has_literal_encoding != 0:
		return Log.error(self, GlobalScope.Error.ERR_INVALID_PARAMETER, "literal encoding not supported")

	# main loop
	var token = null
	var __rounds = 0
	while true:
		
		if __rounds == 4:
#		if __rounds == 5246:
			pass
		# decode next token
		print_debug_stuff(token, __rounds)
		if d_current_input_byte & 1: # copy token
			if _set_bits_used(1):
				return Log.error(self, GlobalScope.Error.ERR_PARSE_ERROR, "decompression error: '%s'" % [Codes.PK_ERROR_VALUE])
			else:
				var index = d_copy_length_jump_table[d_current_input_byte & 0xFF]
				if _set_bits_used(COPY_LENGTH_BASE_BITS[index]):
					return Log.error(self, GlobalScope.Error.ERR_PARSE_ERROR, "decompression error: '%s'" % [Codes.PK_ERROR_VALUE])
				else:
					var extra_bits = COPY_LENGTH_EXTRA_BITS[index]
					if extra_bits > 0:
						var extra_bits_value = d_current_input_byte & ((1 << extra_bits) - 1)
						if _set_bits_used(extra_bits) && index + extra_bits_value != 270:
							return Log.error(self, GlobalScope.Error.ERR_PARSE_ERROR, "decompression error: '%s'" % [Codes.PK_ERROR_VALUE])
						index = COPY_LENGTH_BASE_VALUE[index] + extra_bits_value
					token = index + 256
		else: # literal token
			if _set_bits_used(1):
				return Log.error(self, GlobalScope.Error.ERR_PARSE_ERROR, "decompression error: '%s'" % [Codes.PK_ERROR_VALUE])
			token = d_current_input_byte & 0xFF
			if _set_bits_used(8):
				return Log.error(self, GlobalScope.Error.ERR_PARSE_ERROR, "decompression error: '%s'" % [Codes.PK_ERROR_VALUE])

		if token == Codes.PK_EOF:
			break
		elif token >= 256: # offset shift
			var length = token - 254
			var offset = _get_copy_offset(length) # <--------- at round 2
			if offset == 0:
				return Log.error(self, GlobalScope.Error.ERR_PARSE_ERROR, "decompression error: '%s'" % [Codes.PK_ERROR_VALUE])
			var src_ptr = d_output_buffer_ptr - offset
			for i in range(length):
				d_output_buffer[d_output_buffer_ptr + i] = d_output_buffer[src_ptr + i]
			d_output_buffer_ptr += length
		else: # literal byte
			d_output_buffer[d_output_buffer_ptr] = token
			d_output_buffer_ptr += 1
		
		# flush buffer if needed
		if d_output_buffer_ptr >= 8192:
			_output_func(4096)
			
			var remaining = d_output_buffer_ptr - 4096
			for i in range(remaining):
				d_output_buffer[i] = d_output_buffer[4096 + i]
			d_output_buffer_ptr = remaining
		__rounds += 1
	_output_func(d_output_buffer_ptr - 4096)
	# ====== return from pk_explode_data <------------ back to pk_explode
	
	print_debug_stuff(token, __rounds)
	if token != Codes.PK_EOF:
		return Log.error(self, GlobalScope.Error.ERR_PARSE_ERROR, "decompression error: '%s'" % [Codes.PK_ERROR_VALUE])
	if token_stop:
		return Log.error(self, GlobalScope.Error.ERR_PARSE_ERROR, "COMP error uncompressing")
	if token_output_ptr != expected_size:
		return Log.error(self, GlobalScope.Error.ERR_FILE_EOF, "decompression completed with incorrect size")
	return r_output_data


