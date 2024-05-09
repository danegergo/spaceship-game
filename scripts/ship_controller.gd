class_name Player
extends CharacterBody3D

const XY_SPEED = 1000

@export_range(0.0, 3.0) var forward_speed_increment := 0.5
@export var max_speed := 600

@onready var third_person_camera: ThirdPersonCamera = $ThirdPersonCamera
@onready var first_person_camera: Camera3D = $FirstPersonCamera

var forward_speed = 100.0

func _process(delta):
	if Input.is_action_just_pressed("switch_camera"):
		first_person_camera.current = !first_person_camera.current
		third_person_camera.current = !third_person_camera.current

func _physics_process(delta):
	var input_dir = Input.get_vector("move_right", "move_left", "move_down", "move_up")
	var direction = (transform.basis * Vector3(input_dir.x, input_dir.y, 1)).normalized()
	
	if direction:
		velocity.x = direction.x * XY_SPEED
		velocity.y = direction.y * XY_SPEED
		velocity.z = direction.z * forward_speed
	else:
		velocity.x = move_toward(velocity.x, 0, XY_SPEED)
		velocity.y = move_toward(velocity.y, 0, XY_SPEED)
		velocity.z = move_toward(velocity.z, 0, forward_speed)

	if forward_speed < max_speed:
		forward_speed += forward_speed_increment
	
	move_and_slide()
