extends KinematicBody

export var input_strength = Vector2.ZERO
export var jump_strength = -1
var jump_was_pressed = false

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
var launched_velocity = Vector3.ZERO
var dampening = 0.9825 # todo: make steering behaviour
var was_on_floor = false
export var current_floor_normal = Vector3.UP

# turning
onready var Meshes = $Meshes
onready var Collision = $CollisionShape

func _physics_process(delta):
	
	var turn_amount = deg2rad(edging * input_strength.x * -1)
	
	var magnitude = accel * input_strength.y * delta
	magnitude = clamp(magnitude, max_reverse, max_speed)
	
	if is_on_floor():
		velocity.y = -5
		current_floor_normal = get_floor_normal()
		rotation = rotation.move_toward(current_floor_normal, delta * 4)
		was_on_floor = true
	elif was_on_floor:
		velocity.y = -2
		launched_velocity = velocity * 1.25
		was_on_floor = false
	else:
		rotation = rotation.move_toward(Vector3.UP, delta * 0.25)
		turn_amount *= 0.8
	
	if input_strength.x != 0:
		Meshes.set_rotation(Vector3(0, Meshes.rotation.y + (turn_amount / 2), 0))
		Collision.set_rotation(Vector3(0, Collision.rotation.y + (turn_amount / 2), 0))
#	else:
#		Meshes.rotate(Vector3.UP, 0)
#		Collision.rotate(Vector3.UP, 0)
	
	var rotated_magnitude = Vector3.ZERO
	
	if is_on_floor():
		rotated_magnitude.z = magnitude
		rotated_magnitude = rotated_magnitude.rotated(current_floor_normal, Meshes.rotation.y + 0.98)
		rotated_magnitude.y = 0 # but don't fly upwards if we face upwards
	else:
		velocity += launched_velocity * delta
	print($CollisionShape.rotation)
	velocity += (rotated_magnitude + gravity) * delta
	velocity = velocity.rotated(Vector3.UP, turn_amount / 2)
	move_and_slide(velocity, current_floor_normal, false, 4, 1.1, false)
	velocity.x *= dampening
	velocity.z *= dampening
