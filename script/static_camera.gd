extends Camera2D

var room_positions = {
	"DiningRoom": Vector2(0, -220),
	"Kitchen": Vector2(-700, -200),
	"LivingRoom": Vector2(500, -200),
	"Basement": Vector2(0, 250),
	"Attic": Vector2(0, -450)
}

@export var follow_range := 150.0  # How far the camera can move from room center
@export var follow_speed := 5.0    # How smoothly the camera follows

@onready var rooms_node = get_node("../Rooms")
@onready var player = get_node("../Player")

var current_room_position := Vector2.ZERO

func _ready():
	make_current()
	enabled = true
	current_room_position = room_positions["DiningRoom"]
	global_position = current_room_position

func _process(delta):
	update_camera_for_current_room()
	follow_player(delta)

func update_camera_for_current_room():
	for room in rooms_node.get_children():
		if room.visible and room.name in room_positions:
			current_room_position = room_positions[room.name]
			break

func follow_player(delta):
	if not player:
		return
		
	# Get the offset from room center to player
	var target_offset = player.global_position - current_room_position
	
	# Clamp the offset within the follow range
	target_offset.x = clamp(target_offset.x, -follow_range, follow_range)
	target_offset.y = clamp(target_offset.y, -follow_range, follow_range)
	
	# Calculate target position (room position + clamped offset)
	var target_position = current_room_position + target_offset
	
	# Smoothly move to target position
	global_position = global_position.lerp(target_position, follow_speed * delta)
