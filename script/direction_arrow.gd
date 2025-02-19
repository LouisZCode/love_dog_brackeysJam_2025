extends Node2D

@export var margin := 50.0  # Distance from screen edge
var target_position: Vector2
@onready var camera = get_viewport().get_camera_2d()
@onready var arrow_sprite = $Sprite2D

func _ready():
	hide()  # Start hidden

func point_to(target_pos: Vector2):
	target_position = target_pos
	show()

func _process(_delta):
	if not camera:
		return
		
	# Get direction from camera center to target
	var direction = target_position - camera.global_position
	
	# Check if target is in current room
	var current_room = null
	for room in get_tree().get_nodes_in_group("rooms"):
		if room.visible:
			current_room = room
			break
	
	# Hide if problem is in current room
	if current_room:
		var room_bounds = Rect2(current_room.global_position - Vector2(500, 300), Vector2(1000, 600))
		if room_bounds.has_point(target_position):
			hide()
			return
		
	# Show and update arrow
	show()
	
	# Get screen coordinates
	var screen_center = get_viewport_rect().size / 2
	var screen_bounds = screen_center - Vector2(margin, margin)
	
	# Calculate arrow position at screen edge
	var arrow_pos = direction.normalized() * min(direction.length(), screen_bounds.length())
	position = screen_center + arrow_pos
	
	# Point arrow in correct direction
	rotation = direction.angle()
