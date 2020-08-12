extends Spatial

func _process(delta):
	$Ramp/Boarder.rotate_object_local(Vector3.UP, delta)
