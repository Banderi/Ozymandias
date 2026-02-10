extends File
class_name FileEx

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
func get_null_terminated_string() -> String:
	var csv = get_csv_line("\u0000")
	return csv[0]

func end_reached():
	return get_position() >= get_len()

var cursor = 0
func push_cursor_base(n):
	cursor += n
	seek(cursor)
