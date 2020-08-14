extends Path

func _ready():
	var points = curve.get_point_count()
	for i in points:
		print(curve.get_point_tilt(i))
