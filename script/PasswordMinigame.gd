extends MinigameBase

# Password configuration
var pattern_length := 5
var current_pattern := []
var user_progress := 0
@onready var pattern_label = $PatternLabel
@onready var instruction_label = $InstructionLabel

# Define the display area (similar to QuickClean)
var display_area = Rect2(Vector2(300, 200), Vector2(400, 200))

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
	#instruction_label.position = Vector2(display_area.position.x, display_area.position.y - 50)
	
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

func check_input(input_value: String):
	if input_value == current_pattern[user_progress]:
		# Correct input
		user_progress += 1
		display_pattern()  # Update display with new green character
		
		if user_progress == pattern_length:
			win_game()
	else:
		# Incorrect input
		generate_new_pattern()
		display_pattern()
