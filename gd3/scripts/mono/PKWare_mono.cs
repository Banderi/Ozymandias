using Godot;
using Godot.Collections;
using System;
using System.Linq;
using System.Linq.Expressions;
using System.Runtime.InteropServices;


public class PKWare_mono : Node
{
	// Log.error(...)
	Dictionary Errors;
	byte[] error(string Err, string Message)
	{
		Globals.Log.Call("error", "", Errors[Err], Message);
		return new byte[0];
	}
	
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		GD.Print("*** MONO: PKWareMono loaded: " + this);
		
		// GlobalScope.Errors
		var script = ResourceLoader.Load("res://scripts/classes/GlobalScope.gd") as Script;
		Dictionary consts = script.GetScriptConstantMap();
		Errors = consts["Error"] as Dictionary;

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
	void _construct_explode_jump_table(int size, int[] bits, int[] codes, int[] jump) // jump[] <-- output
	{
		for (int i = size - 1; i > -1; i--) {
			var bit = bits[i];
			var code = codes[i];
			while (code < 0x100) {
				jump[code] = i;
				code += 1 << bit;
			}
		}
	}

	enum Codes
	{
		PK_SUCCESS = 0,
		PK_INVALID_WINDOWSIZE = 1,
		PK_LITERAL_ENCODING_UNSUPPORTED = 2,
		PK_TOO_FEW_INPUT_BYTES = 3,
		PK_ERROR_DECODING = 4,
		PK_EOF = 773,
		PK_ERROR_VALUE = 774
	}

	// lookup tables for copy offset encoding
	static readonly int[] COPY_OFFSET_BITS = {
		2, 4, 4, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6,
		6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
		7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
		8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
	};
	static readonly int[] COPY_OFFSET_CODE = {
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
	static readonly int[] COPY_LENGTH_BASE_BITS = {3, 2, 3, 3, 4, 4, 4, 5, 5, 5, 5, 6, 6, 6, 7, 7};
	static readonly int[] COPY_LENGTH_BASE_VALUE = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x0A, 0x0E, 0x16, 0x26, 0x46, 0x86, 0x106};
	static readonly int[] COPY_LENGTH_BASE_CODE = {0x05, 0x03, 0x01, 0x06, 0x0A, 0x02, 0x0C, 0x14, 0x04, 0x18, 0x08, 0x30, 0x10, 0x20, 0x40, 0x00};
	static readonly int[] COPY_LENGTH_EXTRA_BITS = {0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 5, 6, 7, 8};

	// explode/implode tables
	int[] d_copy_offset_jump_table;	// 256
	int[] d_copy_length_jump_table; // 256
	int[] c_codeword_bits;			// 774
	int[] c_codeword_values;		// 774

	struct Copy {
		public int length;
		public int offset;
	}

	// ================= token
	class Tokenizer {
		internal bool stop = false;
		internal int in_ptr = 0;
		internal int in_length = 0;
		internal int out_ptr = 0;
		internal int out_length = 0;
	}
	Tokenizer tokenizer;

	int _window_size;
	int _dictionary_size;

	byte[] _input_buffer;			// 8708 (deflate) --- 2048 (inflate)
	byte[] _output_buffer;			// 2050 (deflate) --- 8708 (inflate) < 2x 4096 (max dict size) + 516 for copying

	byte[] r_input_data; // <------------- REAL input data!
	byte[] r_output_data; // <------------ REAL output buffer!
	int _output_buffer_ptr;

	// ================= decompression (inflate)
	int d_current_input_byte;
	int d_current_input_bits_available;

	int d_input_buffer_ptr;
	int d_input_buffer_end;

	// ================= compression (deflate)
	int c_copy_offset_extra_mask;
	int c_current_output_bits_used;
	int[] c_analyze_offset_table;	// 2304
	int[] c_analyze_index;			// 8708
	int[] c_long_matcher;			// 518

	int _input_func(int starting_buffer_ptr, int length) {
		if (tokenizer.stop)
			return 0;
		if (tokenizer.in_ptr >= tokenizer.in_length)
			return 0;
		length = Math.Min(length, tokenizer.in_length - tokenizer.in_ptr);
		Buffer.BlockCopy(r_input_data, tokenizer.in_ptr, _input_buffer, starting_buffer_ptr, length);
		tokenizer.in_ptr += length;
		return length;
	}
	void _output_func(int starting_buffer_ptr, int length) {
		if (tokenizer.stop)
			return;
		if (tokenizer.out_ptr >= tokenizer.out_length) {
			error("ERR_OUT_OF_MEMORY", "COMP2 out of buffer space");
			tokenizer.stop = true;
			return;
		}
		if (tokenizer.out_length - tokenizer.out_ptr < length) {
			error("ERR_FILE_CORRUPT", "COMP1 corrupt");
			tokenizer.stop = true;
		} else {
			Buffer.BlockCopy(_output_buffer, starting_buffer_ptr, r_output_data, tokenizer.out_ptr, length);
			tokenizer.out_ptr += length;
		}
	}
	bool _set_bits_used(int num_bits) {
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
	int _get_copy_offset(int copy_length) {
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
		tokenizer = new Tokenizer();
		d_current_input_byte = 0;
		d_current_input_bits_available = 0;
		_input_buffer = new byte[2048];
		_output_buffer = new byte[8708];

		r_input_data = compressed_data;
		r_output_data = new byte[expected_size];
		tokenizer.in_length = compressed_data.Length;
		tokenizer.out_length = expected_size;
		
		// read initial buffer
		d_input_buffer_end = _input_func(0, 2048);
		if (d_input_buffer_end <= 4)
			return error("ERR_INVALID_DATA", "compressed data too small");
		_output_buffer_ptr = 4096;

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
				var src_ptr = _output_buffer_ptr - offset;
				for (int i = 0; i < length; i++)
					_output_buffer[_output_buffer_ptr + i] = _output_buffer[src_ptr + i];
				// Buffer.BlockCopy(_output_buffer, src_ptr, _output_buffer, _output_buffer_ptr, length);
				_output_buffer_ptr += length;
			} else { // literal byte
				_output_buffer[_output_buffer_ptr] = (byte)token;
				_output_buffer_ptr += 1;
			}
			// flush buffer if needed
			if (_output_buffer_ptr >= 8192) {
				_output_func(4096, 4096);
				
				var remaining = _output_buffer_ptr - 4096;
				Buffer.BlockCopy(_output_buffer, 4096, _output_buffer, 0, remaining);
				_output_buffer_ptr = remaining;
			}
			__rounds++;
		}
		_output_func(4096, _output_buffer_ptr - 4096);
		// ====== return from pk_explode_data <------------ back to pk_explode
		
		if (token != (int)Codes.PK_EOF)
			return error("ERR_PARSE_ERROR", $"decompression error: '{Codes.PK_ERROR_VALUE}'");
		if (tokenizer.stop)
			return error("ERR_PARSE_ERROR", "COMP error uncompressing");
		if (tokenizer.out_ptr != expected_size)
			return error("ERR_FILE_EOF", "decompression completed with incorrect size");
		return r_output_data;
	}

	byte _fetch_oob_input_buffer(int i) {	// this is necessary because in the OG code the indexer goes out of bounds. though
		if (i < 8708)						// technically undefined behavior, pk_comp_buffer's layout has output_data[] set
			return _input_buffer[i];		// right after input_data[], and this is used by the code deterministically (e.g.
		else								// the first two bytes - IS_LITERAL_ENCODING and WINDOW_SIZE - are *always* 00 06)
			return _output_buffer[i - 8708];
	}
	void _write_bits(int num_bits, int value) {
		if (num_bits > 8) { // but never more than 16
			num_bits -= 8;
			_write_bits(8, value);
			value >>= 8;
		}
		int current_bits_used = c_current_output_bits_used;
		byte shifted_value = (byte)(value << c_current_output_bits_used);
		_output_buffer[_output_buffer_ptr] |= shifted_value;
		c_current_output_bits_used += num_bits;
		if (c_current_output_bits_used == 8) {
			_output_buffer_ptr++;
			c_current_output_bits_used = 0;
		} else if (c_current_output_bits_used > 8) {
			_output_buffer_ptr++;
			_output_buffer[_output_buffer_ptr] = (byte) (value >> (8 - current_bits_used));
			c_current_output_bits_used -= 8;
		}
		if (_output_buffer_ptr >= 2048){
			// _flush_full_buffer
			_output_func(0, 2048);
			byte new_first_byte = _output_buffer[2048];
			byte last_byte = _output_buffer[_output_buffer_ptr];
			_output_buffer_ptr -= 2048;
			System.Array.Clear(_output_buffer, 0, 2050);
			if (_output_buffer_ptr != 0)
				_output_buffer[0] = new_first_byte;
			if (c_current_output_bits_used != 0)
				_output_buffer[_output_buffer_ptr] = last_byte;
		}
	}
	void _determine_copy(int input_index, ref Copy copy) {
		int input_ptr = input_index;

		int hash_value = 4 * _input_buffer[input_ptr] + 5 * _input_buffer[input_ptr + 1];
		int analyze_offset_ptr = hash_value;
		int hash_analyze_index = c_analyze_offset_table[analyze_offset_ptr];

		int min_match_index = input_index - _dictionary_size + 1;
		int analyze_index_ptr = hash_analyze_index;
		
		if (c_analyze_index[analyze_index_ptr] < min_match_index) {
			do {
				analyze_index_ptr++;
				hash_analyze_index++;
			} while (c_analyze_index[analyze_index_ptr] < min_match_index);
			c_analyze_offset_table[analyze_offset_ptr] = hash_analyze_index;
		}

		int max_matched_bytes = 1;
		int prev_input_ptr = input_ptr - 1;
		int hash_analyze_index_ptr = hash_analyze_index;
		int start_match = c_analyze_index[hash_analyze_index_ptr];
		if (prev_input_ptr <= start_match) {
			copy.length = 0;
			return;
		}
		int input_ptr_copy = input_ptr;
		while (true) {
			if (_input_buffer[start_match + max_matched_bytes - 1] == _input_buffer[input_ptr_copy + max_matched_bytes - 1] &&
				_input_buffer[start_match] == _input_buffer[input_ptr_copy]) {
				int start_match_plus_one = start_match + 1;
				int input_ptr_copy_plus_one = input_ptr_copy + 1;
				int matched_bytes_s = 2;
				do {
					start_match_plus_one++;
					input_ptr_copy_plus_one++;
					if (_input_buffer[start_match_plus_one] != _fetch_oob_input_buffer(input_ptr_copy_plus_one))
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
			start_match = c_analyze_index[hash_analyze_index_ptr];
			if (prev_input_ptr <= start_match) {
				copy.length = max_matched_bytes < 2 ? 0 : max_matched_bytes;
				return;
			}
		}
		if (max_matched_bytes == 516) {
			copy.length = max_matched_bytes;
			copy.offset--;
			return;
		}
		if (c_analyze_index[hash_analyze_index + 1] >= prev_input_ptr) {
			copy.length = max_matched_bytes;
			return;
		}
		int long_offset = 0;
		int long_index = 1;
		c_long_matcher[0] = -1;
		c_long_matcher[1] = 0;
		do {
			if (_fetch_oob_input_buffer(input_ptr + long_index) != _input_buffer[input_ptr + long_offset]) {
				long_offset = c_long_matcher[long_offset];
				if (long_offset != -1)
					continue;
			}
			long_index++;
			long_offset++;
			c_long_matcher[long_index] = long_offset;
		} while (long_index < max_matched_bytes);
		int matched_bytes = max_matched_bytes;
		int match_ptr = max_matched_bytes + c_analyze_index[hash_analyze_index];
		while (true) {
			matched_bytes = c_long_matcher[matched_bytes];
			if (matched_bytes == -1)
				matched_bytes = 0;
			hash_analyze_index_ptr = hash_analyze_index;
			int better_match_ptr;
			do {
				hash_analyze_index_ptr++;
				hash_analyze_index++;
				better_match_ptr = c_analyze_index[hash_analyze_index_ptr];
				if (better_match_ptr >= prev_input_ptr) {
					copy.length = max_matched_bytes;
					return;
				}
			} while (better_match_ptr + matched_bytes < match_ptr); 
			if (_input_buffer[input_ptr + max_matched_bytes - 2] != _input_buffer[better_match_ptr + max_matched_bytes - 2]) {
				while (true) {
					hash_analyze_index++;
					better_match_ptr = c_analyze_index[hash_analyze_index];
					if (better_match_ptr >= prev_input_ptr) {
						copy.length = max_matched_bytes;
						return;
					}
					if (_input_buffer[better_match_ptr + max_matched_bytes - 2] == _input_buffer[input_ptr + max_matched_bytes - 2] &&
						_input_buffer[better_match_ptr] == _input_buffer[input_ptr]) {
						matched_bytes = 2;
						match_ptr = better_match_ptr + 2;
						break;
					}
				}
			} else if (better_match_ptr + matched_bytes != match_ptr) {
				matched_bytes = 0;
				match_ptr = c_analyze_index[hash_analyze_index_ptr];
			}
			while (_fetch_oob_input_buffer(input_ptr + matched_bytes) == _input_buffer[match_ptr]) {
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
	void _analyze_input(int input_start, int input_end) {
		System.Array.Clear(c_analyze_offset_table, 0, c_analyze_offset_table.Length);
		for (int index = input_start; index < input_end; index++)
			c_analyze_offset_table[4 * _input_buffer[index] + 5 * _input_buffer[index + 1]]++;
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
		tokenizer = new Tokenizer();
		c_current_output_bits_used = 0;
		_input_buffer = new byte[8708];
		_output_buffer = new byte[2050];

		c_analyze_offset_table = new int[2304];
   		c_analyze_index = new int[8708];
		c_long_matcher = new int[518];

		// int estimated_out_bufsize = tokenizer.in_length + 1024;
		int estimated_out_bufsize = 3000000; // todo: resize this automatically
		tokenizer.in_length = raw_data.Length;
		tokenizer.out_length = estimated_out_bufsize; // this gets used accordingly
		r_input_data = raw_data;
		r_output_data = new byte[estimated_out_bufsize];

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
		bool eof = false;
		int has_leftover_data = 0;

		_output_buffer[0] = 0; // no literal encoding
		_output_buffer[1] = (byte)_window_size;
		_output_buffer_ptr = 2;

		int input_ptr = _dictionary_size + 516;

		c_current_output_bits_used = 0;

		int __rounds = 0;
		while (!eof) {
			// _fill_input_buffer
			int bytes_to_read = 4096;
			int bytes_used = 0;
			int bytes_read;
			do {
				bytes_read = _input_func(_dictionary_size + 516 + bytes_used, bytes_to_read);
				bytes_used += bytes_read;
				bytes_to_read -= bytes_read;
			} while (bytes_read != 0 && bytes_to_read > 0);
			if (bytes_used != 4096) {
				eof = true;
				if (bytes_used == 0 && has_leftover_data == 0)
					break;
			}
			int input_end = _dictionary_size + bytes_used; // keep 516 bytes leftover
			if (eof)
				input_end += 516; // eat the 516 leftovers anyway

			if (has_leftover_data == 0) {
				_analyze_input(input_ptr, input_end + 1);
				has_leftover_data++;
				if (_dictionary_size != 4096)
					has_leftover_data++;

			} else if (has_leftover_data == 1) {
				_analyze_input(input_ptr - _dictionary_size + 516, input_end + 1);
				has_leftover_data++;
			} else if (has_leftover_data == 2)
				_analyze_input(input_ptr - _dictionary_size, input_end + 1);

			int __r_rounds = 0;
			while (input_ptr < input_end) {
				bool write_literal = false;
				bool write_copy = false;

				Copy copy = new Copy();
				_determine_copy(input_ptr, ref copy);

				if ((copy.length == 0) || (copy.length == 2 && copy.offset >= 256))
					write_literal = true;
				else if (eof && input_ptr + copy.length > input_end) {
					copy.length = input_end - input_ptr;
					if (input_end - input_ptr > 2 || (input_end - input_ptr == 2 && copy.offset < 256))
						write_copy = true;
					else
						write_literal = true;
				} else if (copy.length >= 8 || input_ptr + 1 >= input_end)
					write_copy = true;
				else {
					// check if next copy would be better
					Copy next_copy = new Copy();
					_determine_copy(input_ptr + 1, ref next_copy);
					if (copy.length >= next_copy.length)
						write_copy = true;
					else if (copy.length + 1 == next_copy.length && copy.offset <= 128)
						write_copy = true;
					else
						write_literal = true;
				}

				// write copy or literal
				if (write_copy) {
					_write_bits(c_codeword_bits[copy.length + 254], c_codeword_values[copy.length + 254]);
					if (copy.length == 2) {
						_write_bits(COPY_OFFSET_BITS[copy.offset >> 2], COPY_OFFSET_CODE[copy.offset >> 2]);
						_write_bits(2, copy.offset & 3);
					} else {
						_write_bits(COPY_OFFSET_BITS[copy.offset >> _window_size], COPY_OFFSET_CODE[copy.offset >> _window_size]);
						_write_bits(_window_size, copy.offset & c_copy_offset_extra_mask);
					}
					input_ptr += copy.length;
				} else if (write_literal) {
					_write_bits(c_codeword_bits[_input_buffer[input_ptr]], c_codeword_values[_input_buffer[input_ptr]]);
					input_ptr++;
				}
				__r_rounds++;
			}

			if (!eof) {
				input_ptr -= 4096;
				Buffer.BlockCopy(_input_buffer, 4096, _input_buffer, 0, _dictionary_size + 516);
			}
			__rounds++;
		}

		// write EOF
		_write_bits(c_codeword_bits[(int)Codes.PK_EOF], c_codeword_values[(int)Codes.PK_EOF]);
		if (c_current_output_bits_used != 0)
			_output_buffer_ptr++;

		_output_func(0, _output_buffer_ptr);
		
		System.Array.Resize(ref r_output_data, tokenizer.out_ptr);
		return r_output_data;
	}
}
