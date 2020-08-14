extends KinematicBody

export var input_strength = Vector2.ZERO # input x = l/r, input y = fwd/back
export var jump_strength = -1 # 3 parts: just pressed, pressed and released
# todo: add frame timer to determine how big a jump should be
var jump_was_pressed = false

# stats
export var accel: float = 800.0
export var edging: float = 2.0

# clamps
var max_speed: float = 300.0
var min_speed: float = 10.0
var max_reverse: float = -20.0

# physics
export var current_floor_normal = Vector3.UP
var gravity = Vector3(0, -9.81, 0)
var velocity = Vector3.ZERO
var launched_velocity = Vector3.ZERO # pushes us when we're not on the ground
var dampening = 0.9825 # right now pushing forward makes you move, and this slows you down otherwise
var currently_on_floor = false
var was_on_floor = false

# visual turning & calculation of rotated_magnitude
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
	
	Meshes.set_rotation(Vector3(0, Meshes.rotation.y + (turn_amount / 2), 0))
	Collision.set_rotation(Vector3(0, Collision.rotation.y + (turn_amount / 2), 0))
	
	var rotated_magnitude = Vector3.ZERO
	var jump_velocity = Vector3.ZERO
	
	if is_on_floor(): # this check isn't reliable, I don't have a snapping solution for sharp ramps and a ball collider :(
		currently_on_floor = true
		rotated_magnitude.z = magnitude
		rotated_magnitude = rotated_magnitude.rotated(current_floor_normal, Meshes.rotation.y + 0.98)
		rotated_magnitude.y = 0 # but don't fly upwards if we face upwards
		if jump_strength == 0:
			jump_was_pressed = true
		if jump_strength == -1 and jump_was_pressed:
			jump_was_pressed = false
			velocity += current_floor_normal * 30
			currently_on_floor = false
	else:
		velocity += launched_velocity * delta
		jump_was_pressed = false # this will cause bugs i swear on it
	velocity += (rotated_magnitude + jump_velocity + gravity) * delta
	velocity = velocity.rotated(Vector3.UP, turn_amount / 2)
# warning-ignore:return_value_discarded
	move_and_slide(velocity, current_floor_normal, false, 4, 1.1, false)
	velocity.x *= dampening # todo: eventually replace this system
	velocity.z *= dampening # I'd hope to advance normally when pressing nothing and to brake harder than this when pressing back
	
