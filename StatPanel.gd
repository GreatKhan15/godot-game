extends Panel

@export var slide_speed: float = 8.0  # Adjust speed
var is_open = false
var target_x = 0.0

func _ready():
	target_x = 0
	position.x = size.x  # Start hidden offscreen (assuming anchored top-right)

func _process(delta):
	# Smoothly move the panel's x position
	position.x = lerp(position.x, float(target_x), slide_speed * delta)

func _input(event):
	if event.is_action_pressed("ui_tab"):
		is_open = !is_open
		if is_open:
			target_x = -size.x  # Slide out (fully visible)
		else:
			target_x = 0  # Slide in (hidden)
