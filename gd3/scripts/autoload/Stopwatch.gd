extends Node
# ANTIMONY 'Stopwatch' by Banderi --- v1.1

enum {
	Milliseconds = 0,
	Microsecond = 1
}

func start():
	return OS.get_ticks_usec()
func stop(from, time: int, message: String, precision: int = Milliseconds):
	match precision:
		Milliseconds:
			Log.generic(from, message + " (%d milliseconds)" % [OS.get_ticks_msec() - float(time) * 0.001])
		Microsecond:
			Log.generic(from, message + " (%d microseconds)" % [OS.get_ticks_usec() - time])
func query(time: int, precision: int = Milliseconds):
	match precision:
		Milliseconds:
			return OS.get_ticks_msec() - float(time) * 0.001
		Microsecond:
			return OS.get_ticks_usec() - time
