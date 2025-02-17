extends CharacterBody2D

@export var walk_speed := 300.0
@export var run_speed := 600.0
@export var acceleration := 1500.0
@export var friction := 1000.0

# Jump variables
@export var jump_force := -400.0
@export var jump_cut_height := 0.4
@export var max_fall_speed := 500.0
@export var fall_acceleration := 1800.0
@export var jump_acceleration := 1000.0
@export var coyote_time := 0.15  # Time in seconds you can jump after leaving platform
@export var jump_buffer_time := 0.1  # Time in seconds to buffer jump input

@onready var animated_sprite = $AnimatedSprite2D

enum DogState { IDLE, WALKING, RUNNING, JUMPING, FALLING, FIXING }
var current_state: DogState = DogState.IDLE
var is_at_table := false
var facing_right := true
var current_noise := 0.0
var was_jumping := false
var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var can_jump := true
var wants_to_jump := false

func _physics_process(delta):
	update_timers(delta)
	handle_jump_input()
	handle_jump(delta)
	handle_horizontal_movement(delta)
	update_state()
	move_and_slide()
	update_animation_state()

func update_timers(delta):
	if is_on_floor():
		can_jump = true
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta
		if coyote_timer <= 0:
			can_jump = false
	
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
		if jump_buffer_timer <= 0:
			wants_to_jump = false

func handle_jump_input():
	if Input.is_action_just_pressed("jump"):
		wants_to_jump = true
		jump_buffer_timer = jump_buffer_time

func handle_jump(delta):
	# Apply different gravity based on upward/downward movement
	if not is_on_floor():
		var gravity_force = fall_acceleration if velocity.y > 0 else jump_acceleration
		velocity.y += gravity_force * delta
		
		# Cap fall speed
		if velocity.y > max_fall_speed:
			velocity.y = max_fall_speed
	
	# Execute jump if buffered jump input exists and we can jump
	if wants_to_jump and can_jump:
		velocity.y = jump_force
		was_jumping = true
		can_jump = false
		wants_to_jump = false
		jump_buffer_timer = 0
	
	# Variable jump height when releasing jump button
	if was_jumping and Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= jump_cut_height
		was_jumping = false

func handle_horizontal_movement(delta):
	var direction = Input.get_axis("ui_left", "ui_right")
	var is_running = Input.is_action_pressed("run")  # This is space
	var target_speed = run_speed if is_running else walk_speed
	
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * target_speed, acceleration * delta)
		facing_right = direction > 0
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

func update_state():
	if is_on_floor():
		if abs(velocity.x) > 10:
			current_state = DogState.RUNNING if abs(velocity.x) > walk_speed else DogState.WALKING
		else:
			current_state = DogState.IDLE
	else:
		current_state = DogState.JUMPING if velocity.y < 0 else DogState.FALLING

func update_animation_state():
	animated_sprite.flip_h = !facing_right
	
	match current_state:
		DogState.IDLE:
			animated_sprite.play("idle")
		DogState.WALKING, DogState.RUNNING:
			animated_sprite.play("run")
			animated_sprite.speed_scale = 1.5 if abs(velocity.x) > walk_speed else 1.0
		DogState.JUMPING:
			animated_sprite.play("jump" if has_animation("jump") else "idle")
		DogState.FALLING:
			animated_sprite.play("fall" if has_animation("fall") else "idle")
		DogState.FIXING:
			animated_sprite.play("idle")

func has_animation(anim_name: String) -> bool:
	return animated_sprite.sprite_frames.has_animation(anim_name)
