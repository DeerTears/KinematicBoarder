extends Node

var start_time = OS.get_ticks_msec()

var number_of_racers: int = 1

func reset_time():
	start_time = OS.get_ticks_msec()
func get_time() -> int:
	return (OS.get_ticks_msec() - start_time)

func convert_msec_to_timestamp(msec:int) -> String:
	var minutes: float = floor(float(msec) / 60000)
# warning-ignore:narrowing_conversion
	var remainder: int = msec - (minutes * 60000)
# warning-ignore:integer_division
	var seconds: int = remainder / 1000
	var milli: int = remainder - (seconds * 1000)
	return "%s:%s.%s" % [minutes, seconds, milli]
