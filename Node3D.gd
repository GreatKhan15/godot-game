extends Node3D

@export var grid_size: int = 10
@export var spacing: float = 15.0
@export var max_size: Vector3 = Vector3(5, 30, 3)
@export var position_jitter: float = 0.5
@export var park_chance: float = 0.2


@export var waves: int = 30
@export var enemiesinwave: int = 30
@export var wavetimer: int = 60
@export var baseHealth: float = 100
@export var healthMultiply: float = 1.5
@export var ENEMYMASS = 8

var spawned: int = 0
var currentHealth


func _ready():
	randomize()
	generate_town()
	currentHealth = baseHealth

# Generate more complex town with different building types
func generate_town():
	for x in range(grid_size):
		for z in range(grid_size):
			if randf() < park_chance:
				continue

			# Create StaticBody3D to hold mesh and collision
			var building = StaticBody3D.new()
			add_child(building)

			# Create mesh instance
			var mesh = MeshInstance3D.new()
			var building_type = randf_range(0, 1)  # Randomly pick a building type
			var box = BoxMesh.new()
			var cylinder = CylinderMesh.new()
			
			if building_type < 0.33:
				# Box-shaped building (original design)
				box.size.x = randf_range(1.5, max_size.x)
				box.size.y = randf_range(2.0, max_size.y)
				box.size.z = randf_range(1.5, max_size.z)
				mesh.mesh = box
			else:
				# Cylinder-shaped building
				cylinder.bottom_radius = randf_range(1.5, max_size.x)
				cylinder.top_radius = cylinder.bottom_radius
				cylinder.height = randf_range(2.0, max_size.y)
				mesh.mesh = cylinder

			# Apply material to the mesh
			var material = StandardMaterial3D.new()
			material.albedo_color = Color(0.7, 0.7, 0.7) # Default gray color if no texture
			material.metallic = 1
			material.metallic_specular = 0.9
			mesh.material_override = material
			building.add_child(mesh)

			# Create collision shape (matching the selected mesh type)
			var collision = CollisionShape3D.new()
			if building_type < 0.33:
				var box_shape = BoxShape3D.new()
				box_shape.size = box.size
				collision.shape = box_shape
			else:
				var cylinder_shape = CylinderShape3D.new()
				cylinder_shape.radius = cylinder.bottom_radius
				cylinder_shape.height = cylinder.height
				collision.shape = cylinder_shape
			building.add_child(collision)


			# Random slight offset
			var offset_x = randf_range(-position_jitter, position_jitter)
			var offset_z = randf_range(-position_jitter, position_jitter)

			# Set position of the building
			var height = box.size.y
			building.transform.origin = Vector3(
				(x * spacing) + offset_x,
				height / 2.0,
				(z * spacing) + offset_z
			)


func _physics_process(_delta):
	if( spawned < enemiesinwave ):
		var enemy = RigidBody3D.new()
		enemy.set_meta("type","enemy")
		var enemyMeshinst = MeshInstance3D.new()
		
		var enemyMaterial = StandardMaterial3D.new()
		enemyMaterial.albedo_color = Color.RED
		
		var enemyMesh = BoxMesh.new()
		enemyMesh.material = enemyMaterial
		enemyMesh.size = Vector3(3,3,3)
		enemyMeshinst.mesh = enemyMesh
		
		var enemyCol = CollisionShape3D.new()
		var box_shape = BoxShape3D.new()
		box_shape.size = enemyMesh.size
		enemyCol.shape = box_shape
		
		enemy.transform.origin = Vector3(randf()*100, 10, randf()*100 )
		enemy.add_child(enemyCol)
		enemy.add_child(enemyMeshinst)
		enemy.mass = ENEMYMASS
		
		var hpBar = Sprite3D.new()
		hpBar.name = "hpBar"
		var hpText = GradientTexture2D.new()
		var grad = Gradient.new()
		grad.set_color(0,Color(0.8,0.2,0.2))
		grad.set_color(1,Color.RED)
		hpText.gradient = grad
		hpText.width = 300
		hpText.height = 30
		hpBar.set_meta("health",currentHealth)
		hpBar.set_meta("maxhealth",currentHealth)
		
		hpBar.texture = hpText
		hpBar.billboard = true
		enemy.add_child(hpBar)
		enemy.set_script(load("res://enemy_script.gd"))
		add_child(enemy)
		spawned = spawned + 1
	
