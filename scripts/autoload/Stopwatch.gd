extends Node
# ANTIMONY 'Stopwatch' by Banderi --- v1.2

enum {
	Milliseconds = 0,
	Microsecond = 1
}

func start():
	return OS.get_ticks_usec()
func stop(from, start_microseconds: int, message: String, precision: int = Milliseconds):
	var diff = Time.get_ticks_usec() - start_microseconds
	match precision:
		Milliseconds:
			Log.generic(from, message + " (%d milliseconds)" % [float(diff) * 0.001])
		Microsecond:
			Log.generic(from, message + " (%d microseconds)" % [diff])
func query(start_microseconds: int, precision: int = Milliseconds):
	var diff = Time.get_ticks_usec() - start_microseconds
	match precision:
		Milliseconds:
			return float(diff) * 0.001
		Microsecond:
			return diff
