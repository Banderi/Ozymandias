extends File
class_name FileEx
# ANTIMONY 'XHRHandler' by Banderi --- v1.1

func get_u8():
	return get_8()
func get_u16():
	return get_16()
func get_u32():
	return get_32()
func get_i8():
	return (get_8() + 128) % 256 - 128
func get_i16():
	return (get_16() + 32768) % 65536 - 32768
func get_i32():
	return (get_32() + 2147483648) % 4294967296 - 2147483648

# cannot rely on get_csv_line() because quotation marks mess it up.
func get_until(delim: int) -> PoolByteArray:
	var buffer = PoolByteArray()
	while !eof_reached():
		var b = get_buffer(1)[0]
		if b == 0x00:
			return buffer
		buffer.append(b)
	return buffer
func get_null_terminated_utf8() -> String:
	return get_until(0x00).get_string_from_utf8()
func get_null_terminated_ascii() -> String:
	return get_until(0x00).get_string_from_ascii()

func end_reached(strict = false):
	if strict:
		return get_position() == get_len()
	return get_position() >= get_len()

# this is a detached cursor helper, useful for block reading
var cursor = 0
func push_cursor_base(n):
	cursor += n
	seek(cursor)
