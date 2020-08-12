extends KinematicBody

export var input_strength = Vector2.ZERO

# clamps
var max_speed: float = 300.0
var min_speed: float = 10.0
var max_reverse: float = -2.0

# stats
export var accel: float = 800.0
export var edging: float = 3.0

# physics
var gravity = Vector3(0, -9.81, 0)
var velocity = Vector3.ZERO
var dampening = Vector3(0.985,1,0.985) # todo: make steering behaviour
var floor_angle: Vector3 # ensures we get all the normal applied to our angle
var spinflip_angle: Vector3 # added to floor_angle to get our total angle
var max_angle = 0.8
export var current_floor_normal = Vector3.UP # exported for debug arrow

func _physics_process(delta):
	input_strength = input_strength.normalized()
	var turn_amount = deg2rad(edging * input_strength.x * -1)
	var magnitude = accel * input_strength.y * delta
	magnitude = clamp(magnitude, max_reverse, max_speed)
	var rotated_magnitude : Vector3
	
	if is_on_floor():
		# my way of snapping to the ground for right now
		velocity.y = -.2
		current_floor_normal = get_floor_normal()
		#rotation.x = current_floor_normal.x * -1
		#rotation.z = current_floor_normal.z * -1
	
	else:
		# rotate ourselves towards a standing position in the air
		rotation.x = rotation.move_toward(Vector3.UP, delta).x
		rotation.z = rotation.move_toward(Vector3.UP, delta).z
		# turn as if we were already at that standing position
		#current_floor_normal = Vector3.UP
		turn_amount * 0.25
	
	if input_strength.x != 0:
		rotate_object_local(Vector3.UP, turn_amount)
		rotation.x = rotation.move_toward(current_floor_normal, delta * 5).x
		rotation.z = rotation.move_toward(current_floor_normal, delta * 5).z
		#rotate(current_floor_normal, turn_amount)
	
	# next: take my intended speed and rotate it to where I'm facing
	rotated_magnitude = Vector3.ZERO
	rotated_magnitude.x = magnitude
	# use my floor normal as the axis to rotate,
	# and use the amount of degrees I've rotated to determine the angle
	rotated_magnitude.rotated(current_floor_normal, rotation.y)
	rotated_magnitude.y = 0 # but don't fly upwards if we face upwards
	velocity += (rotated_magnitude + gravity) * delta
	move_and_slide(velocity, current_floor_normal, false, 4, max_angle, false)
	velocity *= dampening # lose speed overtime
