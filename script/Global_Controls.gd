extends Node

var game_started := false
signal game_start

func start_game():
	game_started = true
	emit_signal("game_start")
