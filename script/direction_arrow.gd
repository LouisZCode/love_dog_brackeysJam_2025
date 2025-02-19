extends Node2D

@export var margin := 50.0  # Distance from screen edge
@export var active_opacity := 1.0
@export var inactive_opacity := 0.0
@export var fade_speed := 10.0  # Speed of opacity transition

var target_position: Vector2
var target_problem: Node
var current_opacity := 1.0
@onready var camera = get_viewport().get_camera_2d()
@onready var arrow_sprite = $AnimatedSprite2D

func _ready():
	modulate.a = current_opacity
	arrow_sprite.play("idle")

func point_to(target_pos: Vector2):
	target_position = target_pos
	target_problem = get_parent()
	show()

func _process(delta):
	if not camera:
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
