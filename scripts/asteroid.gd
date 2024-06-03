extends RigidBody3D

const DESTROY_DISTANCE = 250
const MIN_FORCE = 350
const MAX_FORCE = 700
const TORQUE = 650
const MIN_ASTEROID_SIZE = 200
const BIG_ASTEROID_CHANCE = 0.025

@onready var collider = $CollisionShape3D
@onready var meshInstance = $MeshInstance3D
var player: Player

func _ready():
	player = get_parent().get_node("Player")
	var force_x = randi_range(MIN_FORCE, MAX_FORCE)
	var force_y = randi_range(MIN_FORCE, MAX_FORCE)
	var force_z = randi_range(-MIN_FORCE, -MAX_FORCE)
	apply_impulse(Vector3(force_x, force_y, force_z))

func _process(delta):
	apply_torque(Vector3(TORQUE, 0, 0))
	if player and (position.z <= player.position.z - DESTROY_DISTANCE):
		queue_free()

func set_mesh_and_collider(new_mesh: ArrayMesh):
	meshInstance.mesh = new_mesh
	var mesh_length = meshInstance.mesh.get_aabb().get_longest_axis_size()
	if mesh_length < MIN_ASTEROID_SIZE:
		var mesh_length_multiplier = MIN_ASTEROID_SIZE / mesh_length
		meshInstance.scale = Vector3(mesh_length_multiplier, mesh_length_multiplier, mesh_length_multiplier)
		mesh_length *= mesh_length_multiplier
	if randf() < BIG_ASTEROID_CHANCE:
		var scale_multiplier = randf_range(3, 5)
		meshInstance.scale *= Vector3(scale_multiplier, scale_multiplier, scale_multiplier)
		
	var colliderSpehere = SphereShape3D.new()
	colliderSpehere.radius = mesh_length / 2
	collider.shape = colliderSpehere
	
