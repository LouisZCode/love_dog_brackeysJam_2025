# ResultsPopup.gd
extends Panel

@onready var title_label = $TitleLabel
@onready var results_label = $ResultsLabel
@onready var continue_label = $ContinueLabel
@onready var player = get_node("/root/Game/Player")  # Adjust path to your player node
@onready var camera = get_node("/root/Game/StaticCamera")  # Add camera reference
@onready var rooms_node = get_node("/root/Game/Rooms")
@onready var problem_manager = get_node("/root/Game/ProblemManager")
@onready var date_manager = get_node("/root/Game/DateManager")
@onready var spawn_points_root = get_node("/root/Game/ProblemSpawnPoints")


var tween: Tween

var can_continue := false
var initial_player_position: Vector2  # Store initial position

func _ready():
	visible = false
	if continue_label:
		continue_label.text = "[center]Press E to continue[/center]"
	if player:
		initial_player_position = player.position  # Store initial position

func _input(event):
	if visible and can_continue:
		if event.is_action_pressed("interact"):  # E key
			visible = false
			get_tree().paused = false  # Unpause the game
			
			# Check win/lose condition
			var love_score = $"../LoveBar".value  # Adjust path as needed
			
			if love_score >= 65:
				# Win - go to next night
				GlobalControls.complete_night()  # This will increment night_number
				reset_level()
			else:
				# Lose - restart current night
				GlobalControls.reset_game()  # This resets to night 1
				reset_level()


func reset_level():
	# Reset player position
	if player:
		player.position = initial_player_position
	
	# Reset game state
	GlobalControls.game_started = false
	
	# Reset and disable managers
	if problem_manager:
		problem_manager.set_process(false)
		problem_manager.active_problems.clear()
		
		# Clean up all existing problems in spawn points
		if spawn_points_root:
			for room_points in spawn_points_root.get_children():
				for spawn_point in room_points.get_children():
					for child in spawn_point.get_children():
						if child.is_in_group("problem"):
							# Properly solve the problem to trigger all cleanup
							child.solve_problem()
	
	if date_manager:
		date_manager.set_process(false)
		# Reset date manager's distraction counts
		date_manager.active_distractions = 0
		date_manager.dangerous_distractions = 0
		date_manager.critical_distractions = 0
	
	# Reset camera and room visibility
	if camera and rooms_node:
		camera.current_room_position = camera.room_positions["Garden"]
		camera.global_position = camera.room_positions["Garden"]
		
		# Update room visibility
		for room in rooms_node.get_children():
			if room.name == "Garden":
				room.show()
			else:
				room.hide()
	
	# Keep UI elements visible but reset their values
	if get_parent():
		var love_bar = get_parent().get_node("LoveBar")
		var distraction_label = get_parent().get_node("DistractionLabel")
		var timer_label = get_parent().get_node("TimerLabel")
		
		if love_bar:
			love_bar.visible = true
			love_bar.value = 100  # Reset to initial value
		
		if distraction_label:
			distraction_label.visible = true
			distraction_label.text = "Distractions: 0"  # Reset distractions
		
		if timer_label:
			timer_label.visible = true
			timer_label.time_remaining = timer_label.total_time  # Reset timer
			timer_label.is_running = false  # Stop timer until game starts again

func display_results(love_score: float, distractions: int):
	visible = true
	can_continue = true
	get_tree().paused = true  # Pause the game
	
	# Calculate rating based on scores
	var rating = calculate_rating(love_score, distractions)
	
	# Format results text with night number
	var results_text = """
[center]
Night {night}
Love Score: {love}%
Distractions: {dist}

Rating: {rating}

{message}
[/center]
""".format({
		"night": GlobalControls.night_number,
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
