extends Node

const ASTEROIDS_DIR = "res://assets/asteroids"
const ASTEROID_SCENE = preload("res://scenes/asteroid.tscn")

@export_range(1, 10) var asteroid_per_frame := 2
@export_range(100, 20000) var asteroid_spawn_dist_z := 1000
@export_range(200, 20000) var max_asteroid_spawn_dist_xy := 500
@export var min_asteroid_size := 1.5

@onready var player: CharacterBody3D = %Player
@onready var scene: Node3D = $".."
@onready var game_over_screen: Control = %GameOverScreen

var asteroid_meshes: Array[ArrayMesh] = []
var threads: Array[Thread] = []
var mesh_files: PackedStringArray
var time_elapsed = 0
var time_of_last_asteroid = 0

func _ready():
	var thread_count = OS.get_processor_count()
	var dir = DirAccess.open(ASTEROIDS_DIR)
	if dir:
		mesh_files = dir.get_files()
		for i in range(thread_count):
			var new_thread = Thread.new()
			var start_index = i * (mesh_files.size() / thread_count)
			var end_index = (i + 1) * (mesh_files.size() / thread_count) if i < thread_count - 1 else mesh_files.size()
			new_thread.start(load_meshes_thread.bind(start_index, end_index))
			threads.append(new_thread)

		for thr in threads:
			thr.wait_to_finish()
		print("Loaded ", asteroid_meshes.size(), " meshes")
	else:
		print("An error occurred when trying to load asteroid meshes.")
		
func _process(delta):
	for i in asteroid_per_frame:
		spawn_new_asteroid()
		
func load_meshes_thread(start_index, end_index):
	for i in range(start_index, end_index):
		if mesh_files[i].ends_with(".obj"):
			var asteroid_mesh = load(ASTEROIDS_DIR + "/" + mesh_files[i])
			if asteroid_mesh and asteroid_mesh.get_aabb().get_longest_axis_size() > min_asteroid_size: 
				asteroid_meshes.append(asteroid_mesh)
		
func spawn_new_asteroid():
	var new_asteroid = ASTEROID_SCENE.instantiate()
	var asteroid_distance_pos_x = randi_range(player.position.x - max_asteroid_spawn_dist_xy, player.position.x + max_asteroid_spawn_dist_xy)
	var asteroid_distance_pos_y = randi_range(player.position.y - max_asteroid_spawn_dist_xy, player.position.y + max_asteroid_spawn_dist_xy)
	new_asteroid.position = Vector3(asteroid_distance_pos_x, asteroid_distance_pos_y, player.position.z + asteroid_spawn_dist_z)
	
	scene.add_child(new_asteroid)
	new_asteroid.set_mesh_and_collider(asteroid_meshes.pick_random())

func _on_player_collision(body: Node):
	get_tree().paused = true;
	game_over_screen.visible = true;

func _on_game_over_pressed():
	get_tree().paused = false;
	get_tree().reload_current_scene()
