extends Node

const ASTEROIDS_DIR = "res://assets/asteroids"
const ASTEROID_SCENE = preload("res://scenes/asteroid.tscn")
const DISTANCE_COUNTDOWN = 3
const SPEED_LINES_MAX_DENSITY = 0.12

@export_range(1, 30) var max_asteroid_per_frame := 15
@export_range(100, 20000) var asteroid_spawn_dist_z := 10000
@export_range(200, 20000) var max_asteroid_spawn_dist_xy := 8000

@onready var player: CharacterBody3D = %Player
@onready var scene: Node3D = $".."
@onready var game_over_screen: Control = %GameOverScreen
@onready var score_label: Label = %Score
@onready var speed_label: Label = %Speed
@onready var speed_lines: Panel = %SpeedLines

var asteroid_meshes: Array[ArrayMesh] = []
var threads: Array[Thread] = []
var mesh_files: PackedStringArray
var time_elapsed = 0
var time_of_last_asteroid = 0
var spawning_active = false
var dist_timer: Timer

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
		
	dist_timer = Timer.new()
	dist_timer.wait_time = DISTANCE_COUNTDOWN
	dist_timer.one_shot = true
	add_child(dist_timer)
	dist_timer.start()
		
func _process(delta):
	for i in ceil((player.forward_speed / player.max_speed) * max_asteroid_per_frame):
		spawn_new_asteroid()
		
	var speed_line_multiplier = player.forward_speed / player.max_speed if player.forward_speed / player.max_speed >= 0.5 else player.forward_speed / player.max_speed / 2
	speed_lines.material.set_shader_parameter("line_density", SPEED_LINES_MAX_DENSITY * speed_line_multiplier);
	score_label.text = "Distance: " + String.num(player.position.z / 100, 0)
	speed_label.text = "Speed: " + String.num(player.velocity.z / 100, 2)
	
func load_meshes_thread(start_index, end_index):
	for i in range(start_index, end_index):
		if mesh_files[i].ends_with(".obj"):
			var asteroid_mesh: ArrayMesh = load(ASTEROIDS_DIR + "/" + mesh_files[i])
			asteroid_meshes.append(asteroid_mesh)
		
func spawn_new_asteroid():
	var new_asteroid = ASTEROID_SCENE.instantiate()
	var asteroid_distance_pos_x = randi_range(player.position.x - max_asteroid_spawn_dist_xy, player.position.x + max_asteroid_spawn_dist_xy)
	var asteroid_distance_pos_y = randi_range(player.position.y - max_asteroid_spawn_dist_xy, player.position.y + max_asteroid_spawn_dist_xy)
	new_asteroid.position = Vector3(
		asteroid_distance_pos_x,
	 	asteroid_distance_pos_y, 
		player.position.z + asteroid_spawn_dist_z - ((dist_timer.time_left / DISTANCE_COUNTDOWN) * (asteroid_spawn_dist_z - 2000) - 2000 if dist_timer.time_left else 0)
	)
	
	scene.add_child(new_asteroid)
	new_asteroid.set_mesh_and_collider(asteroid_meshes.pick_random())

func _on_player_collision(body: Node):
	player.stopped = true
	if player.first_person_camera.current:
		player.third_person_camera.make_current()
		
	player.destroy()
	speed_lines.visible = false
	await get_tree().create_timer(4.0).timeout
	
	get_tree().paused = true;
	game_over_screen.visible = true;

func _on_game_over_pressed():
	get_tree().paused = false;
	get_tree().reload_current_scene()
