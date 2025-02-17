extends Node2D

@export var max_size := 1.0
@export var min_size := 0.2
@export var fade_distance := 200.0
@export var screen_margin := 50.0  # Distance from screen edges

@onready var viewport_size = get_viewport_rect().size
@onready var player = get_node("/root/Game/Player")

var problem_position: Vector2

func _ready():
	scale = Vector2(max_size, max_size)

func _process(_delta):
	if not player:
		return
	
	# Calculate direction to problem
	var to_problem = problem_position - player.global_position
	var distance = to_problem.length()
	
	# Update arrow rotation to point at problem
	rotation = to_problem.angle()
	
	# Calculate arrow position in screen coordinates
	var screen_center = viewport_size / 2
	var screen_pos = to_problem.normalized() * min(distance, fade_distance)
	
	# Keep arrow within screen bounds
	var final_pos = Vector2(
		clamp(screen_pos.x, -screen_center.x + screen_margin, screen_center.x - screen_margin),
		clamp(screen_pos.y, -screen_center.y + screen_margin, screen_center.y - screen_margin)
	)
	
	# Set position relative to screen center
	position = final_pos + screen_center
	
	# Scale based on distance
	var size_factor = lerp(min_size, max_size, 
		clamp(distance / fade_distance, 0.0, 1.0))
	scale = Vector2(size_factor, size_factor)
	
	# Hide when very close
	visible = distance > fade_distance * 0.3

func point_to(pos: Vector2):
	problem_position = pos
