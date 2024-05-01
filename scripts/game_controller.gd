extends Node3D

const ASTEROIDS_DIR = "res://assets/asteroids"

@export_range(1, 10) var asteroid_per_frame := 2

@export_range(100, 10000) var asteroid_spawn_dist_z := 1000

@export_range(200, 5000) var max_asteroid_spawn_dist_xy := 500
	
@onready var player: CharacterBody3D = $Player

var ASTEROID = preload("res://scenes/asteroid.tscn")
var asteroid_meshes: Array[ArrayMesh] = []
var time_elapsed = 0
var time_of_last_asteroid = 0

func _ready():
	var dir = DirAccess.open(ASTEROIDS_DIR)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var asteroid_mesh = load(ASTEROIDS_DIR + "/" + file_name)
			if asteroid_mesh: 
				asteroid_meshes.push_back(asteroid_mesh)
			file_name = dir.get_next()
		print("Loaded ", asteroid_meshes.size(), " meshes")
	else:
		print("An error occurred when trying to load asteroid meshes.")
		
func _process(delta):
	for i in asteroid_per_frame:
		spawn_new_asteroid()
		
func spawn_new_asteroid():
	var new_asteroid = ASTEROID.instantiate()
	var asteroid_distance_pos_x = randi_range(player.position.x - max_asteroid_spawn_dist_xy, player.position.x + max_asteroid_spawn_dist_xy)
	var asteroid_distance_pos_y = randi_range(player.position.y - max_asteroid_spawn_dist_xy, player.position.y + max_asteroid_spawn_dist_xy)
	new_asteroid.position = Vector3(asteroid_distance_pos_x, asteroid_distance_pos_y, player.position.z + asteroid_spawn_dist_z)
	
	add_child(new_asteroid)
	new_asteroid.set_mesh_and_collider(asteroid_meshes.pick_random())
	
	
