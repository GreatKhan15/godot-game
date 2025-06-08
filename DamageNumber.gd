extends Label3D

@export var float_speed = 3.0
@export var life_time = 1.0
var timer = 0.0

func _process(delta):
	timer += delta
	position.y += float_speed * delta  # Move up
	modulate.a = lerp(1.0, 0.0, timer / life_time)  # Fade out alpha
	if timer >= life_time:
		queue_free()
