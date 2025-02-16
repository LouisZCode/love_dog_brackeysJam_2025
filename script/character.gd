extends CharacterBody2D

enum CharacterState { SITTING, TALKING, REACTING }
var current_state: CharacterState = CharacterState.SITTING

@export var character_name: String = "Character"
@export var is_date: bool = false  # false for owner, true for date

# Mood ranges from 0 (unhappy) to 100 (very happy)
var current_mood: float = 50.0

func _ready():
	# Initialize character in sitting position
	current_state = CharacterState.SITTING

func update_mood(change: float):
	current_mood = clamp(current_mood + change, 0.0, 100.0)
	
	if current_mood <= 20.0:
		# Character is very unhappy
		react_to_mood("unhappy")
	elif current_mood >= 80.0:
		# Character is very happy
		react_to_mood("happy")

func react_to_mood(mood_type: String):
	current_state = CharacterState.REACTING
	# Here we'll add animations later
	print(character_name, " is ", mood_type)

# Called when problems occur nearby
func react_to_noise(noise_level: float):
	if noise_level > 70.0:
		update_mood(-1.0)  # High noise decreases mood
		print(character_name, " noticed loud noise!")

# Called when the other character is talking
func listen_to_conversation():
	current_state = CharacterState.TALKING
	update_mood(0.5)  # Small positive mood boost from good conversation
