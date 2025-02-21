extends Node

signal problem_spawned(problem: Node)
signal problem_solved(problem: Node)

@export var spawn_interval_min := 3.0
@export var spawn_interval_max := 8.0
@export var max_simultaneous_problems := 3

var problem_scene = preload("res://scenes/problem.tscn")
@onready var spawn_points_root = $"../ProblemSpawnPoints"
var active_problems := []

func _ready():
	# Start disabled
	set_process(false)
	# Listen for game start
	GlobalControls.connect("game_start", _on_game_start)

func _on_game_start():
	set_process(true)
	# Any other initialization needed
	print("ProblemManager ready")
	start_spawn_timer()

func start_spawn_timer():
	var wait_time = randf_range(spawn_interval_min, spawn_interval_max)
	print("Starting timer for ", wait_time, " seconds")
	var timer = get_tree().create_timer(wait_time)
	timer.timeout.connect(try_spawn_problem)

func try_spawn_problem():
	print("Trying to spawn problem. Active problems: ", active_problems.size())
	if active_problems.size() < max_simultaneous_problems:
		spawn_problem()
	else:
		print("Too many active problems")
	start_spawn_timer()

func get_all_available_spawn_points() -> Array:
	var all_points = []
	print("Checking for spawn points...")
	
	# Get all room spawn point groups
	for room_points in spawn_points_root.get_children():
		print("Checking spawn points in: ", room_points.name)
		# Get individual spawn points (Marker2D nodes)
		var points = room_points.get_children()
		print("Found ", points.size(), " points in ", room_points.name)
		all_points.append_array(points)
	
	# Filter out points that already have problems
	var available = all_points.filter(func(point): 
		# Check if any child is a Problem node
		for child in point.get_children():
			if child.is_in_group("problem"):  # Add your problem to this group
				return false
		return true
	)
	
	print("Total available points: ", available.size())
	return available

func spawn_problem():
	var available_points = get_all_available_spawn_points()
	
	if available_points.is_empty():
		print("No available spawn points!")
		return
		
	var spawn_point = available_points[randi() % available_points.size()]
	print("Selected spawn point in: ", spawn_point.get_parent().name)
	
	var problem = problem_scene.instantiate()
	# Set the problem type based on spawn point configuration
	problem.problem_type = spawn_point.problem_type
	if problem.problem_type == problem.ProblemType.MINIGAME:
		problem.minigame_name = spawn_point.minigame_name
		
	# Connect the state changed signal BEFORE adding the problem as child
	problem.state_changed.connect(spawn_point._on_problem_state_changed)
	
	problem.problem_solved.connect(
		func():
			if spawn_point.animated_sprite:
				spawn_point.animated_sprite.stop()
				spawn_point.animated_sprite.visible = false
			on_problem_solved(problem)
	)
	
	spawn_point.add_child(problem)
	active_problems.append(problem)
	
	problem.problem_solved.connect(
		func(): on_problem_solved(problem)
	)
	
	print("Spawning problem with type: ", spawn_point.problem_type, " and minigame name: ", spawn_point.minigame_name)
	
	emit_signal("problem_spawned", problem)
	print("Problem spawned at point in ", spawn_point.get_parent().name)

func on_problem_solved(problem: Node):
	active_problems.erase(problem)
	emit_signal("problem_solved", problem)
	print("Problem solved! Remaining: ", active_problems.size())
