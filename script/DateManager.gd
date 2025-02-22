extends Node

signal love_level_changed(new_value: float)
signal distraction_level_changed(new_value: float)
signal date_status_changed(is_going_well: bool)

# Love bar rates
@export_group("Love Bar Settings")
@export var love_increase_rate : int # Rate when no problems
@export var love_decrease_rate_dangerous : int  # Rate per dangerous problem
@export var love_decrease_rate_critical : int   # Rate per critical problem
@export var max_love := 100.0
@export var initial_love := 95.0
@export var good_date_threshold := 55

@onready var timer = get_node("../CanvasLayer/TimerLabel")

var current_love := initial_love
var active_distractions := 0  # For display purposes
var dangerous_distractions := 0  # Problems in dangerous state
var critical_distractions := 0   # Problems in critical state

@onready var radio_music_night1: AudioStreamPlayer2D = $radio_music_night1
@onready var radio_music_night2: AudioStreamPlayer2D = $radio_music_night2
@onready var radio_music_night3: AudioStreamPlayer2D = $radio_music_night3

# Your existing audio and sprite variables
@onready var radio_start: AudioStreamPlayer2D = $radio_start
@onready var radio_stop: AudioStreamPlayer2D = $radio_stop
@onready var music_sprite_1: Sprite2D = $MusicSprite1
@onready var music_sprite_2: Sprite2D = $MusicSprite2

var was_date_going_well := false 
var tween: Tween

var current_radio_music: AudioStreamPlayer2D 

func _ready():
	# Start disabled
	set_process(false)
	# Listen for game start
	GlobalControls.connect("game_start", _on_game_start)

func _on_game_start():
	set_process(true)
	current_love = initial_love
	emit_signal("love_level_changed", current_love)
	timer.start_timer()
	timer.time_up.connect(_on_time_up)
	
	# Stop any currently playing music
	stop_all_music()
	
	# Select and play the appropriate music based on night number
	match GlobalControls.night_number:
		1:
			current_radio_music = radio_music_night1
		2:
			current_radio_music = radio_music_night2
		3:
			current_radio_music = radio_music_night3
	
	if current_radio_music:
		current_radio_music.seek(0.0)  # Reset to beginning
		current_radio_music.play()
		show_music_sprite()

func stop_all_music():
	# Stop all music players
	for music_player in [radio_music_night1, radio_music_night2, radio_music_night3]:
		if music_player and music_player.playing:
			music_player.stop()

func show_music_sprite():
	# Kill previous tween if exists
	if tween:
		tween.kill()
	
	# Store original positions
	var original_pos_1 = music_sprite_1.position
	var original_pos_2 = music_sprite_2.position
	
	tween = create_tween()
	
	# First sprite animation
	if music_sprite_1:
		# Fade in
		tween.tween_property(music_sprite_1, "modulate:a", 1.0, 0.5)
		# Gentle floating with musical sway
		tween.parallel().tween_property(music_sprite_1, "position:x", 
			original_pos_1.x + 10, 0.8).set_trans(Tween.TRANS_SINE)
		tween.parallel().tween_property(music_sprite_1, "position:y", 
			original_pos_1.y - 20, 1.0).set_trans(Tween.TRANS_SINE)
		# Additional sway
		tween.tween_property(music_sprite_1, "position:x", 
			original_pos_1.x - 10, 0.8).set_trans(Tween.TRANS_SINE)
		# Fade out
		tween.tween_property(music_sprite_1, "modulate:a", 0.0, 0.5)
		# Reset position when invisible
		tween.tween_property(music_sprite_1, "position", original_pos_1, 0.01)
	
	# Second sprite animation with delay
	if music_sprite_2:
		tween.tween_interval(0.4)  # Slightly delayed start
		# Fade in
		tween.tween_property(music_sprite_2, "modulate:a", 1.0, 0.5)
		# Gentle floating with musical sway (opposite direction)
		tween.parallel().tween_property(music_sprite_2, "position:x", 
			original_pos_2.x - 10, 0.8).set_trans(Tween.TRANS_SINE)
		tween.parallel().tween_property(music_sprite_2, "position:y", 
			original_pos_2.y - 20, 1.0).set_trans(Tween.TRANS_SINE)
		# Additional sway
		tween.tween_property(music_sprite_2, "position:x", 
			original_pos_2.x + 10, 0.8).set_trans(Tween.TRANS_SINE)
		# Fade out
		tween.tween_property(music_sprite_2, "modulate:a", 0.0, 0.5)
		# Reset position when invisible
		tween.tween_property(music_sprite_2, "position", original_pos_2, 0.01)
	
	# Wait a bit before restarting
	tween.tween_interval(0.3)
	# Restart animation if music still playing
	tween.tween_callback(func(): if current_radio_music.playing: show_music_sprite())


func hide_music_sprite():
	if tween:
		tween.kill()
	if music_sprite_1:
		music_sprite_1.modulate.a = 0
	if music_sprite_2:
		music_sprite_2.modulate.a = 0

func _process(delta):
	if timer.is_running:
		update_love(delta)

func update_love(delta):
	# Get difficulty multiplier based on remaining time
	var time_percentage = timer.get_time_percentage()
	var difficulty = 1.0 + (1.0 - (time_percentage / 100.0))
	
	var is_going_well = current_love >= good_date_threshold
	
	if is_going_well != was_date_going_well:
		if is_going_well:
			if current_radio_music and not current_radio_music.playing:
				current_radio_music.seek(0.0)
				current_radio_music.play()
				show_music_sprite()
		else:
			if current_radio_music and current_radio_music.playing:
				current_radio_music.stop()
				if radio_stop:
					radio_stop.play()
				hide_music_sprite()

	was_date_going_well = is_going_well
	
	# New love calculation logic
	if dangerous_distractions == 0 and critical_distractions == 0:
		# Increase love when no problems
		increase_love(delta)
	else:
		var total_decrease = 0.0
		# Calculate decrease from dangerous problems
		if dangerous_distractions > 0:
			total_decrease += love_decrease_rate_dangerous * delta * difficulty * dangerous_distractions
		# Calculate decrease from critical problems
		if critical_distractions > 0:
			total_decrease += love_decrease_rate_critical * delta * difficulty * critical_distractions
		
		decrease_love(total_decrease)
	
	emit_signal("date_status_changed", current_love >= good_date_threshold)
	
	# Only decrease love if there are DANGEROUS distractions
	if dangerous_distractions > 0:
		var decrease = love_decrease_rate_dangerous * delta * difficulty * dangerous_distractions
		decrease_love(decrease)
	else:
		increase_love(delta)
	
	emit_signal("date_status_changed", current_love >= good_date_threshold)

func add_critical_distraction():
	critical_distractions += 1

func remove_critical_distraction():
	critical_distractions = max(0, critical_distractions - 1)

func increase_love(delta: float) -> void:
	var previous_love = current_love
	current_love = min(current_love + love_increase_rate * delta, max_love)
	if current_love != previous_love:
		emit_signal("love_level_changed", current_love)

func decrease_love(amount: float) -> void:
	var previous_love = current_love
	current_love = max(current_love - amount, 0.0)
	if current_love != previous_love:
		emit_signal("love_level_changed", current_love)

func add_dangerous_distraction():
	dangerous_distractions += 1

func remove_dangerous_distraction():
	dangerous_distractions = max(0, dangerous_distractions - 1)


func _on_time_up():
	# Game over logic here
	print("Time's up! Final love level: ", current_love)
	# You might want to trigger a game over screen here

func add_distraction() -> void:
	active_distractions += 1
	emit_signal("distraction_level_changed", active_distractions)

func remove_distraction() -> void:
	active_distractions = max(0, active_distractions - 1)
	emit_signal("distraction_level_changed", active_distractions)
