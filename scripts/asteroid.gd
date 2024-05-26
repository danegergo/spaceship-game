extends RigidBody3D

const DESTROY_DISTANCE = 250

@onready var collider = $CollisionShape3D
@onready var meshInstance = $MeshInstance3D
var player: Player

func _ready():
	player = get_parent().get_node("Player")

func _process(delta):
	if player and (position.z <= player.position.z - DESTROY_DISTANCE):
		queue_free()

func set_mesh_and_collider(new_mesh: ArrayMesh):
	meshInstance.mesh = new_mesh
	var mesh_length = meshInstance.mesh.get_aabb().get_longest_axis_size()
	var colliderSpehere = SphereShape3D.new()
	colliderSpehere.radius = mesh_length / 2
	collider.shape = colliderSpehere
	
