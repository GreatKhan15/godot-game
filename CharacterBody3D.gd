extends CharacterBody3D

# Movement variables
var speed : float = 5.0
var mouse_sensitivity : float = 0.01

# Camera reference
var camera : Camera3D
var camera_pitch : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	# Initialize the camera (but we won't update it now)
	camera = $Camera3D
	# Set the cursor to hidden for mouse look
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
	# Check for Escape key to release the mouse capture
	if Input.is_action_just_pressed("ui_cancel"):  # Escape button
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE  # Show the cursor and release it
		return  # Exit early so no other code runs after releasing the mouse

	# Get WASD input
	var direction : Vector3 = Vector3.ZERO
	if Input.is_action_pressed("ui_up"):  # W
		direction.z -= 1
	if Input.is_action_pressed("ui_down"):  # S
		direction.z += 1
	if Input.is_action_pressed("ui_left"):  # A
		direction.x -= 1
	if Input.is_action_pressed("ui_right"):  # D
		direction.x += 1
	
	# Normalize direction to avoid faster diagonal movement
	direction = direction.normalized()

	# Set the velocity based on direction
	velocity = direction * speed

	# Apply movement using move_and_slide() with no arguments
	move_and_slide()

	# Handle mouse movement (rotate the sphere, not the camera)
	var mouse_movement : Vector2 = Input.get_last_mouse_velocity() * mouse_sensitivity
	
	# Rotate the sphere around the Y-axis (horizontal movement)
	rotate_y(deg_to_rad(-mouse_movement.x))
	rotate_x(deg_to_rad(-mouse_movement.y))

	
