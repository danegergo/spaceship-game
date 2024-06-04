extends Camera3D

var player: Player
var camera_position: Vector3 = Vector3.ZERO

func _ready():
	player = get_parent()

func _physics_process(delta: float):
	var input_dir = Input.get_vector("move_right", "move_left", "move_down", "move_up")
	var xy_lerp
	var z_lerp = camera_position.lerp(player.global_position - Vector3(0, 0, 20), 0.55)
	
	if (input_dir.x != 0 or input_dir.y != 0):
		xy_lerp = camera_position.lerp(player.global_position - Vector3(0, -9, 0), 0.75)
	else:
		xy_lerp = camera_position.lerp(player.global_position - Vector3(0, -9, 0), 0.025)
		
	camera_position = Vector3(xy_lerp.x, xy_lerp.y, z_lerp.z)
	global_position = camera_position
	
	global_rotation.z = -player.global_rotation.z

