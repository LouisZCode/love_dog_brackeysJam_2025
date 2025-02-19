extends Node2D

@export var margin := 50.0  # Distance from screen edge
@export var active_opacity := 1.0
@export var inactive_opacity := 0.0
@export var fade_speed := 10.0

var target_position: Vector2
var target_problem: Node
var current_opacity := 1.0
@onready var camera = get_viewport().get_camera_2d()
@onready var arrow_sprite = $AnimatedSprite2D

func _ready():
	modulate.a = current_opacity
	arrow_sprite.play("idle")

func setup(problem: Node, pos: Vector2):
	target_problem = problem
	target_position = pos
	show()

func _process(delta):
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
	
	var problem_room = target_problem.get_parent().get_parent()
	
	# Update animation based on problem state
	if target_problem.current_state == 1:  # ProblemState.DANGEROUS
		if arrow_sprite.animation != "danger":
			arrow_sprite.play("danger")
	else:
		if arrow_sprite.animation != "idle":
			arrow_sprite.play("idle")
	
	# Set target opacity based on whether we're in the same room
	var target_opacity = inactive_opacity if problem_room == current_room else active_opacity
	
	# Smoothly transition opacity
	current_opacity = move_toward(current_opacity, target_opacity, fade_speed * delta)
	modulate.a = current_opacity
	
	# Update position only if visible
	if current_opacity > 0:
		var direction = target_position - camera.global_position
		var screen_center = get_viewport_rect().size / 2
		var screen_bounds = screen_center - Vector2(margin, margin)
		var arrow_pos = direction.normalized() * min(direction.length(), screen_bounds.length())
		position = screen_center + arrow_pos
		rotation = direction.angle()
