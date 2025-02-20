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
	var available = all_points.filter(func(point): return point.get_child_count() == 0)
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
	
	spawn_point.add_child(problem)
	active_problems.append(problem)
	
	problem.problem_solved.connect(
		func(): on_problem_solved(problem)
	)
	
	print("Spawning problem with type: ", spawn_point.problem_type, " and minigame name: ", spawn_point.minigame_name)
	
	emit_signal("problem_spawned", problem)
	print("Problem spawned at point in ", spawn_point.get_parent().name)
	
	problem.state_changed.connect(
		func(new_state: String): 
			var animated_sprite = spawn_point.get_node("AnimatedSprite2D")
			var audio_player = spawn_point.get_node("AudioStreamPlayer2D")
			
			match new_state:
				"growing":
					animated_sprite.play(spawn_point.growing_animation)
					if spawn_point.growing_sound:
						audio_player.stream = spawn_point.growing_sound
						audio_player.play()
				"danger":
					animated_sprite.play(spawn_point.danger_animation)
					if spawn_point.danger_sound:
						audio_player.stream = spawn_point.danger_sound
						audio_player.play()
				"critical":
					animated_sprite.play(spawn_point.critical_animation)
					if spawn_point.critical_sound:
						audio_player.stream = spawn_point.critical_sound
						audio_player.play()
	)

func on_problem_solved(problem: Node):
	active_problems.erase(problem)
	emit_signal("problem_solved", problem)
	print("Problem solved! Remaining: ", active_problems.size())
