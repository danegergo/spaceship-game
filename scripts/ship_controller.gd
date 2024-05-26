class_name Player
extends CharacterBody3D

const XY_SPEED = 1000
const CAMERA_TURN_SPEED = 0.03
const MAX_TURN_DEGREE = 25

@export_range(0.0, 3.0) var forward_speed_increment := 0.5
@export var max_speed := 600

@onready var third_person_camera: Camera3D = $ThirdPersonCamera
@onready var first_person_camera: Camera3D = $FirstPersonCamera

var forward_speed = 100.0
var input_dir

signal body_entered(body: Node)

func _process(delta):
	if Input.is_action_just_pressed("switch_camera"):
		print(first_person_camera.current)
		if first_person_camera.current:
			third_person_camera.make_current()
		else:
			first_person_camera.make_current()
			
	var collision: KinematicCollision3D = get_last_slide_collision()
	if (collision):
		body_entered.emit(collision.get_collider())
			

func _physics_process(delta):
	input_dir = Input.get_vector("move_right", "move_left", "move_down", "move_up")
	var direction = (transform.basis * Vector3(input_dir.x, input_dir.y, 0)).normalized()
	
	print(direction.y)
	if direction:
		velocity.x = direction.x * XY_SPEED
		velocity.y = direction.y * XY_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, XY_SPEED)
		velocity.y = move_toward(velocity.y, 0, XY_SPEED)
	velocity.z = forward_speed
		
	tilt_ship(input_dir)
	move_and_slide()
	
	if forward_speed < max_speed:
		forward_speed += forward_speed_increment
	
func tilt_ship(input_dir: Vector2):
	if input_dir.x < 0:
		rotation = rotation.lerp(Vector3(rotation.x, rotation.y, deg_to_rad(MAX_TURN_DEGREE)), CAMERA_TURN_SPEED)
	elif input_dir.x > 0:
		rotation = rotation.lerp(Vector3(rotation.x, rotation.y, deg_to_rad(-MAX_TURN_DEGREE)), CAMERA_TURN_SPEED)
	else:
		rotation = rotation.lerp(Vector3(rotation.x, rotation.y, deg_to_rad(0)), CAMERA_TURN_SPEED)
