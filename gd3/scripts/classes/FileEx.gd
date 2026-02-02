extends File
class_name FileEx

func MAX(bs):
	return (1 << bs)
func u_to_i(unsigned, bs):
	return (unsigned + MAX(bs-1)) % MAX(bs) - MAX(bs-1)
func buffer_padded(arr : PoolByteArray, size):
	var s = size - arr.size()
	if s > 0:
		var t = PoolByteArray()
		t.resize(s)
		t.fill(0)
		arr.append_array(t)
	return arr

func get_null_terminated_string() -> String:
	var csv = get_csv_line("\u0000")
	return csv[0]

func end_reached():
	return get_position() >= get_len()
