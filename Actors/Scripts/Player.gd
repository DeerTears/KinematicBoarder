extends Spatial

onready var Rider = $Rider
onready var CamJoint = $CamJoint
onready var CameraNode = $CamJoint/Camera

# camera settings
export var joypad_sens: float = 0.1
export var mouse_sens: float = 0.01
export var zoom_speed: float = 0.4
export var invert_x: bool = false
export var invert_y: bool = false

# other camera vars
var joycam_step: Vector3 = Vector3.ZERO
var zoom_extent = {"in": 5, "out": 15}
var y_inversion: int = -1 # some lazy enums
var x_inversion: int = -1 # some lazy enums

export var stage_of_race: String = "ready"

func _ready():
	init()

func init():
	CameraNode.set_translation(Vector3(10,0,0))
	CamJoint.rotation_degrees = Vector3(180, 0, 15)
	if invert_y: # I should learn how to use enums here instead
		y_inversion = -1
	else:
		y_inversion = 1
	if invert_x:
		x_inversion = 1
	else:
		x_inversion = -1
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Rider/Meshes/EditorArrow.visible = false
	$InfoBillboard/Rank.visible = false # because we're the player
	$InfoBillboard/Time.visible = false

func _input(event): # input only handles camera stuff
	# joypad camera
	if event.is_action("camera_right") or event.is_action("camera_left"):
		var _strength = (event.get_action_strength("camera_right") - event.get_action_strength("camera_left"))
		joycam_step.y = _strength * joypad_sens * x_inversion
	if event.is_action("camera_up") or event.is_action("camera_down"):
		var _strength = (event.get_action_strength("camera_up") - event.get_action_strength("camera_down"))
		joycam_step.z = _strength * joypad_sens * y_inversion
	
	# mouse camera
	if event is InputEventMouseMotion:
		CamJoint.rotation.y += event.relative.x * mouse_sens * x_inversion
		CamJoint.rotation.z += event.relative.y * mouse_sens * y_inversion

	# zooming
	if event.is_action_pressed("zoom_out"):
		CameraNode.translation.x += zoom_speed
		CameraNode.translation.x = clamp(CameraNode.translation.x, zoom_extent["in"], zoom_extent["out"])
	if event.is_action_pressed("zoom_in"):
		CameraNode.translation.x -= zoom_speed
		CameraNode.translation.x = clamp(CameraNode.translation.x, zoom_extent["in"], zoom_extent["out"])
	
	if event.is_action("reset"):
# warning-ignore:return_value_discarded
		get_tree().reload_current_scene()
		RaceSession.reset_time()
	if event.is_action("quit"):
		var current_time = RaceSession.get_time()
		print(RaceSession.convert_msec_to_timestamp(current_time))
		get_tree().quit()


func _process(_delta):
	# move and clamp camera
	CamJoint.rotation += joycam_step
	CamJoint.rotation.z = clamp(CamJoint.rotation.z, deg2rad(-85), deg2rad(70))
	
	# debugging floor normals
	$NormalJoint.rotation = Rider.current_floor_normal

	# movement!
	if Input.is_action_pressed("fwd"):
		Rider.input_strength.y = Input.get_action_strength("fwd")
	elif Input.is_action_pressed("back"):
		Rider.input_strength.y = Input.get_action_strength("back") * -1
	if Input.is_action_pressed("right"):
		Rider.input_strength.x = Input.get_action_strength("right")
	elif Input.is_action_pressed("left"):
		Rider.input_strength.x = Input.get_action_strength("left") * -1
	Rider.input_strength.normalized()

	# jumping
	if Input.is_action_just_pressed("jump"):
		Rider.jump_strength = 1
		$UI/Margin/HBox/VBoxR/JumpInt.text = Rider.jump_strength as String
		$UI/Margin/HBox/VBoxR/JumpInt/Progress.value = Rider.jump_strength
		return
	if Input.is_action_pressed("jump"):
		Rider.jump_strength = 0
		$UI/Margin/HBox/VBoxR/JumpInt.text = Rider.jump_strength as String
		$UI/Margin/HBox/VBoxR/JumpInt/Progress.value = Rider.jump_strength
		return
	if Input.is_action_just_released("jump"):
		Rider.jump_strength = -1
		$UI/Margin/HBox/VBoxR/JumpInt.text = Rider.jump_strength as String
		$UI/Margin/HBox/VBoxR/JumpInt/Progress.value = Rider.jump_strength
		return


func _on_FinishDetector_area_entered(area):
	if stage_of_race != "finished" and area.name == "Finish":
		stage_of_race = "finished"
		var finish_timestamp = RaceSession.convert_msec_to_timestamp(RaceSession.get_time())
		print_debug(finish_timestamp)
		$InfoBillboard/Time.visible = true
		# todo: make the rank lock in at this point
		$InfoBillboard/Rank.visible = true
