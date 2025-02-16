extends Node2D

enum CharacterState { SITTING, TALKING, DISTRACTED }
var current_state: CharacterState = CharacterState.SITTING

@export var character_name: String = "Character"
@export var is_date: bool = false  # false for owner, true for date
@onready var sprite = $ColorRect  # or your Sprite2D

func _ready():
	# Get DateManager and connect signals
	var date_manager = get_node("/root/Game/DateManager")
	if date_manager:
		date_manager.distraction_level_changed.connect(_on_distraction_level_changed)
		date_manager.love_level_changed.connect(_on_love_level_changed)
	
	current_state = CharacterState.SITTING

func _on_distraction_level_changed(distraction_count: int):
	if distraction_count > 0:
		react_to_distraction()
	else:
		return_to_normal()

func _on_love_level_changed(new_love: float):
	# Could change character's expression based on how well the date is going
	if new_love > 75:
		sprite.color = Color(0.2, 1, 0.2)  # Happy green
	elif new_love < 25:
		sprite.color = Color(1, 0.2, 0.2)  # Unhappy red
	else:
		sprite.color = Color(1, 1, 1)  # Neutral white

func react_to_distraction():
	current_state = CharacterState.DISTRACTED
	# For now, just change color to show distraction
	if is_date:
		sprite.color = Color(1, 0.5, 0.5)  # Light red for date
	else:
		sprite.color = Color(0.5, 0.5, 1)  # Light blue for owner
	print(character_name + " is distracted!")

func return_to_normal():
	current_state = CharacterState.SITTING
	sprite.color = Color(1, 1, 1)  # Return to normal color
	print(character_name + " returned to normal")
