extends RigidBody3D

@onready var hpBar = $hpBar

var health = 100
var maxHealth = 100

# Movement variables
var move_interval = 1 # seconds between direction changes
var move_timer = 0.0
var move_speed = 3.0
var direction
var experience = 40

@onready var levelController = get_node("/root/Main scene/LevelController")
@onready var player = get_node("/root/Main scene/CharacterBody3D")

func _ready():
	health = hpBar.get_meta("health")
	maxHealth = hpBar.get_meta("maxhealth")
	move_timer = move_interval
	direction = Vector3(randf() * 2.0 - 1.0, 0, randf() * 2.0 - 1.0).normalized()

func _physics_process(delta):
	# Update health bar position and size
	hpBar.global_position = global_position + Vector3.UP * 4
	hpBar.texture.width = health / maxHealth * 300

	move_timer -= delta
	if move_timer <= 0.0:
		move_timer = move_interval
		direction = Vector3(randf() * 2.0 - 1.0, 0, randf() * 2.0 - 1.0).normalized()
	linear_velocity.x = direction.x * move_speed
	linear_velocity.z = direction.z * move_speed

func take_damage(amount):
	health -= amount
	
	var damage_scene = preload("res://DamageNumber.tscn")
	var damage_node = damage_scene.instantiate()
	
	damage_node.get_node("Label3D").text = str(amount)
	var random_offset = Vector3(
	randf_range(-3, 3),
	randf_range(1.5, 2.5),
	randf_range(-3, 3)
	)
	damage_node.global_transform.origin = global_transform.origin + random_offset
	
	# Add it to the scene tree (ideally under the same parent or a dedicated UI/3D node)
	get_tree().current_scene.add_child(damage_node)
	
	if health <= 0:
		player.currentEXP += experience
		levelController.alive -= 1
		queue_free()
