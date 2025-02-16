extends Node

signal love_level_changed(new_value: float)
signal distraction_level_changed(new_value: float)
signal date_status_changed(is_going_well: bool)

@export var love_decrease_rate := 2.0
@export var love_increase_rate := 3.0
@export var max_love := 100.0
@export var initial_love := 50.0
@export var good_date_threshold := 75.0

@onready var timer = get_node("../CanvasLayer/TimerLabel")

var current_love := initial_love
var active_distractions := 0

func _ready():
	current_love = initial_love
	emit_signal("love_level_changed", current_love)
	timer.start_timer()
	timer.time_up.connect(_on_time_up)

func _process(delta):
	if timer.is_running:
		update_love(delta)

func update_love(delta):
	# Get difficulty multiplier based on remaining time
	var time_percentage = timer.get_time_percentage()
	var difficulty = 1.0 + (1.0 - (time_percentage / 100.0))  # 1.0 to 2.0
	
	if active_distractions > 0:
		var decrease = love_decrease_rate * delta * difficulty * active_distractions
		decrease_love(decrease)
	else:
		increase_love(delta)
	
	emit_signal("date_status_changed", current_love >= good_date_threshold)

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
