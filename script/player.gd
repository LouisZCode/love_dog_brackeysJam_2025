extends CharacterBody2D

@export var walk_speed := 300.0
@export var run_speed := 600.0
@export var acceleration := 1500.0
@export var friction := 1000.0
@export var debug_mode := true

# Get the gravity from the project settings to be synced with RigidBody nodes
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

enum DogState { IDLE, WALKING, RUNNING, FIXING }
var current_state: DogState = DogState.IDLE
var is_at_table := false
var facing_right := true
var current_noise := 0.0
@export var noise_increase_rate := 2.0  # How fast noise increases while running
@export var noise_decrease_rate := 1.0  # How fast noise decreases while walking/idle
@export var max_noise := 100.0

# Signal for noise level changes
signal noise_level_changed(noise: float)

func _physics_process(delta):
	# Add the gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Get movement input
	var direction = Input.get_axis("ui_left", "ui_right")
	var is_running = Input.is_action_pressed("run")  # Space key by default
	
	# Set speed based on running state
	var target_speed = run_speed if is_running else walk_speed
	
	# Handle movement with acceleration and friction
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * target_speed, acceleration * delta)
		current_state = DogState.RUNNING if is_running else DogState.WALKING
		facing_right = direction > 0
		
		# Update noise level
		if is_running:
			update_noise(delta, true)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		current_state = DogState.IDLE if is_on_floor() else current_state
		update_noise(delta, false)

	move_and_slide()
	update_animation_state()
	
	if debug_mode:
		print_debug_info()

func update_noise(delta: float, is_running: bool) -> void:
	if is_running:
		current_noise = min(current_noise + noise_increase_rate * delta, max_noise)
	else:
		current_noise = max(current_noise - noise_decrease_rate * delta, 0.0)
	
	emit_signal("noise_level_changed", current_noise)

func update_animation_state():
	# This will be used later for animations
	# For now we can just flip the sprite based on direction
	if facing_right:
		scale.x = abs(scale.x)
	else:
		scale.x = -abs(scale.x)

func print_debug_info():
	# Only print every 60 frames to avoid console spam
	if Engine.get_physics_frames() % 60 == 0:
		print("State: ", DogState.keys()[current_state])
		print("At Table: ", is_at_table)
		print("Noise Level: ", current_noise)
		print("Velocity: ", velocity)

func _on_table_area_entered(area):
	if area.name == "TableArea":
		is_at_table = true
		if debug_mode:
			print("Entered table area")

func _on_table_area_exited(area):
	if area.name == "TableArea":
		is_at_table = false
		if debug_mode:
			print("Exited table area")

func start_fixing():
	current_state = DogState.FIXING
	# Add fixing logic here later

func stop_fixing():
	current_state = DogState.IDLE
	# Add stop fixing logic here later

func get_noise_level() -> float:
	return current_noise

# This will be called from the ProblemManager when a problem is nearby
func can_fix_problem() -> bool:
	return current_state != DogState.FIXING and not is_at_table
