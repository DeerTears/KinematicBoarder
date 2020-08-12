extends KinematicBody

export var input_strength = Vector2.ZERO

# clamps
var max_speed: float = 300.0
var min_speed: float = 10.0
var max_reverse: float = -20.0

# stats
export var accel: float = 800.0
export var edging: float = 3.0

# physics
var gravity = Vector3(0, -9.81, 0)
var velocity = Vector3.ZERO
var dampening = 0.9825 # todo: make steering behaviour
export var current_floor_normal = Vector3.UP # ensures we get all the normal applied to our angle
var lerp_to_floor = Vector3.UP
var spin_angle: float
var max_angle = 0.8

func _physics_process(delta):
	input_strength = input_strength.normalized()
	
	var turn_amount = deg2rad(edging * input_strength.x * -1)
	var magnitude = accel * input_strength.y * delta
	magnitude = clamp(magnitude, max_reverse, max_speed)
	
	if is_on_floor():
		# my way of snapping to the ground for right now
		velocity.y = -.25
		var old_y_normal = current_floor_normal.y
		current_floor_normal = get_floor_normal()
		current_floor_normal.y = old_y_normal
		current_floor_normal = current_floor_normal.normalized()
		rotation = rotation.move_toward(current_floor_normal, delta * 5)
		rotation.y = old_y_normal
	
	else:
		# rotate ourselves towards a standing position in the air
		#rotation.x = rotation.move_toward(Vector3.UP, delta).x
		#rotation.z = rotation.move_toward(Vector3.UP, delta).z
		current_floor_normal = Vector3.UP
		turn_amount *= 0.5
	if input_strength.x != 0:
		lerp_to_floor = lerp_to_floor.move_toward(current_floor_normal, delta * 5)
	
	# combine our rotations
	#rotation = lerp_to_floor
	#spin_angle += turn_amount
	rotate_object_local(Vector3.UP, turn_amount)
	
	# next: take my intended speed and rotate it to where I'm facing
	var rotated_magnitude = Vector3.ZERO
	rotated_magnitude.x = magnitude
	# use my floor normal as the axis to rotate,
	# and use the amount of degrees I've rotated to determine the angle
	rotated_magnitude = rotated_magnitude.rotated(current_floor_normal, rotation.y)
	rotated_magnitude.y = 0 # but don't fly upwards if we face upwards
	velocity += (rotated_magnitude + gravity) * delta
	move_and_slide(velocity, current_floor_normal, false, 4, max_angle, false)
	velocity.x *= dampening
	velocity.z *= dampening # lose speed overtime
