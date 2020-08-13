extends KinematicBody

export var input_strength = Vector2.ZERO

# stats
export var accel: float = 800.0
export var edging: float = 2.0

# clamps
var max_speed: float = 300.0
var min_speed: float = 10.0
var max_reverse: float = -20.0

# physics
var gravity = Vector3(0, -9.81, 0)
var velocity = Vector3.ZERO
var dampening = 0.9825 # todo: make steering behaviour
export var current_floor_normal = Vector3.UP

func _physics_process(delta):
	input_strength = input_strength.normalized()
	
	var turn_amount = deg2rad(edging * input_strength.x * -1)
	
	var magnitude = accel * input_strength.y * delta
	magnitude = clamp(magnitude, max_reverse, max_speed)
	
	if is_on_floor():
		current_floor_normal = get_floor_normal()
		rotation.x = rotation.move_toward(current_floor_normal, delta * 5).x
		rotation.z = rotation.move_toward(current_floor_normal, delta * 5).z
		# i can't do rotation.y because this always resets existing turning information
		# ...unless the ball never rotates at all?
		# and i had the player mesh rotate based on the direction of our velocity?
		# so it'd be the velocity i'm adjusting rather than my rotation amount...
		
		velocity.y = -1 # temp way to snap to floor
	else:
		# rotate towards standing position mid-air
		#current_floor_normal = Vector3.UP
		rotation.x = rotation.move_toward(Vector3.UP, delta).x
		rotation.z = rotation.move_toward(Vector3.UP, delta).z
		turn_amount *= 0.5
	if input_strength.x != 0:
		rotate_object_local(Vector3.UP, turn_amount)
	
	# next: take my intended speed and rotate it to where I'm facing
	var rotated_magnitude = Vector3.ZERO
	rotated_magnitude.z = magnitude
	# use my floor normal as the axis to rotate,
	# and use the amount of degrees I've rotated to determine the angle
	rotated_magnitude = rotated_magnitude.rotated(current_floor_normal, rotation.y)
	rotated_magnitude.y = 0 # but don't fly upwards if we face upwards
	velocity += (rotated_magnitude + gravity) * delta
	velocity = velocity.rotated(Vector3.UP, turn_amount)
	move_and_slide(velocity, current_floor_normal, false, 4, 0.8, false)
	velocity.x *= dampening
	velocity.z *= dampening
	print(rotation.y)
