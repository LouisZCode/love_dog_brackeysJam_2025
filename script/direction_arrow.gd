extends Node2D

@export var margin := 50.0  # Distance from screen edge
@onready var camera = get_viewport().get_camera_2d()
@onready var arrow_sprite = $AnimatedSprite2D

var target_position: Vector2
var target_problem: Node

func _ready():
	arrow_sprite.play("idle")

func setup(problem: Node, pos: Vector2):
	target_problem = problem
	target_position = pos

func _process(_delta):
	if not camera or not target_problem or not is_instance_valid(target_problem):
		queue_free()
		return
		
	var player = get_tree().get_first_node_in_group("player")
	var current_room = null
	
	for room in get_tree().get_nodes_in_group("rooms"):
		if room.visible:
			current_room = room
			break
	
	if not current_room or not player:
		hide()
		return
	
	# Get the base room name by removing "SpawnPoints" from the end
	var problem_room = target_problem.get_parent().get_parent()
	var problem_base_room = problem_room.name.trim_suffix("SpawnPoints")
	
	# Hide arrow if in same room
	if current_room.name == problem_base_room:
		hide()
		return
		
	# Show and update arrow if in different room
	show()
	
	# Update animation based on problem state
	if target_problem.current_state == 1:  # ProblemState.DANGEROUS
		if arrow_sprite.animation != "danger":
			arrow_sprite.play("danger")
	else:
		if arrow_sprite.animation != "idle":
			arrow_sprite.play("idle")
	
	# Update position
	var direction = target_position - camera.global_position
	var screen_center = get_viewport_rect().size / 2
	var screen_bounds = screen_center - Vector2(margin, margin)
	var arrow_pos = direction.normalized() * min(direction.length(), screen_bounds.length())
	position = screen_center + arrow_pos
	rotation = direction.angle()
