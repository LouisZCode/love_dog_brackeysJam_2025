extends Node

var night_number := 1
var night_duration : int
var max_num_problems : int
var problem_min_interval : int
var problem_max_interval : int
var bark_time : int
var grow_time : int
var danger_time : int
var game_started := false

signal game_start
signal night_complete

func define_level():
	match night_number:
		1:  # First night - Easy
			night_duration = 6  # 2 minutes
			max_num_problems = 2
			problem_min_interval = 10  # More time between problems
			problem_max_interval = 15
			bark_time = 1
			grow_time = 25  # More time before getting dangerous
			danger_time = 25  # More time in dangerous state
			
		2:  # Second night - Medium
			night_duration = 1  # 2.5 minutes
			max_num_problems = 2
			problem_min_interval = 8
			problem_max_interval = 12
			bark_time = 1
			grow_time = 20
			danger_time = 20
			
		3:  # Third night - Hard (current night 2 settings)
			night_duration = 1  # 3 minutes
			max_num_problems = 3
			problem_min_interval = 8
			problem_max_interval = 12
			bark_time = 1
			grow_time = 22
			danger_time = 18
			
		_:  # If somehow we get beyond night 3, loop back to night 1
			night_number = 1
			define_level()

func start_game():
	game_started = true
	define_level()
	emit_signal("game_start")

func complete_night():
	night_number += 1
	emit_signal("night_complete")
	game_started = false  # Reset for next night

func reset_game():
	night_number = 1
	game_started = false
	define_level()
