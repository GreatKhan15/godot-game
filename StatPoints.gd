extends Label

var flash_speed = 3.0  # Adjust for faster/slower flashing
var alpha = 1.0
var direction = -1  # Start by fading out

func _process(delta):
	if( text != "0"):
		alpha += direction * flash_speed * delta
		if alpha <= 0.2:
			alpha = 0.2
			direction = 1  # Fade back in
		elif alpha >= 1.0:
			alpha = 1.0
			direction = -1  # Fade back out

		modulate.a = alpha
	else:
		modulate.a = 1.0
