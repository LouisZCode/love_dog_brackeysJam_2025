extends CharacterBody2D

@export var move_speed := 400.0
@export var wipe_offset := 30.0   # How far the wipe goes each direction
@export var wipe_speed := 0.2    # Time for each wipe position
@onready var wipe_sound: AudioStreamPlayer2D = $Wipesound

var can_clean := false
var current_spot = null
var initial_position := Vector2.ZERO
var is_wiping := false
var wipe_step := 0

func _ready():
	initial_position = position

func _physics_process(delta):
	# Get input direction
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * move_speed
	move_and_slide()
	
	# Handle wipe animation if active
	if is_wiping:
		match wipe_step:
			0:  # Right
				position.x = initial_position.x + wipe_offset
				wipe_step += 1
				await get_tree().create_timer(wipe_speed).timeout
			1:  # Left
				position.x = initial_position.x - wipe_offset
				wipe_step += 1
				await get_tree().create_timer(wipe_speed).timeout
			2:  # Center
				position.x = initial_position.x
				is_wiping = false
				wipe_step = 0
	
	# Check for cleaning action
	if can_clean and current_spot and Input.is_action_just_pressed("interact"):
		current_spot.clean()
		start_wipe()

func start_wipe():
	if not is_wiping:
		is_wiping = true
		wipe_step = 0
		initial_position = position
		if wipe_sound:
			wipe_sound.play()

func _on_clean_area_entered(area):
	if area.is_in_group("cleanable"):
		can_clean = true
		current_spot = area

func _on_clean_area_exited(area):
	if area == current_spot:
		can_clean = false
		current_spot = null
