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

func define_level():
	if night_number == 1:
		night_duration = 60
		max_num_problems = 2
		problem_min_interval = 8
		problem_max_interval = 12
		bark_time = 1
		grow_time = 20
		danger_time = 20
		
func start_game():
	game_started = true
	define_level()
	emit_signal("game_start")
