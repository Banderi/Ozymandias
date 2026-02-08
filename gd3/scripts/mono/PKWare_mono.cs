using Godot;
using Godot.Collections;
using System;
using System.Linq.Expressions;

public class PKWare_mono : Node
{
	// Log.error(...)
	private Node Log;
	private Dictionary Errors;
	private byte[] error(string Err, string Message) {
		GetNode("/root/Log").Call("error", "", Errors[Err], Message);
		return new byte[0];
	}
	
	enum Codes {
		PK_SUCCESS = 0,
		PK_INVALID_WINDOWSIZE = 1,
		PK_LITERAL_ENCODING_UNSUPPORTED = 2,
		PK_TOO_FEW_INPUT_BYTES = 3,
		PK_ERROR_DECODING = 4,
		PK_EOF = 773,
		PK_ERROR_VALUE = 774
	}

	// lookup tables for copy offset encoding
	private static readonly int[] COPY_OFFSET_BITS = {
		2, 4, 4, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6,
		6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
		7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
		8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
	};
	private static readonly int[] COPY_OFFSET_CODE = {
		0x03, 0x0D, 0x05, 0x19, 0x09, 0x11, 0x01, 0x3E,
		0x1E, 0x2E, 0x0E, 0x36, 0x16, 0x26, 0x06, 0x3A,
		0x1A, 0x2A, 0x0A, 0x32, 0x12, 0x22, 0x42, 0x02,
		0x7C, 0x3C, 0x5C, 0x1C, 0x6C, 0x2C, 0x4C, 0x0C,
		0x74, 0x34, 0x54, 0x14, 0x64, 0x24, 0x44, 0x04,
		0x78, 0x38, 0x58, 0x18, 0x68, 0x28, 0x48, 0x08,
		0xF0, 0x70, 0xB0, 0x30, 0xD0, 0x50, 0x90, 0x10,
		0xE0, 0x60, 0xA0, 0x20, 0xC0, 0x40, 0x80, 0x00,
	};

	// lookup tables for copy length encoding
	private static readonly int[] COPY_LENGTH_BASE_BITS = {3, 2, 3, 3, 4, 4, 4, 5, 5, 5, 5, 6, 6, 6, 7, 7};
	private static readonly int[] COPY_LENGTH_BASE_VALUE = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x0A, 0x0E, 0x16, 0x26, 0x46, 0x86, 0x106};
	private static readonly int[] COPY_LENGTH_BASE_CODE = {0x05, 0x03, 0x01, 0x06, 0x0A, 0x02, 0x0C, 0x14, 0x04, 0x18, 0x08, 0x30, 0x10, 0x20, 0x40, 0x00};
	private static readonly int[] COPY_LENGTH_EXTRA_BITS = {0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 5, 6, 7, 8};

	// explode/implode tables
	private int[] d_copy_offset_jump_table;	// 256
	private int[] d_copy_length_jump_table; // 256
	private int[] c_codeword_bits;			// 774
	private int[] c_codeword_values;		// 774

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		// Called every time the node is added to the scene.
		// Initialization here.
		GD.Print("PKWareMono");
		
		// Log.error(...)
		Log = GetNode("/root/Log");
		var script = ResourceLoader.Load("res://scripts/classes/GlobalScope.gd") as Script;
		Dictionary consts = script.GetScriptConstantMap();
		Errors = consts["Error"] as Dictionary;

		_PK_init();
	}

	// init global/const data & tables
	private void _PK_init() {
		// PKWare explode jump tables
		d_copy_offset_jump_table = new int[256];
		d_copy_length_jump_table = new int[256];
		_construct_explode_jump_table(16, COPY_LENGTH_BASE_BITS, COPY_LENGTH_BASE_CODE, d_copy_length_jump_table);
		_construct_explode_jump_table(64, COPY_OFFSET_BITS, COPY_OFFSET_CODE, d_copy_offset_jump_table);

		// PKWare implode bits/value tables
		c_codeword_bits = new int[774];
		c_codeword_values = new int[774];
		for (int i = 0; i < 256; i++) {			// literal bytes: 9 bits (8-bit value + leading 0)
			c_codeword_bits[i] = 9;				// 8 + 1 for leading zero
			c_codeword_values[i] = (i << 1);	// include leading zero to indicate literal byte
		}
		int code_index = 256;
		for (int i = 0; i < 16; i++) {			// copy length codes after the literal bits
			int base_bits = COPY_LENGTH_BASE_BITS[i];
			int extra_bits = COPY_LENGTH_EXTRA_BITS[i];
			int base_code = COPY_LENGTH_BASE_CODE[i];
			int max = 1 << extra_bits;
			for (int j = 0; j < max; j++) {
				c_codeword_bits[code_index] = 1 + base_bits + extra_bits;
				c_codeword_values[code_index] = 1 | (base_code << 1) | (j << (base_bits + 1));
				code_index++;
			}
		}
	}
	private void _construct_explode_jump_table(int size, int[] bits, int[] codes, int[] jump) { // jump[] <-- output
		for (int i = size - 1; i > -1; i--) {
			var bit = bits[i];
			var code = codes[i];
			while (code < 0x100) {
				jump[code] = i;
				code += 1 << bit;
			}
		}
	}


	// ================= token
	private bool token_stop;
	private int token_input_ptr;
	private int token_input_length;
	private int token_output_ptr;
	private int token_output_length;
	private void _reset_token() {
		token_stop = false;
		token_input_ptr = 0;
		token_input_length = 0;
		token_output_ptr = 0;
		token_output_length = 0;
	}

	private int _window_size;
	private int _dictionary_size;

	// ================= decompression (inflate)
	private int d_current_input_byte;
	private int d_current_input_bits_available;

	private int d_input_buffer_ptr;
	private int d_input_buffer_end;
	private int d_output_buffer_ptr;
	
	private byte[] _input_buffer;			// 8708 (deflate) --- 2048 (inflate)
	private byte[] _output_buffer;			// 2050 (deflate) --- 8708 (inflate) < 2x 4096 (max dict size) + 516 for copying

	// ================= compression (deflate)
	private int c_copy_offset_extra_mask;
	private int c_current_output_bits_used;
	private int[] c_analyze_offset_table;	// 2304
	private int[] c_analyze_index;			// 8708
	private int[] c_long_matcher;			// 518

	// private int c_current_copy_length;
	// private int c_current_copy_offset;
	// private int c_next_copy_length;
	// private int c_next_copy_offset;

	private struct Copy {
		public int length;
		public int offset;
	}
	private Copy c_copy;
	// private int c_copy_length;
	// private int c_copy_offset;


	private byte[] r_input_data; // <------------- REAL input data!
	private byte[] r_output_data; // <------------ REAL output buffer!

	private int _input_func(int starting_buffer_ptr, int length) {
		if (token_stop)
			return 0;
		if (token_input_ptr >= token_input_length)
			return 0;
		length = Math.Min(length, token_input_length - token_input_ptr);
		for (int i = 0; i < length; i++)
			_input_buffer[i + starting_buffer_ptr] = r_input_data[token_input_ptr + i];
		token_input_ptr += length;
		return length;
	}
	private void _output_func(int starting_buffer_ptr, int length) {
		if (token_stop)
			return;
		if (token_output_ptr >= token_output_length) {
			error("ERR_OUT_OF_MEMORY", "COMP2 out of buffer space");
			token_stop = true;
			return;
		}
		if (token_output_length - token_output_ptr < length) {
			error("ERR_FILE_CORRUPT", "COMP1 corrupt");
			token_stop = true;
		} else {
			for (int i = 0; i < length; i++)
				r_output_data[token_output_ptr + i] = _output_buffer[starting_buffer_ptr + i];
			token_output_ptr += length;
		}
	}
	private bool _set_bits_used(int num_bits) {
		if (d_current_input_bits_available >= num_bits) {
			d_current_input_bits_available -= num_bits;
			d_current_input_byte = d_current_input_byte >> num_bits;
			return false;
		}
		d_current_input_byte = d_current_input_byte >> d_current_input_bits_available;
		
		// need to read more bytes
		if (d_input_buffer_ptr == d_input_buffer_end) {
			d_input_buffer_ptr = 2048;
			d_input_buffer_end = 2048;
			d_input_buffer_end = _input_func(0, 2048);
			if (d_input_buffer_end == 0)
				return true;
			d_input_buffer_ptr = 0;
		}
		d_current_input_byte |= _input_buffer[d_input_buffer_ptr] << 8;
		d_input_buffer_ptr += 1;
		d_current_input_byte = d_current_input_byte >> (num_bits - d_current_input_bits_available);
		d_current_input_bits_available += 8 - num_bits;
		return false;
	}
	private int _get_copy_offset(int copy_length) {
		var index = d_copy_offset_jump_table[d_current_input_byte & 0xFF];
		if (_set_bits_used(COPY_OFFSET_BITS[index]))
			return 0;
		int offset;
		if (copy_length == 2) {
			offset = (d_current_input_byte & 3) | (index << 2);
			if (_set_bits_used(2))
				return 0;
		} else {
			offset = (d_current_input_byte & _dictionary_size) | (index << _window_size);
			if (_set_bits_used(_window_size))
				return 0;
		}
		return offset + 1;
	}
	public byte[] Inflate(byte[] compressed_data, int expected_size) {
		_reset_token();
		d_current_input_byte = 0;
		d_current_input_bits_available = 0;
		_input_buffer = new byte[2048];
		_output_buffer = new byte[8708];

		r_input_data = compressed_data;
		r_output_data = new byte[expected_size];
		token_input_length = compressed_data.Length;
		token_output_length = expected_size;
		
		// read initial buffer
		d_input_buffer_end = _input_func(0, 2048);
		if (d_input_buffer_end <= 4)
			return error("ERR_INVALID_DATA", "compressed data too small");
		d_output_buffer_ptr = 4096;

		// fetch header params
		var has_literal_encoding = _input_buffer[0];
		_window_size = _input_buffer[1];
		d_current_input_byte = _input_buffer[2];
		d_input_buffer_ptr = 3;
		if (_window_size < 4 || _window_size > 6)
			return error("ERR_INVALID_PARAMETER", $"invalid window size '{_window_size}'");
		_dictionary_size = 0xFFFF >> (16 - _window_size);
		if (has_literal_encoding != 0)
			return error("ERR_INVALID_PARAMETER", "literal encoding not supported");

		// main loop
		int token;
		int __rounds = 0;
		while (true) {

			// decode next token
			if ((d_current_input_byte & 1) == 1) { // copy token
				if (_set_bits_used(1))
					return error("ERR_PARSE_ERROR", $"decompression error: '{Codes.PK_ERROR_VALUE}'");
				else {
					var index = d_copy_length_jump_table[d_current_input_byte & 0xFF];
					if (_set_bits_used(COPY_LENGTH_BASE_BITS[index]))
						return error("ERR_PARSE_ERROR", $"decompression error: '{Codes.PK_ERROR_VALUE}'");
					else {
						var extra_bits = COPY_LENGTH_EXTRA_BITS[index];
						if (extra_bits > 0) {
							var extra_bits_value = d_current_input_byte & ((1 << extra_bits) - 1);
							if (_set_bits_used(extra_bits) && index + extra_bits_value != 270)
								return error("ERR_PARSE_ERROR", $"decompression error: '{Codes.PK_ERROR_VALUE}'");
							index = COPY_LENGTH_BASE_VALUE[index] + extra_bits_value;
						}
						token = index + 256;
					}
				}
			} else { // literal token
				if (_set_bits_used(1))
					return error("ERR_PARSE_ERROR", $"decompression error: '{Codes.PK_ERROR_VALUE}'");
				token = d_current_input_byte & 0xFF;
				if (_set_bits_used(8))
					return error("ERR_PARSE_ERROR", $"decompression error: '{Codes.PK_ERROR_VALUE}'");
			}
			if (token == (int)Codes.PK_EOF)
				break;
			else if (token >= 256) { // offset shift
				var length = token - 254;
				var offset = _get_copy_offset(length);
				if (offset == 0)
					return error("ERR_PARSE_ERROR", $"decompression error: '{Codes.PK_ERROR_VALUE}'");
				var src_ptr = d_output_buffer_ptr - offset;
				for (int i = 0; i < length; i++)
					_output_buffer[d_output_buffer_ptr + i] = _output_buffer[src_ptr + i];
				d_output_buffer_ptr += length;
			} else { // literal byte
				_output_buffer[d_output_buffer_ptr] = (byte)token;
				d_output_buffer_ptr += 1;
			}
			// flush buffer if needed
			if (d_output_buffer_ptr >= 8192) {
				_output_func(4096, 4096);
				
				var remaining = d_output_buffer_ptr - 4096;
				for (int i = 0; i < remaining; i++)
					_output_buffer[i] = _output_buffer[4096 + i];
				d_output_buffer_ptr = remaining;
			}
			__rounds++;
		}
		_output_func(4096, d_output_buffer_ptr - 4096);
		// ====== return from pk_explode_data <------------ back to pk_explode
		
		if (token != (int)Codes.PK_EOF)
			return error("ERR_PARSE_ERROR", $"decompression error: '{Codes.PK_ERROR_VALUE}'");
		if (token_stop)
			return error("ERR_PARSE_ERROR", "COMP error uncompressing");
		if (token_output_ptr != expected_size)
			return error("ERR_FILE_EOF", "decompression completed with incorrect size");
		return r_output_data;
	}

	private int pk_implode_fill_input_buffer(int bytes_to_read) {
		int used = 0;
		int read;
		do {
			read = _input_func(_dictionary_size + 516 + used, bytes_to_read);
			used += read;
			bytes_to_read -= read;
		} while (read != 0 && bytes_to_read > 0);
		return used;
	}
	private void pk_implode_flush_full_buffer() {
		_output_func(0, 2048);
		byte new_first_byte = _output_buffer[2048];
		byte last_byte = _output_buffer[d_output_buffer_ptr];
		d_output_buffer_ptr -= 2048;
		// memset(_output_buffer, 0, 2050); // <------- useless????
		for (int i = 0; i < 2050; i++)
			_output_buffer[i] = 0;
		if (d_output_buffer_ptr != 0)
			_output_buffer[0] = new_first_byte;
		if (c_current_output_bits_used != 0)
			_output_buffer[d_output_buffer_ptr] = last_byte;
	}
	private void pk_implode_write_bits(int num_bits, int value) {
		if (num_bits > 8) { // but never more than 16
			num_bits -= 8;
			pk_implode_write_bits(8, value);
			value >>= 8;
		}
		int current_bits_used = c_current_output_bits_used;
		byte shifted_value = (byte)(value << c_current_output_bits_used);
		_output_buffer[d_output_buffer_ptr] |= shifted_value;
		c_current_output_bits_used += num_bits;
		if (c_current_output_bits_used == 8) {
			d_output_buffer_ptr++;
			c_current_output_bits_used = 0;
		} else if (c_current_output_bits_used > 8) {
			d_output_buffer_ptr++;
			_output_buffer[d_output_buffer_ptr] = (byte) (value >> (8 - current_bits_used));
			c_current_output_bits_used -= 8;
		}
		if (d_output_buffer_ptr >= 2048)
			pk_implode_flush_full_buffer();
	}
	private void pk_implode_write_copy_length_offset(ref Copy copy) {
		pk_implode_write_bits(c_codeword_bits[copy.length + 254], c_codeword_values[copy.length + 254]);

		if (copy.length == 2) {
			pk_implode_write_bits(COPY_OFFSET_BITS[copy.offset >> 2], COPY_OFFSET_CODE[copy.offset >> 2]);
			pk_implode_write_bits(2, copy.offset & 3);
		} else {
			pk_implode_write_bits(COPY_OFFSET_BITS[copy.offset >> _window_size], COPY_OFFSET_CODE[copy.offset >> _window_size]);
			pk_implode_write_bits(_window_size, copy.offset & c_copy_offset_extra_mask);
		}
	}
	private void pk_implode_determine_copy(int input_index, ref Copy copy) {
		// uint8_t *input_ptr = &_input_buffer[input_index];
		// int hash_value = 4 * input_ptr[0] + 5 * input_ptr[1];
		int input_ptr = input_index;




		// ********************
		int INPUT_INDEX = input_index;
		int CHECK = input_ptr - INPUT_INDEX; // should be 0





		int hash_value = 4 * _input_buffer[input_ptr] + 5 * _input_buffer[input_ptr + 1];
		// uint16_t *analyze_offset_ptr = &c_analyze_offset_table[hash_value];
		// uint16_t hash_analyze_index = *analyze_offset_ptr;
		int analyze_offset_ptr = hash_value;
		int hash_analyze_index = c_analyze_offset_table[analyze_offset_ptr];

		// int min_match_index = input_index - _dictionary_size + 1;
		// uint16_t *analyze_index_ptr = &c_analyze_index[hash_analyze_index];
		int min_match_index = input_index - _dictionary_size + 1;
		int analyze_index_ptr = hash_analyze_index;
		
		// if (*analyze_index_ptr < min_match_index) {
		if (c_analyze_index[analyze_index_ptr] < min_match_index) {
			do {
				analyze_index_ptr++;
				hash_analyze_index++;
			// } while (*analyze_index_ptr < min_match_index);
			} while (c_analyze_index[analyze_index_ptr] < min_match_index);
			// *analyze_offset_ptr = hash_analyze_index;
			c_analyze_offset_table[analyze_offset_ptr] = hash_analyze_index;
		}



		
		// ********************
		CHECK = input_ptr - INPUT_INDEX;




		int max_matched_bytes = 1;
		// uint8_t *prev_input_ptr = input_ptr - 1;
		int prev_input_ptr = input_ptr - 1;
		// uint16_t *hash_analyze_index_ptr = &c_analyze_index[hash_analyze_index];
		int hash_analyze_index_ptr = hash_analyze_index;
		// uint8_t *start_match = &_input_buffer[*hash_analyze_index_ptr];
		int start_match = c_analyze_index[hash_analyze_index_ptr];
		// int start_match = hash_analyze_index_ptr;
		if (prev_input_ptr <= start_match) {
			copy.length = 0;
			return;
		}
		// uint8_t *input_ptr_copy = input_ptr;
		int input_ptr_copy = input_ptr;
		while (true) {
			// if (start_match[max_matched_bytes - 1] == input_ptr_copy[max_matched_bytes - 1] &&
				// *start_match == *input_ptr_copy) {
			if (_input_buffer[start_match + max_matched_bytes - 1] == _input_buffer[input_ptr_copy + max_matched_bytes - 1] &&
				_input_buffer[start_match] == _input_buffer[input_ptr_copy]) {
				// uint8_t *start_match_plus_one = start_match + 1;
				// uint8_t *input_ptr_copy_plus_one = input_ptr_copy + 1;
				int start_match_plus_one = start_match + 1;
				int input_ptr_copy_plus_one = input_ptr_copy + 1;
				int matched_bytes_s = 2;
				do {
					start_match_plus_one++;
					input_ptr_copy_plus_one++;
					// if (*start_match_plus_one != *input_ptr_copy_plus_one)
					if (_input_buffer[start_match_plus_one] != _input_buffer[input_ptr_copy_plus_one])
						break;

					matched_bytes_s++;
				} while (matched_bytes_s < 516);
				input_ptr_copy = input_ptr;
				if (matched_bytes_s >= max_matched_bytes) {
					copy.offset =  input_ptr - start_match_plus_one - 1 + matched_bytes_s;
					max_matched_bytes = matched_bytes_s;
					if (matched_bytes_s > 10)
						break;

				}
			}
			hash_analyze_index_ptr++;
			hash_analyze_index++;
			// start_match = &_input_buffer[*hash_analyze_index_ptr];
			// start_match = hash_analyze_index_ptr;
			// int a = c_analyze_index[hash_analyze_index_ptr];
			start_match = c_analyze_index[hash_analyze_index_ptr];
			if (prev_input_ptr <= start_match) { // <---------------- BUG
				copy.length = max_matched_bytes < 2 ? 0 : max_matched_bytes;
				return;
			}
		}
		if (max_matched_bytes == 516) {
			copy.length = max_matched_bytes;
			copy.offset--;
			return;
		}
		// if (&_input_buffer[c_analyze_index[hash_analyze_index + 1]] >= prev_input_ptr) {
		if (c_analyze_index[hash_analyze_index + 1] >= prev_input_ptr) {
			copy.length = max_matched_bytes;
			return;
		}
		// Complex algorithm for finding longer match
		int long_offset = 0;
		int long_index = 1;
		c_long_matcher[0] = -1;
		c_long_matcher[1] = 0;
		do {
			// if (input_ptr[long_index] != input_ptr[long_offset]) {
			if (_input_buffer[input_ptr + long_index] != _input_buffer[input_ptr + long_offset]) {
				long_offset = c_long_matcher[long_offset];
				if (long_offset != -1)
					continue;
			}
			long_index++;
			long_offset++;
			c_long_matcher[long_index] = long_offset;
		} while (long_index < max_matched_bytes);
		int matched_bytes = max_matched_bytes;
		// uint8_t *match_ptr = &_input_buffer[max_matched_bytes] + c_analyze_index[hash_analyze_index];
		int match_ptr = max_matched_bytes + c_analyze_index[hash_analyze_index];
		while (true) {
			matched_bytes = c_long_matcher[matched_bytes];
			if (matched_bytes == -1)
				matched_bytes = 0;

			// hash_analyze_index_ptr = &c_analyze_index[hash_analyze_index];
			// uint8_t *better_match_ptr;
			hash_analyze_index_ptr = hash_analyze_index;
			int better_match_ptr;
			do {
				hash_analyze_index_ptr++;
				hash_analyze_index++;
				// better_match_ptr = &_input_buffer[*hash_analyze_index_ptr];
				better_match_ptr = c_analyze_index[hash_analyze_index_ptr];
				// int a = matched_bytes + better_match_ptr;
				if (better_match_ptr >= prev_input_ptr) {
					copy.length = max_matched_bytes;
					return; // <-------- BUG!
				}
			// } while (&better_match_ptr[matched_bytes] < match_ptr);
			} while (better_match_ptr + matched_bytes < match_ptr); 
			// if (input_ptr[max_matched_bytes - 2] != better_match_ptr[max_matched_bytes - 2]) {
			if (_input_buffer[input_ptr + max_matched_bytes - 2] != _input_buffer[better_match_ptr + max_matched_bytes - 2]) {
				while (true) {
					hash_analyze_index++;
					// better_match_ptr = &_input_buffer[c_analyze_index[hash_analyze_index]];
					better_match_ptr = c_analyze_index[hash_analyze_index];
					if (better_match_ptr >= prev_input_ptr) {
						copy.length = max_matched_bytes;
						return;
					}
					// if (better_match_ptr[max_matched_bytes - 2] == input_ptr[max_matched_bytes - 2] &&
						// *better_match_ptr == *input_ptr) {
					if (_input_buffer[better_match_ptr + max_matched_bytes - 2] == _input_buffer[input_ptr + max_matched_bytes - 2] &&
						_input_buffer[better_match_ptr] == _input_buffer[input_ptr]) {
						matched_bytes = 2;
						match_ptr = better_match_ptr + 2;
						break;
					}
				}
			// } else if (&better_match_ptr[matched_bytes] != match_ptr) {
			} else if (better_match_ptr + matched_bytes != match_ptr) {
				matched_bytes = 0;
				// match_ptr = &_input_buffer[*hash_analyze_index_ptr];
				match_ptr = c_analyze_index[hash_analyze_index_ptr];
			}
			// while (input_ptr[matched_bytes] == *match_ptr) {
			while (_input_buffer[input_ptr + matched_bytes] == _input_buffer[match_ptr]) { // <------------------------------------------------- BUG!
				matched_bytes++;
				if (matched_bytes >= 516)
					break;

				match_ptr++;
			}
			if (matched_bytes >= max_matched_bytes) {
				copy.offset = input_ptr - better_match_ptr - 1;
				if (matched_bytes > max_matched_bytes) {
					max_matched_bytes = matched_bytes;
					if (matched_bytes == 516) {
						copy.length = 516;
						return;
					}
					do {
						// if (input_ptr[long_index] != input_ptr[long_offset]) {
						if (_input_buffer[input_ptr + long_index] != _input_buffer[input_ptr + long_offset]) {
							long_offset = c_long_matcher[long_offset];
							if (long_offset != -1)
								continue;

						}
						long_index++;
						long_offset++;
						c_long_matcher[long_index] = long_offset;
					} while (long_index < matched_bytes);
				}
			}
		}
		// never reached
	}
	private bool pk_implode_next_copy_is_better(int offset, ref Copy current_copy) {
		// struct pk_copy_length_offset next_copy;
		// pk_implode_determine_copy(buf, offset + 1, &next_copy);
		// int c_next_copy_length = 0;
		// int c_next_copy_offset = 0;
		Copy next_copy = new Copy();
		pk_implode_determine_copy(offset + 1, ref next_copy);
		if (current_copy.length >= next_copy.length)
			return false;
		if (current_copy.length + 1 == next_copy.length && current_copy.offset <= 128)
			return false;
		return true;
	}
	private void pk_implode_analyze_input(int input_start, int input_end) {
		for (int i = 0; i < c_analyze_offset_table.Length; i++)
			c_analyze_offset_table[i] = 0;
		// memset(c_analyze_offset_table, 0, sizeof(c_analyze_offset_table));
		for (int index = input_start; index < input_end; index++) {
			c_analyze_offset_table[4 * _input_buffer[index] + 5 * _input_buffer[index + 1]]++;
		}

		int running_total = 0;
		for (int i = 0; i < 2304; i++) {
			running_total += c_analyze_offset_table[i];
			c_analyze_offset_table[i] = running_total;
		}

		for (int index = input_end - 1; index >= input_start; index--) {
			int hash_value = 4 * _input_buffer[index] + 5 * _input_buffer[index + 1];
			int value = --c_analyze_offset_table[hash_value];
			c_analyze_index[value] = index;
		}
	}
	public byte[] Deflate(byte[] raw_data, int dictionary_size) {
		_reset_token();
		c_current_output_bits_used = 0;
		_input_buffer = new byte[8708];
		_output_buffer = new byte[2050];

		c_analyze_offset_table = new int[2304];
   		c_analyze_index = new int[8708];
		c_long_matcher = new int[518];
		// d_output_buffer_ptr = 0; // <---- this gets set later

		r_input_data = raw_data;
		r_output_data = new byte[3000000]; // buffer of fixed size
		token_input_length = raw_data.Length;
		token_output_length = 3000000; // this gets used accordingly

		// prepare dictionary size, window size, and copy offset extra mask
		switch (dictionary_size) {
			case 1024:
				_window_size = 4;
				c_copy_offset_extra_mask = 0xf;
				break;
			case 2048:
				_window_size = 5;
				c_copy_offset_extra_mask = 0x1f;
				break;
			case 4096:
				_window_size = 6;
				c_copy_offset_extra_mask = 0x3f;
				break;
			default:
				return error("PK_INVALID_WINDOWSIZE", "compressed data too small");
		}
		_dictionary_size = dictionary_size;

		// ---------> pk_implode_data(...)




		// d_output_buffer_ptr = 0; // <---- this gets set later
		bool eof = false;
		int has_leftover_data = 0;

		_output_buffer[0] = 0; // no literal encoding
		_output_buffer[1] = (byte)_window_size;
		d_output_buffer_ptr = 2;

		int input_ptr = _dictionary_size + 516;
		// pk_memset(&_output_buffer[2], 0, 2048);

		c_current_output_bits_used = 0;

		int __rounds = 0;
		while (!eof) {
			if (__rounds == 1){
				int a = 2;}
			int bytes_read = pk_implode_fill_input_buffer(4096);
			if (bytes_read != 4096) {
				eof = true;
				if (bytes_read == 0 && has_leftover_data == 0)
					break;

			}
			int input_end = _dictionary_size + bytes_read; // keep 516 bytes leftover
			if (eof)
				input_end += 516; // eat the 516 leftovers anyway


			if (has_leftover_data == 0) {
				pk_implode_analyze_input(input_ptr, input_end + 1);
				has_leftover_data++;
				if (_dictionary_size != 4096)
					has_leftover_data++;

			} else if (has_leftover_data == 1) {
				pk_implode_analyze_input(input_ptr - _dictionary_size + 516, input_end + 1);
				has_leftover_data++;
			} else if (has_leftover_data == 2)
				pk_implode_analyze_input(input_ptr - _dictionary_size, input_end + 1);

			int __r_rounds = 0;
			while (input_ptr < input_end) {
				bool write_literal = false;
				bool write_copy = false;

				if (__rounds == 17 && __r_rounds == 154){
					bool a = true;}
				// c_current_copy_length = 0;
				// c_current_copy_offset = 0;
				// c_next_copy_length = 0;
				// c_next_copy_offset = 0;
				// struct pk_copy_length_offset copy;
				Copy copy = new Copy();
				pk_implode_determine_copy(input_ptr, ref copy);

				if (copy.length == 0)
					write_literal = true;
				else if (copy.length == 2 && copy.offset >= 256)
					write_literal = true;
				else if (eof && input_ptr + copy.length > input_end) {
					copy.length = input_end - input_ptr;
					if (input_end - input_ptr > 2 || (input_end - input_ptr == 2 && copy.offset < 256))
						write_copy = true;
					else
						write_literal = true;
				} else if (copy.length >= 8 || input_ptr + 1 >= input_end)
					write_copy = true;
				else if (pk_implode_next_copy_is_better(input_ptr, ref copy))
					write_literal = true;
				else
					write_copy = true;

				if (write_copy) {
					pk_implode_write_copy_length_offset(ref copy);
					input_ptr += copy.length;
				} else if (write_literal) {
					// Write literal
					pk_implode_write_bits(c_codeword_bits[_input_buffer[input_ptr]], c_codeword_values[_input_buffer[input_ptr]]);
					input_ptr++;
				}
				__r_rounds++;
			}

			if (!eof) {
				input_ptr -= 4096;
				// pk_memcpy(_input_buffer, &_input_buffer[4096], _dictionary_size + 516);
				// byte b = _input_buffer[4096];
				for (int i = 0; i < _dictionary_size + 516; i++)
					_input_buffer[i] = _input_buffer[4096 + i];
			}
			__rounds++;
		}

		// Write EOF
		pk_implode_write_bits(c_codeword_bits[(int)Codes.PK_EOF], c_codeword_values[(int)Codes.PK_EOF]);
		if (c_current_output_bits_used != 0)
			d_output_buffer_ptr++;

		_output_func(0, d_output_buffer_ptr);
		
		// // read initial buffer
		// d_input_buffer_end = _input_func(2048);
		// if (d_input_buffer_end <= 4)
		// 	return error("ERR_INVALID_DATA", "compressed data too small");
		// d_output_buffer_ptr = 4096;

		// // fetch header params
		// var has_literal_encoding = _input_buffer[0];
		// _window_size = _input_buffer[1];
		// d_current_input_byte = _input_buffer[2];
		// d_input_buffer_ptr = 3;
		// if (_window_size < 4 || _window_size > 6)
		// 	return error("ERR_INVALID_PARAMETER", $"invalid window size '{_window_size}'");
		// _dictionary_size = 0xFFFF >> (16 - _window_size);
		// if (has_literal_encoding != 0)
		// 	return error("ERR_INVALID_PARAMETER", "literal encoding not supported");

		// // main loop
		// int token;
		// int __rounds = 0;
		// while (true) {

		// 	// decode next token
		// 	if ((d_current_input_byte & 1) == 1) { // copy token
		// 		if (_set_bits_used(1))
		// 			return error("ERR_PARSE_ERROR", $"decompression error: '{Codes.PK_ERROR_VALUE}'");
		// 		else {
		// 			var index = d_copy_length_jump_table[d_current_input_byte & 0xFF];
		// 			if (_set_bits_used(COPY_LENGTH_BASE_BITS[index]))
		// 				return error("ERR_PARSE_ERROR", $"decompression error: '{Codes.PK_ERROR_VALUE}'");
		// 			else {
		// 				var extra_bits = COPY_LENGTH_EXTRA_BITS[index];
		// 				if (extra_bits > 0) {
		// 					var extra_bits_value = d_current_input_byte & ((1 << extra_bits) - 1);
		// 					if (_set_bits_used(extra_bits) && index + extra_bits_value != 270)
		// 						return error("ERR_PARSE_ERROR", $"decompression error: '{Codes.PK_ERROR_VALUE}'");
		// 					index = COPY_LENGTH_BASE_VALUE[index] + extra_bits_value;
		// 				}
		// 				token = index + 256;
		// 			}
		// 		}
		// 	} else { // literal token
		// 		if (_set_bits_used(1))
		// 			return error("ERR_PARSE_ERROR", $"decompression error: '{Codes.PK_ERROR_VALUE}'");
		// 		token = d_current_input_byte & 0xFF;
		// 		if (_set_bits_used(8))
		// 			return error("ERR_PARSE_ERROR", $"decompression error: '{Codes.PK_ERROR_VALUE}'");
		// 	}
		// 	if (token == (int)Codes.PK_EOF)
		// 		break;
		// 	else if (token >= 256) { // offset shift
		// 		var length = token - 254;
		// 		var offset = _get_copy_offset(length);
		// 		if (offset == 0)
		// 			return error("ERR_PARSE_ERROR", $"decompression error: '{Codes.PK_ERROR_VALUE}'");
		// 		var src_ptr = d_output_buffer_ptr - offset;
		// 		for (int i = 0; i < length; i++)
		// 			_output_buffer[d_output_buffer_ptr + i] = _output_buffer[src_ptr + i];
		// 		d_output_buffer_ptr += length;
		// 	} else { // literal byte
		// 		_output_buffer[d_output_buffer_ptr] = (byte)token;
		// 		d_output_buffer_ptr += 1;
		// 	}
		// 	// flush buffer if needed
		// 	if (d_output_buffer_ptr >= 8192) {
		// 		_output_func(4096);
				
		// 		var remaining = d_output_buffer_ptr - 4096;
		// 		for (int i = 0; i < remaining; i++)
		// 			_output_buffer[i] = _output_buffer[4096 + i];
		// 		d_output_buffer_ptr = remaining;
		// 	}
		// 	__rounds++;
		// }
		// _output_func(d_output_buffer_ptr - 4096);
		// // ====== return from pk_explode_data <------------ back to pk_explode
		
		// if (token != (int)Codes.PK_EOF)
		// 	return error("ERR_PARSE_ERROR", $"decompression error: '{Codes.PK_ERROR_VALUE}'");
		// if (token_stop)
		// 	return error("ERR_PARSE_ERROR", "COMP error uncompressing");
		System.Array.Resize(ref r_output_data, token_output_ptr);
		return r_output_data;
	}
}
