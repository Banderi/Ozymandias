extends Node
# ANTIMONY 'Stopwatch' by Banderi --- v1.0

func start():
	return OS.get_ticks_usec()
func stop(from, time : int, message : String, precision : int = 0):
	match precision:
		0:
			Log.generic(from, message + " (%d milliseconds)" % [OS.get_ticks_msec() - float(time) * 0.001])
		1:
			Log.generic(from, message + " (%d microseconds)" % [OS.get_ticks_msec() - time])
