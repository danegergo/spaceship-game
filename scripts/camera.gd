extends Camera3D

@onready var player: Player = %CharacterBody3D

func _physics_process(delta: float):
	var input_dir = Input.get_vector("move_right", "move_left", "move_down", "move_up")
	var xy_lerp
	var z_lerp = position.lerp(player.position - Vector3(0, -7, 20), 0.5)
	if (input_dir.x != 0 or input_dir.y != 0):
		xy_lerp = z_lerp
	else:
		xy_lerp = position.lerp(player.position - Vector3(0, -7, 20), 0.025)
	position = Vector3(xy_lerp.x, xy_lerp.y, z_lerp.z)
	
	rotation.z = -player.rotation.z
