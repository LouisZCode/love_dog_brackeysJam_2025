extends Node2D

var active_problems = []
@export var problem_scenes: Array[PackedScene]
@export var min_spawn_time: float = 5.0
@export var max_spawn_time: float = 15.0

func _ready():
	start_problem_timer()

func start_problem_timer():
	var timer = get_tree().create_timer(randf_range(min_spawn_time, max_spawn_time))
	timer.timeout.connect(spawn_problem)

func spawn_problem():
	# Implementation for spawning new problems
	pass

func resolve_problem(problem_id: int):
	# Implementation for fixing problems
	pass
