# ResultsPopup.gd
extends Panel

@onready var title_label = $TitleLabel
@onready var results_label = $ResultsLabel
@onready var continue_label = $ContinueLabel

var can_continue := false

var tween: Tween

func _ready():
	visible = false
	if continue_label:
		continue_label.text = "[center]Press E to continue[/center]"
		# Start pulsing animation
		_start_pulse_animation()

func _input(event):
	if visible and can_continue:
		if event.is_action_pressed("interact"):  # Assuming "interact" is mapped to E
			visible = false
			# You might want to emit a signal here to restart the game
			# or return to the main menu

func display_results(love_score: float, distractions: int):
	visible = true
	can_continue = true
	
	# Calculate rating based on scores
	var rating = calculate_rating(love_score, distractions)
	
	# Format results text
	var results_text = """
[center]
Love Score: {love}%
Distractions: {dist}

Rating: {rating}

{message}
[/center]
""".format({
		"love": ceil(love_score),
		"dist": distractions,
		"rating": rating,
		"message": get_rating_message(rating)
	})
	
	results_label.text = results_text

func calculate_rating(love_score: float, distractions: int) -> String:
	# Adjust these thresholds as needed for your game
	if love_score >= 90 and distractions <= 1:
		return "S"
	elif love_score >= 80 and distractions <= 2:
		return "A"
	elif love_score >= 70 and distractions <= 3:
		return "B"
	elif love_score >= 60:
		return "C"
	else:
		return "D"

func get_rating_message(rating: String) -> String:
	match rating:
		"S":
			return "Perfect Date! ❤️"
		"A":
			return "Great Date! 💕"
		"B":
			return "Good Date! 👍"
		"C":
			return "Could Be Better 😅"
		_:
			return "Try Again? 🤔"

func _start_pulse_animation():
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_loops()  # Make it repeat
	
	# Pulse the alpha of the continue label
	tween.tween_property(continue_label, "modulate:a", 0.5, 1.0)
	tween.tween_property(continue_label, "modulate:a", 1.0, 1.0)
