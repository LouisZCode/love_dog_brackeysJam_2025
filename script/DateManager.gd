extends Node

signal love_level_changed(new_value: float)
signal distraction_level_changed(new_value: float)

@export var love_decrease_rate := 5.0  # How fast love decreases with distractions
@export var love_increase_rate := 2.0  # How fast love increases normally
@export var max_love := 100.0
@export var initial_love := 50.0

var current_love := initial_love
var active_distractions := 0
var total_time := 0.0

func _ready():
	current_love = initial_love
	emit_signal("love_level_changed", current_love)

func _process(delta):
	total_time += delta
	
	# Update love based on distractions
	if active_distractions > 0:
		decrease_love(delta)
	else:
		increase_love(delta)

func increase_love(delta: float) -> void:
	current_love = min(current_love + love_increase_rate * delta, max_love)
	emit_signal("love_level_changed", current_love)

func decrease_love(delta: float) -> void:
	current_love = max(current_love - love_decrease_rate * delta, 0.0)
	emit_signal("love_level_changed", current_love)

func add_distraction() -> void:
	active_distractions += 1
	emit_signal("distraction_level_changed", active_distractions)

func remove_distraction() -> void:
	active_distractions = max(0, active_distractions - 1)
	emit_signal("distraction_level_changed", active_distractions)

func get_love_level() -> float:
	return current_love

func get_date_success() -> bool:
	return current_love >= 75.0  # Date is successful if love is above 75%
