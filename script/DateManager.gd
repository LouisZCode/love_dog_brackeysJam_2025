extends Node

signal love_level_changed(new_value: float)
signal distraction_level_changed(new_value: float)
signal date_status_changed(is_going_well: bool)

@export var love_decrease_rate := 5.0
@export var love_increase_rate := 2.0
@export var max_love := 100.0
@export var initial_love := 50.0
@export var good_date_threshold := 75.0

var current_love := initial_love
var active_distractions := 0

func _ready():
	current_love = initial_love
	emit_signal("love_level_changed", current_love)

func _process(delta):
	if active_distractions > 0:
		decrease_love(delta)
	else:
		increase_love(delta)
	
	# Emit date status
	emit_signal("date_status_changed", current_love >= good_date_threshold)

func increase_love(delta: float) -> void:
	var previous_love = current_love
	current_love = min(current_love + love_increase_rate * delta, max_love)
	if current_love != previous_love:
		emit_signal("love_level_changed", current_love)

func decrease_love(delta: float) -> void:
	var previous_love = current_love
	current_love = max(current_love - love_decrease_rate * delta, 0.0)
	if current_love != previous_love:
		emit_signal("love_level_changed", current_love)

func add_distraction() -> void:
	active_distractions += 1
	emit_signal("distraction_level_changed", active_distractions)
	print("New distraction added. Total: ", active_distractions)

func remove_distraction() -> void:
	active_distractions = max(0, active_distractions - 1)
	emit_signal("distraction_level_changed", active_distractions)
	print("Distraction removed. Remaining: ", active_distractions)
