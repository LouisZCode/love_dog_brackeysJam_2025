extends Node2D

enum CharacterState { SITTING, TALKING, DISTRACTED }
enum MoodState { VERY_UNHAPPY, UNHAPPY, HAPPY, VERY_HAPPY }

var current_state: CharacterState = CharacterState.SITTING
var current_mood: MoodState = MoodState.UNHAPPY

@export var character_name: String = "Character"
@export var is_date: bool = false  # false for owner, true for date

@onready var animated_sprite = $AnimatedSprite2D
@onready var initial_position := position  # Store initial position

@export var lean_amount := 50.0  # Base amount they can move
@export var min_distance := 50.0  # Minimum distance between characters
@export var max_distance := 50.0  # Maximum distance between characters

func _ready():
	# Get DateManager and connect signals
	var date_manager = get_node("/root/Game/DateManager")
	if date_manager:
		date_manager.distraction_level_changed.connect(_on_distraction_level_changed)
		date_manager.love_level_changed.connect(_on_love_level_changed)
	
	current_state = CharacterState.SITTING
	update_animation()

func _on_distraction_level_changed(distraction_count: int):
	if distraction_count > 0:
		react_to_distraction()
	else:
		return_to_normal()

func _on_love_level_changed(new_love: float):
	# Update mood based on love level
	if new_love < 20:
		current_mood = MoodState.VERY_UNHAPPY
	elif new_love < 60:
		current_mood = MoodState.UNHAPPY
	elif new_love < 90:
		current_mood = MoodState.HAPPY
	else:
		current_mood = MoodState.VERY_HAPPY
	
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

func react_to_distraction():
	current_state = CharacterState.DISTRACTED
	update_animation()
	print(character_name + " is distracted!")

func return_to_normal():
	current_state = CharacterState.SITTING
	update_animation()
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
