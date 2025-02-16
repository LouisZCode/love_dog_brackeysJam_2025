extends Node

signal problem_spawned(problem: Node)
signal problem_solved(problem: Node)

@export var spawn_interval_min := 3.0
@export var spawn_interval_max := 8.0
@export var max_simultaneous_problems := 3

var problem_scene = preload("res://scenes/problem.tscn")  # Adjust path
@onready var spawn_points = $"../Rooms/DiningRoom/ProblemSpawnPoints".get_children()
@onready var date_manager = $"../DateManager"

var active_problems := []

func _ready():
	start_spawn_timer()

func start_spawn_timer():
	var timer = get_tree().create_timer(randf_range(spawn_interval_min, spawn_interval_max))
	timer.timeout.connect(try_spawn_problem)

func try_spawn_problem():
	if active_problems.size() < max_simultaneous_problems:
		spawn_problem()
	start_spawn_timer()

func spawn_problem():
	# Get available spawn points (those without problems)
	var available_points = spawn_points.filter(func(point): 
		return point.get_child_count() == 0
	)
	
	if available_points.is_empty():
		return
		
	var spawn_point = available_points[randi() % available_points.size()]
	
	var problem = problem_scene.instantiate()
	spawn_point.add_child(problem)
	active_problems.append(problem)
	
	# Connect to problem's signals
	problem.tree_exited.connect(
		func(): on_problem_solved(problem)
	)
	
	emit_signal("problem_spawned", problem)
	print("Problem spawned at: ", spawn_point.name)

func on_problem_solved(problem: Node):
	active_problems.erase(problem)
	emit_signal("problem_solved", problem)
	print("Problem solved! Remaining: ", active_problems.size())
