extends Node


var problem_scene = preload("res://scenes/problem.tscn")  # Adjust path as needed
@onready var spawn_points = $"../Rooms/DiningRoom/ProblemSpawnPoints".get_children()

func _ready():
	# Spawn initial problems
	spawn_problem()
	spawn_problem()

func spawn_problem():
	# Get a random available spawn point
	var available_points = spawn_points.filter(func(point): 
		return point.get_child_count() == 0
	)
	
	if available_points.is_empty():
		return
		
	var spawn_point = available_points[randi() % available_points.size()]
	
	# Create and add the problem
	var problem = problem_scene.instantiate()
	spawn_point.add_child(problem)
