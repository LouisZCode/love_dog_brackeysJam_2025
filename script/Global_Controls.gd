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
		1:
			night_duration = 60  # 1 minute
			max_num_problems = 2
			problem_min_interval = 8
			problem_max_interval = 12
			bark_time = 1
			grow_time = 20
			danger_time = 20
		2:
			night_duration = 120  # 2 minutes
			max_num_problems = 3
			problem_min_interval = 7
			problem_max_interval = 10
			bark_time = 1
			grow_time = 18
			danger_time = 18
		3:
			night_duration = 180  # 3 minutes
			max_num_problems = 3
			problem_min_interval = 6
			problem_max_interval = 9
			bark_time = 1
			grow_time = 15
			danger_time = 15
		4:
			night_duration = 240  # 4 minutes
			max_num_problems = 4
			problem_min_interval = 5
			problem_max_interval = 8
			bark_time = 1
			grow_time = 12
			danger_time = 12
		5:
			night_duration = 300  # 5 minutes
			max_num_problems = 4
			problem_min_interval = 4
			problem_max_interval = 7
			bark_time = 1
			grow_time = 10
			danger_time = 10
		_:  # Night 6 and beyond
			night_duration = 300  # Keep at 5 minutes
			max_num_problems = 5
			problem_min_interval = max(3, 8 - night_number)  # Gradually decrease but never below 3
			problem_max_interval = max(5, 12 - night_number)  # Gradually decrease but never below 5
			bark_time = 1
			grow_time = max(8, 20 - (night_number * 2))  # Gradually decrease but never below 8
			danger_time = max(8, 20 - (night_number * 2))  # Gradually decrease but never below 8

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
