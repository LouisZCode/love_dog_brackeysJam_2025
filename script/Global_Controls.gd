extends Node

var night_number := 1

var date_diration : int

var game_started := false

signal game_start

func start_game():
	game_started = true
	emit_signal("game_start")
