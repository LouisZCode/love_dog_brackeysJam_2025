extends Node2D

enum CharacterState { SITTING, TALKING, DISTRACTED }
enum MoodState { VERY_UNHAPPY, UNHAPPY, HAPPY, VERY_HAPPY }

var current_state: CharacterState = CharacterState.SITTING
var current_mood: MoodState = MoodState.UNHAPPY

@onready var talk_timer: Timer = $TalkTimer  # Add this timer node
@onready var talk_sfx: AudioStreamPlayer2D = $TalkSFX  # Add this audio player node
@onready var distracted_sfx: AudioStreamPlayer2D = $DistractedSFX

@export var character_name: String = "Character"
@export var is_date: bool = false  # false for owner, true for date

@onready var animated_sprite = $AnimatedSprite2D
@onready var initial_position := position  # Store initial position

@export var lean_amount := 50.0  # Base amount they can move
@export var min_distance := 50.0  # Minimum distance between characters
@export var max_distance := 50.0  # Maximum distance between characters

var is_talking := false
var talk_interval_min := 1.0  # Minimum time between talks
var talk_interval_max := 3.0  # Maximum time between talks
var talk_duration_min := 10.0  # Minimum talk duration
var talk_duration_max := 12.0  # Maximum talk duration

func _ready():
	# Get DateManager and connect signals
	var date_manager = get_node("/root/Game/DateManager")
	if date_manager:
		date_manager.distraction_level_changed.connect(_on_distraction_level_changed)
		date_manager.love_level_changed.connect(_on_love_level_changed)
	
	current_state = CharacterState.SITTING
	update_animation()
	
		# Setup talk timer
	if !talk_timer:
		talk_timer = Timer.new()
		add_child(talk_timer)
	talk_timer.one_shot = true
	talk_timer.timeout.connect(_on_talk_timer_timeout)
	
	# Start talk cycle if game is active
	if GlobalControls.game_started:
		start_talk_cycle()
	
	# Connect to game start signal
	GlobalControls.game_start.connect(start_talk_cycle)
	
	if talk_sfx:
		talk_sfx.stream.loop = true
	if distracted_sfx:
		distracted_sfx.stream.loop = true

func _on_distraction_level_changed(distraction_count: int):
	if distraction_count > 0:
		react_to_distraction()
	else:
		return_to_normal()

func _on_love_level_changed(new_love: float):
	# Update mood based on love level
	var previous_mood = current_mood
	
	if new_love < 20:
		current_mood = MoodState.VERY_UNHAPPY
	elif new_love < 60:
		current_mood = MoodState.UNHAPPY
	elif new_love < 90:
		current_mood = MoodState.HAPPY
	else:
		current_mood = MoodState.VERY_HAPPY
	
	# If mood improved to HAPPY or VERY_HAPPY, potentially start talking sooner
	if (current_mood == MoodState.HAPPY or current_mood == MoodState.VERY_HAPPY) and (previous_mood == MoodState.UNHAPPY or previous_mood == MoodState.VERY_UNHAPPY):
		if !is_talking and current_state != CharacterState.DISTRACTED:
			talk_timer.stop()
			talk_timer.start(get_talk_interval())
	
	update_animation()
	update_position(new_love)

func update_position(love_level: float):
	# Calculate lean factor (-1 to 1, but now inverted)
	var lean_factor = -(love_level - 50.0) / 50.0  
	
	# Calculate new position but clamp the movement
	var target_position = initial_position
	
	# Calculate movement but clamp it between min and max
	var movement = lean_amount * lean_factor
	movement = clamp(movement, -max_distance/2, max_distance/2)
	
	if is_date:
		target_position.x += movement
	else:
		target_position.x -= movement
	
	# Smoothly move to new position
	var tween = create_tween()
	tween.tween_property(self, "position", target_position, 0.5).set_trans(Tween.TRANS_QUAD)

func start_talk_cycle():
	# Start first talk after random delay
	talk_timer.start(randf_range(talk_interval_min, talk_interval_max))

func _on_talk_timer_timeout():
	if current_state != CharacterState.DISTRACTED:
		start_talking()

func start_talking():
	current_state = CharacterState.TALKING
	is_talking = true
	update_animation()
	
	if talk_sfx:
		talk_sfx.seek(0.0)  # Start from beginning
		talk_sfx.play()
	
	# Use longer talk duration
	var talk_duration = randf_range(talk_duration_min, talk_duration_max)
	await get_tree().create_timer(talk_duration).timeout
	
	stop_talking()

func get_talk_interval() -> float:
	# Return shorter intervals when happy/very happy
	match current_mood:
		MoodState.VERY_HAPPY:
			return randf_range(0.5, 1.0)  # Very frequent talks
		MoodState.HAPPY:
			return randf_range(0.8, 1.5)  # Frequent talks
		MoodState.UNHAPPY:
			return randf_range(1.0, 3.0)  # Normal intervals
		MoodState.VERY_UNHAPPY:
			return randf_range(2.0, 4.0)  # Less frequent talks
		_:
			return randf_range(1.0, 3.0)  # Default interval

func stop_talking():
	if is_talking:
		current_state = CharacterState.SITTING
		is_talking = false
		update_animation()
		
		if talk_sfx:
			talk_sfx.stop()
		
		# Use mood-based interval for next talk
		talk_timer.start(get_talk_interval())

func react_to_distraction():
	if is_talking:
		stop_talking()
	
	current_state = CharacterState.DISTRACTED
	update_animation()
	
	if distracted_sfx:
		distracted_sfx.seek(0.0)  # Start from beginning
		distracted_sfx.play()
	
	print(character_name + " is distracted!")

func return_to_normal():
	current_state = CharacterState.SITTING
	update_animation()
	
	if distracted_sfx:
		distracted_sfx.stop()
	
	print(character_name + " returned to normal")

func update_animation():
	# Base animation name on mood
	var base_anim = match_mood_to_animation()
	
	# Modify animation based on state
	match current_state:
		CharacterState.SITTING:
			animated_sprite.play(base_anim + "_idle")
		CharacterState.DISTRACTED:
			animated_sprite.play(base_anim + "_distracted")
		CharacterState.TALKING:
			animated_sprite.play(base_anim + "_talking")

func match_mood_to_animation() -> String:
	match current_mood:
		MoodState.VERY_UNHAPPY:
			return "mood_d"
		MoodState.UNHAPPY:
			return "mood_c"
		MoodState.HAPPY:
			return "mood_b"
		MoodState.VERY_HAPPY:
			return "mood_a"
		_:
			return "mood_c"  # Default mood
