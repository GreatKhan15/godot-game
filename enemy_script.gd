extends RigidBody3D

@onready var hpBar = $hpBar

var health = 100
var maxHealth = 100

# Movement variables
var move_interval = 1 # seconds between direction changes
var move_timer = 0.0
var move_speed = 3.0
var direction

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
	if health <= 0:
		queue_free()
