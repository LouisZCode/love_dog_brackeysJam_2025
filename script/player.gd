extends CharacterBody2D

@export var walk_speed := 300.0
@export var run_speed := 600.0
@export var acceleration := 1500.0
@export var friction := 1000.0

@onready var animated_sprite = $AnimatedSprite2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
enum DogState { IDLE, WALKING, RUNNING, FIXING }
var current_state: DogState = DogState.IDLE
var is_at_table := false
var facing_right := true
var current_noise := 0.0

func _physics_process(delta):
	# Add the gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Get movement input
	var direction = Input.get_axis("ui_left", "ui_right")
	var is_running = Input.is_action_pressed("run")
	
	# Set speed based on running state
	var target_speed = run_speed if is_running else walk_speed
	
	# Handle movement with acceleration and friction
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * target_speed, acceleration * delta)
		current_state = DogState.RUNNING if is_running else DogState.WALKING
		facing_right = direction > 0
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		current_state = DogState.IDLE if is_on_floor() else current_state

	move_and_slide()
	update_animation_state()

func update_animation_state():
	# Update sprite direction
	animated_sprite.flip_h = !facing_right
	
	# Update animation based on state
	match current_state:
		DogState.IDLE:
			animated_sprite.play("idle")
		DogState.WALKING, DogState.RUNNING:
			animated_sprite.play("run")
			# Optionally adjust animation speed based on running
			animated_sprite.speed_scale = 1.5 if current_state == DogState.RUNNING else 1.0
		DogState.FIXING:
			animated_sprite.play("idle")  # Or a fixing animation if you have one
