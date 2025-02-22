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

var animation_completed := false  # Add this variable at the top
var tween: Tween

var can_continue := false
var initial_player_position: Vector2  # Store initial position

@onready var ending_screen = preload("res://scenes/ending_screen.tscn")

func _ready():
	visible = false
	if continue_label:
		continue_label.text = "[center]Press E to continue[/center]"
	if player:
		initial_player_position = player.position  # Store initial position

func _input(event):
	if visible:
		if event.is_action_pressed("interact"):
			if !animation_completed:
				# Skip animation
				if tween:
					tween.kill()
				
				# Show all content immediately
				var rating = calculate_rating($"../LoveBar".value, int($"../DistractionLabel".text.split(": ")[1]))
				title_label.text = "[center][color=yellow]Night " + str(GlobalControls.night_number) + " Results![/color][/center]"
				
				var love_score = $"../LoveBar".value
				var distractions = int($"../DistractionLabel".text.split(": ")[1])
				var color_love = get_love_score_color(love_score)
				var color_dist = get_distraction_color(distractions)
				
				results_label.text = """[center]
Love Score: [color={color_love}]{love}%[/color]

Distractions: [color={color_dist}]{dist}[/color]

[rainbow freq=1.0]Rating: {rating}[/rainbow]

[color=aqua]{message}[/color][/center]
""".format({
					"color_love": color_love,
					"love": ceil(love_score),
					"color_dist": color_dist,
					"dist": distractions,
					"rating": rating,
					"message": get_rating_message(rating)
				})
				
				continue_label.modulate.a = 1.0
				animation_completed = true
				can_continue = true
				_start_pulse_animation()
# In ResultsPopup.gd, modify the elif can_continue part in _input:
			elif can_continue:
				visible = false
				get_tree().paused = false
				
				var love_score = $"../LoveBar".value
				if love_score >= 65:
					# Check if this was the final night with a good score
					if GlobalControls.night_number == 3 and love_score >= 80:
						# Show ending screen
						var end_screen = ending_screen.instantiate()
						get_tree().root.add_child(end_screen)
						end_screen.show_ending()
					else:
						# Continue to next night
						GlobalControls.complete_night()
						reset_level()
				else:
					# Lose - restart from night 1
					GlobalControls.reset_game()
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
	get_tree().paused = true
	animation_completed = false
	can_continue = false  # Will be set to true after animation or skip
	
	# Hide all labels initially
	title_label.text = ""
	results_label.text = ""
	continue_label.modulate.a = 0
	
	var rating = calculate_rating(love_score, distractions)
	
	# Create animation sequence
	if tween:
		tween.kill()
	tween = create_tween()
	
	# Animate title
	tween.tween_callback(func():
		title_label.text = "[center][wave amp=50 freq=5][color=yellow]Night " + str(GlobalControls.night_number) + " Results![/color][/wave][/center]"
	)
	tween.tween_interval(1.0)
	
	# Animate love score
	tween.tween_callback(func():
		var color = get_love_score_color(love_score)
		results_label.text = "[center]Love Score: [color=" + color + "]" + str(ceil(love_score)) + "%[/color][/center]"
	)
	tween.tween_interval(0.8)
	
	# Animate distractions
	tween.tween_callback(func():
		var prev_text = results_label.text
		var color = get_distraction_color(distractions)
		results_label.text = prev_text + "\n\nDistractions: [color=" + color + "]" + str(distractions) + "[/color]"
	)
	tween.tween_interval(0.8)
	
	# Animate rating
	tween.tween_callback(func():
		var prev_text = results_label.text
		results_label.text = prev_text + "\n\n[rainbow freq=1.0]Rating: " + rating + "[/rainbow]"
	)
	tween.tween_interval(0.8)
	
	# Animate message
	tween.tween_callback(func():
		var prev_text = results_label.text
		results_label.text = prev_text + "\n\n[wave amp=50 freq=2][color=aqua]" + get_rating_message(rating) + "[/color][/wave]"
	)
	
	# Fade in continue label
	tween.tween_property(continue_label, "modulate:a", 1.0, 0.5)
	
	# Mark animation as completed and enable continue
	tween.tween_callback(func():
		animation_completed = true
		can_continue = true
		_start_pulse_animation()
	)

func calculate_rating(love_score: float, distractions: int) -> String:
	# Adjust these thresholds as needed for your game
	if love_score >= 90:
		return "S"
	elif love_score >= 80:
		return "A"
	elif love_score >= 70:
		return "B"
	elif love_score >= 60:
		return "C"
	else:
		return "D"

func get_rating_message(rating: String) -> String:
	match rating:
		"S":
			return "Perfect Date! "
		"A":
			return "Great Date!"
		"B":
			return "Good Date!"
		"C":
			return "Could Be Better"
		_:
			return "Try Again?"

func _start_pulse_animation():
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_loops()  # Make it repeat
	
	# Pulse the alpha of the continue label
	tween.tween_property(continue_label, "modulate:a", 0.5, 1.0)
	tween.tween_property(continue_label, "modulate:a", 1.0, 1.0)
	
# Helper functions for colors
func get_love_score_color(score: float) -> String:
	if score >= 90: return "#FFD700"  # Gold
	elif score >= 80: return "#FFA500"  # Orange
	elif score >= 70: return "#98FB98"  # Pale green
	elif score >= 60: return "#87CEEB"  # Sky blue
	else: return "#FF6347"  # Tomato red

func get_distraction_color(count: int) -> String:
	match count:
		0: return "#00FF00"  # Bright green
		1: return "#FFFF00"  # Yellow
		2: return "#FFA500"  # Orange
		_: return "#FF0000"  # Red
