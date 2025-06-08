extends Node3D

@onready var explosion_light: OmniLight3D = $OmniLight3D
@onready var area: Area3D = $Area3D
var grow = true
var physics_frame_counter = 0
var damage_applied = false

var minDamage = 0
var maxDamage = 10

func _ready():
	#explosion_light.visible = true
	explosion_light.light_energy = 1
	await get_tree().create_timer(0.5).timeout
	grow = false

func _physics_process(delta):
	if not damage_applied:
		physics_frame_counter += 1
		if physics_frame_counter >= 2:
			apply_damage()
			damage_applied = true

func _process(delta):
	if(grow):
		explosion_light.light_energy = lerp(explosion_light.light_energy,10.0,delta*5)
	else:
		explosion_light.light_energy = lerp(explosion_light.light_energy,0.0,delta*5)
	
	if( explosion_light.light_energy < 1):
		queue_free()

func apply_damage():
	var bodies = area.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("take_damage"):
			var damage = randf_range(minDamage,maxDamage)
			body.take_damage(int(damage))
