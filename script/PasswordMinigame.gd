extends MinigameBase

@onready var game_font = preload("res://assets/fonts/PixelOperator8.ttf")

# Password configuration
var pattern_length := 5
var current_pattern := []
var user_progress := 0
@onready var pattern_label = $PatternLabel
@onready var instruction_label = $InstructionLabel
@onready var typesound: AudioStreamPlayer2D = $Typesound
@onready var win_sound: AudioStreamPlayer2D = $win_sound
@onready var lose_sound: AudioStreamPlayer2D = $lose_sound


# Define the display area (similar to QuickClean)
var display_area = Rect2(Vector2(300, 270), Vector2(400, 2700))
@onready var left_hand = $LeftHandSprite
@onready var right_hand = $RightHandSprite
@export var type_offset := 10.0   # How far up the sprites move
@export var type_speed := 0.1    # How long the animation takes

# Arrows and input mapping
var input_map = {
	"ui_up": "↑",
	"ui_down": "↓",
	"ui_left": "←",
	"ui_right": "→",
	"interact": "E"
}

func setup_minigame():
	setup_labels()
	generate_new_pattern()
	display_pattern()

func setup_labels():
	# Set up instruction label
	instruction_label.text = "[center]Match the pattern using arrow keys and E![/center]"
	instruction_label.bbcode_enabled = true
	
	# Apply the custom font
	instruction_label.add_theme_font_override("normal_font", game_font)
	pattern_label.add_theme_font_override("normal_font", game_font)
	
	# Set up pattern label
	pattern_label.bbcode_enabled = true
	pattern_label.position = display_area.position
	pattern_label.custom_minimum_size = Vector2(display_area.size.x, 100)

func generate_new_pattern():
	current_pattern.clear()
	user_progress = 0
	var possible_inputs = input_map.values()
	
	for i in pattern_length:
		var random_input = possible_inputs[randi() % possible_inputs.size()]
		current_pattern.append(random_input)

func display_pattern():
	var display_text = "[center][font_size=52]"
	for i in pattern_length:
		var color = "red" if i >= user_progress else "green"
		display_text += "[color=%s]%s[/color] " % [color, current_pattern[i]]
	display_text += "[/font_size][/center]"
	pattern_label.text = display_text

func _input(event):
	if not is_active:
		return
		
	var input_detected = false
	var input_value = ""
	
	# Check for each possible input
	for action in input_map.keys():
		if event.is_action_pressed(action):
			input_detected = true
			input_value = input_map[action]
			break
	
	if input_detected:
		check_input(input_value)


func animate_typing(is_left_hand: bool):
	typesound.play()
	var sprite = left_hand if is_left_hand else right_hand
	var initial_position = sprite.position

	
	# Move up
	sprite.position.y = initial_position.y - type_offset
	await get_tree().create_timer(type_speed).timeout
	# Move back
	sprite.position.y = initial_position.y

func check_input(input_value: String):
	# Safety check to prevent out of bounds
	if user_progress >= pattern_length or user_progress >= len(current_pattern):
		print("Warning: Progress index out of bounds")
		return

	match input_value:
		"←", "↓":  # Left hand inputs
			animate_typing(true)
		"→", "↑", "E":  # Right hand inputs
			animate_typing(false)
	
	# Safety check again before comparing
	if user_progress < len(current_pattern) and input_value == current_pattern[user_progress]:
		# Correct input
		user_progress += 1
		display_pattern()
		
		if user_progress == pattern_length:
			win_sound.play()
			var timer = get_tree().create_timer(0.5)  # Half second delay
			timer.timeout.connect(func(): win_game())
	else:
		# Incorrect input
		lose_sound.play()
		generate_new_pattern()
		display_pattern()
