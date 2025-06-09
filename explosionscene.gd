extends Node3D

@onready var explosion_light: OmniLight3D = $OmniLight3D
@onready var area: Area3D = $Area3D
@onready var explosionballs1 = $GPUParticles3D2
@onready var explosionballs2 = $GPUParticles3D3

var grow = true
var physics_frame_counter = 0
var damage_applied = false
var aoeScale = 1
var procMat : ParticleProcessMaterial
var procMat2 : ParticleProcessMaterial

var minDamage = 0
var maxDamage = 10

func _ready():
	procMat = explosionballs1.process_material
	procMat2 = explosionballs2.process_material
	if procMat.scale_min != aoeScale:
		procMat.scale_min = aoeScale
		procMat2.scale_min = aoeScale
		procMat.scale_max = aoeScale
		procMat2.scale_max = aoeScale
		explosionballs1.restart()
		explosionballs2.restart()
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
