extends Node3D
@onready var light: OmniLight3D = $MeshInstance3D/OmniLight3D
var handNode : Transform3D
var target_position : Vector3 = Vector3.ZERO



var skeleton: Skeleton3D
var bone_name: String
var bone_idx: int = -1

var fade_time = 0.2
var fade_alpha := 0.0
var fade_speed := 1  # adjust to taste
var fade_in := true

func _ready():
	if skeleton and bone_name != "":
		bone_idx = skeleton.find_bone(bone_name)
		if bone_idx == -1:
			print("Bone not found: ", bone_name)

func _process(delta):
	if bone_idx != -1:
		var bone_transform = skeleton.get_bone_global_pose(bone_idx)
		var global_bone_pos : Vector3 = skeleton.to_global(bone_transform.origin)
		update_beam(global_bone_pos, target_position)
		
	if fade_in:
		fade_alpha += fade_speed * delta
		if fade_alpha >= fade_time:
			fade_alpha = fade_time
			fade_in = false
	else:
		fade_alpha -= fade_speed * delta
		if fade_alpha <= 0.0:
			fade_alpha = 0.0
			queue_free()

	light.light_energy = fade_alpha * 25.0  # adjust multiplier to taste
	
func update_beam(player_pos: Vector3, explosion_pos: Vector3):
	var direction = explosion_pos - player_pos
	var distance = direction.length()
	global_transform.origin = player_pos
	scale = Vector3(0.1,0.1,distance)
	look_at(explosion_pos)


